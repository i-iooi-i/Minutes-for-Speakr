import 'dart:async';
import 'dart:ffi';
import 'dart:io' show Platform;

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:win32/win32.dart';

/// Reports the peak output level (0.0–1.0) of the default render
/// endpoint. We use this on Windows to detect when speaker output is
/// silent — combined with mic-released, that's the signal to ask the
/// user whether to stop the auto-recording.
///
/// `package:win32` 5.15 doesn't ship a generated `IAudioMeterInformation`
/// binding, so the interface vtable is called directly here. The IID is
/// stable since Vista. Only `GetPeakValue` (vtable index 3) is used.
abstract class OutputMeter {
  /// Stream of peak values (0.0 – 1.0). Emits at the configured
  /// interval; on errors emits 0.0 and keeps trying.
  Stream<double> get peaks;
  Future<void> dispose();
}

OutputMeter createOutputMeter({
  Duration sampleInterval = const Duration(milliseconds: 500),
}) {
  // Escape hatch: setting `SPEAKR_DISABLE_OUTPUT_METER=1` bypasses the
  // real Windows COM meter entirely. The noop still emits 0.0 at the
  // configured interval, so the coordinator's silence-detection clock
  // keeps ticking and the stop-prompt falls back to "mic released only".
  // Useful if the COM path ever regresses on a specific machine.
  if (Platform.environment['SPEAKR_DISABLE_OUTPUT_METER'] == '1') {
    return _NoopOutputMeter(sampleInterval);
  }
  if (Platform.isWindows) return _WindowsOutputMeter(sampleInterval);
  return _NoopOutputMeter(sampleInterval);
}

class _NoopOutputMeter implements OutputMeter {
  _NoopOutputMeter([this.interval = const Duration(milliseconds: 500)]) {
    _ctrl = StreamController<double>.broadcast(
      onListen: _start,
      onCancel: _stop,
    );
  }

  final Duration interval;
  late final StreamController<double> _ctrl;
  Timer? _timer;

  @override
  Stream<double> get peaks => _ctrl.stream;

  void _start() {
    // Emit 0.0 immediately so the coordinator's silence-since clock
    // starts ticking without an interval of dead air.
    if (!_ctrl.isClosed) _ctrl.add(0.0);
    _timer ??= Timer.periodic(interval, (_) {
      if (!_ctrl.isClosed) _ctrl.add(0.0);
    });
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> dispose() async {
    _stop();
    if (!_ctrl.isClosed) await _ctrl.close();
  }
}

const String _iidIAudioMeterInformation =
    '{C02216F6-8C67-4B5B-9D00-D008E73E0064}';
const String _clsidMMDeviceEnumerator =
    '{bcde0395-e52f-467c-8e3d-c4579291692e}';
const String _iidIMMDeviceEnumerator = '{a95664d2-9614-4f35-a746-de8db63617e6}';

class _WindowsOutputMeter implements OutputMeter {
  _WindowsOutputMeter(this.interval) {
    _ctrl = StreamController<double>.broadcast(
      onListen: _start,
      onCancel: _stop,
    );
  }

  final Duration interval;
  late final StreamController<double> _ctrl;
  Timer? _timer;
  Pointer<COMObject>? _meter;
  bool _comInitialized = false;
  // One-shot kill switch: once the meter fails (COM init throws, vtable
  // call fails, Activate returns null, etc.), stop touching native COM
  // for the lifetime of this meter and emit 0.0 forever. The meter is
  // best-effort — emitting silence beats crashing the Flutter process.
  bool _giveUp = false;

  @override
  Stream<double> get peaks => _ctrl.stream;

  void _start() {
    _ensureMeter();
    _timer ??= Timer.periodic(interval, (_) => _tick());
    // Fire one immediately so callers don't wait an interval for the
    // first sample.
    Future<void>.microtask(_tick);
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    _release();
  }

  void _tick() {
    if (!_ctrl.isClosed) _ctrl.add(_readPeak());
  }

