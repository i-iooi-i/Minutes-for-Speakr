import 'package:speakr_app/l10n/strings.dart';
// Hand-rolled domain models for the Speakr REST API v1.
// Source of truth: openapi/speakr-openapi.json (info.version 1.0.0).
// Regenerate manually if the API gains new shapes.

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'models.freezed.dart';
part 'models.g.dart';

// The v1 list endpoint returns ISO-8601 timestamps; the unofficial detail
// endpoint at /api/recordings/{id} returns "Apr 23, 2026, 2:19:29 PM" with a
// U+202F narrow no-break space before AM/PM. Accept both shapes.
DateTime? _parseFlexibleDate(Object? raw) {
  if (raw is! String || raw.isEmpty) return null;
  DateTime? parsed = DateTime.tryParse(raw);
  if (parsed == null) {
    final normalized = raw.replaceAll(' ', ' ').replaceAll(' ', ' ');
    try {
      parsed = DateFormat("MMM d, yyyy, h:mm:ss a", "en_US").parse(normalized);
    } catch (_) {
      return null;
    }
  }
  // Both Speakr endpoints emit naive strings that semantically represent
  // UTC (v1 .isoformat() has no Z; the unofficial detail endpoint runs
  // through babel using the server's TIMEZONE env, default UTC). Dart
  // parses naive strings as local — reinterpret the components as UTC so
  // .toLocal() at display time produces the correct local wall clock.
  if (parsed.isUtc) return parsed;
  return DateTime.utc(
    parsed.year,
    parsed.month,
    parsed.day,
    parsed.hour,
    parsed.minute,
    parsed.second,
    parsed.millisecond,
    parsed.microsecond,
  );
}

enum RecordingStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('QUEUED')
  queued,
  @JsonValue('PROCESSING')
  processing,
  @JsonValue('SUMMARIZING')
  summarizing,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('FAILED')
  failed;

  bool get isInProgress =>
      this == RecordingStatus.pending ||
      this == RecordingStatus.queued ||
      this == RecordingStatus.processing ||
      this == RecordingStatus.summarizing;

  String get displayLabel => switch (this) {
    RecordingStatus.pending => tr("Pending"),
    RecordingStatus.queued => tr("Queued"),
    RecordingStatus.processing => tr("Processing"),
    RecordingStatus.summarizing => tr("Summarizing"),
    RecordingStatus.completed => tr("Completed"),
    RecordingStatus.failed => tr("Failed"),
  };
}

// Tolerant decoder so an unknown server-side status (e.g. a future addition
// the client doesn't know yet) shows up as in-progress instead of crashing
// the recordings list with an ArgumentError from $enumDecode.
RecordingStatus _parseRecordingStatus(Object? raw) {
  if (raw is! String) return RecordingStatus.pending;
  for (final v in RecordingStatus.values) {
    if (_$RecordingStatusEnumMap[v] == raw) return v;
  }
  return RecordingStatus.pending;
}

@freezed
sealed class Tag with _$Tag {
  const factory Tag({
    required int id,
    required String name,
    String? color,
    @JsonKey(name: 'custom_prompt') String? customPrompt,
    @JsonKey(name: 'default_language') String? defaultLanguage,
    @JsonKey(name: 'default_min_speakers') int? defaultMinSpeakers,
    @JsonKey(name: 'default_max_speakers') int? defaultMaxSpeakers,
  }) = _Tag;

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
}

// Server-side organizational folder. Each recording belongs to 0 or 1.
// `/recordings` payloads embed a denormalized stub `{id, name}` only — the
// color is fetched separately from `/folders` and looked up at render time.
@freezed
sealed class Folder with _$Folder {
  const factory Folder({
    required int id,
    required String name,
    String? color,
    @JsonKey(name: 'recording_count') int? recordingCount,
  }) = _Folder;

  factory Folder.fromJson(Map<String, dynamic> json) => _$FolderFromJson(json);
}

@freezed
sealed class Speaker with _$Speaker {
  const factory Speaker({
    required int id,
    required String name,
    @JsonKey(name: 'has_voice_profile') @Default(false) bool hasVoiceProfile,
    @JsonKey(name: 'use_count') @Default(0) int useCount,
    @JsonKey(name: 'last_used', fromJson: _parseFlexibleDate)
    DateTime? lastUsed,
  }) = _Speaker;

  factory Speaker.fromJson(Map<String, dynamic> json) =>
      _$SpeakerFromJson(json);
}

