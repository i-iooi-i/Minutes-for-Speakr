import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:speakr_app/api/models.dart';
import 'package:speakr_app/desktop/library/library_desktop_screen.dart';
import 'package:speakr_app/features/library/library_controller.dart';
import 'package:speakr_app/l10n/strings.dart';
import 'package:speakr_app/services/preferences/time_format_preference.dart';
import 'package:speakr_app/services/preferences/time_format_providers.dart';
import 'package:speakr_app/theme/typography.dart';

void main() {
  setUpAll(() => initializeDateFormatting('zh_CN'));
  for (final width in [670.0, 1100.0]) {
    testWidgets('Chinese library fits $width and play navigates explicitly', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      applyLanguage('zh');
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: LibraryDesktopScreen()),
          ),
          GoRoute(
            path: '/recording/:id',
            builder: (_, state) => Scaffold(
              body: Text(
                '${state.pathParameters['id']}:${state.uri.queryParameters['play']}',
              ),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            libraryItemsProvider.overrideWith(
              (_) async => [
                RemoteLibraryItem(
                  Recording.fromJson({
                    'id': 42,
                    'title': '很长的中文会议标题：产品体验与录音流程评审',
                    'status': 'COMPLETED',
                    'audio_duration': 500,
                    'created_at': '2026-10-28T08:00:00Z',
                    'participants': '张明、王强、李娜',
                  }),
                ),
              ],
            ),
            foldersProvider.overrideWith((_) async => []),
            timeFormatPreferenceProvider.overrideWith(
              (_) async => TimeFormatPreference.system,
            ),
          ],
          child: LocalizedApp(
            builder: (locale) => MaterialApp.router(
              theme: buildSpeakrTheme(),
              routerConfig: router,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('播放'));
      await tester.pumpAndSettle();
      expect(find.text('42:1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
