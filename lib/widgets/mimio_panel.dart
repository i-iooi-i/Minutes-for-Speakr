import 'package:flutter/material.dart';
import '../theme/appearance.dart';
import '../theme/colors.dart';

/// Paint the outline after opaque child surfaces so curved corners stay intact.
class MimioPanel extends StatelessWidget {
  const MimioPanel({
    super.key,
    required this.child,
    this.radius = 12,
    this.margin,
  });
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? margin;
  @override
  Widget build(BuildContext context) {
    AppearanceScope.watch(context);
    final corners = BorderRadius.circular(radius);
    return Container(
      margin: margin,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: SpeakrColors.surface,
        borderRadius: corners,
      ),
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: SpeakrColors.line),
        borderRadius: corners,
      ),
      child: child,
    );
  }
}
