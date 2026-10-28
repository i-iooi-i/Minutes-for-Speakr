import 'package:speakr_app/l10n/strings.dart';

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../auto_record/auto_record_settings.dart';
import 'live_audio_recorder.dart';

/// Shared Dart-side wrapper for the native Speakr recorder (Windows
/// WASAPI, Android MediaProjection). Both platforms expose the same
/// `MethodChannel("speakr.audio/recorder")` surface so we keep a single
/// Dart implementation; per-platform differences (e.g. Android's
/// per-session consent flow) live in the native code.
class NativeLiveAudioRecorder implements LiveAudioRecorder {
  NativeLiveAudioRecorder._(
    this._supportsSystemAudio,
    this._supportsProcessLoopback,
    this._supportsVideo,
  );

  static const MethodChannel _channel = MethodChannel('speakr.audio/recorder');

  // Poll cadence for the audio level — ~20 Hz matches the design's
  // breathing-dot animation. Native side buffers the latest RMS-derived
  // level; we pull it via `getLevel` so we don't need an EventChannel
  // (whose sinks can only fire on the platform thread on Windows).
  static const Duration _levelPollInterval = Duration(milliseconds: 50);

  final bool _supportsSystemAudio;
  final bool _supportsProcessLoopback;
  final bool _supportsVideo;

  static Future<NativeLiveAudioRecorder> probe() async {
    bool supportsSystem = false;
    bool supportsProcess = false;
    try {
      final result = await _channel.invokeMethod<bool>('supportsSystemAudio');
      supportsSystem = result ?? false;
    } on MissingPluginException {
      supportsSystem = false;
    } catch (_) {
      supportsSystem = false;
    }
    if (supportsSystem) {
      try {
        final r = await _channel.invokeMethod<bool>('supportsProcessLoopback');
        supportsProcess = r ?? false;
      } on MissingPluginException {
        supportsProcess = false;
      } catch (_) {
        supportsProcess = false;
      }
    }
    return NativeLiveAudioRecorder._(
      supportsSystem,
      supportsProcess,
      await probeVideoSupport(),
    );
  }

  /// Whether the native recorder can record a window as video. Safe to
  /// call while a recording is running.
  static Future<bool> probeVideoSupport() async {
    try {
      return await _channel.invokeMethod<bool>('supportsVideo') ?? false;
    } catch (_) {
      // Android's recorder doesn't implement it: MissingPluginException.
      return false;
    }
  }

  @override
  bool get supportsSystemAudio => _supportsSystemAudio;

  @override
  bool get supportsProcessLoopback => _supportsProcessLoopback;

  @override
  bool get supportsVideo => _supportsVideo;

  @override
  bool get supportsLiveMicToggle => true;

  @override
  Stream<double> get audioLevel {
    // One controller per listener, so each subscription gets its own
    // polling timer. The controller is closed (and the timer cancelled)
    // automatically when the subscription is cancelled.
    late StreamController<double> controller;
    Timer? timer;

    Future<void> tick() async {
      try {
        final v = await _channel.invokeMethod<double>('getLevel');
        if (controller.isClosed) return;
        final clamped = (v ?? 0.0).clamp(0.0, 1.0);
        controller.add(clamped);
      } catch (_) {
        // MissingPlugin or platform error — emit silence so subscribers
        // don't see stale values.
        if (!controller.isClosed) controller.add(0.0);
      }
    }

    controller = StreamController<double>(
      onListen: () {
        timer = Timer.periodic(_levelPollInterval, (_) => tick());
        // Kick an immediate sample so the meter isn't blank for the
        // first poll interval after the listener attaches.
        tick();
      },
      onCancel: () async {
        timer?.cancel();
        timer = null;
      },
    );
    return controller.stream;
  }

