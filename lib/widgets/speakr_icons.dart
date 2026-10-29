// Stroke icons ported from `AIcon` in direction-a-1.jsx (lines 19-31).
// Implemented as CustomPainters so they pick up `currentColor` from the
// IconTheme exactly like the SVGs in the React mock.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/colors.dart';

enum SpeakrIcon {
  back,
  search,
  more,
  plus,
  mic,
  star,
  send,
  pause,
  stop,
  flag,
  chev,
  close,
  play,
  flagBookmark,
  settings,
  minimize,
  trash,
  pip,
  refresh,
  filter,
  speaker,
  expand,
}

class SpeakrIconView extends StatelessWidget {
  const SpeakrIconView(this.icon, {super.key, this.size = 20, this.color});
  final SpeakrIcon icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? SpeakrColors.ink;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _IconPainter(icon, c)),
    );
  }
}

class _IconPainter extends CustomPainter {
  _IconPainter(this.icon, this.color);
  final SpeakrIcon icon;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Paint at a 20×20 grid then scale.
    final s = size.width / 20.0;
    canvas.scale(s);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color;

    switch (icon) {
      case SpeakrIcon.back:
        final p = Path()
          ..moveTo(12.5, 4)
          ..lineTo(6.5, 10)
          ..lineTo(12.5, 16);
        canvas.drawPath(p, stroke);
        break;
      case SpeakrIcon.search:
        canvas.drawCircle(const Offset(9, 9), 5.5, stroke);
        canvas.drawLine(const Offset(13, 13), const Offset(16.5, 16.5), stroke);
        break;
      case SpeakrIcon.more:
        canvas.drawCircle(const Offset(4.5, 10), 1.2, fill);
        canvas.drawCircle(const Offset(10, 10), 1.2, fill);
        canvas.drawCircle(const Offset(15.5, 10), 1.2, fill);
        break;
      case SpeakrIcon.plus:
        canvas.drawLine(const Offset(10, 4), const Offset(10, 16), stroke);
        canvas.drawLine(const Offset(4, 10), const Offset(16, 10), stroke);
        break;
      case SpeakrIcon.mic:
        final body = RRect.fromRectAndRadius(
          const Rect.fromLTWH(7.5, 3, 5, 9),
          const Radius.circular(2.5),
        );
        canvas.drawRRect(body, stroke);
        final arc = Path()
          ..moveTo(4.5, 9.5)
          ..arcToPoint(
            const Offset(15.5, 9.5),
            radius: const Radius.circular(5.5),
            largeArc: false,
            clockwise: false,
          );
        canvas.drawPath(arc, stroke);
        canvas.drawLine(const Offset(10, 15), const Offset(10, 17.5), stroke);
        break;
      case SpeakrIcon.star:
        final p = Path()
          ..moveTo(10, 1.5)
          ..lineTo(12.6, 7.2)
          ..lineTo(18.5, 7.8)
          ..lineTo(13.9, 11.8)
          ..lineTo(15.4, 17.6)
          ..lineTo(10, 14.6)
          ..lineTo(4.6, 17.6)
          ..lineTo(6.1, 11.8)
          ..lineTo(1.5, 7.8)
          ..lineTo(7.4, 7.2)
          ..close();
        canvas.drawPath(p, fill);
        break;
      case SpeakrIcon.send:
        final p = Path()
          ..moveTo(2.5, 10)
          ..lineTo(17, 3.3)
          ..lineTo(13.7, 17.3)
          ..lineTo(9.7, 11.7)
          ..close();
        canvas.drawPath(p, stroke);
        break;
      case SpeakrIcon.pause:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(5.5, 4.5, 3.2, 11),
            const Radius.circular(1),
          ),
          fill,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(11.4, 4.5, 3.2, 11),
            const Radius.circular(1),
          ),
          fill,
        );
        break;
      case SpeakrIcon.stop:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(5.5, 5.5, 9, 9),
            const Radius.circular(1.5),
          ),
          fill,
        );
        break;
      case SpeakrIcon.flag:
      case SpeakrIcon.flagBookmark:
        canvas.drawLine(const Offset(5, 3), const Offset(5, 17), stroke);
        final p = Path()
          ..moveTo(5, 4)
          ..lineTo(14, 4)
          ..lineTo(12, 7)
          ..lineTo(14, 10)
          ..lineTo(5, 10);
        canvas.drawPath(p, stroke);
        break;
      case SpeakrIcon.chev:
        final p = Path()
          ..moveTo(7.5, 5)
          ..lineTo(12.5, 10)
          ..lineTo(7.5, 15);
        canvas.drawPath(p, stroke);
        break;
      case SpeakrIcon.close:
        canvas.drawLine(const Offset(5, 5), const Offset(15, 15), stroke);
        canvas.drawLine(const Offset(15, 5), const Offset(5, 15), stroke);
        break;
      case SpeakrIcon.play:
        final p = Path()
          ..moveTo(6, 4)
          ..lineTo(16, 10)
          ..lineTo(6, 16)
          ..close();
        canvas.drawPath(p, fill);
        break;
      case SpeakrIcon.settings:
        const cx = 10.0;
        const cy = 10.0;
        const outerR = 7.6;
        const innerR = 5.4;
        const teeth = 8;
        const period = (math.pi * 2) / teeth;
        const halfTooth = period / 4;
        Offset at(double r, double a) =>
            Offset(cx + r * math.cos(a), cy + r * math.sin(a));
        final cog = Path();
        for (var i = 0; i < teeth; i++) {
          final base = i * period;
          final a1 = base - halfTooth;
          final a2 = base + halfTooth;
          final a3 = base + period - halfTooth;
          if (i == 0) {
            final start = at(outerR, a1);
            cog.moveTo(start.dx, start.dy);
          }
          final outerEnd = at(outerR, a2);
          cog.arcToPoint(
            outerEnd,
            radius: const Radius.circular(outerR),
            clockwise: true,
          );
          final innerStart = at(innerR, a2);
          cog.lineTo(innerStart.dx, innerStart.dy);
          final innerEnd = at(innerR, a3);
          cog.arcToPoint(
            innerEnd,
            radius: const Radius.circular(innerR),
            clockwise: true,
          );
          final nextOuter = at(outerR, a3);
          cog.lineTo(nextOuter.dx, nextOuter.dy);
        }
        cog.close();
        canvas.drawPath(cog, stroke);
        canvas.drawCircle(const Offset(cx, cy), 2.0, stroke);
        break;
      case SpeakrIcon.minimize:
        // Chevron pointing down — communicates "collapse to bottom".
        final p = Path()
          ..moveTo(5, 8)
          ..lineTo(10, 13)
          ..lineTo(15, 8);
        canvas.drawPath(p, stroke);
        break;
      case SpeakrIcon.pip:
        // Outer screen frame.
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(3, 5, 14, 11),
            const Radius.circular(1.5),
          ),
          stroke,
        );
        // Small inset rectangle in the top-right corner — mirrors where
        // the mini-window actually docks on screen.
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(10.5, 7, 5, 3.5),
            const Radius.circular(0.8),
          ),
          fill,
        );
        break;
      case SpeakrIcon.refresh:
        // Open arc with a chevron arrowhead at one end — classic refresh glyph.
        const cx = 10.0;
        const cy = 10.0;
        const r = 6.0;
        final startAngle = -math.pi / 2 + 0.35;
        const sweep = math.pi * 1.7;
        canvas.drawArc(
          Rect.fromCircle(center: const Offset(cx, cy), radius: r),
          startAngle,
          sweep,
          false,
          stroke,
        );
        final sx = cx + r * math.cos(startAngle);
        final sy = cy + r * math.sin(startAngle);
        // Tangent backward from the start (points toward the gap), and radial outward.
        final tBackX = math.sin(startAngle);
        final tBackY = -math.cos(startAngle);
        final radX = math.cos(startAngle);
        final radY = math.sin(startAngle);
        const ah = 2.6;
        final tip = Offset(sx + tBackX * ah, sy + tBackY * ah);
        final wingOuter = Offset(sx + radX * ah * 0.55, sy + radY * ah * 0.55);
        final wingInner = Offset(sx - radX * ah * 0.55, sy - radY * ah * 0.55);
        canvas.drawLine(tip, wingOuter, stroke);
        canvas.drawLine(tip, wingInner, stroke);
        break;
      case SpeakrIcon.filter:
        // Three stacked horizontal lines that taper toward the bottom — the
        // funnel glyph from the design (`M1.5 3h10M3 6.5h7M5 10h3`, scaled
        // from a 13×13 viewBox to the 20×20 painter grid).
        const k = 20.0 / 13.0;
        final funnel = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4 * k
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          Offset(1.5 * k, 3 * k),
          Offset(11.5 * k, 3 * k),
          funnel,
        );
        canvas.drawLine(
          Offset(3 * k, 6.5 * k),
          Offset(10 * k, 6.5 * k),
          funnel,
        );
        canvas.drawLine(Offset(5 * k, 10 * k), Offset(8 * k, 10 * k), funnel);
        break;
      case SpeakrIcon.speaker:
        // Speaker box with two sound waves on the right — represents
        // system / loopback audio capture.
        final box = Path()
          ..moveTo(3.5, 8)
          ..lineTo(6.5, 8)
          ..lineTo(10, 4.5)
          ..lineTo(10, 15.5)
          ..lineTo(6.5, 12)
          ..lineTo(3.5, 12)
          ..close();
        canvas.drawPath(box, stroke);
        // Two arcs to the right of the box.
        final wave1 = Path()
          ..moveTo(12.5, 7.5)
          ..arcToPoint(
            const Offset(12.5, 12.5),
            radius: const Radius.circular(2.8),
            largeArc: false,
            clockwise: true,
          );
        canvas.drawPath(wave1, stroke);
        final wave2 = Path()
          ..moveTo(14.6, 5.5)
          ..arcToPoint(
            const Offset(14.6, 14.5),
            radius: const Radius.circular(5.0),
            largeArc: false,
            clockwise: true,
          );
        canvas.drawPath(wave2, stroke);
        break;
      case SpeakrIcon.expand:
        // Diagonal arrows pointing outward — "open larger window".
        // Paths from mini-window.jsx:130-134 on a 16×16 viewBox, scaled to 20×20.
        // Top-right corner: M9 2 h5 v5 + diagonal M14 2 l-5 5
        final tr = Path()
          ..moveTo(11.25, 2.5)
          ..lineTo(17.5, 2.5)
          ..lineTo(17.5, 8.75);
        canvas.drawPath(tr, stroke);
        canvas.drawLine(
          const Offset(17.5, 2.5),
          const Offset(11.25, 8.75),
          stroke,
        );
        // Bottom-left corner: M7 14 H2 V9 + diagonal M2 14 l5 -5
        final bl = Path()
          ..moveTo(8.75, 17.5)
          ..lineTo(2.5, 17.5)
          ..lineTo(2.5, 11.25);
        canvas.drawPath(bl, stroke);
        canvas.drawLine(
          const Offset(2.5, 17.5),
          const Offset(8.75, 11.25),
          stroke,
        );
        break;
      case SpeakrIcon.trash:
        // Lid
        canvas.drawLine(
          const Offset(3.5, 5.5),
          const Offset(16.5, 5.5),
          stroke,
        );
        // Handle on lid
        final handle = Path()
          ..moveTo(8, 5.5)
          ..lineTo(8, 3.5)
          ..lineTo(12, 3.5)
          ..lineTo(12, 5.5);
        canvas.drawPath(handle, stroke);
        // Bin body
        final bin = Path()
          ..moveTo(5.5, 5.5)
          ..lineTo(6.3, 16.5)
          ..lineTo(13.7, 16.5)
          ..lineTo(14.5, 5.5);
        canvas.drawPath(bin, stroke);
        // Inner ribs
        canvas.drawLine(const Offset(8.5, 8.5), const Offset(8.5, 14), stroke);
        canvas.drawLine(
          const Offset(11.5, 8.5),
          const Offset(11.5, 14),
          stroke,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _IconPainter old) =>
      old.icon != icon || old.color != color;
}

/// 36×36 ghost icon button used throughout the design (`iconBtn` in JSX).
class GhostIconButton extends StatelessWidget {
  const GhostIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 20,
  });
  final SpeakrIcon icon;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Center(child: SpeakrIconView(icon, size: size)),
      ),
    );
  }
}
