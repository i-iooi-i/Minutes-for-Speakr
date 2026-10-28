import 'package:speakr_app/l10n/strings.dart';

import 'dart:async';
import 'dart:io' show Platform;

import 'package:collection/collection.dart';
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
import '../../services/preferences/time_format_preference.dart';
import '../../services/preferences/time_format_providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../utils/formatters.dart';
import '../../widgets/speakr_icons.dart';
import '../shell/desktop_shortcuts.dart';

class LiveDesktopScreen extends ConsumerStatefulWidget {
  const LiveDesktopScreen({super.key});

  @override
  ConsumerState<LiveDesktopScreen> createState() => _LiveDesktopScreenState();
}

class _LiveDesktopScreenState extends ConsumerState<LiveDesktopScreen> {
  StreamSubscription<RecordingNav>? _navSub;

  @override
  void initState() {
    super.initState();
    final controller = ref.read(recordingControllerProvider.notifier);
    _navSub = controller.navStream.listen(_onNav);
    final state = ref.read(recordingControllerProvider);
    if (!state.started && !state.uploading) {
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

    final canPause = state.started;
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
                    paused: state.paused,
                    onMinimize: _minimize,
                    onShowMini: canOpenMini ? controller.openMini : null,
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 14,
                          child: _LeftPane(
                            state: state,
                            controller: controller,
                            onDiscard: () =>
                                ref.read(discardArmedProvider.notifier).state =
                                    true,
                          ),
                        ),
                        Container(
                          width: 340,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3F1EC),
                            border: Border(
                              left: BorderSide(color: SpeakrColors.line),
                            ),
                          ),
                          child: _CapturePanel(
                            state: state,
                            controller: controller,
                          ),
                        ),
                      ],
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
    required this.paused,
    required this.onMinimize,
    this.onShowMini,
  });
  final bool paused;
  final VoidCallback onMinimize;
  final VoidCallback? onShowMini;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Container(
      height: 44,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: SpeakrColors.line)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _BorderButton(
            label: tr("Minimize"),
            leading: const SpeakrIconView(
              SpeakrIcon.minimize,
              size: 14,
              color: SpeakrColors.ink2,
            ),
            onTap: onMinimize,
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PulseDot(paused: paused),
              const SizedBox(width: 8),
              Text(
                paused ? tr("PAUSED") : tr("RECORDING"),
                style: SpeakrText.mono(
                  size: 11,
                  color: SpeakrColors.recordingDot,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (onShowMini != null)
            _BorderButton(
              label: tr("Mini window"),
              leading: const SpeakrIconView(
                SpeakrIcon.pip,
                size: 14,
                color: SpeakrColors.ink2,
              ),
              onTap: onShowMini!,
            )
          else
            const SizedBox(width: 110),
        ],
      ),
    );
  }
}