  @override
  Future<bool> isRecording() async {
    try {
      final r = await _channel.invokeMethod<bool>('isRecording');
      return r ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> hasMicPermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  @override
  Future<bool> requestMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  @override
  Future<bool> requestSystemPermission() async {
    if (!_supportsSystemAudio) return false;
    try {
      final r = await _channel.invokeMethod<bool>('requestSystemPermission');
      return r ?? false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<List<int>> findProcessPids({
    String? exePath,
    required String matchKey,
    required AllowlistKind kind,
  }) async {
    if (!_supportsProcessLoopback && !_supportsVideo) return const <int>[];
    try {
      final r = await _channel
          .invokeListMethod<int>('findProcessPids', <String, dynamic>{
            if (exePath != null) 'exePath': exePath,
            'matchKey': matchKey,
            'kind': kind.name,
          });
      return r ?? const <int>[];
    } on PlatformException {
      return const <int>[];
    } on MissingPluginException {
      return const <int>[];
    }
  }

  @override
  Future<List<CaptureWindow>> findCaptureWindows({
    List<int> pids = const [],
  }) async {
    if (!_supportsVideo) return const <CaptureWindow>[];
    try {
      final r = await _channel.invokeListMethod<Map<Object?, Object?>>(
        'findCaptureWindows',
        <String, dynamic>{'pids': pids},
      );
      return [for (final m in r ?? const []) CaptureWindow.fromChannel(m)];
    } on PlatformException {
      return const <CaptureWindow>[];
    }
  }

  @override
  Future<void> start({
    required String path,
    required bool micEnabled,
    required SystemAudioMode systemMode,
    int? processLoopbackPid,
    int? videoHwnd,
  }) async {
    if (videoHwnd != null && !_supportsVideo) {
      throw UnsupportedError(
        tr("Video capture is not supported on this platform."),
      );
    }
    if (systemMode != SystemAudioMode.off && !_supportsSystemAudio) {
      throw UnsupportedError(
        tr("System audio capture is not supported on this platform."),
      );
    }
    if (systemMode == SystemAudioMode.processOnly &&
        !_supportsProcessLoopback) {
      throw UnsupportedError(
        tr(
          "Per-process system audio capture is not supported on this Windows build. Use systemMode allSystem instead.",
        ),
      );
    }
    await _channel.invokeMethod<void>('start', <String, dynamic>{
      'path': path,
      'micEnabled': micEnabled,
      'systemMode': _systemModeToChannel(systemMode),
      if (processLoopbackPid != null) 'processLoopbackPid': processLoopbackPid,
      if (videoHwnd != null) 'videoHwnd': videoHwnd,
    });
  }

  @override
  Future<void> pause() async {
    await _channel.invokeMethod<void>('pause');
  }

  @override
  Future<void> resume() async {
    await _channel.invokeMethod<void>('resume');
  }

  @override
  Future<void> setMicEnabled(bool enabled) async {
    await _channel.invokeMethod<void>('setMicEnabled', <String, dynamic>{
      'enabled': enabled,
    });
  }

  @override
  Future<void> setSystemMode(
    SystemAudioMode mode, {
    int? processLoopbackPid,
  }) async {
    if (mode != SystemAudioMode.off && !_supportsSystemAudio) {
      throw UnsupportedError(
        tr("System audio capture is not supported on this platform."),
      );
    }
    if (mode == SystemAudioMode.processOnly && !_supportsProcessLoopback) {
      throw UnsupportedError(
        tr(
          "Per-process system audio capture is not supported on this Windows build.",
        ),
      );
    }
    await _channel.invokeMethod<void>('setSystemMode', <String, dynamic>{
      'mode': _systemModeToChannel(mode),
      if (processLoopbackPid != null) 'processLoopbackPid': processLoopbackPid,
    });
  }

  @override
  Future<void> setVideoTarget(int? hwnd) async {
    await _channel.invokeMethod<void>('setVideoTarget', <String, dynamic>{
      'hwnd': hwnd ?? 0,
    });
  }

  @override
  Future<String?> stop() async {
    try {
      return await _channel.invokeMethod<String>('stop');
    } on PlatformException catch (e) {
      throw Exception(e.message ?? tr("Recorder failed to stop."));
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await _channel.invokeMethod<void>('dispose');
    } catch (_) {}
  }

  static String _systemModeToChannel(SystemAudioMode mode) {
    switch (mode) {
      case SystemAudioMode.off:
        return 'off';
      case SystemAudioMode.allSystem:
        return 'all';
      case SystemAudioMode.processOnly:
        return 'process';
    }
  }
}
