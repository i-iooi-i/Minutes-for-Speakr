import 'package:flutter/material.dart';
import '../../theme/colors.dart';

/// Names come from recording metadata; colors are stable local presentation.
class ParticipantAvatars extends StatelessWidget {
  const ParticipantAvatars({super.key, required this.participants});
  final String participants;
  @override
  Widget build(BuildContext context) {
    final names = participants
        .split(RegExp(r'[,，;；、\n]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    const palette = [
      SpeakrColors.accent,
      SpeakrColors.tagCustomer,
      SpeakrColors.tagDesign,
      SpeakrColors.tag1on1,
      SpeakrColors.tagPersonal,
    ];
    final visible = names.take(3).toList();
    return Tooltip(
      message: names.join('、'),
      child: SizedBox(
        width: visible.length * 20.0 + 10 + (names.length > 3 ? 24 : 0),
        height: 30,
        child: Stack(
          children: [
            for (var i = 0; i < visible.length; i++)
              Positioned(
                left: i * 20.0,
                child: Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        palette[visible[i].runes.fold<int>(0, (a, b) => a + b) %
                            palette.length],
                    border: Border.all(color: SpeakrColors.surface, width: 2),
                  ),
                  child: Text(
                    visible[i].characters.first.toUpperCase(),
                    style: const TextStyle(
                      color: SpeakrColors.bg,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            if (names.length > 3)
              Positioned(
                right: 0,
                top: 6,
                child: Text(
                  '+${names.length - 3}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: SpeakrColors.muted,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
