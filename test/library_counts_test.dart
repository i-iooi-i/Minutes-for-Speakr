import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speakr_app/api/providers.dart';
import 'package:speakr_app/api/speakr_api.dart';
import 'package:speakr_app/features/library/library_controller.dart';
void main() {
 test('global counts traverse pages and do not follow library filters', () async {
 final dio = Dio(); var calls = 0;
 dio.interceptors.add(InterceptorsWrapper(onRequest: (o,h) {
 calls++;
 expect(o.queryParameters.containsKey('folder_id'),false);
 expect(o.queryParameters.containsKey('archived'),false);
 final page=o.queryParameters['page'];
 h.resolve(Response(requestOptions:o,statusCode:200,data:{'recordings':[{'id':page,'is_highlighted':page==2,'folder_id':3}], 'page':page,'per_page':1,'total':2,'total_pages':2}));
 }));
 final c=ProviderContainer(overrides:[speakrApiProvider.overrideWithValue(SpeakrApi(dio))]);
 addTearDown(c.dispose); addTearDown(dio.close);
 final records=await c.read(libraryCountsRecordingsProvider.future);
 expect(records.length,2); expect(records.where((r)=>r.isHighlighted).length,1);
 c.read(libraryFilterProvider.notifier).setStatus('archived');
 c.read(libraryFilterProvider.notifier).setFolder(99);
 c.read(libraryFilterProvider.notifier).setQuery('missing');
 expect((await c.read(libraryCountsRecordingsProvider.future)).length,2);
 expect(calls,2);
 c.read(uploadKickProvider.notifier).state++;
 await c.read(libraryCountsRecordingsProvider.future);
 expect(calls,4);
 });
}
