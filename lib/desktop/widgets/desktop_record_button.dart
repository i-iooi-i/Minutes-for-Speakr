import 'package:flutter/material.dart';
import '../../l10n/strings.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../shell/desktop_shortcuts.dart';

class DesktopRecordButton extends StatelessWidget {
  const DesktopRecordButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: SpeakrColors.ink,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: SpeakrColors.recordingDot,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 9),
            Text(
              tr("New recording"),
              style: SpeakrText.sans(
                size: 13,
                weight: FontWeight.w500,
                color: SpeakrColors.bg,
                letterSpacing: 0.2,
              ),
            ),
            if (supportsKeyboardShortcuts) ...[
              const SizedBox(width: 8),
              Text(
                '${modLabel}R',
                style: SpeakrText.mono(
                  size: 10,
                  color: SpeakrColors.bg,
                  letterSpacing: 0.5,
                ).copyWith(color: SpeakrColors.bg.withValues(alpha: 0.6)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

