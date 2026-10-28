import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speakr_app/api/models.dart';
import 'package:speakr_app/api/speakr_api.dart';
import 'package:speakr_app/features/detail/recording_statistics.dart';

void main() {
  test('speaker timing merges overlapping segments and excludes invalid timestamps', () {
    final rows = recordingSpeakerActivity([
      const TranscriptSegment(speaker: 'A', sentence: 'one', startTime: 0, endTime: 10),
      const TranscriptSegment(speaker: 'A', sentence: 'two', startTime: 5, endTime: 15),
      const TranscriptSegment(speaker: 'A', sentence: 'three', startTime: 20, endTime: 18),
      const TranscriptSegment(speaker: 'B', sentence: 'four'),
    ]);
    expect(rows[0].seconds, 15);
    expect(rows[0].segments, 3);
    expect(rows[0].timedSegments, 2);
    expect(rows[1].seconds, 0);
    expect(rows[1].timedSegments, 0);
  });
  test('empty transcript does not invent a speaker or duration', () {
    expect(recordingSpeakerActivity([]), isEmpty);
    expect(recordingSpeakerActivity([const TranscriptSegment(sentence: ' ')]), isEmpty);
  });
  test('notes API reads markdown and sends empty text to explicitly clear notes', () async {
    final dio = Dio();
    final requests = <RequestOptions>[];
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      requests.add(options);
      handler.resolve(Response(requestOptions: options, statusCode: 200, data: {'notes': options.method == 'GET' ? '# Notes\n- 中文' : options.data['notes']}));
    }));
    final api = SpeakrApi(dio);
    expect(await api.getRecordingNotes(42), '# Notes\n- 中文');
    await api.saveRecordingNotes(42, '');
    expect(requests.map((r) => r.method), ['GET', 'PUT']);
    expect(requests.last.path, '/recordings/42/notes');
    expect(requests.last.data, {'notes': ''});
    dio.close();
  });
}
