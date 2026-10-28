import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/speakr_icons.dart';

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

class DesktopDropdown<T> extends StatefulWidget {
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
  State<DesktopDropdown<T>> createState() => _DesktopDropdownState<T>();
}

class _DesktopDropdownState<T> extends State<DesktopDropdown<T>> {
  final GlobalKey _key = GlobalKey();
  OverlayEntry? _overlay;

  String _labelFor(T v) => widget.options.firstWhere((o) => o.value == v).label;

  void _toggle() {
    if (_overlay != null) {
      _close();
      return;
    }
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;
    _overlay = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _close,
            ),
          ),
          Positioned(
            left: offset.dx,
            top: offset.dy + size.height + 4,
            child: Material(
              elevation: 0,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: SpeakrColors.surface,
                  border: Border.all(color: SpeakrColors.line),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      offset: Offset(0, 8),
                      blurRadius: 20,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                constraints: BoxConstraints(minWidth: widget.minWidth + 20),
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final o in widget.options)
                        InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            widget.onChanged(o.value);
                            _close();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: o.value == widget.value
                                  ? SpeakrColors.bgAlt
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              o.label,
                              style: SpeakrText.sans(
                                size: 12,
                                color: SpeakrColors.ink,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlay!);
  }

  void _close() {
    _overlay?.remove();
    _overlay = null;
  }

  @override
  void dispose() {
    _close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      key: _key,
      color: SpeakrColors.surface,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: SpeakrColors.line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: _toggle,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: widget.minWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: SizedBox(
              height: 36,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _labelFor(widget.value),
                    style: SpeakrText.sans(size: 12, color: SpeakrColors.ink),
                  ),
                  const SizedBox(width: 6),
                  CustomPaint(
                    size: const Size(10, 10),
                    painter: _ChevronPainter(SpeakrColors.ink2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  _ChevronPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * 0.25, size.height * 0.4)
      ..lineTo(size.width * 0.5, size.height * 0.65)
      ..lineTo(size.width * 0.75, size.height * 0.4);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _ChevronPainter oldDelegate) =>
      oldDelegate.color != color;
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
        side: const BorderSide(color: SpeakrColors.line),
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
      shape: const StadiumBorder(side: BorderSide(color: SpeakrColors.line)),
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

class DesktopActionItem {
  const DesktopActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.dividerAbove = false,
    this.danger = false,
  });

  final SpeakrIcon icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool dividerAbove;
  final bool danger;
}

/// Anchored action menu used by the desktop detail header (and any other
/// surface that wants a right-aligned popover of recording-level actions).
/// Pass a [builder] that wires the trigger child's onTap to [toggle].
class DesktopActionMenu extends StatefulWidget {
  const DesktopActionMenu({
    super.key,
    required this.items,
    required this.builder,
    this.minWidth = 240,
  });

  final List<DesktopActionItem> items;
  final Widget Function(BuildContext context, VoidCallback toggle) builder;
  final double minWidth;

  @override
  State<DesktopActionMenu> createState() => _DesktopActionMenuState();
}

class _DesktopActionMenuState extends State<DesktopActionMenu> {
  final GlobalKey _key = GlobalKey();
  OverlayEntry? _overlay;

  void _toggle() {
    if (_overlay != null) {
      _close();
      return;
    }
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;
    final screenWidth = MediaQuery.of(context).size.width;
    _overlay = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _close,
            ),
          ),
          Positioned(
            right: screenWidth - (offset.dx + size.width),
            top: offset.dy + size.height + 4,
            child: Material(
              elevation: 0,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: SpeakrColors.surface,
                  border: Border.all(color: SpeakrColors.line),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      offset: Offset(0, 8),
                      blurRadius: 20,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                constraints: BoxConstraints(minWidth: widget.minWidth),
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final item in widget.items) ...[
                        if (item.dividerAbove)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Divider(height: 1, color: SpeakrColors.line),
                          ),
                        _ActionRow(
                          item: item,
                          onTap: () {
                            _close();
                            item.onTap();
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlay!);
  }

  void _close() {
    _overlay?.remove();
    _overlay = null;
  }

  @override
  void dispose() {
    _close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _key, child: widget.builder(context, _toggle));
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.item, required this.onTap});
  final DesktopActionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = item.danger ? SpeakrColors.danger : SpeakrColors.ink;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            SpeakrIconView(item.icon, size: 14, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.label,
                    style: SpeakrText.sans(size: 13, color: color),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: SpeakrText.sans(
                        size: 11,
                        color: SpeakrColors.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
