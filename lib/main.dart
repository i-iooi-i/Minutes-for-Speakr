import 'theme/appearance.dart';
import 'services/preferences/local_avatar.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:workmanager/workmanager.dart';

import 'app.dart';
import 'l10n/strings.dart';
import 'features/auto_upload/auto_upload_worker.dart';
import 'features/auto_upload/workmanager_callback.dart';
import 'features/library/library_controller.dart';
import 'features/live/mini/mini_ipc.dart';
import 'features/live/mini/mini_recorder_app.dart';
import 'services/auto_record/auto_record_bootstrap.dart';
import 'services/dev/dev_window_title.dart';
import 'services/tray/tray_bridge.dart';

Future<void> main(List<String> args) async {
  // Drop two error-level mpv log lines that media_kit / libmpv emit on every
  // player init — `osc` (video-only property doesn't exist in libmpv) and
  // `lavf: Failed to create file cache` (HTTP stream cache falls back to the
  // 32MB in-memory buffer). media_kit's MPVLogLevel can't be set below `error`,
  // so we filter at the print boundary. Real playback failures still surface
  // via AudioPlayer's error stream.
  //
  // ensureInitialized and runApp must share a zone — Flutter asserts on a
  // mismatch — so the entire main body runs inside this zone, not just runApp.
  await runZoned<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await loadLanguage();
      await appAppearance.load();
      await localAvatar.load();

      // Windows-only: when invoked as a child engine by desktop_multi_window
      // the args are ['multi_window', '<int windowId>', '<jsonArgs>'].
      if (!kIsWeb && Platform.isWindows && _isMiniWindowLaunch(args)) {
        final windowId = int.tryParse(args[1]) ?? -1;
        String role = MiniIpc.argRoleMini;
        try {
          final parsed = jsonDecode(args.length > 2 ? args[2] : '{}');
          if (parsed is Map && parsed['role'] is String) {
            role = parsed['role'] as String;
          }
        } catch (_) {}
        if (role == MiniIpc.argRoleMini && windowId > 0) {
          runApp(
            ProviderScope(
              child: AppearanceApp(
                builder: () => MiniRecorderApp(windowId: windowId),
              ),
            ),
          );
          return;
        }
      }

      if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
        JustAudioMediaKit.ensureInitialized();
      }

      if (!kIsWeb && Platform.isAndroid) {
        await Workmanager().initialize(autoUploadCallbackDispatcher);
        await Workmanager().registerPeriodicTask(
          AutoUploadTaskNames.periodic,
          AutoUploadTaskNames.periodic,
          frequency: const Duration(minutes: 15),
          constraints: Constraints(networkType: NetworkType.connected),
          existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
        );
      }

      // Build the provider container ourselves so the auto-record bootstrap
      // and the UI share state. Without this, ProviderScope would create
      // its own container and the bootstrap couldn't reach into it.
      final container = ProviderContainer();

      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        // No WorkManager on desktop — run a foreground polling loop. The
        // worker bails internally when the feature is disabled, so this is
        // cheap when not configured. After each scan, bump the kick so the
        // Library list reflects any uploads/deletions promptly.
        Timer.periodic(const Duration(minutes: 5), (_) async {
          await runAutoUploadScan(trigger: 'desktop_timer');
          container.read(uploadKickProvider.notifier).state++;
        });
      }

      if (!kIsWeb && Platform.isWindows) {
        // Fire and forget — the bootstrap is only relevant on Windows and
        // failures are non-fatal (the rest of the app works without it).
        unawaited(AutoRecordBootstrap.start(container));
        unawaited(applyDevBranchTitleIfDebug());
        installTrayBridge(container);
        appLanguage.addListener(() => unawaited(syncTrayLanguage()));
        await syncTrayLanguage();
      }

      runApp(
        UncontrolledProviderScope(
          container: container,
          child: AppearanceApp(builder: () => const SpeakrApp()),
        ),
      );
    },
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        if (line.startsWith('MPV: [error]')) return;
        parent.print(zone, line);
      },
    ),
  );
}

bool _isMiniWindowLaunch(List<String> args) {
  return args.isNotEmpty && args.first == 'multi_window';
}
