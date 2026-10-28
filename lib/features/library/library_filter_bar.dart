import 'package:speakr_app/l10n/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/models.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/speakr_icons.dart';
import 'library_controller.dart';

/// Unified filter bar shown above the recording list. Replaces the previous
/// stacked status-pill row + folder-pill row with a single "Filters" pill
/// that toggles an inline picker panel covering Status / Folder / Tags.
/// Active selections collapse into removable chips next to the pill.
///
/// Single-select per section: nothing-selected = "all". Tapping a selected
/// chip clears it.
class LibraryFilterBar extends ConsumerStatefulWidget {
  const LibraryFilterBar({super.key});

  @override
  ConsumerState<LibraryFilterBar> createState() => _LibraryFilterBarState();
}

class _LibraryFilterBarState extends ConsumerState<LibraryFilterBar> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final filter = ref.watch(libraryFilterProvider);
    final folders = ref.watch(foldersProvider).value ?? const <Folder>[];
    final tags = ref.watch(tagsProvider).value ?? const <Tag>[];

    final activeStatus = filter.statusKey != 'all';
    final activeCount =
        (activeStatus ? 1 : 0) +
        (filter.folderId == null ? 0 : 1) +
        (filter.tagId == null ? 0 : 1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _FiltersPill(
                open: _open,
                count: activeCount,
                onTap: () => setState(() => _open = !_open),
              ),
              const SizedBox(width: 8),
              if (!_open && activeCount > 0)
                Expanded(
                  child: _ActiveChipsStrip(
                    filter: filter,
                    folders: folders,
                    tags: tags,
                  ),
                )
              else
                const Spacer(),
              if (activeCount > 0) ...[
                const SizedBox(width: 4),
                _ClearButton(onTap: _clearAll),
              ],
            ],
          ),
          if (_open) _PickerPanel(filter: filter, folders: folders, tags: tags),
        ],
      ),
    );
  }

  void _clearAll() {
    final n = ref.read(libraryFilterProvider.notifier);
    n.setStatus('all');
    n.setFolder(null);
    n.setTag(null);
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Filters pill (toggle button)
// ─────────────────────────────────────────────────────────────────────────

class _FiltersPill extends StatelessWidget {
  const _FiltersPill({
    required this.open,
    required this.count,
    required this.onTap,
  });
  final bool open;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final filled = open || count > 0;
    final fg = filled ? SpeakrColors.bg : SpeakrColors.ink2;
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: filled ? SpeakrColors.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: filled ? null : Border.all(color: SpeakrColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpeakrIconView(SpeakrIcon.filter, size: 13, color: fg),
            const SizedBox(width: 7),
            Text(tr("Filters"), style: SpeakrText.sans(size: 13, color: fg)),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: SpeakrColors.bg.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '$count',
                  style: SpeakrText.mono(
                    size: 10,
                    color: SpeakrColors.bg,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Active selection chips (visible when collapsed and at least one filter set)
// ─────────────────────────────────────────────────────────────────────────

class _ActiveChipsStrip extends ConsumerWidget {
  const _ActiveChipsStrip({
    required this.filter,
    required this.folders,
    required this.tags,
  });
  final LibraryFilter filter;
  final List<Folder> folders;
  final List<Tag> tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    final notifier = ref.read(libraryFilterProvider.notifier);
    final children = <Widget>[];

    if (filter.statusKey != 'all') {
      final key = filter.statusKey;
      children.add(
        _ActiveChip(
          leading: key == 'highlighted'
              ? const SpeakrIconView(
                  SpeakrIcon.star,
                  size: 10,
                  color: SpeakrColors.ink2,
                )
              : null,
          label: _statusLabel(key),
          color: SpeakrColors.ink2,
          borderColor: SpeakrColors.line,
          onTap: () => notifier.setStatus('all'),
        ),
      );
    }
    if (filter.folderId != null) {
      final f = folders.firstWhere(
        (f) => f.id == filter.folderId,
        orElse: () => Folder(id: filter.folderId!, name: tr("Folder")),
      );
      final c = parseHexColor(f.color);
      children.add(
        _ActiveChip(
          leading: _swatch(c, square: true, size: 6),
          label: f.name,
          color: c,
          borderColor: c.withValues(alpha: 0.33),
          onTap: () => notifier.setFolder(null),
        ),
      );
    }
    if (filter.tagId != null) {
      final t = tags.firstWhere(
        (t) => t.id == filter.tagId,
        orElse: () => Tag(id: filter.tagId!, name: tr("Tag")),
      );
      final c = parseHexColor(t.color);
      children.add(
        _ActiveChip(
          label: t.name,
          color: c,
          borderColor: c.withValues(alpha: 0.33),
          onTap: () => notifier.setTag(null),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  const _ActiveChip({
    required this.label,
    required this.color,
    required this.borderColor,
    required this.onTap,
    this.leading,
  });
  final String label;
  final Color color;
  final Color borderColor;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 5)],
            Text(
              label.toUpperCase(),
              style: SpeakrText.mono(size: 10, color: color, letterSpacing: 1),
            ),
            const SizedBox(width: 4),
            Text(
              '×',
              style: SpeakrText.serif(
                size: 12,
                color: color.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Clear-all link
// ─────────────────────────────────────────────────────────────────────────

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Text(
          tr("CLEAR"),
          style: SpeakrText.mono(
            size: 10,
            color: SpeakrColors.muted,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Picker panel (Status / Folder / Tags sections)
// ─────────────────────────────────────────────────────────────────────────

class _PickerPanel extends ConsumerWidget {
  const _PickerPanel({
    required this.filter,
    required this.folders,
    required this.tags,
  });
  final LibraryFilter filter;
  final List<Folder> folders;
  final List<Tag> tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    final notifier = ref.read(libraryFilterProvider.notifier);
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: SpeakrColors.bgAlt,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: SpeakrColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(tr("Status")),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (final key in const [
                'completed',
                'processing',
                'highlighted',
              ])
                _PickerChip(
                  label: _statusLabel(key),
                  active: filter.statusKey == key,
                  leading: (active) => _statusLeading(key, active),
                  onTap: () =>
                      notifier.setStatus(filter.statusKey == key ? 'all' : key),
                ),
            ],
          ),
          if (folders.isNotEmpty) ...[
            const SizedBox(height: 12),
            _SectionLabel(tr("Folder")),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final f in folders)
                  _PickerChip(
                    label: f.name,
                    active: filter.folderId == f.id,
                    tint: parseHexColor(f.color),
                    leading: (active) => _swatch(
                      active ? SpeakrColors.bg : parseHexColor(f.color),
                      square: true,
                      size: 7,
                    ),
                    onTap: () => notifier.setFolder(
                      filter.folderId == f.id ? null : f.id,
                    ),
                  ),
              ],
            ),
          ],
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            _SectionLabel(tr("Tags")),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final t in tags)
                  _PickerChip(
                    label: t.name,
                    active: filter.tagId == t.id,
                    tint: parseHexColor(t.color),
                    onTap: () =>
                        notifier.setTag(filter.tagId == t.id ? null : t.id),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: SpeakrText.mono(
          size: 9,
          color: SpeakrColors.muted,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

/// One chip inside the picker panel. Two visual modes:
///  - **Default** (no `tint`): selected = ink fill + bg text; unselected =
///    transparent + ink text + line border.
///  - **Tinted** (folder / tag): selected = `tint` fill + bg text + `tint`
///    border; unselected = transparent + `tint` text + tint@33% border.
class _PickerChip extends StatelessWidget {
  const _PickerChip({
    required this.label,
    required this.active,
    required this.onTap,
    this.tint,
    this.leading,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color? tint;
  final Widget Function(bool active)? leading;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final tinted = tint != null;
    final fg = tinted
        ? (active ? SpeakrColors.bg : tint!)
        : (active ? SpeakrColors.bg : SpeakrColors.ink);
    final bg = tinted
        ? (active ? tint! : Colors.transparent)
        : (active ? SpeakrColors.ink : Colors.transparent);
    final border = tinted
        ? (active ? tint! : tint!.withValues(alpha: 0.33))
        : (active ? SpeakrColors.ink : SpeakrColors.line);
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              DefaultTextStyle.merge(
                style: TextStyle(color: fg),
                child: IconTheme(
                  data: IconThemeData(color: fg),
                  child: leading!(active),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(label, style: SpeakrText.sans(size: 12, color: fg)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Status helpers
// ─────────────────────────────────────────────────────────────────────────

String _statusLabel(String key) {
  switch (key) {
    case 'completed':
      return tr("Completed");
    case 'processing':
      return tr("Processing");
    case 'highlighted':
      return tr("Highlighted");
  }
  return key;
}

Widget _statusLeading(String key, bool active) {
  switch (key) {
    case 'completed':
      return _dot(SpeakrColors.ok);
    case 'processing':
      return _dot(SpeakrColors.recordingDot);
    case 'highlighted':
      return SpeakrIconView(
        SpeakrIcon.star,
        size: 10,
        color: active ? SpeakrColors.bg : SpeakrColors.ink,
      );
  }
  return const SizedBox.shrink();
}

Widget _dot(Color color) => Container(
  width: 6,
  height: 6,
  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
);

Widget _swatch(Color color, {required bool square, required double size}) =>
    Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: square
            ? BorderRadius.circular(2)
            : BorderRadius.circular(size),
      ),
    );
