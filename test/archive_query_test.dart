import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speakr_app/api/speakr_api.dart';
void main() {
 test('archive filter is a boolean query and preserves other filters', () async {
 final dio = Dio();
 final requests = <RequestOptions>[];
 dio.interceptors.add(InterceptorsWrapper(onRequest: (o,h) {
 requests.add(o);
 h.resolve(Response(requestOptions:o,statusCode:200,data:{'recordings': [], 'page':1,'per_page':50,'total':0,'total_pages':1}));
 }));
 final api=SpeakrApi(dio);
 await api.listRecordings(archived:true, folderId:3, query:'review');
 expect(requests.last.queryParameters['archived'],'true');
 expect(requests.last.queryParameters['folder_id'],3);
 expect(requests.last.queryParameters['q'],'review');
 expect(requests.last.queryParameters.containsKey('status'),false);
 await api.listRecordings();
 expect(requests.last.queryParameters.containsKey('archived'),false);
 dio.close();
 });
}
