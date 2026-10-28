import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/colors.dart';
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
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        modActivator(LogicalKeyboardKey.keyR): () => context.push('/live'),
        modActivator(LogicalKeyboardKey.keyK): () {
          ref.read(sidebarCollapsedProvider.notifier).state = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(sidebarSearchFocusProvider).requestFocus();
          });
        },
        modActivator(LogicalKeyboardKey.comma): () => context.push('/settings'),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: SpeakrColors.bg,
          body: Row(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                decoration: BoxDecoration(
                  color: SpeakrColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: SpeakrColors.line),
                ),
                clipBehavior: Clip.antiAlias,
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
