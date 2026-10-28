import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/colors.dart';
import 'desktop_shortcuts.dart';
import 'desktop_sidebar.dart';

/// Which top-level area the sidebar should highlight.
enum DesktopShellRoute { library }

/// Persistent left-sidebar shell used by the Library and Detail screens at
/// desktop widths. The sidebar is 240 px wide and always visible.
class DesktopShell extends ConsumerWidget {
  const DesktopShell({super.key, required this.child, required this.active});

  final Widget child;
  final DesktopShellRoute active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        modActivator(LogicalKeyboardKey.keyR): () => context.push('/live'),
        modActivator(LogicalKeyboardKey.keyK): () {
          ref.read(sidebarSearchFocusProvider).requestFocus();
        },
        modActivator(LogicalKeyboardKey.comma): () => context.push('/settings'),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: SpeakrColors.bg,
          body: Row(
            children: [
              DesktopSidebar(active: active),
              const VerticalDivider(width: 1, color: SpeakrColors.line),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
