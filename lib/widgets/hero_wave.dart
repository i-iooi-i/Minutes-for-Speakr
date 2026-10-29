// Decorative hero waveform for the Onboarding intro slide.
// Mirrors the SVG built in direction-a-1.jsx lines 158-165.

import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../theme/colors.dart';
import '../theme/appearance.dart';

class HeroWave extends StatelessWidget {
  const HeroWave({
    super.key,
    this.width = 280,
    this.height = 160,
    this.color,
    this.bars = 48,
  });

  final double width;
  final double height;
  final Color? color;
  final int bars;

  @override
  Widget build(BuildContext context) {
    AppearanceScope.watch(context);
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _HeroWavePainter(color: color ?? SpeakrColors.ink, bars: bars),
      ),
    );
  }
}

class _HeroWavePainter extends CustomPainter {
  _HeroWavePainter({required this.color, required this.bars});

  final Color color;
  final int bars;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.85);
    for (var i = 0; i < bars; i++) {
      final h =
          6 + math.sin(i * 0.4 + 1).abs() * (60 + math.sin(i * 0.15) * 40);
      final clamped = h.clamp(6.0, size.height - 6).toDouble();
      final x = i * (size.width / bars) + 4;
      final y = size.height / 2 - clamped / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, 2.5, clamped),
          const Radius.circular(1.25),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HeroWavePainter old) =>
      old.color != color || old.bars != bars;
}
