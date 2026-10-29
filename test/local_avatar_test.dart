import 'package:speakr_app/l10n/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speakr_app/services/preferences/local_avatar.dart';
import 'package:speakr_app/widgets/avatar_settings.dart';
import 'package:speakr_app/widgets/user_avatar.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('URL persists across reload and reset removes it', () async {
    final first = LocalAvatarController();
    await first.save('  https://example.com/avatar.png?size=80  ');
    final second = LocalAvatarController();
    await second.load();
    expect(second.value, 'https://example.com/avatar.png?size=80');
    await second.save('');
    await first.load();
    expect(first.value, isEmpty);
    expect(
      (await SharedPreferences.getInstance()).containsKey(
        LocalAvatarController.preferenceKey,
      ),
      isFalse,
    );
  });
  test(
    'rejects non-web or credential-bearing URLs without changing saved value',
    () async {
      final controller = LocalAvatarController();
      await controller.save('https://example.com/ok.png');
      for (final bad in [
        'file:///secret.png',
        'javascript:alert(1)',
        'https://',
        'https://user:pass@example.com/a',
      ]) {
        await expectLater(controller.save(bad), throwsFormatException);
        expect(controller.value, 'https://example.com/ok.png');
      }
    },
  );
  testWidgets(
    'invalid input displays an error; default restoration clears the editor',
    (tester) async {
      final controller = LocalAvatarController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AvatarSettings(controller: controller)),
        ),
      );
      await tester.enterText(find.byType(TextField), 'not-a-url');
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text(tr('Enter a valid HTTP or HTTPS image URL without account credentials.')), findsOneWidget);
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(controller.value, isEmpty);
    },
  );
  testWidgets('broken image falls back without an uncaught image error', (
    tester,
  ) async {
    final controller = LocalAvatarController()
      ..value = 'https://example.com/missing.png';
    await tester.pumpWidget(
      MaterialApp(home: UserAvatar(controller: controller)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ColoredBox), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
