import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/library/library_controller.dart';
import '../../features/live/live_controller.dart';
import '../../features/live/recording_state.dart' show SystemAudioMode;
import 'auto_record_coordinator.dart';
import 'auto_record_providers.dart';
import 'auto_record_settings.dart' show AllowlistKind;

/// Singleton entry point for the auto-record subsystem. Constructed
/// once in [main] (Windows-only) and disposed when the process exits.
///
/// Ownership is intentionally outside the Riverpod graph so the
/// subsystem is alive even when no widgets are mounted (e.g. during the
/// splash gate before credentials resolve).
class AutoRecordBootstrap {
  AutoRecordBootstrap._(this.coordinator);

  final AutoRecordCoordinator coordinator;

  static AutoRecordBootstrap? _instance;
  static AutoRecordBootstrap? get instance => _instance;

  /// Initializes the auto-record subsystem on Windows. No-ops on other
  /// platforms. Safe to call multiple times — only the first wins.
  static Future<AutoRecordBootstrap?> start(ProviderContainer container) async {
    if (!Platform.isWindows) return null;
    if (_instance != null) return _instance;
    try {
      // Force the providers to materialize so the singletons live for
      // the app's lifetime, not just while a widget watches them.
      final store = await container.read(autoRecordStoreProvider.future);
      final monitor = container.read(micMonitorProvider);
      final meter = container.read(outputMeterProvider);
      final recording = container.read(recordingControllerProvider.notifier);
      // Pre-warm the server tag list so per-app/global tag-ID overrides
      // can be resolved to names by the time mic activity actually fires
      // applyTriggerMetadata. Fire-and-forget — failures here just mean
      // the first auto-recording shows nothing in `activeTags` until the
      // user opens the live screen.
      container.read(tagsProvider.future).ignore();

      final coordinator = AutoRecordCoordinator(
        micMonitor: monitor,
        outputMeter: meter,
        recording: recording,
        startRecording:
            ({
              bool? micEnabled,
              SystemAudioMode? systemMode,
              String? processSourceName,
              int? processSourcePid,
              bool? videoEnabled,
              List<int>? videoPids,
            }) => recording.start(
              micEnabled: micEnabled,
              systemMode: systemMode,
              processSourceName: processSourceName,
              processSourcePid: processSourcePid,
              videoEnabled: videoEnabled,
              videoPids: videoPids,
            ),
        findProcessPids:
            ({
              String? exePath,
              required String matchKey,
              required AllowlistKind kind,
            }) => recording.findProcessPids(
              exePath: exePath,
              matchKey: matchKey,
              kind: kind,
            ),
        stopAndUpload: recording.stopAndUpload,
        cancelRecording: recording.cancel,
        store: store,
        onStopCountdown: recording.setAutoStopCountdown,
        onSettingsChanged: () =>
            container.invalidate(autoRecordSettingsProvider),
        applyTriggerMetadata:
            ({required speakers, required tagIds, required folderId}) {
              recording.setSpeakers(speakers);
              // Resolve tag IDs to names against the cached server tag list.
              // If `tagsProvider` hasn't loaded yet (rare; usually warm by
              // the time mic activity is detected), apply what we can — the
              // user can always edit before stopping.
              final knownTags = container.read(tagsProvider).value ?? const [];
              final names = <String>[
                for (final id in tagIds)
                  for (final t in knownTags)
                    if (t.id == id) t.name,
              ];
              recording.setActiveTags(names);
              recording.setFolder(folderId);
            },
      );
      recording.onResumeAutoStop = coordinator.resumeFromStopCountdown;
      coordinator.start();
      _instance = AutoRecordBootstrap._(coordinator);
      // Re-publish via the override so consumers can watch it.
      // (We can't override after creation, so consumers should reach
      //  through `AutoRecordBootstrap.instance?.coordinator` instead.)
      return _instance;
    } catch (e, st) {
      debugPrint('[auto-record] bootstrap failed: $e\n$st');
      return null;
    }
  }

  Future<void> dispose() async {
    await coordinator.dispose();
    _instance = null;
  }
}

/// Synchronous accessor used by the UI. Returns null on non-Windows or
/// before bootstrap completes.
final autoRecordCoordinatorProvider = Provider<AutoRecordCoordinator?>((ref) {
  return AutoRecordBootstrap.instance?.coordinator;
});

/// Stop-prompt stream the app shell listens to. Empty stream when
/// bootstrap hasn't run.
final autoRecordPromptsProvider = StreamProvider<StopPromptRequest>((
  ref,
) async* {
  final coord = ref.watch(autoRecordCoordinatorProvider);
  if (coord == null) {
    yield* const Stream<StopPromptRequest>.empty();
    return;
  }
  yield* coord.prompts;
});
