import 'package:speakr_app/l10n/strings.dart';

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/auto_record/auto_record_coordinator.dart'
    show kAutoStopCountdownSeconds;
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';
import '../../../widgets/speakr_icons.dart';
import '../recording_state.dart';
import 'recording_mirror.dart';

/// Always-on-top mini pill shown above other apps during a live recording
/// on Windows. Replaces the older 320×540 panel with a single 36 px tall
/// dark pill: live dot · timer · discard · pause/resume · stop & save ·
/// open in main. Source picker and metadata editing move back to the main
/// `/live` page per the Option A design.
class MiniRecorderScreen extends ConsumerStatefulWidget {
  const MiniRecorderScreen({super.key});

  @override
  ConsumerState<MiniRecorderScreen> createState() => _MiniRecorderScreenState();
}

class _MiniRecorderScreenState extends ConsumerState<MiniRecorderScreen> {
  // Tap-to-arm pattern for the discard button. A real AlertDialog can't
  // be rendered inside the 248×40 pill window (it gets clipped). Instead,
  // the first tap turns the trash button red for [_discardArmWindow];
  // a second tap within the window discards. Tapping elsewhere or letting
  // the timer expire reverts to the ghost state.
  static const _discardArmWindow = Duration(seconds: 3);
  bool _discardArmed = false;
  Timer? _disarmTimer;

