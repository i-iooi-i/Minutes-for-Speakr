import 'dart:io' show Platform;

/// Plain immutable value object for one folder watched by auto-upload.
/// A list of these is persisted via [AutoUploadSettingsStore] as a JSON
/// array in SharedPreferences.
///
/// Kept hand-rolled (no Freezed) because the field set is small and
/// codegen would just add build-runner round-trips.
class FolderUploadConfig {
  const FolderUploadConfig({
    required this.id,
    this.enabled = false,
    this.folderPath,
    this.treeUri,
    this.parsePresetId,
    this.customRegex,
    this.customCaptureGroup,
    this.customFormat,
    this.tagId,
    this.folderId,
    this.language,
    this.minSpeakers,
    this.maxSpeakers,
    this.autoDeleteShorterThanSeconds,
  });

  /// Mints a fresh entry with a locally-unique id. Used by the UI when
  /// the user adds a new folder.
  factory FolderUploadConfig.newEntry({String? folderPath, String? treeUri}) {
    return FolderUploadConfig(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      enabled: true,
      folderPath: folderPath,
      treeUri: treeUri,
    );
  }

  factory FolderUploadConfig.fromJson(Map<String, dynamic> json) {
    return FolderUploadConfig(
      id: json['id'] as String,
      enabled: json['enabled'] as bool? ?? false,
      folderPath: json['folderPath'] as String?,
      treeUri: json['treeUri'] as String?,
      parsePresetId: json['parsePresetId'] as String?,
      customRegex: json['customRegex'] as String?,
      customCaptureGroup: (json['customCaptureGroup'] as num?)?.toInt(),
      customFormat: json['customFormat'] as String?,
      tagId: (json['tagId'] as num?)?.toInt(),
      folderId: (json['folderId'] as num?)?.toInt(),
      language: json['language'] as String?,
      minSpeakers: (json['minSpeakers'] as num?)?.toInt(),
      maxSpeakers: (json['maxSpeakers'] as num?)?.toInt(),
      autoDeleteShorterThanSeconds:
          (json['autoDeleteShorterThanSeconds'] as num?)?.toInt(),
    );
  }

  final String id;
  final bool enabled;

  /// Human-readable location of the watched folder. On Windows this is the
  /// real filesystem path the worker reads with `dart:io`. On Android it is
  /// display-only: the worker operates on [treeUri] instead.
  final String? folderPath;

  /// Android only: the persisted `ACTION_OPEN_DOCUMENT_TREE` grant the
  /// worker enumerates, reads and deletes through. Null on Windows, and
  /// null for Android entries saved before the Storage Access Framework
  /// migration — those must be re-picked once (see [needsAndroidGrant]).
  final String? treeUri;

  /// Identifier of a preset in [kDateTimePresets] or `'custom'`. `null`
  /// means filename parsing is off; the worker uses the file's mtime.
  final String? parsePresetId;

  /// Only consulted when [parsePresetId] == `'custom'`.
  final String? customRegex;
  final int? customCaptureGroup;
  final String? customFormat;

  /// Tag id automatically attached to every auto-upload. `null` = no tag.
  final int? tagId;

  /// Speakr folder id every auto-upload from this watched folder is filed
  /// into. `null` = leave the recording unfiled.
  final int? folderId;

  final String? language;
  final int? minSpeakers;
  final int? maxSpeakers;

  /// If non-null, files in this folder whose decoded audio duration is
  /// strictly shorter than this many seconds are deleted from disk by the
  /// auto-upload worker without being uploaded. `null` disables the check.
  final int? autoDeleteShorterThanSeconds;

  bool get hasFolder =>
      (folderPath != null && folderPath!.isNotEmpty) || treeUri != null;
  bool get parsingEnabled => parsePresetId != null;

  /// True for an Android entry that still carries only a legacy raw path
  /// and no tree grant. The worker cannot read it; the UI asks the user to
  /// re-select the folder.
  bool get needsAndroidGrant =>
      Platform.isAndroid && hasFolder && treeUri == null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'enabled': enabled,
    if (folderPath != null) 'folderPath': folderPath,
    if (treeUri != null) 'treeUri': treeUri,
    if (parsePresetId != null) 'parsePresetId': parsePresetId,
    if (customRegex != null) 'customRegex': customRegex,
    if (customCaptureGroup != null) 'customCaptureGroup': customCaptureGroup,
    if (customFormat != null) 'customFormat': customFormat,
    if (tagId != null) 'tagId': tagId,
    if (folderId != null) 'folderId': folderId,
    if (language != null) 'language': language,
    if (minSpeakers != null) 'minSpeakers': minSpeakers,
    if (maxSpeakers != null) 'maxSpeakers': maxSpeakers,
    if (autoDeleteShorterThanSeconds != null)
      'autoDeleteShorterThanSeconds': autoDeleteShorterThanSeconds,
  };

  FolderUploadConfig copyWith({
    String? id,
    bool? enabled,
    Object? folderPath = _sentinel,
    Object? treeUri = _sentinel,
    Object? parsePresetId = _sentinel,
    Object? customRegex = _sentinel,
    Object? customCaptureGroup = _sentinel,
    Object? customFormat = _sentinel,
    Object? tagId = _sentinel,
    Object? folderId = _sentinel,
    Object? language = _sentinel,
    Object? minSpeakers = _sentinel,
    Object? maxSpeakers = _sentinel,
    Object? autoDeleteShorterThanSeconds = _sentinel,
  }) {
    return FolderUploadConfig(
      id: id ?? this.id,
      enabled: enabled ?? this.enabled,
      folderPath: folderPath == _sentinel
          ? this.folderPath
          : folderPath as String?,
      treeUri: treeUri == _sentinel ? this.treeUri : treeUri as String?,
      parsePresetId: parsePresetId == _sentinel
          ? this.parsePresetId
          : parsePresetId as String?,
      customRegex: customRegex == _sentinel
          ? this.customRegex
          : customRegex as String?,
      customCaptureGroup: customCaptureGroup == _sentinel
          ? this.customCaptureGroup
          : customCaptureGroup as int?,
      customFormat: customFormat == _sentinel
          ? this.customFormat
          : customFormat as String?,
      tagId: tagId == _sentinel ? this.tagId : tagId as int?,
      folderId: folderId == _sentinel ? this.folderId : folderId as int?,
      language: language == _sentinel ? this.language : language as String?,
      minSpeakers: minSpeakers == _sentinel
          ? this.minSpeakers
          : minSpeakers as int?,
      maxSpeakers: maxSpeakers == _sentinel
          ? this.maxSpeakers
          : maxSpeakers as int?,
      autoDeleteShorterThanSeconds: autoDeleteShorterThanSeconds == _sentinel
          ? this.autoDeleteShorterThanSeconds
          : autoDeleteShorterThanSeconds as int?,
    );
  }
}

const Object _sentinel = Object();
