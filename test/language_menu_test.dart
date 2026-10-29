import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speakr_app/l10n/strings.dart';
import 'package:speakr_app/theme/typography.dart';
import 'package:speakr_app/widgets/mimio_menu.dart';

void main() {
  testWidgets('language selector shares menus and persists both languages', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    applyLanguage('en');
    addTearDown(() => applyLanguage('zh'));
    await tester.pumpWidget(
      LocalizedApp(
        builder: (_) => MaterialApp(
          theme: buildSpeakrTheme(),
          home: const Scaffold(body: LanguagePicker()),
        ),
      ),
    );
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.byType(MimioMenuItem<String>), findsNWidgets(2));
    expect(find.text('简体中文'), findsNothing);
    await tester.tap(find.text('Simplified Chinese'));
    await tester.pumpAndSettle();
    expect(appLanguage.value, 'zh');
    expect(
      (await SharedPreferences.getInstance()).getString(languagePreferenceKey),
      'zh',
    );
    await tester.tap(find.text('简体中文'));
    await tester.pumpAndSettle();
    expect(find.text('英语'), findsOneWidget);
    expect(find.text('English'), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(MimioMenuItem<String>), findsNothing);
    await tester.tap(find.text('简体中文'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('英语'));
    await tester.pumpAndSettle();
    expect(appLanguage.value, 'en');
    expect(
      (await SharedPreferences.getInstance()).getString(languagePreferenceKey),
      'en',
    );
    expect(tester.takeException(), isNull);
  });
}
