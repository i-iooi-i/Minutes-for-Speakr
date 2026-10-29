import 'package:flutter/foundation.dart';

/// How a mic-using app is matched against the allowlist. Win32 apps
/// register under `NonPackaged` with their full exe path; MSIX apps
/// register under their package family name (e.g. `MSTeams_8wekyb3d8bbwe`).
enum AllowlistKind {
  /// Match on the .exe basename, case-insensitively (e.g. `Teams.exe`).
  exeBasename,

  /// Match if the app's MSIX package family starts with this prefix
  /// (e.g. `MSTeams` matches `MSTeams_8wekyb3d8bbwe`).
  packagedPrefix,
}

/// Per-app and global scope for system-audio capture.
///
/// * [allSystem] — mix every app's audio (today's behavior; the recorder
///   uses WASAPI loopback against the default render endpoint).
/// * [processOnly] — only audio from the trigger process tree is mixed.
///   Requires Windows build ≥ 20348 (Server 2022 / Windows 11);
///   silently degrades to [allSystem] on older Windows when chosen as
///   a per-app preference, with a one-time warning on the live screen.
enum SystemAudioScope { allSystem, processOnly }

SystemAudioScope? _scopeFromJson(Object? raw) {
  if (raw is! String) return null;
  switch (raw) {
    case 'all':
      return SystemAudioScope.allSystem;
    case 'process':
      return SystemAudioScope.processOnly;
    default:
      return null;
  }
}

String _scopeToJson(SystemAudioScope scope) =>
    scope == SystemAudioScope.processOnly ? 'process' : 'all';

@immutable
class AllowlistEntry {
  const AllowlistEntry({
    required this.key,
    required this.displayName,
    required this.kind,
    this.speakers,
    this.tagIds = const [],
    this.folderId,
    this.micEnabled,
    this.systemEnabled,
    this.systemScope,
    this.videoEnabled,
  });

  /// The match value: an exe basename or an MSIX family prefix. Stored
  /// verbatim; comparison is case-insensitive.
  final String key;

  /// Human-readable name shown in the UI ("Microsoft Teams").
  final String displayName;

  final AllowlistKind kind;

  /// Per-app speaker count override. `null` means use
  /// [AutoRecordSettings.defaultSpeakers].
  final int? speakers;

  /// Per-app tag IDs to attach to recordings triggered by this app.
  /// Empty means use [AutoRecordSettings.defaultTagIds].
  final List<int> tagIds;

  /// Per-app Speakr folder id to file recordings triggered by this app
  /// into. `null` means use [AutoRecordSettings.defaultFolderId].
  final int? folderId;

  /// Per-app override for whether the microphone source is recorded.
  /// `null` means use [AutoRecordSettings.defaultMicEnabled].
  final bool? micEnabled;

  /// Per-app override for whether the system-audio source is recorded.
  /// `null` means use [AutoRecordSettings.defaultSystemEnabled].
  final bool? systemEnabled;

  /// Per-app override for the system-audio scope (all vs. process-only).
  /// `null` means use [AutoRecordSettings.defaultSystemScope]. Only
  /// honored when [systemEnabled] resolves to true.
  final SystemAudioScope? systemScope;

  /// Per-app override for whether the app's window is recorded as
  /// video. `null` means use [AutoRecordSettings.defaultVideoEnabled].
  final bool? videoEnabled;

