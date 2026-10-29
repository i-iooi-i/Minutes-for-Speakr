import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/colors.dart';

class SpeakrLogo extends StatelessWidget {
  const SpeakrLogo({super.key, this.size = 24, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'speakr-mark-square.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color ?? SpeakrColors.ink, BlendMode.srcIn),
    );
  }
}