class _BorderButton extends StatelessWidget {
  const _BorderButton({required this.label, required this.onTap, this.leading});
  final String label;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: SpeakrColors.line),
        borderRadius: BorderRadius.circular(5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: onTap,
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 6)],
              Text(
                label,
                style: SpeakrText.sans(size: 12, color: SpeakrColors.ink2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.paused});
  final bool paused;
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Opacity(
        opacity: widget.paused ? 0.5 : 0.3 + 0.7 * (1 - _c.value),
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: SpeakrColors.recordingDot,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// LEFT pane — title, big timer, scrolling waveform, controls
// ─────────────────────────────────────────────────────────

class _LeftPane extends StatelessWidget {
  const _LeftPane({
    required this.state,
    required this.controller,
    required this.onDiscard,
  });
  final RecordingState state;
  final RecordingController controller;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final started = state.started;
    final paused = state.paused;
    final uploading = state.uploading;

    return Padding(
      padding: const EdgeInsets.fromLTRB(60, 50, 60, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _TitleBlock(),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BigTimer(elapsedSeconds: state.elapsedSeconds),
                const SizedBox(height: 18),
                _StartedLine(
                  elapsedSeconds: state.elapsedSeconds,
                  mic: state.micEnabled,
                  systemMode: state.systemMode,
                  processSourceName: state.processSourceName,
                ),
                const SizedBox(height: 12),
                _BreathingDot(
                  paused: paused || !started,
                  level: state.audioLevel,
                ),
              ],
            ),
          ),
          if (state.error != null) ...[
            Text(
              state.error!,
              style: SpeakrText.sans(size: 13, color: SpeakrColors.danger),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PillBtn(
                label: tr("Discard"),
                leading: const Icon(
                  Icons.delete_outline,
                  size: 14,
                  color: SpeakrColors.ink,
                ),
                onTap: started && !uploading ? onDiscard : null,
              ),
              const SizedBox(width: 18),
              _BigPauseButton(
                paused: paused,
                onTap: started ? controller.togglePause : null,
              ),
              const SizedBox(width: 18),
              _PillBtn(
                label: tr("Stop & save"),
                leading: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: SpeakrColors.recordingDot,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                onTap: started && !uploading ? controller.stopAndUpload : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Header above the timer: small uppercase eyebrow + serif placeholder
/// title + italic hint. Mirrors the design's "TITLE / Untitled recording /
/// A title will be generated…" block. The title isn't editable from here;
/// it's generated after the recording is summarized.
class _TitleBlock extends StatelessWidget {
  const _TitleBlock();

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr("TITLE"),
          style: SpeakrText.mono(
            size: 10,
            color: SpeakrColors.muted,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 6, bottom: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: SpeakrColors.line)),
          ),
          child: Text(
            tr("Untitled recording"),
            style: SpeakrText.serif(
              size: 32,
              color: SpeakrColors.muted,
            ).copyWith(fontStyle: FontStyle.italic),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          tr(
            "A title will be generated automatically after the recording is summarized.",
          ),
          style: SpeakrText.sans(
            size: 12,
            color: SpeakrColors.muted,
          ).copyWith(fontStyle: FontStyle.italic),
        ),
      ],
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
      size: 128,
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

class _StartedLine extends ConsumerWidget {
  const _StartedLine({
    required this.elapsedSeconds,
    required this.mic,
    required this.systemMode,
    this.processSourceName,
  });
  final int elapsedSeconds;
  final bool mic;
  final SystemAudioMode systemMode;
  final String? processSourceName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    final String sysLabel;
    switch (systemMode) {
      case SystemAudioMode.off:
        sysLabel = '';
      case SystemAudioMode.allSystem:
        sysLabel = tr("System audio");
      case SystemAudioMode.processOnly:
        sysLabel = processSourceName ?? tr("Process audio");
    }
    final src = mic && sysLabel.isNotEmpty
        ? tr("Mic + {0}", [sysLabel])
        : mic
        ? tr("Mic only")
        : sysLabel.isNotEmpty
        ? tr("{0} only", [sysLabel])
        : tr("No source");
    final startedAt = DateTime.now().subtract(
      Duration(seconds: elapsedSeconds),
    );
    final pref =
        ref.watch(timeFormatPreferenceProvider).asData?.value ??
        TimeFormatPreference.system;
    final timeStr = formatHourMinute(
      startedAt,
      use24Hour: resolveUse24Hour(pref, context),
    ).toUpperCase();
    return Text(
      tr("STARTED {0}   ·   {1}", [timeStr, src.toUpperCase()]),
      style: SpeakrText.mono(
        size: 11,
        color: SpeakrColors.muted,
        letterSpacing: 1.5,
      ),
    );
  }
}

/// Single calm dot that breathes with the captured audio level. Floor
/// is 0.18 (per design) so the dot never collapses to nothing while
/// active. When paused or before recording starts, the dot/mid ring
/// soften to the line colour and the caption flips to "NO SIGNAL".
class _BreathingDot extends StatelessWidget {
  const _BreathingDot({required this.paused, required this.level});
  final bool paused;
  final double level;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final clamped = paused
        ? 0.05
        : (level.isFinite ? level.clamp(0.18, 1.0) : 0.18);
    final coreSize = 28.0 + clamped * 36.0; // 28 → 64 px
    final ringSize = coreSize + 26.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Static outer ring — fixed max bound.
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: SpeakrColors.line),
                  ),
                ),
                // Mid breathing ring — tracks the level, ink-tinted while
                // recording and line-tinted while paused.
                AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.linear,
                  width: ringSize,
                  height: ringSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: (paused ? SpeakrColors.line : SpeakrColors.ink)
                          .withValues(alpha: paused ? 0.25 : 0.18),
                    ),
                  ),
                ),
                // Core dot.
                AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.linear,
                  width: coreSize,
                  height: coreSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: paused ? SpeakrColors.line : SpeakrColors.ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            paused ? tr("NO SIGNAL") : tr("AUDIO LEVEL"),
            style: SpeakrText.mono(
              size: 10,
              color: SpeakrColors.muted,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
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
      color: Colors.white,
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
      width: 84,
      height: 84,
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

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
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
              sub: _desktopSystemSub(state.systemMode, state.processSourceName),
              value: state.systemMode,
              pending: state.systemPending,
              onChanged: controller.setSystemMode,
              options: [
                PillSourceOption(id: SystemAudioMode.off, label: tr("Off")),
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
                style: SpeakrText.sans(size: 11, color: SpeakrColors.muted),
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
                  style: SpeakrText.sans(size: 11, color: SpeakrColors.muted),
                ),
              ),
          ],
          const SizedBox(height: 22),
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
              ).copyWith(fontStyle: FontStyle.italic),
            )
          else
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final t in tags)
                  _TagChipBtn(
                    tag: t,
                    active: activeTagSet.contains(t.name.toLowerCase()),
                    onTap: () => controller.toggleTag(t.name),
                  ),
              ],
            ),
          if (supportsKeyboardShortcuts) ...[
            const SizedBox(height: 30),
            _ShortcutsHint(),
          ],
        ],
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
        color: Colors.white,
        border: Border.all(color: SpeakrColors.line),
        borderRadius: BorderRadius.circular(5),
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
        color: Colors.white,
        border: Border.all(color: SpeakrColors.line),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              tr("How many voices?"),
              style: SpeakrText.sans(
                size: 12,
                color: SpeakrColors.muted,
              ).copyWith(fontStyle: FontStyle.italic),
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

class _ShortcutsHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final rows = [
      [tr("Pause / resume"), '$modLabel.'],
      [tr("Stop & save"), '$modLabel$returnKeyLabel'],
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: SpeakrColors.bg,
        border: Border.all(color: SpeakrColors.line),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: rows
            .mapIndexed(
              (i, row) => Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      row[0],
                      style: SpeakrText.sans(
                        size: 11.5,
                        color: SpeakrColors.muted,
                        height: 1.5,
                      ),
                    ),
                    Text(
                      row[1],
                      style: SpeakrText.mono(
                        size: 10,
                        color: SpeakrColors.muted,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
