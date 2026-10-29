import 'package:speakr_app/theme/appearance.dart';
import '../l10n/strings.dart';
import 'package:flutter/material.dart';

import '../api/models.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

/// Pill with a pulsing red dot used in the Library list for non-completed
/// recordings (matches direction-a-2.jsx lines 102-110).
class StatusBadge extends StatefulWidget {
  const StatusBadge({super.key, required this.status});
  final RecordingStatus status;

  @override
  State<StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<StatusBadge>
    with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    final inProgress = widget.status.isInProgress;
    if (inProgress) {
      _ctrl ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      )..repeat(reverse: true);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: SpeakrColors.line),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (inProgress)
            FadeTransition(
              opacity: Tween(begin: 1.0, end: 0.3).animate(_ctrl!),
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: SpeakrColors.recordingDot,
                  shape: BoxShape.circle,
                ),
              ),
            )
          else
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: widget.status == RecordingStatus.failed
                    ? SpeakrColors.danger
                    : SpeakrColors.ok,
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 6),
          Text(
            widget.status.displayLabel.toLowerCase(),
            style: SpeakrText.mono(size: 10, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}