@freezed
sealed class SpeakerSuggestion with _$SpeakerSuggestion {
  const factory SpeakerSuggestion({
    @JsonKey(name: 'speaker_id') required int speakerId,
    required String name,
    @Default(0.0) double confidence,
    @Default(0.0) double similarity,
    @JsonKey(name: 'embedding_count') @Default(0) int embeddingCount,
  }) = _SpeakerSuggestion;

  factory SpeakerSuggestion.fromJson(Map<String, dynamic> json) =>
      _$SpeakerSuggestionFromJson(json);
}

@freezed
sealed class Recording with _$Recording {
  const factory Recording({
    required int id,
    String? title,
    @JsonKey(name: 'meeting_date', fromJson: _parseFlexibleDate)
    DateTime? meetingDate,
    @JsonKey(name: 'created_at', fromJson: _parseFlexibleDate)
    DateTime? createdAt,
    String? participants,
    @JsonKey(name: 'file_size') int? fileSize,
    @JsonKey(name: 'is_highlighted') @Default(false) bool isHighlighted,
    @JsonKey(name: 'is_archived') @Default(false) bool isArchived,
    @JsonKey(name: 'is_inbox') @Default(false) bool isInbox,
    @JsonKey(fromJson: _parseRecordingStatus)
    @Default(RecordingStatus.completed)
    RecordingStatus status,
    @Default(<Tag>[]) List<Tag> tags,

    @JsonKey(name: 'folder_id') int? folderId,
    Folder? folder,

    // Returned by the v1 list endpoint.
    @JsonKey(name: 'audio_available') bool? audioAvailable,
    @JsonKey(name: 'error_message') String? errorMessage,
    @JsonKey(name: 'has_summary') bool? hasSummary,
    @JsonKey(name: 'has_transcription') bool? hasTranscription,
    @JsonKey(name: 'original_filename') String? originalFilename,

    // Optional rich fields returned by the unofficial /api/recordings/{id}.
    String? summary,
    String? notes,
    String? transcription,
    @JsonKey(name: 'audio_duration') double? audioDuration,

    // Optional transcription parameters — present on the unofficial detail
    // endpoint when set; absent otherwise. Used to pre-fill the reprocess
    // transcription dialog.
    @JsonKey(name: 'transcription_model') String? transcriptionModel,
    String? language,
    @JsonKey(name: 'min_speakers') int? minSpeakers,
    @JsonKey(name: 'max_speakers') int? maxSpeakers,
    String? hotwords,
    @JsonKey(name: 'initial_prompt') String? initialPrompt,
  }) = _Recording;

  factory Recording.fromJson(Map<String, dynamic> json) =>
      _$RecordingFromJson(json);
}

// Response from the unofficial GET /api/config. Only the fields the client
// uses are typed; everything else is ignored by json_serializable.
@freezed
sealed class TranscriptionModelOption with _$TranscriptionModelOption {
  const factory TranscriptionModelOption({
    required String label,
    required String value,
  }) = _TranscriptionModelOption;

  factory TranscriptionModelOption.fromJson(Map<String, dynamic> json) =>
      _$TranscriptionModelOptionFromJson(json);
}

@freezed
sealed class Config with _$Config {
  const factory Config({
    @JsonKey(name: 'transcription_model_options')
    @Default(<TranscriptionModelOption>[])
    List<TranscriptionModelOption> transcriptionModelOptions,
    @JsonKey(name: 'connector_supports_diarization')
    @Default(false)
    bool connectorSupportsDiarization,
    @JsonKey(name: 'connector_supports_speaker_count')
    @Default(false)
    bool connectorSupportsSpeakerCount,
    @JsonKey(name: 'connector_supports_hotwords')
    @Default(false)
    bool connectorSupportsHotwords,
    @JsonKey(name: 'connector_supports_initial_prompt')
    @Default(false)
    bool connectorSupportsInitialPrompt,
    // Server keeps the video stream of uploads (VIDEO_RETENTION). When
    // false, an uploaded .mp4 is reduced to its audio.
    @JsonKey(name: 'video_retention') @Default(false) bool videoRetention,
    // Upload limit for files the server stores as-is, video included.
    @JsonKey(name: 'max_file_size_mb') int? maxFileSizeMb,
  }) = _Config;

  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);
}

@freezed
sealed class RecordingPage with _$RecordingPage {
  const factory RecordingPage({
    @Default(<Recording>[]) List<Recording> recordings,
    @Default(1) int page,
    @JsonKey(name: 'per_page') @Default(25) int perPage,
    @Default(0) int total,
    @JsonKey(name: 'total_pages') @Default(1) int totalPages,
  }) = _RecordingPage;

