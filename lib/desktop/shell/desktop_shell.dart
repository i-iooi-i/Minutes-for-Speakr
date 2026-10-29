import '../widgets/library_search.dart';
import 'package:speakr_app/theme/appearance.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/colors.dart';
import '../../widgets/mimio_panel.dart';
import 'desktop_shortcuts.dart';
import 'desktop_sidebar.dart';
import 'package:speakr_app/l10n/strings.dart';

/// Which top-level area the sidebar should highlight.
enum DesktopShellRoute { library, recording }

/// Persistent left-sidebar shell used by the Library and Detail screens at
/// desktop widths, with an expandable navigation rail.
class DesktopShell extends ConsumerWidget {
  const DesktopShell({super.key, required this.child, required this.active});

  final Widget child;
  final DesktopShellRoute active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        modActivator(LogicalKeyboardKey.keyR): () => context.push('/live'),
        modActivator(LogicalKeyboardKey.keyK): () {
          ref.read(librarySearchExpandedProvider.notifier).state = true;
          if (GoRouterState.of(context).uri.path != '/library') {
            context.go('/library');
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(librarySearchFocusProvider).requestFocus();
          });
        },
        modActivator(LogicalKeyboardKey.comma): () => context.push('/settings'),
      },
      child: FocusScope(
        autofocus: true,
        child: Scaffold(
          backgroundColor: SpeakrColors.bg,
          body: Row(
            children: [
              MimioPanel(
                radius: 18,
                margin: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                child: DesktopSidebar(active: active),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
