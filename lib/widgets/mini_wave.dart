// Port of `AMiniWave` from direction-a-1.jsx (lines 90-113).
// Seeded random bars with a progress overlay.

import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/appearance.dart';

class MiniWave extends StatelessWidget {
  const MiniWave({
    super.key,
    this.width = 110,
    this.height = 22,
    this.seed = 1,
    this.color,
    this.progress = 0,
    this.bars = 36,
  });

  final double width;
  final double height;
  final int seed;
  final Color? color;
  final double progress;
  final int bars;

  @override
  Widget build(BuildContext context) {
    AppearanceScope.watch(context);
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _MiniWavePainter(
          seed: seed,
          color: color ?? SpeakrColors.ink,
          progress: progress,
          bars: bars,
        ),
      ),
    );
  }
}

class _MiniWavePainter extends CustomPainter {
  _MiniWavePainter({
    required this.seed,
    required this.color,
    required this.progress,
    required this.bars,
  });

  final int seed;
  final Color color;
  final double progress;
  final int bars;

  double _r(int i) {
    // Mirrors the JS hash:  sin(i*12.9898 + seed*78.233)*43758.5453 → fract
    final raw =
        (12.9898 * i + 78.233 * seed) * 43758.5453 + 12.345; // arbitrary salt
    final s = ((raw % 1) - (raw % 1).floor()).abs(); // fractional part
    return s.clamp(0.0, 1.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bw = size.width / (bars * 1.6);
    final gap = bw * 0.6;
    for (var i = 0; i < bars; i++) {
      final h = (0.25 + _r(i) * 0.75) * size.height;
      final x = i * (bw + gap);
      final y = (size.height - h) / 2;
      final past = (i / bars) < progress;
      final paint = Paint()..color = color.withValues(alpha: past ? 1.0 : 0.3);
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, bw, h),
        Radius.circular(bw / 2),
      );
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniWavePainter old) =>
      old.seed != seed ||
      old.color != color ||
      old.progress != progress ||
      old.bars != bars;
}
