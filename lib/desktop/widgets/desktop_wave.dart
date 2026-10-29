import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/appearance.dart';

/// Illustrative horizontal waveform (not measured audio amplitude) used in the desktop detail player. Bars are
/// pseudo-randomly tall (deterministic, seeded) with an envelope that swells
/// in the middle. Bars before [progress] are drawn at full opacity, the rest
/// muted. Tappable: passes a 0..1 fraction back to [onSeek].
class DesktopWave extends StatefulWidget {
  const DesktopWave({
    super.key,
    this.progress = 0,
    this.playing = false,
    this.seed = 7,
    this.height = 48,
    this.color,
    this.onSeek,
  });

  final bool playing;
  final double progress;
  final int seed;
  final double height;
  final Color? color;
  final ValueChanged<double>? onSeek;

  @override
  State<DesktopWave> createState() => _DesktopWaveState();
}

class _DesktopWaveState extends State<DesktopWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  void _sync() {
    if (widget.playing && !MediaQuery.disableAnimationsOf(context)) {
      if (!_motion.isAnimating) _motion.repeat();
    } else {
      _motion.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(DesktopWave oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppearanceScope.watch(context);
    return LayoutBuilder(
      builder: (context, c) {
        final wave = RepaintBoundary(
          child: SizedBox(
            width: c.maxWidth,
            height: widget.height + (widget.onSeek != null ? 24 : 0),
            child: CustomPaint(
              painter: _WavePainter(
                progress: widget.progress,
                seed: widget.seed,
                color: widget.color ?? SpeakrColors.ink,
                motion: _motion,
                showPlayhead: widget.onSeek != null,
              ),
            ),
          ),
        );
        if (widget.onSeek == null) return wave;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) =>
              widget.onSeek!((d.localPosition.dx / c.maxWidth).clamp(0.0, 1.0)),
          onHorizontalDragUpdate: (d) =>
              widget.onSeek!((d.localPosition.dx / c.maxWidth).clamp(0.0, 1.0)),
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
    required this.motion,
    required this.showPlayhead,
  }) : super(repaint: motion);
  final Color accent = SpeakrColors.accent;
  final bool showPlayhead;
  final Animation<double> motion;
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
      final pulse = motion.value == 0
          ? 1.0
          : 0.7 + 0.3 * math.sin(motion.value * math.pi * 2 + i * 1.7);
      final bh = hRatio * (showPlayhead ? h - 24 : h) * pulse;
      final x = i * (bw + gap);
      final y = (h - bh) / 2;
      final past = (i / bars) < progress;
      p.color = past ? accent : color.withValues(alpha: 0.32);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, bw, bh),
          Radius.circular(bw / 2),
        ),
        p,
      );
    }
    if (showPlayhead) {
      final x = (progress.clamp(0.0, 1.0) * w).clamp(3.0, w - 3.0);
      p
        ..color = accent
        ..strokeWidth = 2;
      canvas.drawLine(Offset(x, 4), Offset(x, h - 1), p);
      canvas.drawCircle(Offset(x, 4), 3, p);
    }
  }

  double _seedRand(int i) {
    final x = math.sin(i * 12.9898 + 78.233) * 43758.5453;
    return x - x.floorToDouble();
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.accent != accent ||
      oldDelegate.progress != progress ||
      oldDelegate.seed != seed ||
      oldDelegate.color != color;
}
