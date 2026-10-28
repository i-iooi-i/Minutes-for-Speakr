import 'package:speakr_app/l10n/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../theme/colors.dart';
import '../../../theme/typography.dart';
import '../../../widgets/mono_eyebrow.dart';
import '../live_controller.dart';

/// Whether the global discard-recording confirmation sheet is currently
/// armed. Flipped true from any "discard" entry point (the persistent
/// recording bar, the mobile `/live` page, the desktop `/live` page);
/// the [DiscardOverlay] mounted in `RecordingMiniPlayer` watches this
/// and renders the scrim + sheet on top of everything — including the
/// persistent bar itself, which is otherwise the topmost layer.
final discardArmedProvider = StateProvider<bool>((ref) => false);

/// App-level host for the discard confirmation sheet. Mounted once
/// inside `RecordingMiniPlayer`'s Stack, drawn after the bar so the
/// scrim + sheet sit above the bar visually. Animates the sheet up
/// from the bottom and fades a scrim in. Auto-dismisses if the
/// underlying recording ends while armed.
class DiscardOverlay extends ConsumerWidget {
  const DiscardOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    // If the recording stops (e.g. via the controller from elsewhere)
    // while the sheet is armed, drop the armed flag so the overlay
    // animates back out cleanly.
    ref.listen(recordingControllerProvider, (prev, next) {
      final stillActive = next.started || next.uploading;
      if (!stillActive && ref.read(discardArmedProvider)) {
        ref.read(discardArmedProvider.notifier).state = false;
      }
    });

    final armed = ref.watch(discardArmedProvider);
    void dismiss() => ref.read(discardArmedProvider.notifier).state = false;

    return IgnorePointer(
      ignoring: !armed,
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: armed ? 1.0 : 0.0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: dismiss,
                child: Container(color: const Color(0x73141210)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              offset: armed ? Offset.zero : const Offset(0, 1),
              // Fade as well as slide: the sheet's upward shadow would
              // otherwise peek above the bottom edge while it's parked.
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 240),
                opacity: armed ? 1.0 : 0.0,
                child: SafeArea(
                  top: false,
                  // Cap the sheet's width on desktop / tablet so it doesn't
                  // stretch edge-to-edge across a wide window.
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: const DiscardSheet(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom-sheet body for confirming discard of an in-progress
/// recording. Reads `formattedElapsed` from [recordingControllerProvider]
/// directly so the timer ticks while the sheet is visible. Normally
/// rendered by [DiscardOverlay]; not instantiated directly.
class DiscardSheet extends ConsumerWidget {
  const DiscardSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    final elapsed = ref.watch(
      recordingControllerProvider.select((s) => s.formattedElapsed),
    );

    void dismiss() => ref.read(discardArmedProvider.notifier).state = false;

    Future<void> confirmDiscard() async {
      dismiss();
      // Auto-record coordinator listens to controller state and tears
      // its own session down when `cancel()` empties the recording.
      await ref.read(recordingControllerProvider.notifier).cancel();
    }

    // Without a Material ancestor, Flutter paints yellow debug
    // underlines beneath every Text. `showModalBottomSheet` provided
    // one for free; our inline overlay doesn't, so wrap explicitly.
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: SpeakrColors.bg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
          ),
          border: Border(top: BorderSide(color: SpeakrColors.line)),
          boxShadow: [
            BoxShadow(
              color: Color(0x2E000000),
              blurRadius: 40,
              offset: Offset(0, -12),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 3,
                decoration: BoxDecoration(
                  color: SpeakrColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: MonoEyebrow(
                tr("Discard recording"),
                size: 9,
                color: SpeakrColors.danger,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tr("Throw away {0} of audio?", [elapsed]),
              textAlign: TextAlign.center,
              style: SpeakrText.serif(size: 22, height: 1.25),
            ),
            const SizedBox(height: 8),
            Text(
              tr(
                "This recording will be permanently deleted. It won't be transcribed or saved to your library.",
              ),
              textAlign: TextAlign.center,
              style: SpeakrText.sans(
                size: 13,
                color: SpeakrColors.muted,
                height: 1.45,
              ).copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: confirmDiscard,
              child: Container(
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: SpeakrColors.danger,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  tr("Discard recording").toUpperCase(),
                  style: SpeakrText.mono(
                    size: 11,
                    color: SpeakrColors.bg,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: dismiss,
              child: Container(
                height: 44,
                alignment: Alignment.center,
                color: Colors.transparent,
                child: Text(
                  tr("Keep recording").toUpperCase(),
                  style: SpeakrText.mono(
                    size: 11,
                    color: SpeakrColors.ink,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
