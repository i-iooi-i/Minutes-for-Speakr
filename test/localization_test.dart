import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speakr_app/api/models.dart';
import 'package:speakr_app/l10n/strings.dart';
import 'package:speakr_app/l10n/zh_cn.dart';
import 'package:speakr_app/utils/formatters.dart';
import 'package:speakr_app/widgets/status_badge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await loadLanguage();
  });
  tearDown(() => applyLanguage('zh'));

  test('Chinese is default; selection survives a new load', () async {
    expect(appLanguage.value, 'zh');
    await setLanguage('en');
    applyLanguage('zh');
    await loadLanguage();
    expect(appLanguage.value, 'en');
    expect(tr('Recording'), 'Recording');
    await setLanguage('zh');
    expect(tr('Recording'), '录音');
  });

  test('explicit 12/24-hour selection is respected in Chinese', () {
    final time = DateTime(2026, 10, 28, 14, 5);
    expect(formatHourMinute(time, use24Hour: true), '14:05');
    expect(formatHourMinute(time, use24Hour: false), '下午 2:05');
    applyLanguage('en');
    expect(formatHourMinute(time, use24Hour: false), '2:05 PM');
  });

  test('translations preserve each positional placeholder', () {
    final placeholder = RegExp(r'\{\d+\}');
    for (final entry in zhCN.entries) {
      final source = placeholder.allMatches(entry.key).map((m) => m[0]).toList()
        ..sort();
      final target =
          placeholder.allMatches(entry.value).map((m) => m[0]).toList()..sort();
      expect(target, source, reason: entry.key);
      expect(entry.value, isNotEmpty);
    }
    expect(tr('Could not load tags: {0}', ['name {1}']), '无法加载标签：name {1}');
    expect(tr('User-created meeting title'), 'User-created meeting title');
  });

  test('localized display does not alter API enums or English wire dates', () {
    final recording = Recording.fromJson({
      'id': 1,
      'status': 'COMPLETED',
      'meeting_date': 'Apr 23, 2026, 2:19:29 PM',
    });
    expect(recording.status.displayLabel, '已完成');
    expect(recording.toJson()['status'], 'COMPLETED');
    expect(recording.meetingDate, DateTime.utc(2026, 4, 23, 14, 19, 29));
    expect(
      formatRelativeDay(DateTime(2026, 10, 27), today: DateTime(2026, 10, 28)),
      '昨天',
    );
    expect(
      formatRelativeDay(DateTime(2026, 10, 26), today: DateTime(2026, 10, 28)),
      '星期一',
    );
  });

  testWidgets('locale switch updates const descendants and Material dialogs', (
    tester,
  ) async {
    await tester.pumpWidget(
      LocalizedApp(
        builder: (locale) => MaterialApp(
          locale: locale,
          supportedLocales: appLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: const Scaffold(
            body: Column(
              children: [
                LanguagePicker(),
                StatusBadge(status: RecordingStatus.completed),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('已完成'), findsOneWidget);
    await setLanguage('en');
    await tester.pumpAndSettle();
    expect(find.text('completed'), findsOneWidget);
    expect(find.text('已完成'), findsNothing);
    await setLanguage('zh');
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(StatusBadge));
    expect(MaterialLocalizations.of(context).cancelButtonLabel, '取消');
    expect(find.text('已完成'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
