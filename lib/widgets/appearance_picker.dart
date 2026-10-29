import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../theme/appearance.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

/// Shared appearance controls for the desktop and compact settings layouts.
class AppearancePicker extends StatefulWidget {
  const AppearancePicker({super.key});
  @override
  State<AppearancePicker> createState() => _AppearancePickerState();
}

class _AppearancePickerState extends State<AppearancePicker> {
  bool _saving = false;
  Future<void> _save({ThemeMode? mode, MimioPalette? palette}) async {
    setState(() => _saving = true);
    try {
      await appAppearance.set(mode: mode, palette: palette);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('Could not save appearance. Please try again.')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('Color mode'),
          style: SpeakrText.sans(size: 14, weight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in [
              (ThemeMode.light, Icons.light_mode_outlined, 'Light'),
              (ThemeMode.dark, Icons.dark_mode_outlined, 'Dark'),
              (
                ThemeMode.system,
                Icons.desktop_windows_outlined,
                'Follow system',
              ),
            ])
              _choice(
                label: tr(option.$3),
                selected: appAppearance.mode == option.$1,
                leading: Icon(option.$2, size: 18, color: SpeakrColors.ink2),
                onTap: () => _save(mode: option.$1),
              ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          tr('Accent color'),
          style: SpeakrText.sans(size: 14, weight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          tr('Seven palettes shared with CoPage.'),
          style: SpeakrText.sans(size: 12, color: SpeakrColors.muted),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final palette in MimioPalette.values)
              _choice(
                label: tr(palette.label),
                selected: appAppearance.palette == palette,
                leading: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: palette.accent(appAppearance.brightness),
                  ),
                ),
                onTap: () => _save(palette: palette),
              ),
          ],
        ),
      ],
    );
  }

  Widget _choice({
    required String label,
    required bool selected,
    required Widget leading,
    required VoidCallback onTap,
  }) => Semantics(
    selected: selected,
    button: true,
    child: Material(
      color: selected
          ? SpeakrColors.accent.withValues(alpha: .09)
          : SpeakrColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? SpeakrColors.accent : SpeakrColors.line,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _saving ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              leading,
              const SizedBox(width: 8),
              Text(label, style: SpeakrText.sans(size: 13)),
              const SizedBox(width: 12),
              Icon(
                selected ? Icons.check_rounded : null,
                size: 16,
                color: SpeakrColors.accent,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
