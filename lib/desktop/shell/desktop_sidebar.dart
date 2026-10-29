import 'package:speakr_app/widgets/user_avatar.dart';
import 'package:speakr_app/theme/appearance.dart';
import 'package:speakr_app/l10n/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../api/models.dart';
import '../../features/library/library_controller.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/speakr_icons.dart';
import '../../widgets/mimio_logo.dart';
import 'desktop_shell.dart';

final sidebarCollapsedProvider = StateProvider<bool>((ref) => false);

/// Persistent sidebar: search, nav items, folders, tags,
/// user chip. Reads the same Library providers the main list uses and writes
/// folder/tag/status selections back through [libraryFilterProvider].
class DesktopSidebar extends ConsumerWidget {
  const DesktopSidebar({super.key, required this.active});

  final DesktopShellRoute active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    final filter = ref.watch(libraryFilterProvider);
    final folders = ref.watch(foldersProvider).value ?? const <Folder>[];
    final tags = ref.watch(tagsProvider).value ?? const <Tag>[];
    final recs = ref.watch(libraryCountsRecordingsProvider).value;
    final totalCount = recs?.length;
    final highlightedCount = recs?.where((r) => r.isHighlighted).length;
    final processingCount =
        recs?.where((r) => r.status.isInProgress).length ?? 0;
    int? countForFolder(int id) => recs?.where((r) => r.folderId == id).length;

    final onLibrary = active == DesktopShellRoute.library;
    final noFilters =
        filter.statusKey == 'all' &&
        filter.folderId == null &&
        filter.tagId == null;

