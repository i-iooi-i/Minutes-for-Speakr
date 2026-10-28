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
import 'desktop_shell.dart';
import 'desktop_shortcuts.dart';

final sidebarCollapsedProvider = StateProvider<bool>((ref) => false);

/// FocusNode for the sidebar search field. Hoisted to a provider so the
/// desktop shell can request focus from a global Ctrl/⌘+K shortcut.
final sidebarSearchFocusProvider = Provider<FocusNode>((ref) {
  final node = FocusNode(debugLabel: 'sidebarSearch');
  ref.onDispose(node.dispose);
  return node;
});

/// Persistent sidebar: search, nav items, folders, tags,
/// user chip. Reads the same Library providers the main list uses and writes
/// folder/tag/status selections back through [libraryFilterProvider].
class DesktopSidebar extends ConsumerWidget {
  const DesktopSidebar({super.key, required this.active});

  final DesktopShellRoute active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
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
    if (collapsed) {
      return SizedBox(
        width: 56,
        child: Column(
          children: [
            const SizedBox(height: 8),
            toggle(),
            const SizedBox(height: 12),
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
                  style: IconButton.styleFrom(
                    backgroundColor: filter.statusKey == entry.$1
                        ? SpeakrColors.bgAlt
                        : Colors.transparent,
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
                  const Icon(
                    Icons.graphic_eq_rounded,
                    size: 18,
                    color: SpeakrColors.accent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Minutes',
                    style: SpeakrText.sans(size: 13, weight: FontWeight.w600),
                  ),
                  const Spacer(),
                  toggle(),
                ],
              ),
            ),
            // Search field — pushes back to the library filter provider
            const Padding(
              padding: EdgeInsets.fromLTRB(10, 4, 10, 12),
              child: _SidebarSearch(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      active: onLibrary && filter.statusKey == 'archived',
                      onTap: () => _selectStatus(ref, context, 'archived'),
                    ),
                    if (folders.isNotEmpty) ...[
                      const Padding(
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
                          active: onLibrary && filter.folderId == f.id,
                          onTap: () => _selectFolder(ref, context, f.id),
                        ),
                    ],
                    if (tags.isNotEmpty) ...[
                      const Padding(
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
                          active: filter.tagId == t.id,
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

class _SidebarSearch extends ConsumerStatefulWidget {
  const _SidebarSearch();

  @override
  ConsumerState<_SidebarSearch> createState() => _SidebarSearchState();
}

class _SidebarSearchState extends ConsumerState<_SidebarSearch> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    ref.listen(libraryFilterProvider.select((f) => f.query), (previous, next) {
      if (previous != next && _ctrl.text != (next ?? '')) {
        _ctrl.text = next ?? '';
        setState(() {});
      }
    });
    final focus = ref.watch(sidebarSearchFocusProvider);
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: SpeakrColors.bgAlt,
        border: Border.all(color: SpeakrColors.line),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          const SpeakrIconView(
            SpeakrIcon.search,
            size: 14,
            color: SpeakrColors.muted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _ctrl,
              focusNode: focus,
              style: SpeakrText.sans(size: 12, color: SpeakrColors.ink),
              decoration: InputDecoration(
                isCollapsed: true,
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: tr("Search recordings, press Enter"),
                hintStyle: SpeakrText.sans(size: 12, color: SpeakrColors.muted),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (v) {
                final n = ref.read(libraryFilterProvider.notifier);
                n.setStatus('all');
                n.setFolder(null);
                n.setTag(null);
                n.setQuery(v.trim());
                if (GoRouterState.of(context).uri.path != '/library') {
                  context.go('/library');
                }
              },
            ),
          ),
          if (_ctrl.text.isNotEmpty)
            SizedBox(
              width: 24,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 14,
                tooltip: tr('Clear search'),
                icon: const Icon(Icons.close),
                onPressed: () {
                  _ctrl.clear();
                  ref.read(libraryFilterProvider.notifier).setQuery(null);
                  setState(() {});
                },
              ),
            ),
          if (supportsKeyboardShortcuts && _ctrl.text.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                border: Border.all(color: SpeakrColors.line),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                '${modLabel}K',
                style: SpeakrText.mono(
                  size: 9,
                  color: SpeakrColors.muted,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    this.count,
    this.dot,
    this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final int? count;
  final Color? dot;
  final IconData? icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: active ? SpeakrColors.bgAlt : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: BoxDecoration(
              color: active ? SpeakrColors.bgAlt : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
            ),
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
                    color: SpeakrColors.ink2,
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
                      color: active ? SpeakrColors.ink : SpeakrColors.ink2,
                    ),
                  ),
                ),
                if (count != null)
                  Text(
                    '$count',
                    style: SpeakrText.mono(
                      size: 10,
                      color: SpeakrColors.muted,
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
    return Material(
      color: SpeakrColors.surface,
      child: InkWell(
        onTap: () => context.push('/settings'),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: SpeakrColors.line)),
          ),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: SpeakrColors.ink,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  tr("ME"),
                  style: SpeakrText.serif(
                    size: 11,
                    color: SpeakrColors.bg,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Minutes',
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
              const SpeakrIconView(
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