  @override
  void dispose() {
    _disarmTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleDiscardTap() async {
    if (_discardArmed) {
      _disarmTimer?.cancel();
      _discardArmed = false;
      await ref.read(recordingMirrorProvider.notifier).cancel();
      return;
    }
    setState(() => _discardArmed = true);
    _disarmTimer?.cancel();
    _disarmTimer = Timer(_discardArmWindow, () {
      if (!mounted) return;
      setState(() => _discardArmed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final state = ref.watch(recordingMirrorProvider);
    final mirror = ref.read(recordingMirrorProvider.notifier);

    return Scaffold(
      // The Win32 window underneath is a rounded popup clipped via
      // SetWindowRgn. Painting the entire surface with ink keeps the
      // corners visually clean during any pre-clip frame.
      backgroundColor: SpeakrColors.ink,
      body: Center(
        child: state.autoStopSecondsLeft != null
            ? _MeetingEndedPill(
                secondsLeft: state.autoStopSecondsLeft!,
                onDragStart: mirror.beginDrag,
                onResume: mirror.resumeAutoStop,
              )
            : _Pill(
                state: state,
                discardArmed: _discardArmed,
                onDragStart: mirror.beginDrag,
                onDiscard: _handleDiscardTap,
                onTogglePause: state.started ? mirror.togglePause : null,
                onStop: state.started && !state.uploading ? mirror.stop : null,
                onOpenMain: mirror.showMain,
              ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.state,
    required this.discardArmed,
    required this.onDragStart,
    required this.onDiscard,
    required this.onTogglePause,
    required this.onStop,
    required this.onOpenMain,
  });

  final RecordingState state;
  final bool discardArmed;
  final Future<void> Function() onDragStart;
  final Future<void> Function() onDiscard;
  final VoidCallback? onTogglePause;
  final VoidCallback? onStop;
  final Future<void> Function() onOpenMain;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final paused = state.paused;
    final uploading = state.uploading;
    final timerText = state.formattedElapsed;

    return Container(
      height: 36,
      padding: const EdgeInsets.fromLTRB(12, 0, 4, 0),
      decoration: BoxDecoration(
        color: SpeakrColors.ink,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillDrag(
            onDragStart: onDragStart,
            child: _LeftCluster(
              armed: discardArmed,
              paused: paused,
              timerText: timerText,
            ),
          ),
          const SizedBox(width: 9),
          _PillDrag(onDragStart: onDragStart, child: const _Hairline()),
          const SizedBox(width: 9),
          _PillButton(
            background: discardArmed
                ? SpeakrColors.recordingDot.withValues(alpha: 0.95)
                : const Color(0x14FFFFFF), // ~8% white
            onTap: () => onDiscard(),
            child: SpeakrIconView(
              SpeakrIcon.trash,
              size: 14,
              color: discardArmed
                  ? SpeakrColors.bg
                  : SpeakrColors.bg.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: 9),
          _PillButton(
            background: const Color(0x29FFFFFF), // ~16% white — primary
            onTap: onTogglePause,
            child: SpeakrIconView(
              paused ? SpeakrIcon.play : SpeakrIcon.pause,
              size: 12,
              color: SpeakrColors.bg,
            ),
          ),
          const SizedBox(width: 9),
          _PillButton(
            background: SpeakrColors.recordingDot.withValues(alpha: 0.95),
            onTap: onStop,
            child: uploading
                ? const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.6,
                      color: SpeakrColors.bg,
                    ),
                  )
                : Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: SpeakrColors.bg,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
          ),
          const SizedBox(width: 9),
          _PillDrag(onDragStart: onDragStart, child: const _Hairline()),
          const SizedBox(width: 9),
          _PillButton(
            background: const Color(0x14FFFFFF),
            onTap: () => onOpenMain(),
            child: SpeakrIconView(
              SpeakrIcon.expand,
              size: 13,
              color: SpeakrColors.bg.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

/// Replaces the control pill while an idle auto-recording counts down to
/// its automatic stop: "Meeting ended" + countdown on the left, a single
/// Resume button on the right. A lighter fill behind the content drains
/// right-to-left over the countdown. Sized to fit the same 248 px window.
class _MeetingEndedPill extends StatelessWidget {
  const _MeetingEndedPill({
    required this.secondsLeft,
    required this.onDragStart,
    required this.onResume,
  });

  final int secondsLeft;
  final Future<void> Function() onDragStart;
  final Future<void> Function() onResume;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    // Main pushes whole seconds; animate each step to the *next* second's
    // value over one second so the bar drains continuously, not in jumps.
    final target =
        (secondsLeft - 1).clamp(0, kAutoStopCountdownSeconds) /
        kAutoStopCountdownSeconds;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 36,
        color: SpeakrColors.ink,
        child: Stack(
          children: [
            Positioned.fill(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 1.0, end: target),
                duration: const Duration(seconds: 1),
                builder: (context, value, _) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: const ColoredBox(color: Color(0x1FFFFFFF)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 4, 0),
              child: _content(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PillDrag(
          onDragStart: onDragStart,
          child: SizedBox(
            width: 138,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr("Meeting ended"),
                  style: SpeakrText.sans(
                    size: 12,
                    weight: FontWeight.w600,
                    color: SpeakrColors.bg,
                  ),
                ),
                Text(
                  secondsLeft > 0
                      ? tr("Stopping in {0}s", [secondsLeft])
                      : tr("Stopping…"),
                  style:
                      SpeakrText.mono(
                        size: 10,
                        color: SpeakrColors.bg.withValues(alpha: 0.6),
                      ).copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: const Color(0x29FFFFFF), // ~16% white — primary
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: secondsLeft > 0 ? () => onResume() : null,
            child: SizedBox(
              height: 28,
              width: 74,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SpeakrIconView(
                    SpeakrIcon.play,
                    size: 10,
                    color: SpeakrColors.bg,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tr("Resume"),
                    style: SpeakrText.sans(
                      size: 12,
                      weight: FontWeight.w600,
                      color: SpeakrColors.bg,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Left cluster of the pill: pulsing dot + mono timer in the normal
/// state, swapped for a single "Discard?" label when the user has armed
/// the trash button. Both states render in the same fixed-width slot so
/// the pill's overall length never reflows.
class _LeftCluster extends StatelessWidget {
  const _LeftCluster({
    required this.armed,
    required this.paused,
    required this.timerText,
  });

  final bool armed;
  final bool paused;
  final String timerText;

  // 6 (dot) + 9 (gap) + 56 (timer slot) = 71 px
  static const double _slotWidth = 71;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return SizedBox(
      width: _slotWidth,
      child: armed
          ? Align(
              alignment: Alignment.centerLeft,
              child: Text(
                tr("Discard?"),
                style: SpeakrText.sans(
                  size: 12,
                  weight: FontWeight.w600,
                  color: SpeakrColors.recordingDot,
                ),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PulsingDot(paused: paused),
                const SizedBox(width: 9),
                SizedBox(
                  width: 56,
                  child: Text(
                    timerText,
                    textAlign: TextAlign.left,
                    style:
                        SpeakrText.mono(
                          size: 11,
                          color: paused
                              ? SpeakrColors.bg.withValues(alpha: 0.55)
                              : SpeakrColors.bg,
                          letterSpacing: 0.4,
                        ).copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// 1 × 16 px white-at-14 % vertical hairline used between the timer
/// cluster and the control cluster.
class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Container(width: 1, height: 16, color: const Color(0x24FFFFFF));
  }
}

/// Pulsing recording dot: 6 px circle, orange while recording (fades
/// 1.0 ↔ 0.35 every 1.4 s), grey and static while paused.
class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.paused});
  final bool paused;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  late final Animation<double> _opacity = Tween(
    begin: 1.0,
    end: 0.35,
  ).animate(_ctrl);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    if (widget.paused) {
      return Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: SpeakrColors.muted,
          shape: BoxShape.circle,
        ),
      );
    }
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: SpeakrColors.recordingDot,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// 26 px circular button used on the dark pill. [background] is the
/// inner fill (e.g. 8 % white for ghost, orange for stop). [onTap] = null
/// renders the button at half-opacity and disables interaction.
///
/// Tooltips are intentionally omitted: the OS window is only 40 px tall,
/// so Flutter's tooltip layer would always render outside the visible
/// surface and get clipped.
class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.background,
    required this.onTap,
    required this.child,
  });

  final Color background;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Material(
        color: background,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(width: 26, height: 26, child: Center(child: child)),
        ),
      ),
    );
  }
}

/// Wraps a non-button pill piece (dot, timer, hairline) so pressing it
/// initiates a Windows window-move on the mini HWND.
class _PillDrag extends StatelessWidget {
  const _PillDrag({required this.onDragStart, required this.child});
  final Future<void> Function() onDragStart;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return MouseRegion(
      cursor: SystemMouseCursors.move,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          if (event.buttons == kPrimaryMouseButton) {
            onDragStart();
          }
        },
        child: child,
      ),
    );
  }
}
