import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';
import 'mono_eyebrow.dart';

/// Section in the Settings screen — a labelled group of [SettingsRow]s
/// separated by hairline borders. Lifted from settings_screen.dart so
/// other settings sub-screens can share the same visual idiom.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.label, required this.children});
  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: SpeakrColors.line)),
      ),
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 8),
            child: MonoEyebrow(label, size: 10),
          ),
          ...children,
        ],
      ),
    );
  }
}

/// One row inside a [SettingsGroup]. Three mutually exclusive trailing
/// modes: a static value (default), a toggle, or an arbitrary trailing
/// widget. Tap the row by passing [onTap].
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.label,
    this.value,
    this.subtitle,
    this.mono = false,
    this.valueColor,
    this.toggleValue,
    this.onToggle,
    this.trailing,
    this.onTap,
  });

  final String label;
  final String? value;
  final String? subtitle;
  final bool mono;
  final Color? valueColor;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: SpeakrColors.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: SpeakrText.sans(size: 14, color: SpeakrColors.ink),
                ),
              ),
              if (toggleValue != null)
                SettingsToggle(
                  value: toggleValue!,
                  onChanged: onToggle ?? (_) {},
                )
              else if (trailing != null)
                trailing!
              else
                Flexible(
                  child: Text(
                    value ?? '—',
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: mono
                        ? SpeakrText.mono(
                            size: 13,
                            color: valueColor ?? SpeakrColors.muted,
                            letterSpacing: 0,
                          )
                        : SpeakrText.sans(
                            size: 13,
                            color: valueColor ?? SpeakrColors.muted,
                          ),
                  ),
                ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, size: 18, color: SpeakrColors.muted),
              ],
            ],
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: SpeakrText.mono(
                size: 11,
                color: SpeakrColors.muted,
                letterSpacing: 0,
              ),
            ),
          ],
        ],
      ),
    );
    if (onTap == null) return body;
    return InkWell(onTap: onTap, child: body);
  }
}

class SettingsToggle extends StatelessWidget {
  const SettingsToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 38,
        height: 22,
        decoration: BoxDecoration(
          color: value ? SpeakrColors.ink : SpeakrColors.line,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 180),
              top: 3,
              left: value ? 19 : 3,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: SpeakrColors.bg,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
