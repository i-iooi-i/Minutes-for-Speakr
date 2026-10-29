import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/tokens.dart';

const mimioMenuConstraints = BoxConstraints(minWidth: 224, maxWidth: 224);

/// One menu surface and alignment contract for all product actions/selectors.
class MimioMenuButton<T> extends PopupMenuButton<T> {
  const MimioMenuButton({
    super.key,
    required super.itemBuilder,
    super.onSelected,
    super.tooltip,
    super.enabled,
    super.child,
    super.icon,
    super.color,
    super.surfaceTintColor,
    super.elevation,
    super.shadowColor,
    super.shape,
    super.borderRadius = SpeakrRadius.control,
    super.clipBehavior = Clip.antiAlias,
    super.style = const ButtonStyle(
      shape: WidgetStatePropertyAll(CircleBorder()),
    ),
    super.position = PopupMenuPosition.under,
    super.offset = const Offset(0, 6),
    super.constraints = mimioMenuConstraints,
  });
}

class MimioSelectOption<T> {
  const MimioSelectOption({required this.value, required this.label});
  final T value;
  final String label;
}

/// Shared selector: same popup, selected check, keyboard and dismissal behavior
/// as action menus. Labels are localized by the caller; server data stays intact.
class MimioSelect<T> extends StatelessWidget {
  const MimioSelect({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.placeholder = '',
    this.icon = Icons.tune_rounded,
    this.minWidth = 100,
    this.expanded = false,
    this.tooltip,
  });
  final T? value;
  final List<MimioSelectOption<T>> options;
  final ValueChanged<T> onChanged;
  final String placeholder;
  final IconData icon;
  final double minWidth;
  final bool expanded;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final selected = options.where((o) => o.value == value).firstOrNull;
    final label = Text(
      selected?.label ?? placeholder,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: SpeakrText.sans(size: 13, color: SpeakrColors.ink),
    );
    return MimioMenuButton<T>(
      tooltip: tooltip,
      onSelected: onChanged,
      itemBuilder: (_) => [
        for (final o in options)
          MimioMenuItem<T>(
            value: o.value,
            label: o.label,
            icon: icon,
            selected: o.value == value,
          ),
      ],
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: minWidth, minHeight: 40),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (expanded) Expanded(child: label) else Flexible(child: label),
              const SizedBox(width: 8),
              Icon(
                Icons.expand_more_rounded,
                size: 18,
                color: SpeakrColors.ink2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MimioMenuItem<T> extends PopupMenuItem<T> {
  MimioMenuItem({
    super.key,
    required super.value,
    required String label,
    required IconData icon,
    bool selected = false,
    bool danger = false,
    Color? iconColor,
  }) : super(
         height: 40,
         padding: const EdgeInsets.symmetric(horizontal: 12),
         child: Row(
           children: [
             Icon(
               icon,
               size: 18,
               color: danger
                   ? SpeakrColors.danger
                   : iconColor ?? SpeakrColors.ink2,
             ),
             const SizedBox(width: 12),
             Expanded(
               child: Text(
                 label,
                 maxLines: 1,
                 overflow: TextOverflow.ellipsis,
                 style: SpeakrText.sans(
                   size: 13,
                   color: danger ? SpeakrColors.danger : SpeakrColors.ink,
                 ),
               ),
             ),
             const SizedBox(width: 8),
             SizedBox(
               width: 18,
               child: selected
                   ? Icon(
                       Icons.check_rounded,
                       size: 18,
                       color: SpeakrColors.ink,
                     )
                   : null,
             ),
           ],
         ),
       );
}

class MimioMenuDivider<T> extends PopupMenuItem<T> {
  MimioMenuDivider({super.key})
    : super(
        enabled: false,
        height: 12,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Divider(height: 1, thickness: 1, color: SpeakrColors.line),
      );
}
