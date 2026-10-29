import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import '../../theme/appearance.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../l10n/strings.dart';
import '../../features/library/library_controller.dart';
import '../../widgets/speakr_icons.dart';
import '../shell/desktop_shortcuts.dart';

final librarySearchExpandedProvider = StateProvider<bool>((ref) => false);
final librarySearchFocusProvider = Provider<FocusNode>((ref) {
  final node = FocusNode(debugLabel: 'librarySearch');
  ref.onDispose(node.dispose);
  return node;
});

class LibrarySearch extends ConsumerStatefulWidget {
  const LibrarySearch({super.key});

  @override
  ConsumerState<LibrarySearch> createState() => _LibrarySearchState();
}

class _LibrarySearchState extends ConsumerState<LibrarySearch> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl.text = ref.read(libraryFilterProvider).query ?? '';
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    ref.listen(libraryFilterProvider.select((f) => f.query), (previous, next) {
      if (previous != next && _ctrl.text != (next ?? '')) {
        _ctrl.text = next ?? '';
        setState(() {});
      }
    });
    final focus = ref.watch(librarySearchFocusProvider);
    final expanded = ref.watch(librarySearchExpandedProvider);
    if (!expanded && _ctrl.text.isEmpty) {
      return IconButton(
        tooltip: '${tr('Search')} (${modLabel}K)',
        icon: SpeakrIconView(
          SpeakrIcon.search,
          size: 20,
          color: SpeakrColors.ink,
        ),
        onPressed: () {
          ref.read(librarySearchExpandedProvider.notifier).state = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) focus.requestFocus();
          });
        },
      );
    }
    return Container(
      width: 260,
      height: 38,
      decoration: ShapeDecoration(
        color: SpeakrColors.bgAlt,
        shape: StadiumBorder(side: BorderSide(color: SpeakrColors.line)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          SpeakrIconView(
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
          SizedBox(
            width: 28,
            height: 28,
            child: IconButton(
              padding: EdgeInsets.zero,
              style: IconButton.styleFrom(
                fixedSize: const Size.square(28),
                minimumSize: const Size.square(28),
                maximumSize: const Size.square(28),
                shape: const CircleBorder(),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.standard,
              ),
              iconSize: 14,
              tooltip: tr('Clear search'),
              icon: SpeakrIconView(
                SpeakrIcon.close,
                size: 14,
                color: SpeakrColors.ink,
              ),
              onPressed: () {
                _ctrl.clear();
                ref.read(libraryFilterProvider.notifier).setQuery(null);
                focus.unfocus();
                ref.read(librarySearchExpandedProvider.notifier).state = false;
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}
