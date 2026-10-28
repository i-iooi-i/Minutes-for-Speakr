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
        // Discard resets this top-level recorder to its preparation state.
        break;
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
                    state: state,
                    onShowMini: canOpenMini ? controller.openMini : null,
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 730),
                              child: Column(
                                children: [
                                  _RecordingIdentity(
                                    state: state,
                                    controller: controller,
                                  ),
                                  SizedBox(
                                    height: 430,
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
  const _TopBar({required this.state, this.onShowMini});
  final RecordingState state;
  final VoidCallback? onShowMini;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: SpeakrColors.line)),
    ),
    child: Row(
      children: [
        Icon(
          Icons.circle,
          size: 9,
          color: state.started ? SpeakrColors.recordRed : SpeakrColors.muted,
        ),
        const SizedBox(width: 10),
        Text(
          tr(
            state.uploading
                ? 'Uploading'
                : state.started
                ? (state.paused ? 'Paused' : 'Recording')
                : 'Prepare recording',
          ),
          style: SpeakrText.sans(size: 14, weight: FontWeight.w500),
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
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
      child: Column(
        children: [
          _BigTimer(elapsedSeconds: state.elapsedSeconds),
          const SizedBox(height: 34),
          SizedBox(
            height: 84,
            child: _BreathingDot(
              paused: !started || paused || uploading,
              level: state.audioLevel,
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
            FilledButton(
              onPressed:
                  starting ||
                      (!state.micEnabled &&
                          state.systemMode == SystemAudioMode.off)
                  ? null
                  : onStart,
              style: FilledButton.styleFrom(
                backgroundColor: SpeakrColors.recordRed,
                foregroundColor: Colors.white,
                fixedSize: const Size(108, 108),
                shape: const CircleBorder(),
                padding: EdgeInsets.zero,
              ),
              child: Semantics(
                label: tr(starting ? 'Starting recording' : 'Start recording'),
                child: const Icon(Icons.fiber_manual_record, size: 38),
              ),
            )
          else
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 12,
              children: [
                _PillBtn(
                  label: tr('Discard'),
                  leading: const Icon(Icons.delete_outline, size: 22),
                  onTap: uploading ? null : onDiscard,
                ),
                const SizedBox(width: 28),
                _BigPauseButton(
                  paused: paused,
                  onTap: uploading ? null : controller.togglePause,
                ),
                const SizedBox(width: 28),
                _PillBtn(
                  label: tr('Stop & save'),
                  leading: const Icon(
                    Icons.stop_rounded,
                    size: 24,
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
    final leading = '$h';
    final style = SpeakrText.sans(
      size: 88,
      weight: FontWeight.w300,
      height: 1,
      letterSpacing: -2,
    ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
    final dimColon = style.copyWith(
      color: SpeakrColors.ink.withValues(alpha: 0.35),
    );
    final spans = <InlineSpan>[
      TextSpan(text: leading, style: style),
      TextSpan(text: ':', style: dimColon),
      TextSpan(text: m.toString().padLeft(2, '0'), style: style),
      TextSpan(text: ':', style: dimColon),
      TextSpan(text: ss, style: style),
    ];
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text.rich(
          TextSpan(children: spans),
          textAlign: TextAlign.center,
        ),
      ),
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
      final h = 7 + levels[i] * (size.height - 10);
      p.color = !paused && i > levels.length * .65 && levels[i] > .02
          ? SpeakrColors.accent
          : SpeakrColors.muted.withValues(alpha: .45);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(i * step, (size.height - h) / 2, 2.5, h),
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
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 9)],
              Text(
                label,
                style: SpeakrText.sans(size: 14, color: SpeakrColors.ink),
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
      width: 108,
      height: 108,
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
              size: 38,
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

class _RecordingIdentity extends ConsumerWidget {
  const _RecordingIdentity({required this.state, required this.controller});
  final RecordingState state;
  final RecordingController controller;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folders = ref.watch(foldersProvider).value ?? const <Folder>[];
    final tags = ref.watch(tagsProvider).value ?? const <Tag>[];
    final selected = folders.where((f) => f.id == state.folderId).firstOrNull;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 44, 24, 0),
      child: Column(
        children: [
          Text(
            tr('Untitled recording'),
            style: SpeakrText.sans(size: 26, weight: FontWeight.w500),
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PopupMenuButton<int>(
                tooltip: tr('Folder'),
                onSelected: (id) => controller.setFolder(id == -1 ? null : id),
                itemBuilder: (_) => [
                  PopupMenuItem(value: -1, child: Text(tr('No folder'))),
                  for (final f in folders)
                    PopupMenuItem(value: f.id, child: Text(f.name)),
                ],
                child: _IdentityChip(
                  icon: Icons.folder_outlined,
                  label: selected?.name ?? tr('No folder'),
                  color: selected == null
                      ? SpeakrColors.ink2
                      : parseHexColor(selected.color),
                ),
              ),
              for (final tag in tags.where(
                (t) => state.activeTags.contains(t.name),
              ))
                InkWell(
                  onTap: () => controller.toggleTag(tag.name),
                  borderRadius: BorderRadius.circular(100),
                  child: _IdentityChip(
                    icon: Icons.sell_outlined,
                    label: tag.name,
                    color: parseHexColor(tag.color),
                  ),
                ),
              PopupMenuButton<String>(
                tooltip: tr('Tags'),
                icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                onSelected: controller.toggleTag,
                itemBuilder: (_) => [
                  for (final t in tags)
                    CheckedPopupMenuItem(
                      value: t.name,
                      checked: state.activeTags.contains(t.name),
                      child: Text(t.name),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IdentityChip extends StatelessWidget {
  const _IdentityChip({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: icon == Icons.folder_outlined
          ? Colors.transparent
          : color.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(100),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(label, style: SpeakrText.sans(size: 12, color: color)),
      ],
    ),
  );
}

class _CapturePanel extends StatelessWidget {
  const _CapturePanel({required this.state, required this.controller});
  final RecordingState state;
  final RecordingController controller;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth >= 620
            ? (constraints.maxWidth - 24) / 3
            : constraints.maxWidth;
        Widget card(IconData icon, String label, String sub, Widget control) =>
            Container(
              width: width,
              height: 88,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1C2024), Color(0xFF171B1E)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SpeakrColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 18, color: SpeakrColors.ink2),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(label, style: SpeakrText.sans(size: 13)),
                      ),
                      SizedBox(height: 32, child: control),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SpeakrText.sans(size: 11, color: SpeakrColors.muted),
                  ),
                ],
              ),
            );
        return Column(
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                card(
                  Icons.mic_none_rounded,
                  tr('Microphone'),
                  tr('Default device'),
                  SizedBox(
                    width: 42,
                    child: Transform.scale(
                      scale: .72,
                      child: Switch(
                        value: state.micEnabled,
                        activeThumbColor: Colors.white,
                        activeTrackColor: const Color(0xFF00BA94),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: state.micPending || state.uploading
                            ? null
                            : controller.setMicEnabled,
                      ),
                    ),
                  ),
                ),
                card(
                  Icons.volume_up_outlined,
                  tr('System audio'),
                  _desktopSystemSub(state.systemMode, state.processSourceName),
                  SizedBox(
                    width: 42,
                    child: Transform.scale(
                      scale: .72,
                      child: Switch(
                        value: state.systemMode != SystemAudioMode.off,
                        activeThumbColor: Colors.white,
                        activeTrackColor: const Color(0xFF00BA94),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged:
                            !state.systemAudioSupported ||
                                state.systemPending ||
                                state.uploading
                            ? null
                            : (v) => controller.setSystemMode(
                                v
                                    ? SystemAudioMode.allSystem
                                    : SystemAudioMode.off,
                              ),
                      ),
                    ),
                  ),
                ),
                card(
                  Icons.people_outline_rounded,
                  tr('Speakers'),
                  tr('How many voices?'),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _StepButton(
                        label: '−',
                        onTap: () => controller.setSpeakers(state.speakers - 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('${state.speakers}'),
                      ),
                      _StepButton(
                        label: '+',
                        onTap: () => controller.setSpeakers(state.speakers + 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (state.videoSupported && state.videoRecording)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _VideoSourceCard(state: state, controller: controller),
              ),
            if (state.processSourceName != null &&
                state.processLoopbackSupported)
              TextButton(
                onPressed: () =>
                    controller.setSystemMode(SystemAudioMode.processOnly),
                child: Text(state.processSourceName!),
              ),
          ],
        );
      },
    ),
  );
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
