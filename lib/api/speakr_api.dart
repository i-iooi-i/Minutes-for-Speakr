import 'package:speakr_app/l10n/strings.dart';
// Thin Dio-based client over the Speakr API v1.
// One method per OpenAPI operation that the UI actually calls. Other
// operations from openapi/speakr-openapi.json can be added as needed.

import 'dart:io';

import 'package:dio/dio.dart';

import 'models.dart';

class SpeakrApiException implements Exception {
  SpeakrApiException(this.statusCode, this.message, [this.cause]);
  final int? statusCode;
  final String message;
  final Object? cause;

  @override
  String toString() => 'SpeakrApiException($statusCode): $message';
}

class SpeakrApi {
  SpeakrApi(this._dio);

  final Dio _dio;
  Dio get dio => _dio;

  // ── Recordings ────────────────────────────────────────────────────────────
  Future<RecordingPage> listRecordings({
    int page = 1,
    int perPage = 25,
    String? status,
    bool? archived,
    String sortBy = 'meeting_date',
    String sortOrder = 'desc',
    int? tagId,
    int? folderId,
    String? query,
  }) async {
    final res = await _get<Map<String, dynamic>>(
      '/recordings',
      query: {
        'page': page,
        'per_page': perPage,
        if (status != null) 'status': status,
        if (archived != null) 'archived': archived.toString(),
        'sort_by': sortBy,
        'sort_order': sortOrder,
        if (tagId != null) 'tag_id': tagId,
        if (folderId != null) 'folder_id': folderId,
        if (query != null && query.isNotEmpty) 'q': query,
      },
    );
    return RecordingPage.fromJson(res);
  }

  // Uses the unofficial /api/recordings/{id} endpoint (no /v1) — it returns
  // richer data than the v1 detail endpoint, including audio_duration.
  Future<Recording> getRecording(int id) async {
    final res = await _request<Map<String, dynamic>>(
      () => _dio.get<Map<String, dynamic>>(
        '/recordings/$id',
        options: Options(extra: {'useRootApi': true}),
      ),
    );
    return Recording.fromJson(_unwrap(res, 'recording'));
  }

  Future<String> getRecordingNotes(int id) async {
    final res = await _get<Map<String, dynamic>>('/recordings/$id/notes');
    return res['notes'] as String? ?? '';
  }

  Future<void> saveRecordingNotes(int id, String notes) async {
    await _put<Map<String, dynamic>>('/recordings/$id/notes', {'notes': notes});
  }

  Future<RecordingStatusResponse> getStatus(int id) async {
    final res = await _get<Map<String, dynamic>>('/recordings/$id/status');
    return RecordingStatusResponse.fromJson(res);
  }

  Future<Recording> updateRecording(int id, Map<String, dynamic> patch) async {
    final res = await _patch<Map<String, dynamic>>('/recordings/$id', patch);
    return Recording.fromJson(_unwrap(res, 'recording'));
  }

  Future<void> deleteRecording(int id) async {
    await _delete<void>('/recordings/$id');
  }

  Future<ChatResponse> chat(
    int id,
    String message, {
    List<ChatMessage> history = const [],
  }) async {
    final body = {
      'message': message,
      'conversation_history': history
          .map((m) => {'role': m.role, 'text': m.text})
          .toList(growable: false),
    };
    final res = await _post<Map<String, dynamic>>('/recordings/$id/chat', body);
    return ChatResponse.fromJson(res);
  }