    final collapsed = ref.watch(sidebarCollapsedProvider);
    Widget toggle() => IconButton(
      tooltip: tr(collapsed ? 'Expand sidebar' : 'Collapse sidebar'),
      icon: Icon(
        collapsed
            ? Icons.keyboard_double_arrow_right_rounded
            : Icons.keyboard_double_arrow_left_rounded,
        size: 19,
      ),
      onPressed: () =>
          ref.read(sidebarCollapsedProvider.notifier).state = !collapsed,
    );
    ButtonStyle navStyle(bool selected) => ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => selected
            ? SpeakrColors.navSelected
            : states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.focused)
            ? SpeakrColors.navHover
            : Colors.transparent,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) =>
            selected ||
                states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)
            ? SpeakrColors.accent
            : SpeakrColors.ink2,
      ),
    );
    if (collapsed) {
      return SizedBox(
        width: 56,
        child: Column(
          children: [
            const SizedBox(height: 12),
            const MimioLogo(compact: true, height: 27),
            toggle(),
            const SizedBox(height: 12),
            IconButton(
              tooltip: tr('Start recording'),
              icon: const Icon(
                Icons.mic_none_rounded,
                color: SpeakrColors.recordRed,
              ),
              style: navStyle(!onLibrary),
              onPressed: () => context.go('/live'),
            ),
            for (final entry in [
              ('all', 'All recordings', Icons.graphic_eq_rounded),
              ('highlighted', 'Highlighted', Icons.star_border_rounded),
              ('processing', 'Processing', Icons.hourglass_top_rounded),
              ('archived', 'Archived', Icons.archive_outlined),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: IconButton(
                  tooltip: tr(entry.$2),
                  style: navStyle(
                    onLibrary &&
                        filter.statusKey == entry.$1 &&
                        filter.folderId == null &&
                        filter.tagId == null,
                  ),
                  icon: Icon(entry.$3, size: 19),
                  onPressed: () => entry.$1 == 'all'
                      ? _selectAll(ref, context)
                      : _selectStatus(ref, context, entry.$1),
                ),
              ),
            const Spacer(),
            IconButton(
              tooltip: tr('Settings'),
              icon: const Icon(Icons.settings_outlined, size: 19),
              onPressed: () => context.push('/settings'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    }
    return SizedBox(
      width: 232,
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 6, 0),
              child: Row(
                children: [
                  const MimioLogo(height: 30),
                  const Spacer(),
                  toggle(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _NavItem(
                      label: tr('Start recording'),
                      icon: Icons.mic_none_rounded,
                      iconColor: SpeakrColors.recordRed,
                      active: active == DesktopShellRoute.recording,
                      onTap: () => context.go('/live'),
                    ),
                    _NavItem(
                      label: tr("All recordings"),
                      count: totalCount,
                      active: onLibrary && noFilters,
                      onTap: () => _selectAll(ref, context),
                    ),
                    _NavItem(
                      label: tr("Highlighted"),
                      count: highlightedCount,
                      active: onLibrary && filter.statusKey == 'highlighted',
                      onTap: () => _selectStatus(ref, context, 'highlighted'),
                    ),
                    _NavItem(
                      label: tr("Processing"),
                      count: processingCount,
                      icon: Icons.hourglass_top_rounded,
                      active: onLibrary && filter.statusKey == 'processing',
                      onTap: () => _selectStatus(ref, context, 'processing'),
                    ),
                    _NavItem(
                      label: tr("Archived"),
                      icon: Icons.archive_outlined,
                      count: recs?.where((r) => r.isArchived).length,
                      active: onLibrary && filter.statusKey == 'archived',
                      onTap: () => _selectStatus(ref, context, 'archived'),
                    ),
                    if (folders.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Divider(height: 1, color: SpeakrColors.line),
                      ),
                      _SectionLabel(tr("Folders")),
                      for (final f in folders)
                        _NavItem(
                          label: f.name,
                          count: countForFolder(f.id),
                          icon: Icons.folder_outlined,
                          iconColor: onLibrary && filter.folderId == f.id
                              ? parseHexColor(f.color)
                              : null,
                          active: onLibrary && filter.folderId == f.id,
                          onTap: () => _selectFolder(ref, context, f.id),
                        ),
                    ],
                    if (tags.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Divider(height: 1, color: SpeakrColors.line),
                      ),
                      _SectionLabel(tr("Tags")),
                      for (final t in tags)
                        _NavItem(
                          label: t.name,
                          dot: parseHexColor(t.color),
                          active: onLibrary && filter.tagId == t.id,
                          onTap: () => _selectTag(ref, context, t.id),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            const _UserChip(),
          ],
        ),
      ),
    );
  }

  void _selectAll(WidgetRef ref, BuildContext context) {
    final n = ref.read(libraryFilterProvider.notifier);
    n.setStatus('all');
    n.setFolder(null);
    n.setTag(null);
    n.setQuery(null);
    _goLibrary(context);
  }

  void _selectStatus(WidgetRef ref, BuildContext context, String key) {
    final n = ref.read(libraryFilterProvider.notifier);
    n.setStatus(key);
    n.setFolder(null);
    n.setTag(null);
    n.setQuery(null);
    _goLibrary(context);
  }

  void _selectFolder(WidgetRef ref, BuildContext context, int id) {
    final n = ref.read(libraryFilterProvider.notifier);
    final cur = ref.read(libraryFilterProvider).folderId;
    n.setFolder(cur == id ? null : id);
    _goLibrary(context);
  }

  void _selectTag(WidgetRef ref, BuildContext context, int id) {
    final n = ref.read(libraryFilterProvider.notifier);
    final cur = ref.read(libraryFilterProvider).tagId;
    n.setTag(cur == id ? null : id);
    _goLibrary(context);
  }

  void _goLibrary(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    if (loc != '/library') context.go('/library');
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.label,
    this.count,
    this.dot,
    this.icon,
    this.iconColor,
    required this.active,
    required this.onTap,
  });

  final String label;
  final int? count;
  final Color? dot;
  final IconData? icon;
  final Color? iconColor;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool hovered = false;
  bool focused = false;
  @override
  Widget build(BuildContext context) {
    final label = widget.label;
    final count = widget.count;
    final dot = widget.dot;
    final icon = widget.icon;
    final iconColor = widget.iconColor;
    final active = widget.active;
    final onTap = widget.onTap;
    final emphasized = active || hovered || focused;

    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: active
            ? SpeakrColors.navSelected
            : (hovered || focused)
            ? SpeakrColors.navHover
            : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: onTap,
          onHover: (value) => setState(() => hovered = value),
          onFocusChange: (value) => setState(() => focused = value),
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                if (dot == null) ...[
                  Icon(
                    icon ??
                        (label == tr("All recordings")
                            ? Icons.graphic_eq_rounded
                            : label == tr("Highlighted")
                            ? Icons.star_border_rounded
                            : Icons.graphic_eq_rounded),
                    size: 17,
                    color:
                        iconColor ??
                        (emphasized ? SpeakrColors.accent : SpeakrColors.ink2),
                  ),
                  const SizedBox(width: 10),
                ],
                if (dot != null) ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: dot,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SpeakrText.sans(
                      size: 13,
                      weight: active ? FontWeight.w500 : FontWeight.w400,
                      color: emphasized
                          ? SpeakrColors.accent
                          : SpeakrColors.ink2,
                    ),
                  ),
                ),
                if (count != null)
                  Text(
                    '$count',
                    style: SpeakrText.mono(
                      size: 10,
                      color: emphasized
                          ? SpeakrColors.accent
                          : SpeakrColors.muted,
                      letterSpacing: 0,
                    ),
                  ),
              ],
            ),
          ),
        ),
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
    AppearanceScope.watch(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
      child: Text(
        text.toUpperCase(),
        style: SpeakrText.mono(
          size: 9.5,
          color: SpeakrColors.muted,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _UserChip extends ConsumerWidget {
  const _UserChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    return Material(
      color: SpeakrColors.surface,
      child: InkWell(
        onTap: () => context.push('/settings'),
        child: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: SpeakrColors.line)),
          ),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              const UserAvatar(),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mimio',
                      style: SpeakrText.sans(
                        size: 12.5,
                        weight: FontWeight.w500,
                        color: SpeakrColors.ink,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              SpeakrIconView(
                SpeakrIcon.settings,
                size: 16,
                color: SpeakrColors.ink2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
