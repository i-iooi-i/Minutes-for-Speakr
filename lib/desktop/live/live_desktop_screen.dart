import 'package:speakr_app/l10n/strings.dart';

import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/models.dart';
import '../../features/library/library_controller.dart';
import '../../features/live/live_controller.dart';
import '../../features/live/recording_state.dart';
import '../../features/live/widgets/discard_sheet.dart';
import '../../features/live/widgets/recording_widgets.dart'
    show PillSourceCard, PillSourceOption;
import '../../services/audio/live_audio_recorder.dart' show CaptureWindow;
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/speakr_icons.dart';
import '../shell/desktop_shortcuts.dart';

class LiveDesktopScreen extends ConsumerStatefulWidget {
  const LiveDesktopScreen({super.key});

  @override
  ConsumerState<LiveDesktopScreen> createState() => _LiveDesktopScreenState();
}

class _LiveDesktopScreenState extends ConsumerState<LiveDesktopScreen> {
  StreamSubscription<RecordingNav>? _navSub;
  bool _starting = false;

  Future<void> _start() async {
    if (_starting) return;
    final state = ref.read(recordingControllerProvider);
    if (state.started ||
        state.uploading ||
        (!state.micEnabled && state.systemMode == SystemAudioMode.off)) {
      return;
    }
    setState(() => _starting = true);
    try {
      await ref
          .read(recordingControllerProvider.notifier)
          .start(micEnabled: state.micEnabled, systemMode: state.systemMode);
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  void initState() {
    super.initState();
    final controller = ref.read(recordingControllerProvider.notifier);
    _navSub = controller.navStream.listen(_onNav);
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

  void _minimize() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/library');
    }
  }

  @override
  void dispose() {
    _navSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final state = ref.watch(recordingControllerProvider);
    final controller = ref.read(recordingControllerProvider.notifier);
    final canOpenMini =
        !kIsWeb && Platform.isWindows && state.started && !state.miniOpen;

    final canPause = state.started && !state.uploading;
    final canStop = state.started && !state.uploading;

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        modActivator(LogicalKeyboardKey.period): () {
          if (canPause) controller.togglePause();
        },
        modActivator(LogicalKeyboardKey.enter): () {
          if (canStop) controller.stopAndUpload();
        },
        modActivator(LogicalKeyboardKey.numpadEnter): () {
          if (canStop) controller.stopAndUpload();
        },
        modActivator(LogicalKeyboardKey.comma): () => context.push('/settings'),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: SpeakrColors.bg,
          body: Stack(
            children: [
              Column(
                children: [
                  _TopBar(
                    started: state.started,
                    onMinimize: _minimize,
                    onShowMini: canOpenMini ? controller.openMini : null,
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1100),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 300,
                                    child: _LeftPane(
                                      state: state,
                                      controller: controller,
                                      starting: _starting,
                                      onStart: _start,
                                      onDiscard: () =>
                                          ref
                                                  .read(
                                                    discardArmedProvider
                                                        .notifier,
                                                  )
                                                  .state =
                                              true,
                                    ),
                                  ),
                                  _CapturePanel(
                                    state: state,
                                    controller: controller,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.started,
    required this.onMinimize,
    this.onShowMini,
  });
  final bool started;
  final VoidCallback onMinimize;
  final VoidCallback? onShowMini;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: SpeakrColors.line)),
    ),
    child: Row(
      children: [
        IconButton(
          tooltip: tr('Recordings'),
          onPressed: onMinimize,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 8),
        Text(
          tr(started ? 'Recording' : 'New recording'),
          style: SpeakrText.sans(size: 20, weight: FontWeight.w600),
        ),
        const Spacer(),
        if (onShowMini != null)
          IconButton(
            tooltip: tr('Mini window'),
            onPressed: onShowMini,
            icon: const Icon(Icons.picture_in_picture_alt_outlined, size: 20),
          ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────
// LEFT pane — title, big timer, scrolling waveform, controls
// ─────────────────────────────────────────────────────────

class _LeftPane extends StatelessWidget {
  const _LeftPane({
    required this.state,
    required this.controller,
    required this.onDiscard,
    required this.onStart,
    required this.starting,
  });
  final RecordingState state;
  final RecordingController controller;
  final VoidCallback onDiscard;
  final VoidCallback onStart;
  final bool starting;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final started = state.started;
    final paused = state.paused;
    final uploading = state.uploading;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 22, 32, 18),
      child: Column(
        children: [
          Text(
            tr(
              uploading
                  ? 'Uploading'
                  : started
                  ? (paused ? 'Paused' : 'Recording')
                  : 'Prepare recording',
            ),
            style: SpeakrText.sans(
              size: 14,
              color: started ? SpeakrColors.recordRed : SpeakrColors.ink2,
            ),
          ),
          const SizedBox(height: 14),
          _BigTimer(elapsedSeconds: state.elapsedSeconds),
          if (started)
            SizedBox(
              height: 76,
              child: _BreathingDot(
                paused: paused || uploading,
                level: state.audioLevel,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 22),
              child: Text(
                tr(
                  'Choose your audio sources and speakers below, then start recording.',
                ),
                textAlign: TextAlign.center,
                style: SpeakrText.sans(size: 13, color: SpeakrColors.muted),
              ),
            ),
          if (state.error != null)
            Text(
              state.error!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: SpeakrText.sans(size: 12, color: SpeakrColors.danger),
            ),
          const Spacer(),
          if (!started && !uploading)
            FilledButton.icon(
              onPressed:
                  starting ||
                      (!state.micEnabled &&
                          state.systemMode == SystemAudioMode.off)
                  ? null
                  : onStart,
              style: FilledButton.styleFrom(
                backgroundColor: SpeakrColors.recordRed,
                foregroundColor: Colors.white,
                minimumSize: const Size(160, 46),
              ),
              icon: const Icon(Icons.fiber_manual_record, size: 20),
              label: Text(
                tr(starting ? 'Starting recording' : 'Start recording'),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PillBtn(
                  label: tr('Discard'),
                  leading: const Icon(Icons.delete_outline, size: 16),
                  onTap: uploading ? null : onDiscard,
                ),
                const SizedBox(width: 16),
                _BigPauseButton(
                  paused: paused,
                  onTap: uploading ? null : controller.togglePause,
                ),
                const SizedBox(width: 16),
                _PillBtn(
                  label: tr('Stop & save'),
                  leading: const Icon(
                    Icons.stop_rounded,
                    size: 18,
                    color: SpeakrColors.recordRed,
                  ),
                  onTap: uploading ? null : controller.stopAndUpload,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _BigTimer extends StatelessWidget {
  const _BigTimer({required this.elapsedSeconds});
  final int elapsedSeconds;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final h = elapsedSeconds ~/ 3600;
    final m = (elapsedSeconds ~/ 60) % 60;
    final s = elapsedSeconds % 60;
    final ss = s.toString().padLeft(2, '0');
    final leading = h > 0 ? '$h' : '$m';
    final trailing = h > 0 ? '${m.toString().padLeft(2, '0')}:$ss' : ss;
    // For h>0 we render the inner ':' between mm and ss in the trailing
    // segment as the dimmed separator. We split it ourselves so both
    // colons are dimmed consistently.
    final List<InlineSpan> spans;
    final style = SpeakrText.serif(
      size: 58,
      weight: FontWeight.w300,
      height: 1,
      letterSpacing: -3,
    ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
    final dimColon = style.copyWith(
      color: SpeakrColors.ink.withValues(alpha: 0.35),
    );
    if (h > 0) {
      // h:mm:ss — dim both colons.
      spans = [
        TextSpan(text: leading, style: style),
        TextSpan(text: ':', style: dimColon),
        TextSpan(text: m.toString().padLeft(2, '0'), style: style),
        TextSpan(text: ':', style: dimColon),
        TextSpan(text: ss, style: style),
      ];
    } else {
      // m:ss — single dimmed colon.
      spans = [
        TextSpan(text: leading, style: style),
        TextSpan(text: ':', style: dimColon),
        TextSpan(text: trailing, style: style),
      ];
    }
    return Center(
      child: Text.rich(TextSpan(children: spans), textAlign: TextAlign.center),
    );
  }
}

class _BreathingDot extends StatefulWidget {
  const _BreathingDot({required this.paused, required this.level});
  final bool paused;
  final double level;
  @override
  State<_BreathingDot> createState() => _BreathingDotState();
}

class _BreathingDotState extends State<_BreathingDot> {
  final List<double> _levels = List.filled(96, 0, growable: true);
  @override
  void didUpdateWidget(covariant _BreathingDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.paused) {
      _levels.removeAt(0);
      _levels.add(widget.level.isFinite ? widget.level.clamp(0.0, 1.0) : 0);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Semantics(
      label: tr('AUDIO LEVEL'),
      child: SizedBox(
        width: double.infinity,
        height: 88,
        child: CustomPaint(
          painter: _LiveLevelPainter(List.of(_levels), widget.paused),
        ),
      ),
    ),
  );
}

class _LiveLevelPainter extends CustomPainter {
  _LiveLevelPainter(this.levels, this.paused);
  final List<double> levels;
  final bool paused;
  @override
  void paint(Canvas canvas, Size size) {
    final step = size.width / levels.length;
    final p = Paint();
    for (var i = 0; i < levels.length; i++) {
      final h = 3 + levels[i] * (size.height - 6);
      p.color = !paused && i > levels.length * .65 && levels[i] > .02
          ? SpeakrColors.accent
          : SpeakrColors.muted.withValues(alpha: .45);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(i * step, (size.height - h) / 2, step * .48, h),
          const Radius.circular(2),
        ),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LiveLevelPainter oldDelegate) => true;
}

class _PillBtn extends StatelessWidget {
  const _PillBtn({required this.label, required this.onTap, this.leading});
  final String label;
  final VoidCallback? onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Material(
      color: SpeakrColors.surface,
      shape: const StadiumBorder(side: BorderSide(color: SpeakrColors.line)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 9)],
              Text(
                label.toUpperCase(),
                style: SpeakrText.mono(
                  size: 11,
                  color: SpeakrColors.ink,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BigPauseButton extends StatelessWidget {
  const _BigPauseButton({required this.paused, required this.onTap});
  final bool paused;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return SizedBox(
      width: 54,
      height: 54,
      child: Material(
        color: SpeakrColors.ink,
        shape: const CircleBorder(),
        elevation: 12,
        shadowColor: SpeakrColors.ink.withValues(alpha: 0.18),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: SpeakrIconView(
              paused ? SpeakrIcon.play : SpeakrIcon.pause,
              size: 28,
              color: SpeakrColors.bg,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// RIGHT pane — capture panel
// ─────────────────────────────────────────────────────────

class _CapturePanel extends ConsumerStatefulWidget {
  const _CapturePanel({required this.state, required this.controller});
  final RecordingState state;
  final RecordingController controller;

  @override
  ConsumerState<_CapturePanel> createState() => _CapturePanelState();
}

class _CapturePanelState extends ConsumerState<_CapturePanel> {
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final state = widget.state;
    final controller = widget.controller;
    final tags = ref.watch(tagsProvider).value ?? const <Tag>[];
    final folders = ref.watch(foldersProvider).value ?? const <Folder>[];
    final activeTagSet = {for (final n in state.activeTags) n.toLowerCase()};

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 12, 32, 28),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth > 700
              ? (constraints.maxWidth - 20) / 2
              : constraints.maxWidth;
          return Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              SizedBox(
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeading(tr("Capture")),
                    const SizedBox(height: 14),
                    PillSourceCard<bool>(
                      label: tr("Microphone"),
                      sub: state.micEnabled
                          ? tr("Default device")
                          : tr("Not capturing voice"),
                      value: state.micEnabled,
                      pending: state.micPending,
                      onChanged: controller.setMicEnabled,
                      options: [
                        PillSourceOption(id: false, label: tr("Off")),
                        PillSourceOption(
                          id: true,
                          label: tr("Mic"),
                          icon: SpeakrIcon.mic,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (state.systemAudioSupported)
                      PillSourceCard<SystemAudioMode>(
                        label: tr("System audio"),
                        sub: _desktopSystemSub(
                          state.systemMode,
                          state.processSourceName,
                        ),
                        value: state.systemMode,
                        pending: state.systemPending,
                        onChanged: controller.setSystemMode,
                        options: [
                          PillSourceOption(
                            id: SystemAudioMode.off,
                            label: tr("Off"),
                          ),
                          PillSourceOption(
                            id: SystemAudioMode.allSystem,
                            label: tr("System"),
                            icon: SpeakrIcon.speaker,
                          ),
                          if (state.processSourceName != null &&
                              state.processSourcePid != null &&
                              state.processLoopbackSupported)
                            PillSourceOption(
                              id: SystemAudioMode.processOnly,
                              label: state.processSourceName!,
                            ),
                        ],
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          tr("System audio not supported on this device."),
                          style: SpeakrText.sans(
                            size: 11,
                            color: SpeakrColors.muted,
                          ),
                        ),
                      ),
                    if (state.videoSupported) ...[
                      const SizedBox(height: 8),
                      if (state.videoRecording)
                        _VideoSourceCard(state: state, controller: controller)
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            tr(
                              "Video is off for this recording. Turn on \"Record video\" in Settings to record the meeting window.",
                            ),
                            style: SpeakrText.sans(
                              size: 11,
                              color: SpeakrColors.muted,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              SizedBox(
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeading(tr("Speakers")),
                    const SizedBox(height: 8),
                    _SpeakerStepper(
                      value: state.speakers,
                      onMinus: () => controller.setSpeakers(state.speakers - 1),
                      onPlus: () => controller.setSpeakers(state.speakers + 1),
                    ),
                    const SizedBox(height: 22),
                    _SectionHeading(tr("Folder")),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        _NoneFolderChip(
                          selected: state.folderId == null,
                          onTap: () => controller.setFolder(null),
                        ),
                        for (final f in folders)
                          _FolderChipBtn(
                            folder: f,
                            active: state.folderId == f.id,
                            onTap: () => controller.setFolder(
                              state.folderId == f.id ? null : f.id,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _SectionHeading(tr("Tags")),
                    const SizedBox(height: 8),
                    if (tags.isEmpty)
                      Text(
                        tr("No tags yet"),
                        style: SpeakrText.sans(
                          size: 12,
                          color: SpeakrColors.muted,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          for (final t in tags)
                            _TagChipBtn(
                              tag: t,
                              active: activeTagSet.contains(
                                t.name.toLowerCase(),
                              ),
                              onTap: () => controller.toggleTag(t.name),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The recorded window, with a menu to switch to another window or to
/// none (black frames). Video itself can't be turned on or off
/// mid-recording: the file's streams are fixed when it starts.
class _VideoSourceCard extends StatelessWidget {
  const _VideoSourceCard({required this.state, required this.controller});
  final RecordingState state;
  final RecordingController controller;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final title = state.videoWindowTitle;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: SpeakrColors.surface,
        border: Border.all(color: SpeakrColors.line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: title != null
                  ? const Color(0xFF3A8A5A)
                  : SpeakrColors.line,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr("Video"),
                  style: SpeakrText.sans(
                    size: 13,
                    weight: FontWeight.w500,
                    color: SpeakrColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title ?? tr("No window · recording black"),
                  style: SpeakrText.sans(size: 11, color: SpeakrColors.muted),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _pickWindow(context),
            child: Text(
              tr("Change"),
              style: SpeakrText.sans(size: 12, color: SpeakrColors.ink),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickWindow(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final windows = await controller.listCaptureWindows();
    if (box == null || !context.mounted) return;
    final origin = box.localToGlobal(Offset(0, box.size.height));
    // Wrapped so "no window" (null) is distinguishable from dismissal.
    final picked = await showMenu<_WindowChoice>(
      context: context,
      position: RelativeRect.fromLTRB(
        origin.dx,
        origin.dy,
        origin.dx + box.size.width,
        origin.dy,
      ),
      items: [
        PopupMenuItem(
          value: _WindowChoice(null),
          child: Text(tr("No window (black)")),
        ),
        for (final w in windows)
          PopupMenuItem(
            value: _WindowChoice(w),
            child: SizedBox(
              width: 280,
              child: Text(w.title, overflow: TextOverflow.ellipsis),
            ),
          ),
      ],
    );
    if (picked != null) await controller.selectVideoWindow(picked.window);
  }
}

class _WindowChoice {
  const _WindowChoice(this.window);
  final CaptureWindow? window;
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Text(
      text.toUpperCase(),
      style: SpeakrText.mono(
        size: 9.5,
        color: SpeakrColors.muted,
        letterSpacing: 1.5,
      ),
    );
  }
}

String _desktopSystemSub(SystemAudioMode mode, String? processSourceName) {
  switch (mode) {
    case SystemAudioMode.off:
      return tr("Not capturing app audio");
    case SystemAudioMode.allSystem:
      return tr("All apps · system mix");
    case SystemAudioMode.processOnly:
      return processSourceName != null
          ? tr("{0} only", [processSourceName])
          : tr("Process-only");
  }
}

class _SpeakerStepper extends StatelessWidget {
  const _SpeakerStepper({
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: SpeakrColors.surface,
        border: Border.all(color: SpeakrColors.line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              tr("How many voices?"),
              style: SpeakrText.sans(size: 12, color: SpeakrColors.muted),
            ),
          ),
          _StepButton(label: '−', onTap: onMinus),
          const SizedBox(width: 14),
          SizedBox(
            width: 18,
            child: Center(
              child: Text('$value', style: SpeakrText.serif(size: 20)),
            ),
          ),
          const SizedBox(width: 14),
          _StepButton(label: '+', onTap: onPlus),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Material(
      color: SpeakrColors.bg,
      shape: const CircleBorder(side: BorderSide(color: SpeakrColors.line)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 26,
          height: 26,
          child: Center(
            child: Text(
              label,
              style: SpeakrText.serif(size: 14, weight: FontWeight.w300),
            ),
          ),
        ),
      ),
    );
  }
}

class _FolderChipBtn extends StatelessWidget {
  const _FolderChipBtn({
    required this.folder,
    required this.active,
    required this.onTap,
  });
  final Folder folder;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final c = parseHexColor(folder.color);
    return InkWell(
      borderRadius: BorderRadius.circular(3),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: active ? c : Colors.transparent,
          border: Border.all(color: active ? c : c.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: active ? Colors.white : c,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              folder.name.toUpperCase(),
              style: SpeakrText.mono(
                size: 10,
                color: active ? Colors.white : c,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChipBtn extends StatelessWidget {
  const _TagChipBtn({
    required this.tag,
    required this.active,
    required this.onTap,
  });
  final Tag tag;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final c = parseHexColor(tag.color);
    return InkWell(
      borderRadius: BorderRadius.circular(3),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? c : Colors.transparent,
          border: Border.all(color: active ? c : c.withValues(alpha: 0.33)),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          (active ? tag.name : '+ ${tag.name}').toUpperCase(),
          style: SpeakrText.mono(
            size: 10,
            color: active ? Colors.white : c,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _NoneFolderChip extends StatelessWidget {
  const _NoneFolderChip({required this.selected, required this.onTap});
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final c = SpeakrColors.muted;
    return InkWell(
      borderRadius: BorderRadius.circular(3),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? c : Colors.transparent,
          border: Border.all(color: selected ? c : c.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          tr("NONE"),
          style: SpeakrText.mono(
            size: 10,
            color: selected ? Colors.white : c,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
