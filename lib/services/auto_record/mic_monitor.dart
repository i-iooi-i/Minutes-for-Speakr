import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:win32_registry/win32_registry.dart';

import 'auto_record_settings.dart';
import 'mic_user.dart';

/// Streams the set of apps currently registered as using the default
/// microphone. Polled (default 2 s on Windows). Emits the empty list on
/// unsupported platforms.
abstract class MicMonitor {
  Stream<List<MicUser>> get usersStream;

  /// Last sample. Useful for one-off settings-screen reads without
  /// having to subscribe to the stream.
  List<MicUser> get current;

  Future<void> dispose();
}

MicMonitor createMicMonitor({
  Duration pollInterval = const Duration(seconds: 2),
}) {
  if (Platform.isWindows) {
    return _WindowsMicMonitor(pollInterval: pollInterval);
  }
  return _NoopMicMonitor();
}

// ── Stub for non-Windows ─────────────────────────────────────────────────────

class _NoopMicMonitor implements MicMonitor {
  final _ctrl = StreamController<List<MicUser>>.broadcast();

  @override
  List<MicUser> get current => const [];

  @override
  Stream<List<MicUser>> get usersStream => _ctrl.stream;

  @override
  Future<void> dispose() async => _ctrl.close();
}

// ── Windows: registry poll ──────────────────────────────────────────────────

/// Polls
/// `HKCU\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\
///  ConsentStore\microphone\` and the `NonPackaged\` subkey under it.
///
/// Each leaf has `LastUsedTimeStart` and `LastUsedTimeStop` (FILETIME
/// stored as `REG_QWORD`). When `Start > Stop`, the app is currently
/// using the mic.
class _WindowsMicMonitor implements MicMonitor {
  _WindowsMicMonitor({required this.pollInterval}) {
    _timer = Timer.periodic(pollInterval, (_) => _tick());
    // Fire one immediate tick so the settings screen has a value before
    // the first interval elapses.
    Future<void>.microtask(_tick);
  }

  final Duration pollInterval;
  final _ctrl = StreamController<List<MicUser>>.broadcast();
  Timer? _timer;
  List<MicUser> _last = const [];
  bool _running = false;

  static const _rootPath =
      r'Software\Microsoft\Windows\CurrentVersion'
      r'\CapabilityAccessManager\ConsentStore\microphone';

  @override
  List<MicUser> get current => _last;

  @override
  Stream<List<MicUser>> get usersStream => _ctrl.stream;

  @override
  Future<void> dispose() async {
    _timer?.cancel();
    await _ctrl.close();
  }

  Future<void> _tick() async {
    if (_running) return;
    _running = true;
    try {
      final list = _readAll();
      _last = list;
      _ctrl.add(list);
    } catch (e, st) {
      debugPrint('[mic-monitor] poll failed: $e\n$st');
    } finally {
      _running = false;
    }
  }

  List<MicUser> _readAll() {
    final out = <MicUser>[];
    RegistryKey? root;
    try {
      root = Registry.openPath(
        RegistryHive.currentUser,
        path: _rootPath,
        desiredAccessRights: AccessRights.readOnly,
      );
    } catch (_) {
      return out;
    }
    try {
      for (final subName in root.subkeyNames) {
        if (subName.toLowerCase() == 'nonpackaged') {
          _readNonPackaged(root, out);
        } else {
          _readPackaged(root, subName, out);
        }
      }
    } finally {
      root.close();
    }
    return out;
  }

  void _readPackaged(RegistryKey root, String subName, List<MicUser> out) {
    RegistryKey? key;
    try {
      key = Registry.openPath(
        RegistryHive.currentUser,
        path: '$_rootPath\\$subName',
        desiredAccessRights: AccessRights.readOnly,
      );
    } catch (_) {
      return;
    }
    try {
      final start = _readFiletime(key, 'LastUsedTimeStart');
      final stop = _readFiletime(key, 'LastUsedTimeStop');
      if (start == null && stop == null) return;
      out.add(
        MicUser(
          key: subName,
          displayName: _packageDisplayName(subName),
          kind: AllowlistKind.packagedPrefix,
          lastStart: start ?? DateTime.fromMillisecondsSinceEpoch(0),
          lastStop: stop ?? DateTime.fromMillisecondsSinceEpoch(0),
        ),
      );
    } finally {
      key.close();
    }
  }

  void _readNonPackaged(RegistryKey root, List<MicUser> out) {
    RegistryKey? np;
    try {
      np = Registry.openPath(
        RegistryHive.currentUser,
        path: '$_rootPath\\NonPackaged',
        desiredAccessRights: AccessRights.readOnly,
      );
    } catch (_) {
      return;
    }
    try {
      for (final subName in np.subkeyNames) {
        RegistryKey? key;
        try {
          key = Registry.openPath(
            RegistryHive.currentUser,
            path: '$_rootPath\\NonPackaged\\$subName',
            desiredAccessRights: AccessRights.readOnly,
          );
        } catch (_) {
          continue;
        }
        try {
          final start = _readFiletime(key, 'LastUsedTimeStart');
          final stop = _readFiletime(key, 'LastUsedTimeStop');
          if (start == null && stop == null) continue;
          // Subkey name is `C:#Program Files#...#Teams.exe`.
          final exePath = subName.replaceAll('#', '\\');
          final basename = _basename(exePath);
          out.add(
            MicUser(
              key: basename,
              displayName: basename,
              kind: AllowlistKind.exeBasename,
              exePath: exePath,
              lastStart: start ?? DateTime.fromMillisecondsSinceEpoch(0),
              lastStop: stop ?? DateTime.fromMillisecondsSinceEpoch(0),
            ),
          );
        } finally {
          key.close();
        }
      }
    } finally {
      np.close();
    }
  }

  /// Reads a 64-bit FILETIME registry value (REG_QWORD) and converts to
  /// a Dart [DateTime]. FILETIME = 100-ns ticks since 1601-01-01 UTC.
  DateTime? _readFiletime(RegistryKey key, String name) {
    try {
      final v = key.getIntValue(name);
      if (v == null || v == 0) return null;
      return _filetimeToDateTime(v);
    } catch (_) {
      return null;
    }
  }

  static DateTime _filetimeToDateTime(int filetime) {
    // 11644473600000 ms between 1601-01-01 and 1970-01-01.
    final ms = (filetime ~/ 10000) - 11644473600000;
    if (ms < 0) return DateTime.fromMillisecondsSinceEpoch(0);
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toLocal();
  }

  static String _basename(String path) {
    final i = path.lastIndexOf('\\');
    return i < 0 ? path : path.substring(i + 1);
  }

  static String _packageDisplayName(String packageFamily) {
    // Strip the publisher hash: `MSTeams_8wekyb3d8bbwe` → `MSTeams`.
    final i = packageFamily.indexOf('_');
    return i < 0 ? packageFamily : packageFamily.substring(0, i);
  }
}
