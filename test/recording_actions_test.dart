import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speakr_app/api/models.dart';
import 'package:speakr_app/api/providers.dart';
import 'package:speakr_app/api/speakr_api.dart';
import 'package:speakr_app/desktop/widgets/recording_action_menu.dart';
import 'package:speakr_app/l10n/strings.dart';

void main() {
  test('archive flag and audio/share API contracts', () async {
    expect(
      Recording.fromJson({'id': 1, 'is_archived': true}).isArchived,
      isTrue,
    );
    final dio = Dio();
    final requests = <RequestOptions>[];
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) {
          requests.add(o);
          h.resolve(
            Response(
              requestOptions: o,
              statusCode: 200,
              data: {'share_url': 'https://example.test/share/abc'},
            ),
          );
        },
      ),
    );
    final api = SpeakrApi(dio);
    await api.deleteRecordingAudio(7);
    expect(requests.last.path, '/recordings/7/delete-audio');
    expect(requests.last.method, 'POST');
    expect(await api.createRecordingShare(7), 'https://example.test/share/abc');
    expect(requests.last.data, {'share_summary': true, 'share_notes': false, 'force_new': true});
    dio.close();
  });
  testWidgets('audio deletion requires confirmation and cancel sends nothing', (
    tester,
  ) async {
    applyLanguage('zh');
    final dio = Dio();
    var writes = 0;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) {
          writes++;
          h.resolve(Response(requestOptions: o, statusCode: 200, data: {}));
        },
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [speakrApiProvider.overrideWithValue(SpeakrApi(dio))],
        child: const MaterialApp(
          home: Scaffold(
            body: RecordingActionMenu(
              recording: Recording(id: 7, status: RecordingStatus.completed),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('仅删除音频'));
    await tester.tap(find.text('仅删除音频'));
    await tester.pumpAndSettle();
    expect(find.text('仅删除音频？'), findsOneWidget);
    expect(writes, 0);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(writes, 0);
    dio.close();
  });
}


