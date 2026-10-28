import 'package:speakr_app/l10n/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/live/live_controller.dart';
import '../features/live/recording_state.dart';
import '../features/live/widgets/discard_sheet.dart';
import '../routing/router.dart' show routerProvider;
import '../services/auto_record/auto_record_bootstrap.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'mono_eyebrow.dart';
import 'speakr_icons.dart';

/// Spotify-style mini-player pinned at the bottom of every screen while a
/// recording is active. Tapping the timer/eyebrow region re-opens `/live`;
/// the four trailing buttons (discard, pause, stop, expand) are siblings
/// of the tap target and handle their own actions. Hidden on `/live`
/// itself (the full UI is already visible there).
///
/// Visual language mirrors the Windows always-on-top mini pill:
/// `SpeakrColors.ink` pill with rounded corners, 6 px pulsing dot, mono
/// timer with tabular figures, hairline dividers, and stratified button
/// fills (ghost 8 % white, 16 % white, orange stop).
class RecordingMiniPlayer extends ConsumerWidget {
  const RecordingMiniPlayer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    final state = ref.watch(recordingControllerProvider);
    final coord = ref.watch(autoRecordCoordinatorProvider);
    final isRecording = state.started || state.uploading;
    // We sit above the router in the widget tree (MaterialApp.router
    // builder), so `GoRouter.of(context)` and `GoRouterState.of(context)`
    // are not available. Read the router via Riverpod and listen to the
    // delegate (a ChangeNotifier that fires on push/pop/go) to track the
    // current top-of-stack route.
    final router = ref.watch(routerProvider);
    final delegate = router.routerDelegate;

    return Stack(
      children: [
        Positioned.fill(child: child),
        ListenableBuilder(
          listenable: delegate,
          builder: (context, _) {
            final config = delegate.currentConfiguration;
            final topPath = config.matches.isEmpty
                ? '/'
                : config.matches.last.matchedLocation;
            final onLive = topPath == '/live';
            if (!isRecording || onLive) return const SizedBox.shrink();
            return Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: _Bar(
                  router: router,
                  state: state,
                  isAutoSession: coord?.isAutoSession ?? false,
                  triggerLabel: coord?.activeTriggerLabel,
                ),
              ),
            );
          },
        ),
        // Drawn last so the scrim + sheet sit above the bar.
        const Positioned.fill(child: DiscardOverlay()),
      ],
    );
  }
}

class _Bar extends ConsumerWidget {
  const _Bar({
    required this.router,
    required this.state,
    required this.isAutoSession,
    required this.triggerLabel,
  });

  final GoRouter router;
  final RecordingState state;
  final bool isAutoSession;
  final String? triggerLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    final controller = ref.read(recordingControllerProvider.notifier);
    final coord = ref.read(autoRecordCoordinatorProvider);
    final paused = state.paused;
    final uploading = state.uploading;

    final eyebrow = isAutoSession
        ? tr("AUTO-RECORDING · {0}", [triggerLabel ?? 'Recording'])
        : (paused ? tr("PAUSED") : tr("RECORDING"));

    void handleDiscard() {
      // Arm the global discard provider; the DiscardOverlay mounted in
      // RecordingMiniPlayer renders the scrim + sheet above the bar.
      ref.read(discardArmedProvider.notifier).state = true;
    }

    Future<void> handleStop() async {
      if (uploading) return;
      if (isAutoSession && coord != null) {
        await coord.stopAutoSession();
      } else {
        await controller.stopAndUpload();
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      decoration: BoxDecoration(
        color: SpeakrColors.ink,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 14, 0),
          child: Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => router.go('/live'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          _PulsingDot(paused: paused),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MonoEyebrow(
                                  eyebrow,
                                  size: 9,
                                  color: SpeakrColors.recordingDot,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  state.formattedElapsed,
                                  style:
                                      SpeakrText.mono(
                                        size: 14,
                                        color: paused
                                            ? SpeakrColors.bg.withValues(
                                                alpha: 0.55,
                                              )
                                            : SpeakrColors.bg,
                                        letterSpacing: 0.4,
                                      ).copyWith(
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              const _Hairline(),
              const SizedBox(width: 9),
              _PillButton(
                background: const Color(0x14FFFFFF), // ~8% white — ghost
                onTap: uploading ? null : handleDiscard,
                child: SpeakrIconView(
                  SpeakrIcon.trash,
                  size: 14,
                  color: SpeakrColors.bg.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 9),
              _PillButton(
                background: const Color(0x29FFFFFF), // ~16% white — primary
                onTap: uploading ? null : controller.togglePause,
                child: SpeakrIconView(
                  paused ? SpeakrIcon.play : SpeakrIcon.pause,
                  size: 12,
                  color: SpeakrColors.bg,
                ),
              ),
              const SizedBox(width: 9),
              _PillButton(
                background: SpeakrColors.recordingDot.withValues(alpha: 0.95),
                onTap: uploading ? null : handleStop,
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
              const _Hairline(),
              const SizedBox(width: 9),
              _PillButton(
                background: const Color(0x14FFFFFF),
                onTap: () => router.go('/live'),
                child: SpeakrIconView(
                  SpeakrIcon.expand,
                  size: 13,
                  color: SpeakrColors.bg.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 26 px circular button used on the dark pill. [background] is the inner
/// fill (e.g. 8 % white for ghost, orange for stop). [onTap] = null
/// renders the button at half-opacity and disables interaction. Mirrors
/// the mini window's `_PillButton`.
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

/// 1 × 16 px white-at-24 % vertical hairline matching the mini pill's
/// divider between the timer cluster and the control cluster.
class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Container(width: 1, height: 16, color: const Color(0x3DFFFFFF));
  }
}

/// Pulsing recording dot: 6 px circle, orange while recording (fades
/// 1.0 ↔ 0.35 every 1.4 s), grey and static while paused. Matches the
/// mini window dot exactly.
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