  factory RecordingPage.fromJson(Map<String, dynamic> json) =>
      _$RecordingPageFromJson(json);
}

@freezed
sealed class TranscriptSegment with _$TranscriptSegment {
  const factory TranscriptSegment({
    String? speaker,
    @JsonKey(name: 'start_time') double? startTime,
    @JsonKey(name: 'end_time') double? endTime,
    String? sentence,
  }) = _TranscriptSegment;

  factory TranscriptSegment.fromJson(Map<String, dynamic> json) =>
      _$TranscriptSegmentFromJson(json);
}

@freezed
sealed class RecordingStatusResponse with _$RecordingStatusResponse {
  const factory RecordingStatusResponse({
    @JsonKey(fromJson: _parseRecordingStatus) required RecordingStatus status,
    @JsonKey(name: 'queue_position') int? queuePosition,
    String? message,
  }) = _RecordingStatusResponse;

  factory RecordingStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$RecordingStatusResponseFromJson(json);
}

@freezed
sealed class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String role, // "user" | "assistant"
    required String text,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

@freezed
sealed class ChatResponse with _$ChatResponse {
  const factory ChatResponse({
    @JsonKey(name: 'response') required String response,
  }) = _ChatResponse;

  factory ChatResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatResponseFromJson(json);
}

@freezed
sealed class StatsResponse with _$StatsResponse {
  const factory StatsResponse({
    StatsActivity? activity,
    StatsQueue? queue,
    StatsRecordings? recordings,
    StatsStorage? storage,
    StatsTokens? tokens,
    StatsTranscription? transcription,
  }) = _StatsResponse;

  factory StatsResponse.fromJson(Map<String, dynamic> json) =>
      _$StatsResponseFromJson(json);
}

@freezed
sealed class StatsActivity with _$StatsActivity {
  const factory StatsActivity({
    @JsonKey(name: 'last_transcription', fromJson: _parseFlexibleDate)
    DateTime? lastTranscription,
    @JsonKey(name: 'recordings_today') int? recordingsToday,
  }) = _StatsActivity;

  factory StatsActivity.fromJson(Map<String, dynamic> json) =>
      _$StatsActivityFromJson(json);
}

@freezed
sealed class StatsQueue with _$StatsQueue {
  const factory StatsQueue({
    @JsonKey(name: 'jobs_processing') int? jobsProcessing,
    @JsonKey(name: 'jobs_queued') int? jobsQueued,
  }) = _StatsQueue;

  factory StatsQueue.fromJson(Map<String, dynamic> json) =>
      _$StatsQueueFromJson(json);
}

@freezed
sealed class StatsRecordings with _$StatsRecordings {
  const factory StatsRecordings({
    int? completed,
    int? failed,
    int? pending,
    int? processing,
    int? total,
  }) = _StatsRecordings;

  factory StatsRecordings.fromJson(Map<String, dynamic> json) =>
      _$StatsRecordingsFromJson(json);
}

@freezed
sealed class StatsStorage with _$StatsStorage {
  const factory StatsStorage({
    @JsonKey(name: 'used_bytes') int? usedBytes,
    @JsonKey(name: 'used_human') String? usedHuman,
  }) = _StatsStorage;

  factory StatsStorage.fromJson(Map<String, dynamic> json) =>
      _$StatsStorageFromJson(json);
}

@freezed
sealed class StatsTokens with _$StatsTokens {
  const factory StatsTokens({
    int? budget,
    double? percentage,
    @JsonKey(name: 'used_this_month') int? usedThisMonth,
  }) = _StatsTokens;

  factory StatsTokens.fromJson(Map<String, dynamic> json) =>
      _$StatsTokensFromJson(json);
}

@freezed
sealed class StatsTranscription with _$StatsTranscription {
  const factory StatsTranscription({
    @JsonKey(name: 'budget_minutes') int? budgetMinutes,
    @JsonKey(name: 'budget_seconds') int? budgetSeconds,
    @JsonKey(name: 'estimated_cost') double? estimatedCost,
    double? percentage,
    @JsonKey(name: 'used_this_month_minutes') int? usedThisMonthMinutes,
    @JsonKey(name: 'used_this_month_seconds') int? usedThisMonthSeconds,
  }) = _StatsTranscription;

  factory StatsTranscription.fromJson(Map<String, dynamic> json) =>
      _$StatsTranscriptionFromJson(json);
}