  /// Lazily acquire the device + meter. Recreated transparently after
  /// device-change errors (e.g. user unplugging a USB headset).
  void _ensureMeter() {
    if (_giveUp) return;
    if (_meter != null) return;
    Pointer<COMObject>? enumerator;
    Pointer<COMObject>? device;
    Pointer<COMObject>? meter;
    try {
      if (!_comInitialized) {
        // Each thread that calls a COM API must have a COM apartment.
        // Flutter's main isolate doesn't initialize COM by default
        // (it's done in the platform thread, not the Dart isolate).
        final hr = CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
        // RPC_E_CHANGED_MODE = 0x80010106 — already initialized with a
        // different mode, harmless.
        if (hr == S_OK || hr == S_FALSE || hr == 0x80010106.toSigned(32)) {
          _comInitialized = true;
        }
      }

      final clsid = convertToCLSID(_clsidMMDeviceEnumerator);
      final iidEnumerator = convertToIID(_iidIMMDeviceEnumerator);
      try {
        enumerator = calloc<COMObject>();
        final hr = CoCreateInstance(
          clsid,
          nullptr,
          CLSCTX_ALL,
          iidEnumerator,
          enumerator.cast(),
        );
        if (FAILED(hr)) return;
      } finally {
        free(clsid);
        free(iidEnumerator);
      }

      final ppDevice = calloc<Pointer<COMObject>>();
      try {
        // IMMDeviceEnumerator::GetDefaultAudioEndpoint is vtable index 4.
        final getDefaultAudioEndpoint = (enumerator.ref.vtable + 4)
            .cast<
              Pointer<
                NativeFunction<
                  Int32 Function(
                    Pointer,
                    Int32 dataFlow,
                    Int32 role,
                    Pointer<Pointer<COMObject>> ppEndpoint,
                  )
                >
              >
            >()
            .value
            .asFunction<
              int Function(
                Pointer,
                int dataFlow,
                int role,
                Pointer<Pointer<COMObject>> ppEndpoint,
              )
            >();
        final hr = getDefaultAudioEndpoint(
          enumerator.ref.lpVtbl,
          0 /* eRender */,
          1 /* eMultimedia */,
          ppDevice,
        );
        if (FAILED(hr) || ppDevice.value == nullptr) return;
        device = _wrapComInterface(ppDevice.value);
      } finally {
        free(ppDevice);
      }

      final iidMeter = convertToIID(_iidIAudioMeterInformation);
      final ppMeter = calloc<Pointer<COMObject>>();
      try {
        // IMMDevice::Activate is vtable index 3.
        final activate = (device.ref.vtable + 3)
            .cast<
              Pointer<
                NativeFunction<
                  Int32 Function(
                    Pointer,
                    Pointer<GUID> iid,
                    Uint32 dwClsCtx,
                    Pointer<PROPVARIANT> pActivationParams,
                    Pointer<Pointer> ppInterface,
                  )
                >
              >
            >()
            .value
            .asFunction<
              int Function(
                Pointer,
                Pointer<GUID> iid,
                int dwClsCtx,
                Pointer<PROPVARIANT> pActivationParams,
                Pointer<Pointer> ppInterface,
              )
            >();
        final hr = activate(
          device.ref.lpVtbl,
          iidMeter,
          CLSCTX_ALL,
          nullptr,
          ppMeter.cast(),
        );
        if (FAILED(hr) || ppMeter.value == nullptr) return;
        meter = _wrapComInterface(ppMeter.value);
        _meter = meter;
        meter = null;
      } finally {
        free(iidMeter);
        free(ppMeter);
      }
    } catch (e, st) {
      debugPrint('[output-meter] could not acquire meter: $e\n$st');
      // The output meter is best-effort. If native COM acquisition fails,
      // stop touching this path and keep emitting silence.
    } finally {
      if (meter != null) _releaseComObject(meter);
      if (device != null) _releaseComObject(device);
      if (enumerator != null) _releaseComObject(enumerator);
      if (_meter == null) _giveUp = true;
    }
  }

  Pointer<COMObject> _wrapComInterface(Pointer<COMObject> interfacePtr) {
    final wrapper = calloc<COMObject>();
    wrapper.ref.lpVtbl = interfacePtr.cast<Pointer<IntPtr>>();
    return wrapper;
  }

  void _releaseComObject(Pointer<COMObject>? object) {
    if (object == null) return;
    try {
      // IUnknown::Release at vtable index 2.
      final fn = (object.ref.vtable + 2)
          .cast<Pointer<NativeFunction<Uint32 Function(Pointer)>>>()
          .value
          .asFunction<int Function(Pointer)>();
      fn(object.ref.lpVtbl);
    } catch (_) {
      // Releasing is best-effort during teardown; the meter itself is optional.
    } finally {
      free(object);
    }
  }

  double _readPeak() {
    if (_giveUp) return 0.0;
    final m = _meter;
    if (m == null) {
      // Try to recover after a transient device change.
      _ensureMeter();
      return 0.0;
    }
    final peakOut = calloc<Float>();
    try {
      // IAudioMeterInformation::GetPeakValue is at vtable index 3
      // (after IUnknown's 3 entries). `vtable` is the array base
      // (lpVtbl.value); `lpVtbl` is the interface pointer COM expects
      // as `this`. This matches win32 5.15's own IUnknown helpers —
      // see iunknown.dart:46–49.
      final fn = (m.ref.vtable + 3)
          .cast<
            Pointer<
              NativeFunction<Int32 Function(Pointer, Pointer<Float> pfPeak)>
            >
          >()
          .value
          .asFunction<int Function(Pointer, Pointer<Float> pfPeak)>();
      final hr = fn(m.ref.lpVtbl, peakOut);
      if (FAILED(hr)) {
        // 0x88890004 = AUDCLNT_E_DEVICE_INVALIDATED. Drop the cached
        // meter so the next tick re-acquires the new default endpoint.
        _release();
        _giveUp = true;
        return 0.0;
      }
      return peakOut.value;
    } catch (_) {
      _release();
      _giveUp = true;
      return 0.0;
    } finally {
      free(peakOut);
    }
  }

  void _release() {
    final m = _meter;
    if (m != null) {
      _releaseComObject(m);
      _meter = null;
    }
  }

  @override
  Future<void> dispose() async {
    _stop();
    if (_comInitialized) {
      try {
        CoUninitialize();
      } catch (_) {}
      _comInitialized = false;
    }
    if (!_ctrl.isClosed) await _ctrl.close();
  }
}