  Future<Recording> uploadRecording({
    required File file,
    String? language,
    int? minSpeakers,
    int? maxSpeakers,
    List<int> tagIds = const [],
    int? folderId,
    DateTime? fileLastModified,
    String? notes,
    void Function(int sent, int total)? onProgress,
    Duration? sendTimeout,
  }) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split(RegExp(r'[\\/]')).last,
      ),
      if (language != null) 'language': language,
      if (minSpeakers != null) 'min_speakers': minSpeakers,
      if (maxSpeakers != null) 'max_speakers': maxSpeakers,
      if (folderId != null) 'folder_id': folderId,
      if (fileLastModified != null)
        'file_last_modified': fileLastModified.millisecondsSinceEpoch
            .toString(),
      if (notes != null) 'notes': notes,
      for (var i = 0; i < tagIds.length; i++) 'tag_ids[$i]': tagIds[i],
    });
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/recordings/upload',
        data: form,
        onSendProgress: onProgress,
        options: sendTimeout == null ? null : Options(sendTimeout: sendTimeout),
      );
      return Recording.fromJson(_unwrap(res.data ?? {}, 'recording'));
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Uri audioUrl(int id) {
    final base = _dio.options.baseUrl;
    return Uri.parse('$base/recordings/$id/audio');
  }

  // ── Tags ──────────────────────────────────────────────────────────────────
  Future<List<Tag>> listTags() async {
    final res = await _get<dynamic>('/tags');
    final list = res is List
        ? res
        : (res is Map<String, dynamic> ? (res['tags'] as List? ?? []) : []);
    return list
        .whereType<Map<String, dynamic>>()
        .map(Tag.fromJson)
        .toList(growable: false);
  }

  // ── Folders ───────────────────────────────────────────────────────────────
  Future<List<Folder>> listFolders() async {
    final res = await _get<dynamic>('/folders');
    final list = res is List
        ? res
        : (res is Map<String, dynamic> ? (res['folders'] as List? ?? []) : []);
    return list
        .whereType<Map<String, dynamic>>()
        .map(Folder.fromJson)
        .toList(growable: false);
  }

  Future<Tag> createTag({
    required String name,
    String? color,
    String? customPrompt,
  }) async {
    final res = await _post<Map<String, dynamic>>('/tags', {
      'name': name,
      if (color != null) 'color': color,
      if (customPrompt != null) 'custom_prompt': customPrompt,
    });
    return Tag.fromJson(_unwrap(res, 'tag'));
  }

  Future<void> addTagsToRecording(int recId, List<int> tagIds) async {
    await _post<Map<String, dynamic>>('/recordings/$recId/tags', {
      'tag_ids': tagIds,
    });
  }

  Future<void> removeTagFromRecording(int recId, int tagId) async {
    await _delete<void>('/recordings/$recId/tags/$tagId');
  }

  // ── Processing ────────────────────────────────────────────────────────────
  Future<void> reprocessTranscription(
    int id, {
    String? transcriptionModel,
    String? language,
    int? minSpeakers,
    int? maxSpeakers,
    String? hotwords,
    String? initialPrompt,
  }) async {
    await _post<Map<String, dynamic>>('/recordings/$id/transcribe', {
      if (transcriptionModel != null) 'transcription_model': transcriptionModel,
      if (language != null) 'language': language,
      if (minSpeakers != null) 'min_speakers': minSpeakers,
      if (maxSpeakers != null) 'max_speakers': maxSpeakers,
      if (hotwords != null) 'hotwords': hotwords,
      if (initialPrompt != null) 'initial_prompt': initialPrompt,
    });
  }

  Future<void> reprocessSummary(int id, {String? customPrompt}) async {
    await _post<Map<String, dynamic>>('/recordings/$id/summarize', {
      if (customPrompt != null) 'custom_prompt': customPrompt,
    });
  }

  // ── Speakers ──────────────────────────────────────────────────────────────
  // Response shape isn't in the OpenAPI schema, so the raw map is returned
  // and parsed defensively at the call site. Example body:
  //   {"speakers": [{"label": "...", "identified_name": null,
  //                   "segment_count": 13, "speaker_id": null}, ...],
  //    "suggestions": {}}
  Future<Map<String, dynamic>> getRecordingSpeakers(int id) async {
    return _get<Map<String, dynamic>>('/recordings/$id/speakers');
  }

  Future<void> assignSpeakers(
    int id, {
    required Map<String, dynamic> speakerMap,
    bool regenerateSummary = false,
  }) async {
    await _put<Map<String, dynamic>>('/recordings/$id/speakers/assign', {
      'speaker_map': speakerMap,
      'regenerate_summary': regenerateSummary,
    });
  }

  Future<List<Speaker>> listSpeakers() async {
    final res = await _get<dynamic>('/speakers');
    final list = res is List
        ? res
        : (res is Map<String, dynamic> ? (res['speakers'] as List? ?? []) : []);
    return list
        .whereType<Map<String, dynamic>>()
        .map(Speaker.fromJson)
        .toList(growable: false);
  }

  // GET /api/speakers/suggestions/{recording_id} — root API (no /v1).
  // Returns label → ranked list (best first). Empty list and missing key are
  // treated identically by callers.
  // GET /speakers/suggestions/{recording_id} — bare host path, no /api prefix.
  // Returns label → ranked list (best first). Empty list and missing key are
  // treated identically by callers.
  Future<Map<String, List<SpeakerSuggestion>>> getSpeakerSuggestions(
    int recordingId,
  ) async {
    final res = await _request<Map<String, dynamic>>(
      () => _dio.get<Map<String, dynamic>>(
        '/speakers/suggestions/$recordingId',
        options: Options(extra: {'noApiPrefix': true}),
      ),
    );
    if (res['success'] == false) {
      throw SpeakrApiException(
        null,
        (res['error'] ?? tr("Failed to load suggestions")).toString(),
      );
    }
    final raw = res['suggestions'];
    if (raw is! Map) return const {};
    final out = <String, List<SpeakerSuggestion>>{};
    raw.forEach((key, value) {
      if (key is! String || value is! List) return;
      out[key] = value
          .whereType<Map<String, dynamic>>()
          .map(SpeakerSuggestion.fromJson)
          .toList(growable: false);
    });
    return out;
  }

  // ── Config ────────────────────────────────────────────────────────────────
  // Unofficial /api/config — exposes the admin-curated transcription model
  // list and connector capability flags. Lives at /api (not /api/v1).
  Future<Config> getConfig() async {
    final res = await _request<Map<String, dynamic>>(
      () => _dio.get<Map<String, dynamic>>(
        '/config',
        options: Options(extra: {'useRootApi': true}),
      ),
    );
    return Config.fromJson(res);
  }

  // ── Settings ──────────────────────────────────────────────────────────────
  Future<void> setAutoSummarization(bool enabled) async {
    await _put<Map<String, dynamic>>('/settings/auto-summarization', {
      'enabled': enabled,
    });
  }

  // ── Stats ─────────────────────────────────────────────────────────────────
  Future<StatsResponse> getStats({String scope = 'user'}) async {
    final res = await _get<Map<String, dynamic>>(
      '/stats',
      query: {'scope': scope},
    );
    return StatsResponse.fromJson(res);
  }

  /// Lightweight reachability/auth check used by the onboarding screen.
  Future<bool> ping() async {
    try {
      await _get<dynamic>('/stats', query: {'scope': 'user'});
      return true;
    } on SpeakrApiException catch (e) {
      if (e.statusCode != null && e.statusCode! >= 400 && e.statusCode! < 500) {
        return false;
      }
      rethrow;
    }
  }

  Future<void> deleteRecordingAudio(int id) async {
    await _post<dynamic>('/recordings/$id/delete-audio', {});
  }

  Future<String> createRecordingShare(int id) async {
    final res = await _post<Map<String, dynamic>>('/recordings/$id/share', {
      'share_summary': true,
      'share_notes': false,
      'force_new': true,
    });
    final url = res['share_url'];
    if (url is! String || Uri.tryParse(url)?.scheme != 'https') {
      throw SpeakrApiException(null, 'Invalid share URL', null);
    }
    return url;
  }

  // ── Internals ─────────────────────────────────────────────────────────────
  Future<T> _get<T>(String path, {Map<String, dynamic>? query}) =>
      _request<T>(() => _dio.get<T>(path, queryParameters: query));
  Future<T> _post<T>(String path, dynamic body) =>
      _request<T>(() => _dio.post<T>(path, data: body));
  Future<T> _put<T>(String path, dynamic body) =>
      _request<T>(() => _dio.put<T>(path, data: body));
  Future<T> _patch<T>(String path, dynamic body) =>
      _request<T>(() => _dio.patch<T>(path, data: body));
  Future<T> _delete<T>(String path) => _request<T>(() => _dio.delete<T>(path));

  Future<T> _request<T>(Future<Response<T>> Function() send) async {
    try {
      final res = await send();
      return res.data as T;
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  // Some endpoints wrap the entity in `{recording: {...}}` or `{tag: {...}}`.
  // Accept either shape.
  Map<String, dynamic> _unwrap(Map<String, dynamic> body, String key) {
    final inner = body[key];
    if (inner is Map<String, dynamic>) return inner;
    return body;
  }

  SpeakrApiException _toApiException(DioException e) {
    final code = e.response?.statusCode;
    final data = e.response?.data;
    String msg = e.message ?? tr("Network error");
    if (data is Map<String, dynamic>) {
      msg = (data['error'] ?? data['message'] ?? msg).toString();
    } else if (data is String && data.isNotEmpty) {
      msg = data;
    }
    return SpeakrApiException(code, msg, e);
  }
}
