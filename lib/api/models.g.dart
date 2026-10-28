// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Tag _$TagFromJson(Map<String, dynamic> json) => _Tag(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  color: json['color'] as String?,
  customPrompt: json['custom_prompt'] as String?,
  defaultLanguage: json['default_language'] as String?,
  defaultMinSpeakers: (json['default_min_speakers'] as num?)?.toInt(),
  defaultMaxSpeakers: (json['default_max_speakers'] as num?)?.toInt(),
);

Map<String, dynamic> _$TagToJson(_Tag instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'color': instance.color,
  'custom_prompt': instance.customPrompt,
  'default_language': instance.defaultLanguage,
  'default_min_speakers': instance.defaultMinSpeakers,
  'default_max_speakers': instance.defaultMaxSpeakers,
};

_Folder _$FolderFromJson(Map<String, dynamic> json) => _Folder(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  color: json['color'] as String?,
  recordingCount: (json['recording_count'] as num?)?.toInt(),
);

Map<String, dynamic> _$FolderToJson(_Folder instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'color': instance.color,
  'recording_count': instance.recordingCount,
};

_Speaker _$SpeakerFromJson(Map<String, dynamic> json) => _Speaker(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  hasVoiceProfile: json['has_voice_profile'] as bool? ?? false,
  useCount: (json['use_count'] as num?)?.toInt() ?? 0,
  lastUsed: _parseFlexibleDate(json['last_used']),
);

Map<String, dynamic> _$SpeakerToJson(_Speaker instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'has_voice_profile': instance.hasVoiceProfile,
  'use_count': instance.useCount,
  'last_used': instance.lastUsed?.toIso8601String(),
};

