import 'package:speakr_app/theme/appearance.dart';
import 'package:speakr_app/l10n/strings.dart';

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/models.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/mono_eyebrow.dart';
import '../../widgets/speakr_icons.dart';
import '../library/library_controller.dart';
import 'live_controller.dart';
import 'widgets/discard_sheet.dart';
import 'widgets/recording_widgets.dart';

class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key});

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> {
  bool _tagPickerOpen = false;
  bool _folderPickerOpen = false;
  StreamSubscription<RecordingNav>? _navSub;

  @override
  void initState() {
    super.initState();
    final controller = ref.read(recordingControllerProvider.notifier);
    _navSub = controller.navStream.listen(_onNav);
    // Kick off recording on first mount, only if we haven't already
    // started (e.g. user pushed `/live` while recording was running).
    final state = ref.read(recordingControllerProvider);
    if (!state.started && !state.uploading) {
      // Defer to next frame so the navigation transition is settled before
      // the mic permission prompt appears.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.start();
      });
    }
  }

  void _onNav(RecordingNav event) {
    if (!mounted) return;
    switch (event) {
      case RecordingNav.toLibrary:
        context.go('/library');
      case RecordingNav.pop:
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/library');
        }
    }
  }

  @override
  void dispose() {
    _navSub?.cancel();
    super.dispose();
  }

  void _minimize() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/library');
    }
  }

  void _confirmDiscard() {
    // The shared DiscardOverlay (mounted in RecordingMiniPlayer) renders
    // the confirmation sheet — same look here and from the global bar,
    // with a live-updating elapsed-time label.
    ref.read(discardArmedProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    final state = ref.watch(recordingControllerProvider);
    final controller = ref.read(recordingControllerProvider.notifier);
    final canOpenMini =
        !kIsWeb && Platform.isWindows && state.started && !state.miniOpen;

    return Scaffold(
      backgroundColor: SpeakrColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              onMinimize: _minimize,
              onShowMini: canOpenMini ? controller.openMini : null,
            ),
            const SizedBox(height: 4),
            LiveIndicator(paused: state.paused),
            const SizedBox(height: 18),
            RecordingTimer(text: state.formattedElapsed),
            const Spacer(),
            BreathingDot(
              paused: state.paused || !state.started,
              level: state.audioLevel,
            ),
            const Spacer(),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  state.error!,
                  style: SpeakrText.sans(size: 13, color: SpeakrColors.danger),
                ),
              ),
            const SizedBox(height: 12),
            MetadataCard(
              speakers: state.speakers,
              onSpeakersChanged: controller.setSpeakers,
              activeTags: state.activeTags,
              tagPickerOpen: _tagPickerOpen,
              onToggleTag: controller.toggleTag,
              onToggleEdit: () =>
                  setState(() => _tagPickerOpen = !_tagPickerOpen),
              micEnabled: state.micEnabled,
              systemMode: state.systemMode,
              systemAudioSupported: state.systemAudioSupported,
              processLoopbackSupported: state.processLoopbackSupported,
              processSourceName: state.processSourceName,
              processSourcePid: state.processSourcePid,
              micPending: state.micPending,
              systemPending: state.systemPending,
              onMicChanged: controller.setMicEnabled,
              onSystemModeChanged: controller.setSystemMode,
              tags: ref.watch(tagsProvider).value ?? const <Tag>[],
              folders: ref.watch(foldersProvider).value ?? const <Folder>[],
              folderId: state.folderId,
              folderPickerOpen: _folderPickerOpen,
              onToggleFolderEdit: () =>
                  setState(() => _folderPickerOpen = !_folderPickerOpen),
              onFolderChanged: controller.setFolder,
            ),
            RecordingControls(
              paused: state.paused,
              busy: state.uploading,
              onTogglePause: state.started ? controller.togglePause : null,
              onStop: state.started ? controller.stopAndUpload : null,
              onDiscard: state.started && !state.uploading
                  ? _confirmDiscard
                  : null,
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onMinimize, this.onShowMini});
  final VoidCallback onMinimize;
  final Future<void> Function()? onShowMini;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GhostIconButton(icon: SpeakrIcon.minimize, onTap: onMinimize),
              if (onShowMini != null)
                GhostIconButton(
                  icon: SpeakrIcon.pip,
                  onTap: () => onShowMini!(),
                ),
            ],
          ),
          MonoEyebrow(tr("Recording"), size: 10),
          const SizedBox(width: 36, height: 36),
        ],
      ),
    );
  }
}
