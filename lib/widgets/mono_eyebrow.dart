import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/appearance.dart';
import '../theme/typography.dart';

class MonoEyebrow extends StatelessWidget {
  const MonoEyebrow(this.text, {super.key, this.color, this.size = 11});

  final String text;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    AppearanceScope.watch(context);
    return Text(
      text.toUpperCase(),
      style: SpeakrText.mono(
        size: size,
        color: color ?? SpeakrColors.muted,
        letterSpacing: 1.5,
      ),
    );
  }
}