_SpeakerSuggestion _$SpeakerSuggestionFromJson(Map<String, dynamic> json) =>
    _SpeakerSuggestion(
      speakerId: (json['speaker_id'] as num).toInt(),
      name: json['name'] as String,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      similarity: (json['similarity'] as num?)?.toDouble() ?? 0.0,
      embeddingCount: (json['embedding_count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SpeakerSuggestionToJson(_SpeakerSuggestion instance) =>
    <String, dynamic>{
      'speaker_id': instance.speakerId,
      'name': instance.name,
      'confidence': instance.confidence,
      'similarity': instance.similarity,
      'embedding_count': instance.embeddingCount,
    };

_Recording _$RecordingFromJson(Map<String, dynamic> json) => _Recording(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String?,
  meetingDate: _parseFlexibleDate(json['meeting_date']),
  createdAt: _parseFlexibleDate(json['created_at']),
  participants: json['participants'] as String?,
  fileSize: (json['file_size'] as num?)?.toInt(),
  isHighlighted: json['is_highlighted'] as bool? ?? false,
  isArchived: json['is_archived'] as bool? ?? false,
  isInbox: json['is_inbox'] as bool? ?? false,
  status: json['status'] == null
      ? RecordingStatus.completed
      : _parseRecordingStatus(json['status']),
  tags:
      (json['tags'] as List<dynamic>?)
          ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Tag>[],
  folderId: (json['folder_id'] as num?)?.toInt(),
  folder: json['folder'] == null
      ? null
      : Folder.fromJson(json['folder'] as Map<String, dynamic>),
  audioAvailable: json['audio_available'] as bool?,
  errorMessage: json['error_message'] as String?,
  hasSummary: json['has_summary'] as bool?,
  hasTranscription: json['has_transcription'] as bool?,
  originalFilename: json['original_filename'] as String?,
  summary: json['summary'] as String?,
  notes: json['notes'] as String?,
  transcription: json['transcription'] as String?,
  audioDuration: (json['audio_duration'] as num?)?.toDouble(),
  transcriptionModel: json['transcription_model'] as String?,
  language: json['language'] as String?,
  minSpeakers: (json['min_speakers'] as num?)?.toInt(),
  maxSpeakers: (json['max_speakers'] as num?)?.toInt(),
  hotwords: json['hotwords'] as String?,
  initialPrompt: json['initial_prompt'] as String?,
);

Map<String, dynamic> _$RecordingToJson(_Recording instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'meeting_date': instance.meetingDate?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'participants': instance.participants,
      'file_size': instance.fileSize,
      'is_highlighted': instance.isHighlighted,
      'is_archived': instance.isArchived,
      'is_inbox': instance.isInbox,
      'status': _$RecordingStatusEnumMap[instance.status]!,
      'tags': instance.tags,
      'folder_id': instance.folderId,
      'folder': instance.folder,
      'audio_available': instance.audioAvailable,
      'error_message': instance.errorMessage,
      'has_summary': instance.hasSummary,
      'has_transcription': instance.hasTranscription,
      'original_filename': instance.originalFilename,
      'summary': instance.summary,
      'notes': instance.notes,
      'transcription': instance.transcription,
      'audio_duration': instance.audioDuration,
      'transcription_model': instance.transcriptionModel,
      'language': instance.language,
      'min_speakers': instance.minSpeakers,
      'max_speakers': instance.maxSpeakers,
      'hotwords': instance.hotwords,
      'initial_prompt': instance.initialPrompt,
    };

const _$RecordingStatusEnumMap = {
  RecordingStatus.pending: 'PENDING',
  RecordingStatus.queued: 'QUEUED',
  RecordingStatus.processing: 'PROCESSING',
  RecordingStatus.summarizing: 'SUMMARIZING',
  RecordingStatus.completed: 'COMPLETED',
  RecordingStatus.failed: 'FAILED',
};

_TranscriptionModelOption _$TranscriptionModelOptionFromJson(
  Map<String, dynamic> json,
) => _TranscriptionModelOption(
  label: json['label'] as String,
  value: json['value'] as String,
);

Map<String, dynamic> _$TranscriptionModelOptionToJson(
  _TranscriptionModelOption instance,
) => <String, dynamic>{'label': instance.label, 'value': instance.value};

_Config _$ConfigFromJson(Map<String, dynamic> json) => _Config(
  transcriptionModelOptions:
      (json['transcription_model_options'] as List<dynamic>?)
          ?.map(
            (e) => TranscriptionModelOption.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <TranscriptionModelOption>[],
  connectorSupportsDiarization:
      json['connector_supports_diarization'] as bool? ?? false,
  connectorSupportsSpeakerCount:
      json['connector_supports_speaker_count'] as bool? ?? false,
  connectorSupportsHotwords:
      json['connector_supports_hotwords'] as bool? ?? false,
  connectorSupportsInitialPrompt:
      json['connector_supports_initial_prompt'] as bool? ?? false,
  videoRetention: json['video_retention'] as bool? ?? false,
  maxFileSizeMb: (json['max_file_size_mb'] as num?)?.toInt(),
);

Map<String, dynamic> _$ConfigToJson(_Config instance) => <String, dynamic>{
  'transcription_model_options': instance.transcriptionModelOptions,
  'connector_supports_diarization': instance.connectorSupportsDiarization,
  'connector_supports_speaker_count': instance.connectorSupportsSpeakerCount,
  'connector_supports_hotwords': instance.connectorSupportsHotwords,
  'connector_supports_initial_prompt': instance.connectorSupportsInitialPrompt,
  'video_retention': instance.videoRetention,
  'max_file_size_mb': instance.maxFileSizeMb,
};

_RecordingPage _$RecordingPageFromJson(Map<String, dynamic> json) =>
    _RecordingPage(
      recordings:
          (json['recordings'] as List<dynamic>?)
              ?.map((e) => Recording.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Recording>[],
      page: (json['page'] as num?)?.toInt() ?? 1,
      perPage: (json['per_page'] as num?)?.toInt() ?? 25,
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$RecordingPageToJson(_RecordingPage instance) =>
    <String, dynamic>{
      'recordings': instance.recordings,
      'page': instance.page,
      'per_page': instance.perPage,
      'total': instance.total,
      'total_pages': instance.totalPages,
    };

_TranscriptSegment _$TranscriptSegmentFromJson(Map<String, dynamic> json) =>
    _TranscriptSegment(
      speaker: json['speaker'] as String?,
      startTime: (json['start_time'] as num?)?.toDouble(),
      endTime: (json['end_time'] as num?)?.toDouble(),
      sentence: json['sentence'] as String?,
    );

Map<String, dynamic> _$TranscriptSegmentToJson(_TranscriptSegment instance) =>
    <String, dynamic>{
      'speaker': instance.speaker,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'sentence': instance.sentence,
    };

_RecordingStatusResponse _$RecordingStatusResponseFromJson(
  Map<String, dynamic> json,
) => _RecordingStatusResponse(
  status: _parseRecordingStatus(json['status']),
  queuePosition: (json['queue_position'] as num?)?.toInt(),
  message: json['message'] as String?,
);

Map<String, dynamic> _$RecordingStatusResponseToJson(
  _RecordingStatusResponse instance,
) => <String, dynamic>{
  'status': _$RecordingStatusEnumMap[instance.status]!,
  'queue_position': instance.queuePosition,
  'message': instance.message,
};

_ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) =>
    _ChatMessage(role: json['role'] as String, text: json['text'] as String);

Map<String, dynamic> _$ChatMessageToJson(_ChatMessage instance) =>
    <String, dynamic>{'role': instance.role, 'text': instance.text};

_ChatResponse _$ChatResponseFromJson(Map<String, dynamic> json) =>
    _ChatResponse(response: json['response'] as String);

Map<String, dynamic> _$ChatResponseToJson(_ChatResponse instance) =>
    <String, dynamic>{'response': instance.response};

_StatsResponse _$StatsResponseFromJson(Map<String, dynamic> json) =>
    _StatsResponse(
      activity: json['activity'] == null
          ? null
          : StatsActivity.fromJson(json['activity'] as Map<String, dynamic>),
      queue: json['queue'] == null
          ? null
          : StatsQueue.fromJson(json['queue'] as Map<String, dynamic>),
      recordings: json['recordings'] == null
          ? null
          : StatsRecordings.fromJson(
              json['recordings'] as Map<String, dynamic>,
            ),
      storage: json['storage'] == null
          ? null
          : StatsStorage.fromJson(json['storage'] as Map<String, dynamic>),
      tokens: json['tokens'] == null
          ? null
          : StatsTokens.fromJson(json['tokens'] as Map<String, dynamic>),
      transcription: json['transcription'] == null
          ? null
          : StatsTranscription.fromJson(
              json['transcription'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$StatsResponseToJson(_StatsResponse instance) =>
    <String, dynamic>{
      'activity': instance.activity,
      'queue': instance.queue,
      'recordings': instance.recordings,
      'storage': instance.storage,
      'tokens': instance.tokens,
      'transcription': instance.transcription,
    };

_StatsActivity _$StatsActivityFromJson(Map<String, dynamic> json) =>
    _StatsActivity(
      lastTranscription: _parseFlexibleDate(json['last_transcription']),
      recordingsToday: (json['recordings_today'] as num?)?.toInt(),
    );

Map<String, dynamic> _$StatsActivityToJson(_StatsActivity instance) =>
    <String, dynamic>{
      'last_transcription': instance.lastTranscription?.toIso8601String(),
      'recordings_today': instance.recordingsToday,
    };

_StatsQueue _$StatsQueueFromJson(Map<String, dynamic> json) => _StatsQueue(
  jobsProcessing: (json['jobs_processing'] as num?)?.toInt(),
  jobsQueued: (json['jobs_queued'] as num?)?.toInt(),
);

Map<String, dynamic> _$StatsQueueToJson(_StatsQueue instance) =>
    <String, dynamic>{
      'jobs_processing': instance.jobsProcessing,
      'jobs_queued': instance.jobsQueued,
    };

_StatsRecordings _$StatsRecordingsFromJson(Map<String, dynamic> json) =>
    _StatsRecordings(
      completed: (json['completed'] as num?)?.toInt(),
      failed: (json['failed'] as num?)?.toInt(),
      pending: (json['pending'] as num?)?.toInt(),
      processing: (json['processing'] as num?)?.toInt(),
      total: (json['total'] as num?)?.toInt(),
    );

Map<String, dynamic> _$StatsRecordingsToJson(_StatsRecordings instance) =>
    <String, dynamic>{
      'completed': instance.completed,
      'failed': instance.failed,
      'pending': instance.pending,
      'processing': instance.processing,
      'total': instance.total,
    };

_StatsStorage _$StatsStorageFromJson(Map<String, dynamic> json) =>
    _StatsStorage(
      usedBytes: (json['used_bytes'] as num?)?.toInt(),
      usedHuman: json['used_human'] as String?,
    );

Map<String, dynamic> _$StatsStorageToJson(_StatsStorage instance) =>
    <String, dynamic>{
      'used_bytes': instance.usedBytes,
      'used_human': instance.usedHuman,
    };

_StatsTokens _$StatsTokensFromJson(Map<String, dynamic> json) => _StatsTokens(
  budget: (json['budget'] as num?)?.toInt(),
  percentage: (json['percentage'] as num?)?.toDouble(),
  usedThisMonth: (json['used_this_month'] as num?)?.toInt(),
);

Map<String, dynamic> _$StatsTokensToJson(_StatsTokens instance) =>
    <String, dynamic>{
      'budget': instance.budget,
      'percentage': instance.percentage,
      'used_this_month': instance.usedThisMonth,
    };

_StatsTranscription _$StatsTranscriptionFromJson(Map<String, dynamic> json) =>
    _StatsTranscription(
      budgetMinutes: (json['budget_minutes'] as num?)?.toInt(),
      budgetSeconds: (json['budget_seconds'] as num?)?.toInt(),
      estimatedCost: (json['estimated_cost'] as num?)?.toDouble(),
      percentage: (json['percentage'] as num?)?.toDouble(),
      usedThisMonthMinutes: (json['used_this_month_minutes'] as num?)?.toInt(),
      usedThisMonthSeconds: (json['used_this_month_seconds'] as num?)?.toInt(),
    );

Map<String, dynamic> _$StatsTranscriptionToJson(_StatsTranscription instance) =>
    <String, dynamic>{
      'budget_minutes': instance.budgetMinutes,
      'budget_seconds': instance.budgetSeconds,
      'estimated_cost': instance.estimatedCost,
      'percentage': instance.percentage,
      'used_this_month_minutes': instance.usedThisMonthMinutes,
      'used_this_month_seconds': instance.usedThisMonthSeconds,
    };
