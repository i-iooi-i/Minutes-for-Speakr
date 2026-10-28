import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// Static horizontal waveform used in the desktop detail player. Bars are
/// pseudo-randomly tall (deterministic, seeded) with an envelope that swells
/// in the middle. Bars before [progress] are drawn at full opacity, the rest
/// muted. Tappable: passes a 0..1 fraction back to [onSeek].
class DesktopWave extends StatelessWidget {
  const DesktopWave({
    super.key,
    this.progress = 0,
    this.seed = 7,
    this.height = 48,
    this.color = SpeakrColors.ink,
    this.onSeek,
  });

  final double progress;
  final int seed;
  final double height;
  final Color color;
  final ValueChanged<double>? onSeek;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wave = SizedBox(
          width: c.maxWidth,
          height: height,
          child: CustomPaint(
            painter: _WavePainter(progress: progress, seed: seed, color: color),
          ),
        );
        if (onSeek == null) return wave;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) =>
              onSeek!((d.localPosition.dx / c.maxWidth).clamp(0.0, 1.0)),
          onHorizontalDragUpdate: (d) =>
              onSeek!((d.localPosition.dx / c.maxWidth).clamp(0.0, 1.0)),
          child: wave,
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({
    required this.progress,
    required this.seed,
    required this.color,
  });
  final double progress;
  final int seed;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final bars = (size.width / 5).floor().clamp(12, 220);
    final w = size.width;
    final h = size.height;
    final bw = w / (bars * 1.7);
    final gap = bw * 0.7;
    final p = Paint()..color = color;

    for (var i = 0; i < bars; i++) {
      final r = _seedRand(i + seed * 100);
      final env = 0.4 + 0.6 * math.sin((i / bars) * math.pi);
      final hRatio = (0.15 + r * 0.85) * env;
      final bh = hRatio * h;
      final x = i * (bw + gap);
      final y = (h - bh) / 2;
      final past = (i / bars) < progress;
      p.color = past ? SpeakrColors.accent : color.withValues(alpha: 0.32);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, bw, bh),
          Radius.circular(bw / 2),
        ),
        p,
      );
    }
  }

  double _seedRand(int i) {
    final x = math.sin(i * 12.9898 + 78.233) * 43758.5453;
    return x - x.floorToDouble();
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.seed != seed ||
      oldDelegate.color != color;
}
