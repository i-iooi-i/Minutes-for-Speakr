import 'package:flutter/material.dart';

import '../api/models.dart';
import '../theme/colors.dart';
import '../theme/appearance.dart';
import '../theme/typography.dart';

class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.tag, this.filled = false});
  final Tag tag;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    AppearanceScope.watch(context);
    final c = parseHexColor(tag.color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        color: filled ? c.withValues(alpha: 0.06) : null,
        border: Border.all(color: c.withValues(alpha: 0.33)),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        tag.name.toUpperCase(),
        style: SpeakrText.mono(size: 10, color: _tagInk(c), letterSpacing: 1),
      ),
    );
  }
}

class CustomColorTagChip extends StatelessWidget {
  const CustomColorTagChip({
    super.key,
    required this.label,
    required this.color,
    this.filled = false,
    this.trailing,
    this.onTap,
  });
  final String label;
  final Color color;
  final bool filled;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    AppearanceScope.watch(context);
    final inner = Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.06) : null,
        border: Border.all(color: color.withValues(alpha: 0.33)),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: SpeakrText.sans(size: 11, color: _tagInk(color)),
          ),
          if (trailing != null) const SizedBox(width: 5),
          if (trailing != null) trailing!,
        ],
      ),
    );
    return onTap == null
        ? inner
        : InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(100),
            child: inner,
          );
  }
}

class DashedTagChip extends StatelessWidget {
  const DashedTagChip({
    super.key,
    required this.label,
    required this.color,
    this.onTap,
  });
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    AppearanceScope.watch(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: CustomPaint(
        painter: _DashedBorderPainter(color: color.withValues(alpha: 0.33)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          child: Text(
            '+ ${label.toUpperCase()}',
            style: SpeakrText.sans(size: 11, color: _tagInk(color)),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const dash = 3.0;
    const gap = 2.0;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      Radius.circular(size.height / 2),
    );
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();
    for (final m in metrics) {
      var d = 0.0;
      while (d < m.length) {
        final next = d + dash;
        canvas.drawPath(
          m.extractPath(d, next.clamp(0, m.length).toDouble()),
          paint,
        );
        d = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) => old.color != color;
}

// Keep category hues while ensuring readable text on either theme.
Color _tagInk(Color source) {
  var result = source;
  final background = SpeakrColors.bgAlt.computeLuminance();
  for (var i = 0; i < 24; i++) {
    final l = result.computeLuminance();
    final ratio =
        (l > background ? l + .05 : background + .05) /
        (l > background ? background + .05 : l + .05);
    if (ratio >= 4.5) break;
    result = Color.lerp(
      result,
      appAppearance.brightness == Brightness.dark ? Colors.white : Colors.black,
      .08,
    )!;
  }
  return result;
}
