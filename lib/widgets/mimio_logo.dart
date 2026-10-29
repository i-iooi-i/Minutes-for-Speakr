import 'package:flutter/material.dart';

import '../theme/appearance.dart';
import '../theme/colors.dart';

/// Resolution-independent wordmark; the small audio stroke shares the UI accent.
class MimioLogo extends StatelessWidget {
  const MimioLogo({super.key, this.compact = false, this.height = 32});

  final bool compact;
  final double height;

  @override
  Widget build(BuildContext context) {
    AppearanceScope.watch(context);
    return Semantics(
      label: 'Mimio',
      image: true,
      child: SizedBox(
        width: height * (compact ? 98 : 310) / 84,
        height: height,
        child: CustomPaint(
          painter: MimioLogoPainter(
            ink: SpeakrColors.ink,
            accent: SpeakrColors.accent,
            compact: compact,
          ),
        ),
      ),
    );
  }
}

class MimioLogoPainter extends CustomPainter {
  const MimioLogoPainter({
    required this.ink,
    required this.accent,
    this.compact = false,
  });

  final Color ink;
  final Color accent;
  final bool compact;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / (compact ? 98 : 310), size.height / 84);
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 19
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(10, 74)
        ..lineTo(10, 31)
        ..cubicTo(10, 13, 24, 10, 35, 21)
        ..lineTo(49, 35)
        ..lineTo(63, 21)
        ..cubicTo(74, 10, 88, 13, 88, 31)
        ..lineTo(88, 74),
      stroke,
    );
    canvas.drawLine(
      const Offset(49, 55),
      const Offset(49, 75),
      Paint()
        ..color = accent
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round,
    );
    if (!compact) {
      stroke.strokeWidth = 16;
      final fill = Paint()..color = ink;
      for (final x in [116.0, 232.0]) {
        canvas.drawCircle(Offset(x, 10), 9.5, fill);
        canvas.drawLine(Offset(x, 34), Offset(x, 75), stroke);
      }
      canvas.drawPath(
        Path()
          ..moveTo(141, 75)
          ..lineTo(141, 49)
          ..cubicTo(141, 26, 175, 26, 175, 49)
          ..lineTo(175, 75)
          ..moveTo(175, 49)
          ..cubicTo(175, 26, 209, 26, 209, 49)
          ..lineTo(209, 75),
        stroke,
      );
      canvas.drawOval(const Rect.fromLTWH(255, 33, 47, 42), stroke);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(MimioLogoPainter oldDelegate) =>
      ink != oldDelegate.ink ||
      accent != oldDelegate.accent ||
      compact != oldDelegate.compact;
}
