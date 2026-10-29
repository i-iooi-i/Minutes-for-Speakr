import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speakr_app/api/models.dart';
import 'package:speakr_app/desktop/shell/desktop_shell.dart';
import 'package:speakr_app/desktop/shell/desktop_sidebar.dart';
import 'package:speakr_app/features/library/library_controller.dart';
import 'package:speakr_app/l10n/strings.dart';
import 'package:speakr_app/theme/typography.dart';

void main() {
  testWidgets('archive count survives folder and status filtering', (
    tester,
  ) async {
    applyLanguage('zh');
    final container = ProviderContainer(
      overrides: [
        foldersProvider.overrideWith((_) async => []),
        tagsProvider.overrideWith((_) async => []),
        libraryCountsRecordingsProvider.overrideWith(
          (_) async => [
            Recording.fromJson({'id': 1, 'is_archived': true}),
            Recording.fromJson({'id': 2}),
          ],
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildSpeakrTheme(),
          home: const Scaffold(
            body: SizedBox(
              width: 260,
              child: DesktopSidebar(active: DesktopShellRoute.library),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    void checkCount() {
      final row = find
          .ancestor(of: find.text('已归档'), matching: find.byType(Row))
          .first;
      expect(
        find.descendant(of: row, matching: find.text('1')),
        findsOneWidget,
      );
    }

    checkCount();
    container.read(libraryFilterProvider.notifier).setStatus('archived');
    container.read(libraryFilterProvider.notifier).setFolder(99);
    await tester.pumpAndSettle();
    checkCount();
    expect(tester.takeException(), isNull);
  });
}
