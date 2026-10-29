import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/speakr_icons.dart';
import '../../widgets/mimio_menu.dart';

/// A small bordered icon button used in the desktop header toolbars
/// (refresh, copy, etc.). 30 × 30 with a 1 px line border.
class DesktopToolButton extends StatelessWidget {
  const DesktopToolButton({
    super.key,
    required this.icon,
    this.tooltip,
    required this.onTap,
    this.selected = false,
  });

  final SpeakrIcon icon;
  final String? tooltip;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final btn = Material(
      color: selected ? SpeakrColors.ink : SpeakrColors.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: selected ? SpeakrColors.ink : SpeakrColors.line,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: SpeakrIconView(
              icon,
              size: 14,
              color: selected ? SpeakrColors.bg : SpeakrColors.ink2,
            ),
          ),
        ),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}

class DesktopDivider extends StatelessWidget {
  const DesktopDivider({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 18,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: SpeakrColors.line,
    );
  }
}

class DropdownOption<T> {
  const DropdownOption({required this.value, required this.label});
  final T value;
  final String label;
}

/// Compatibility wrapper; all selectors use the common menu implementation.
class DesktopDropdown<T> extends StatelessWidget {
  const DesktopDropdown({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.minWidth = 100,
  });
  final T value;
  final List<DropdownOption<T>> options;
  final ValueChanged<T> onChanged;
  final double minWidth;
  @override
  Widget build(BuildContext context) => MimioSelect<T>(
    value: value,
    minWidth: minWidth,
    onChanged: onChanged,
    options: [
      for (final o in options)
        MimioSelectOption(value: o.value, label: o.label),
    ],
  );
}

class SegmentOption<T> {
  const SegmentOption({required this.value, required this.icon});
  final T value;
  final Widget icon;
}

class DesktopSegment<T> extends StatelessWidget {
  const DesktopSegment({
    super.key,
    required this.value,
    required this.onChanged,
    required this.options,
  });

  final T value;
  final ValueChanged<T> onChanged;
  final List<SegmentOption<T>> options;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SpeakrColors.surface,
        border: Border.all(color: SpeakrColors.line),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final o in options)
            InkWell(
              onTap: () => onChanged(o.value),
              child: Container(
                width: 36,
                height: 36,
                color: o.value == value ? SpeakrColors.bgAlt : null,
                alignment: Alignment.center,
                child: IconTheme(
                  data: IconThemeData(
                    color: o.value == value
                        ? SpeakrColors.ink
                        : SpeakrColors.muted,
                  ),
                  child: o.icon,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Small text button (height 26, mono 10, line border) used in the detail
/// player and similar dense rows.
class DesktopSmallButton extends StatelessWidget {
  const DesktopSmallButton({super.key, required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SpeakrColors.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: SpeakrColors.line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          alignment: Alignment.center,
          child: Text(
            label,
            style: SpeakrText.mono(
              size: 10,
              color: SpeakrColors.ink2,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

/// Pill-shaped button (rounded 100, 32 high) used for "Export markdown" /
/// "Share link" rows on the summary panel.
class DesktopPillButton extends StatelessWidget {
  const DesktopPillButton({
    super.key,
    required this.label,
    this.onTap,
    this.leading,
    this.background,
    this.foreground,
  });
  final String label;
  final VoidCallback? onTap;
  final Widget? leading;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final fg = foreground ?? SpeakrColors.ink;
    return Material(
      color: background ?? SpeakrColors.surface,
      shape: StadiumBorder(side: BorderSide(color: SpeakrColors.line)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 8)],
              Text(label, style: SpeakrText.sans(size: 12, color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}
