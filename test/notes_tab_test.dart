import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speakr_app/api/providers.dart';
import 'package:speakr_app/api/speakr_api.dart';
import 'package:speakr_app/features/detail/tabs/notes_tab.dart';
import 'package:speakr_app/l10n/strings.dart';

void main() {
  testWidgets('failed note save preserves draft and retry saves it', (tester) async {
    applyLanguage('zh');
    final dio = Dio();
    var attempts = 0;
    var saved = 'original';
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      if (options.method == 'PUT') {
        attempts++;
        if (attempts == 1) {
          handler.reject(DioException(requestOptions: options, type: DioExceptionType.connectionError));
          return;
        }
        saved = options.data['notes'] as String;
      }
      handler.resolve(Response(requestOptions: options, statusCode: 200, data: {'notes': saved}));
    }));
    await tester.pumpWidget(ProviderScope(overrides: [speakrApiProvider.overrideWithValue(SpeakrApi(dio))], child: const MaterialApp(home: Scaffold(body: NotesTab(recordingId: 42)))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('编辑'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    await tester.enterText(find.byType(TextField), '# 我的笔记');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(find.text('保存失败，编辑内容已保留，请重试。'), findsOneWidget);
    expect(find.text('# 我的笔记'), findsOneWidget);
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(saved, '# 我的笔记');
    expect(find.text('我的笔记'), findsOneWidget);
    await tester.tap(find.text('编辑'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'discard me');
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(saved, '# 我的笔记');
    expect(find.text('我的笔记'), findsOneWidget);
    dio.close();
  });
}