  AllowlistEntry copyWith({
    String? key,
    String? displayName,
    AllowlistKind? kind,
    Object? speakers = _sentinel,
    List<int>? tagIds,
    Object? folderId = _sentinel,
    Object? micEnabled = _sentinel,
    Object? systemEnabled = _sentinel,
    Object? systemScope = _sentinel,
    Object? videoEnabled = _sentinel,
  }) {
    return AllowlistEntry(
      key: key ?? this.key,
      displayName: displayName ?? this.displayName,
      kind: kind ?? this.kind,
      speakers: identical(speakers, _sentinel)
          ? this.speakers
          : speakers as int?,
      tagIds: tagIds ?? this.tagIds,
      folderId: identical(folderId, _sentinel)
          ? this.folderId
          : folderId as int?,
      micEnabled: identical(micEnabled, _sentinel)
          ? this.micEnabled
          : micEnabled as bool?,
      systemEnabled: identical(systemEnabled, _sentinel)
          ? this.systemEnabled
          : systemEnabled as bool?,
      systemScope: identical(systemScope, _sentinel)
          ? this.systemScope
          : systemScope as SystemAudioScope?,
      videoEnabled: identical(videoEnabled, _sentinel)
          ? this.videoEnabled
          : videoEnabled as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'displayName': displayName,
    'kind': kind.name,
    if (speakers != null) 'speakers': speakers,
    if (tagIds.isNotEmpty) 'tagIds': tagIds,
    if (folderId != null) 'folderId': folderId,
    // Preserve explicit `false` overrides — drop only when `null`.
    if (micEnabled != null) 'micEnabled': micEnabled,
    if (systemEnabled != null) 'systemEnabled': systemEnabled,
    if (systemScope != null) 'systemScope': _scopeToJson(systemScope!),
    if (videoEnabled != null) 'videoEnabled': videoEnabled,
  };

  factory AllowlistEntry.fromJson(Map<String, dynamic> json) {
    final rawKind = json['kind'] as String? ?? AllowlistKind.exeBasename.name;
    final kind = AllowlistKind.values.firstWhere(
      (k) => k.name == rawKind,
      orElse: () => AllowlistKind.exeBasename,
    );
    return AllowlistEntry(
      key: (json['key'] as String?) ?? '',
      displayName:
          (json['displayName'] as String?) ?? (json['key'] as String? ?? ''),
      kind: kind,
      speakers: (json['speakers'] as num?)?.toInt(),
      tagIds: (json['tagIds'] as List? ?? const [])
          .whereType<num>()
          .map((n) => n.toInt())
          .toList(growable: false),
      folderId: (json['folderId'] as num?)?.toInt(),
      micEnabled: json['micEnabled'] as bool?,
      systemEnabled: json['systemEnabled'] as bool?,
      systemScope: _scopeFromJson(json['systemScope']),
      videoEnabled: json['videoEnabled'] as bool?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AllowlistEntry &&
        other.key.toLowerCase() == key.toLowerCase() &&
        other.kind == kind;
  }

  @override
  int get hashCode => Object.hash(key.toLowerCase(), kind);
}

const Object _sentinel = Object();

@immutable
class RecentlySeenEntry {
  const RecentlySeenEntry({
    required this.key,
    required this.displayName,
    required this.kind,
    required this.lastSeenMs,
  });

  final String key;
  final String displayName;
  final AllowlistKind kind;
  final int lastSeenMs;

  Map<String, dynamic> toJson() => {
    'key': key,
    'displayName': displayName,
    'kind': kind.name,
    'lastSeenMs': lastSeenMs,
  };

  factory RecentlySeenEntry.fromJson(Map<String, dynamic> json) {
    final rawKind = json['kind'] as String? ?? AllowlistKind.exeBasename.name;
    final kind = AllowlistKind.values.firstWhere(
      (k) => k.name == rawKind,
      orElse: () => AllowlistKind.exeBasename,
    );
    return RecentlySeenEntry(
      key: (json['key'] as String?) ?? '',
      displayName:
          (json['displayName'] as String?) ?? (json['key'] as String? ?? ''),
      kind: kind,
      lastSeenMs: (json['lastSeenMs'] as num?)?.toInt() ?? 0,
    );
  }

  AllowlistEntry toAllowlistEntry() =>
      AllowlistEntry(key: key, displayName: displayName, kind: kind);
}

@immutable
class AutoRecordSettings {
  const AutoRecordSettings({
    this.enabled = false,
    this.allowlist = const [],
    this.recentlySeen = const [],
    this.silenceSeconds = 5,
    this.minKeepSeconds = 10,
    this.defaultSpeakers = 2,
    this.defaultTagIds = const [],
    this.defaultFolderId,
    this.defaultMicEnabled = true,
    this.defaultSystemEnabled = false,
    this.defaultSystemScope = SystemAudioScope.allSystem,
    this.defaultVideoEnabled = false,
  });

  final bool enabled;
  final List<AllowlistEntry> allowlist;
  final List<RecentlySeenEntry> recentlySeen;

  /// Auto-stop prompt fires once the trigger app's microphone and the
  /// system audio output have *both* been idle, simultaneously, for at
  /// least this many seconds.
  final int silenceSeconds;

  /// Auto-recorded sessions shorter than this are discarded silently
  /// (no library entry).
  final int minKeepSeconds;

  final int defaultSpeakers;
  final List<int> defaultTagIds;
  final int? defaultFolderId;

  /// Default state of the microphone source for new live sessions.
  final bool defaultMicEnabled;

  /// Default state of the system-audio source for new live sessions.
  /// Only honored on platforms where `LiveAudioRecorder.supportsSystemAudio`
  /// is true (Windows, Android API 29+).
  final bool defaultSystemEnabled;

  /// Default scope for system-audio capture when enabled. New entries
  /// that don't override [AllowlistEntry.systemScope] fall back to this.
  final SystemAudioScope defaultSystemScope;

  /// Default for recording the meeting app's window as video. Only
  /// honored where `LiveAudioRecorder.supportsVideo` is true (Windows).
  final bool defaultVideoEnabled;

  AutoRecordSettings copyWith({
    bool? enabled,
    List<AllowlistEntry>? allowlist,
    List<RecentlySeenEntry>? recentlySeen,
    int? silenceSeconds,
    int? minKeepSeconds,
    int? defaultSpeakers,
    List<int>? defaultTagIds,
    Object? defaultFolderId = _sentinel,
    bool? defaultMicEnabled,
    bool? defaultSystemEnabled,
    SystemAudioScope? defaultSystemScope,
    bool? defaultVideoEnabled,
  }) {
    return AutoRecordSettings(
      enabled: enabled ?? this.enabled,
      allowlist: allowlist ?? this.allowlist,
      recentlySeen: recentlySeen ?? this.recentlySeen,
      silenceSeconds: silenceSeconds ?? this.silenceSeconds,
      minKeepSeconds: minKeepSeconds ?? this.minKeepSeconds,
      defaultSpeakers: defaultSpeakers ?? this.defaultSpeakers,
      defaultTagIds: defaultTagIds ?? this.defaultTagIds,
      defaultFolderId: identical(defaultFolderId, _sentinel)
          ? this.defaultFolderId
          : defaultFolderId as int?,
      defaultMicEnabled: defaultMicEnabled ?? this.defaultMicEnabled,
      defaultSystemEnabled: defaultSystemEnabled ?? this.defaultSystemEnabled,
      defaultSystemScope: defaultSystemScope ?? this.defaultSystemScope,
      defaultVideoEnabled: defaultVideoEnabled ?? this.defaultVideoEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'allowlist': allowlist.map((e) => e.toJson()).toList(),
    'recentlySeen': recentlySeen.map((e) => e.toJson()).toList(),
    'silenceSeconds': silenceSeconds,
    'minKeepSeconds': minKeepSeconds,
    'defaultSpeakers': defaultSpeakers,
    'defaultTagIds': defaultTagIds,
    if (defaultFolderId != null) 'defaultFolderId': defaultFolderId,
    // Always emit, including explicit `false`, so user-toggled-off
    // defaults round-trip correctly.
    'defaultMicEnabled': defaultMicEnabled,
    'defaultSystemEnabled': defaultSystemEnabled,
    'defaultSystemScope': _scopeToJson(defaultSystemScope),
    'defaultVideoEnabled': defaultVideoEnabled,
  };

  factory AutoRecordSettings.fromJson(Map<String, dynamic> json) {
    return AutoRecordSettings(
      enabled: json['enabled'] as bool? ?? false,
      allowlist: (json['allowlist'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AllowlistEntry.fromJson)
          .toList(growable: false),
      recentlySeen: (json['recentlySeen'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(RecentlySeenEntry.fromJson)
          .toList(growable: false),
      silenceSeconds: (json['silenceSeconds'] as num?)?.toInt() ?? 5,
      minKeepSeconds: (json['minKeepSeconds'] as num?)?.toInt() ?? 10,
      defaultSpeakers: (json['defaultSpeakers'] as num?)?.toInt() ?? 2,
      defaultTagIds: (json['defaultTagIds'] as List? ?? const [])
          .whereType<num>()
          .map((n) => n.toInt())
          .toList(growable: false),
      defaultFolderId: (json['defaultFolderId'] as num?)?.toInt(),
      defaultMicEnabled: json['defaultMicEnabled'] as bool? ?? true,
      defaultSystemEnabled: json['defaultSystemEnabled'] as bool? ?? false,
      defaultSystemScope:
          _scopeFromJson(json['defaultSystemScope']) ??
          SystemAudioScope.allSystem,
      defaultVideoEnabled: json['defaultVideoEnabled'] as bool? ?? false,
    );
  }
}
