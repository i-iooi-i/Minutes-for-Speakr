import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/live_audio_recorder_factory.dart';
import '../audio/native_live_audio_recorder.dart';
import 'auto_record_settings.dart';
import 'auto_record_settings_store.dart';
import 'mic_monitor.dart';
import 'mic_user.dart';
import 'output_meter.dart';

/// Async — opens shared_preferences. Cached for the app's lifetime.
final autoRecordStoreProvider = FutureProvider<AutoRecordSettingsStore>((
  ref,
) async {
  return AutoRecordSettingsStore.open();
});

/// Reactive view of the persisted settings. Re-read after every write
/// via `ref.invalidate(autoRecordSettingsProvider)`.
final autoRecordSettingsProvider = FutureProvider<AutoRecordSettings>((
  ref,
) async {
  final store = await ref.watch(autoRecordStoreProvider.future);
  return store.read();
});

final micMonitorProvider = Provider<MicMonitor>((ref) {
  final monitor = createMicMonitor();
  ref.onDispose(monitor.dispose);
  return monitor;
});

final micUsersProvider = StreamProvider<List<MicUser>>((ref) async* {
  final monitor = ref.watch(micMonitorProvider);
  yield monitor.current;
  yield* monitor.usersStream;
});

final outputMeterProvider = Provider<OutputMeter>((ref) {
  final meter = createOutputMeter();
  ref.onDispose(meter.dispose);
  return meter;
});

/// Whether the recorder on this device can capture audio from a
/// specific process tree (Windows ≥ build 20348). Settings screens
/// gate the "Only this app's audio" option on this — when false,
/// per-app sheets show only the all-system choice.
final processLoopbackSupportedProvider = FutureProvider<bool>((ref) async {
  final recorder = await LiveAudioRecorderFactory.createAsync();
  try {
    return recorder.supportsProcessLoopback;
  } finally {
    await recorder.dispose();
  }
});

/// Whether the recorder on this device can record a window as video
/// (Windows 10 1903+). Settings screens hide the video options when false.
/// Probes the channel directly instead of building a recorder: disposing
/// a probe recorder would stop a recording that is in progress.
final videoCaptureSupportedProvider = FutureProvider<bool>(
  (ref) => NativeLiveAudioRecorder.probeVideoSupport(),
);

/// Imperative writer used by the settings screen. Reads through
/// [autoRecordStoreProvider]; invalidates [autoRecordSettingsProvider]
/// after each write so subscribed widgets rebuild.
class AutoRecordSettingsController {
  AutoRecordSettingsController(this._ref);
  final Ref _ref;

  Future<AutoRecordSettings> _read() =>
      _ref.read(autoRecordSettingsProvider.future);

  Future<void> _write(AutoRecordSettings next) async {
    final store = await _ref.read(autoRecordStoreProvider.future);
    await store.write(next);
    _ref.invalidate(autoRecordSettingsProvider);
  }

  Future<void> setEnabled(bool v) async {
    final s = await _read();
    await _write(s.copyWith(enabled: v));
  }

  Future<void> addToAllowlist(AllowlistEntry entry) async {
    final s = await _read();
    if (s.allowlist.contains(entry)) return;
    await _write(s.copyWith(allowlist: [...s.allowlist, entry]));
  }

  Future<void> removeFromAllowlist(AllowlistEntry entry) async {
    final s = await _read();
    final next = s.allowlist.where((e) => e != entry).toList(growable: false);
    await _write(s.copyWith(allowlist: next));
  }

  /// Update the per-app overrides on an existing allowlist entry. Identity
  /// is matched on (key, kind) (i.e. `entry == old`); other fields are
  /// taken from [speakers] / [tagIds]. Pass `clearSpeakers: true` to wipe
  /// the override (revert to global default); pass an empty list to
  /// [tagIds] to revert tags. No-op if the entry isn't in the allowlist.
  Future<void> setEntryOverrides(
    AllowlistEntry entry, {
    int? speakers,
    bool clearSpeakers = false,
    List<int>? tagIds,
    int? folderId,
    bool clearFolder = false,
    bool? micEnabled,
    bool clearMic = false,
    bool? systemEnabled,
    bool clearSystem = false,
    SystemAudioScope? systemScope,
    bool clearSystemScope = false,
    bool? videoEnabled,
    bool clearVideo = false,
  }) async {
    final s = await _read();
    final next = <AllowlistEntry>[
      for (final e in s.allowlist)
        if (e == entry)
          e.copyWith(
            speakers: clearSpeakers ? null : (speakers ?? e.speakers),
            tagIds: tagIds ?? e.tagIds,
            folderId: clearFolder ? null : (folderId ?? e.folderId),
            micEnabled: clearMic ? null : (micEnabled ?? e.micEnabled),
            systemEnabled: clearSystem
                ? null
                : (systemEnabled ?? e.systemEnabled),
            systemScope: clearSystemScope
                ? null
                : (systemScope ?? e.systemScope),
            videoEnabled: clearVideo ? null : (videoEnabled ?? e.videoEnabled),
          )
        else
          e,
    ];
    await _write(s.copyWith(allowlist: next));
  }

  Future<void> setSilenceSeconds(int v) async {
    final s = await _read();
    await _write(s.copyWith(silenceSeconds: v.clamp(3, 120)));
  }

  Future<void> setMinKeepSeconds(int v) async {
    final s = await _read();
    await _write(s.copyWith(minKeepSeconds: v.clamp(0, 600)));
  }

  Future<void> setDefaultSpeakers(int v) async {
    final s = await _read();
    await _write(s.copyWith(defaultSpeakers: v.clamp(1, 12)));
  }

  Future<void> setDefaultTagIds(List<int> ids) async {
    final s = await _read();
    await _write(s.copyWith(defaultTagIds: ids));
  }

  Future<void> setDefaultFolderId(int? id) async {
    final s = await _read();
    await _write(s.copyWith(defaultFolderId: id));
  }

  Future<void> setDefaultMicEnabled(bool v) async {
    final s = await _read();
    await _write(s.copyWith(defaultMicEnabled: v));
  }

  Future<void> setDefaultSystemEnabled(bool v) async {
    final s = await _read();
    await _write(s.copyWith(defaultSystemEnabled: v));
  }

  Future<void> setDefaultSystemScope(SystemAudioScope scope) async {
    final s = await _read();
    await _write(s.copyWith(defaultSystemScope: scope));
  }

  Future<void> setDefaultVideoEnabled(bool v) async {
    final s = await _read();
    await _write(s.copyWith(defaultVideoEnabled: v));
  }

  Future<void> clearRecentlySeen() async {
    final s = await _read();
    await _write(s.copyWith(recentlySeen: const []));
  }
}

final autoRecordSettingsControllerProvider =
    Provider<AutoRecordSettingsController>(
      (ref) => AutoRecordSettingsController(ref),
    );
