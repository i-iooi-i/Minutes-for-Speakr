import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'auto_upload_settings.dart';

/// SharedPreferences-backed persistence for the list of
/// [FolderUploadConfig]s plus the worker's runtime bookkeeping
/// (concurrency lock, last-scan record).
///
/// All reads/writes are async and isolate-safe — the worker isolate
/// spawned by WorkManager and the UI isolate hit the same
/// shared_preferences file.
class AutoUploadSettingsStore {
  AutoUploadSettingsStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<AutoUploadSettingsStore> open() async =>
      AutoUploadSettingsStore(await SharedPreferences.getInstance());

  Future<void> reload() => _prefs.reload();

  // ── Settings ──────────────────────────────────────────────────────────────
  static const _kFolders = 'auto_upload.folders';

  // ── Runtime ───────────────────────────────────────────────────────────────
  static const _kLockMs = 'auto_upload.lock_ms';
  static const _kLockToken = 'auto_upload.lock_token';
  static const _kLastScanMs = 'auto_upload.last_scan_ms';
  static const _kLastScanResult = 'auto_upload.last_scan_result';
  static const _kFileErrors = 'auto_upload.file_errors';
  static const _kUploadedFiles = 'auto_upload.uploaded_files';

  // ── PhoneStateReceiver breadcrumbs (written from Kotlin) ──────────────────
  // The Android receiver writes a trail of every PHONE_STATE broadcast to
  // the same SharedPreferences file. Surfaced in the UI to diagnose why a
  // call-end auto-upload didn't happen (receiver never fired vs. fired
  // but state-machine skipped vs. enqueued but WorkManager didn't run).
  static const _kLastPhoneState = 'auto_upload.last_phone_state';
  static const _kLastPhoneStateMs = 'auto_upload.last_phone_state_ms';
  static const _kLastPhoneStatePrev = 'auto_upload.last_phone_state_prev';
  static const _kLastPhoneStateDecision =
      'auto_upload.last_phone_state_decision';
  static const _kLastCallEndEnqueueMs = 'auto_upload.last_call_end_enqueue_ms';

  List<FolderUploadConfig> readAll() {
    final raw = _prefs.getString(_kFolders);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(FolderUploadConfig.fromJson)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> writeAll(List<FolderUploadConfig> configs) async {
    final encoded = jsonEncode(configs.map((c) => c.toJson()).toList());
    await _prefs.setString(_kFolders, encoded);
  }

  FolderUploadConfig? findById(String id) {
    for (final c in readAll()) {
      if (c.id == id) return c;
    }
    return null;
  }

  // ── Concurrency lock ──────────────────────────────────────────────────────
  /// Returns a lock handle if acquired. Active workers refresh the timestamp;
  /// stale locks are assumed to be abandoned by a killed isolate/process.
  Future<AutoUploadLock?> tryAcquireLock({
    Duration staleAfter = const Duration(seconds: 90),
  }) async {
    await _prefs.reload();
    final now = DateTime.now().millisecondsSinceEpoch;
    final held = _prefs.getInt(_kLockMs) ?? 0;
    if (held > 0 && now - held < staleAfter.inMilliseconds) return null;

    final token =
        '$now-${DateTime.now().microsecondsSinceEpoch}-${identityHashCode(this)}';
    await _prefs.setInt(_kLockMs, now);
    await _prefs.setString(_kLockToken, token);
    await _prefs.reload();
    if (_prefs.getString(_kLockToken) != token) return null;
    return AutoUploadLock._(this, token);
  }

  Future<bool> refreshLock(String token) async {
    await _prefs.reload();
    if (_prefs.getString(_kLockToken) != token) return false;
    return _prefs.setInt(_kLockMs, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> releaseLock({String? token}) async {
    await _prefs.reload();
    if (token != null && _prefs.getString(_kLockToken) != token) return;
    await _prefs.setInt(_kLockMs, 0);
    await _prefs.remove(_kLockToken);
  }

  // ── Last-scan record ──────────────────────────────────────────────────────
  Future<void> recordScanResult(String summary) async {
    await _prefs.setInt(_kLastScanMs, DateTime.now().millisecondsSinceEpoch);
    await _prefs.setString(_kLastScanResult, summary);
  }

  DateTime? get lastScanAt {
    final ms = _prefs.getInt(_kLastScanMs);
    return ms == null || ms == 0
        ? null
        : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  String? get lastScanResult => _prefs.getString(_kLastScanResult);

  // ── PhoneStateReceiver breadcrumb getters ─────────────────────────────────
  /// State string from the most recent `ACTION_PHONE_STATE_CHANGED`
  /// broadcast (e.g. "IDLE", "OFFHOOK", "RINGING"). Null until the first
  /// broadcast since install.
  String? get lastPhoneState => _prefs.getString(_kLastPhoneState);

  /// Timestamp of the most recent broadcast. Null if the receiver hasn't
  /// fired yet — strong signal that runtime READ_PHONE_STATE is denied or
  /// the OEM is suppressing the manifest receiver.
  DateTime? get lastPhoneStateAt {
    final ms = _prefs.getInt(_kLastPhoneStateMs);
    return ms == null || ms == 0
        ? null
        : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  /// The state value the receiver saw on the broadcast *before* the most
  /// recent one. Used to show the OFFHOOK→IDLE state-machine transition
  /// in the diagnostic UI.
  String? get lastPhoneStatePrevious => _prefs.getString(_kLastPhoneStatePrev);

  /// What the receiver decided on the most recent broadcast: "enqueued",
  /// "no_op (...)", or "enqueue_failed: ...". A stuck "no_op" with
  /// previous=null on every IDLE means the process is being killed
  /// between OFFHOOK and IDLE.
  String? get lastPhoneStateDecision =>
      _prefs.getString(_kLastPhoneStateDecision);

  /// Timestamp of the last successful call-end work enqueue. If this
  /// keeps updating but `lastScanAt` doesn't, WorkManager is accepting
  /// the job but Doze/battery optimization is preventing it from running.
  DateTime? get lastCallEndEnqueueAt {
    final ms = _prefs.getInt(_kLastCallEndEnqueueMs);
    return ms == null || ms == 0
        ? null
        : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  // ── Per-file scan errors ──────────────────────────────────────────────────
  /// Errors that the worker recorded while scanning a folder. Keyed by
  /// absolute file path; value is a user-facing message. Used by the
  /// Library's pending tile to surface duration-read failures so the user
  /// can decide between deleting or force-uploading.
  Map<String, String> readFileErrors() {
    final raw = _prefs.getString(_kFileErrors);
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const {};
      return {
        for (final entry in decoded.entries)
          if (entry.key is String && entry.value is String)
            entry.key as String: entry.value as String,
      };
    } catch (_) {
      return const {};
    }
  }

  Future<void> _writeFileErrors(Map<String, String> errors) async {
    if (errors.isEmpty) {
      await _prefs.remove(_kFileErrors);
      return;
    }
    await _prefs.setString(_kFileErrors, jsonEncode(errors));
  }

  Future<void> setFileError(String path, String message) async {
    final next = Map<String, String>.from(readFileErrors());
    next[path] = message;
    await _writeFileErrors(next);
  }

  Future<void> clearFileError(String path) async {
    final current = readFileErrors();
    if (!current.containsKey(path)) return;
    final next = Map<String, String>.from(current)..remove(path);
    await _writeFileErrors(next);
  }

  /// Drops error entries whose path is no longer in [stillExisting].
  /// Called once at the start of each scan so deleted files don't leave
  /// orphan badges behind.
  Future<void> pruneFileErrors(Set<String> stillExisting) async {
    final current = readFileErrors();
    if (current.isEmpty) return;
    final next = <String, String>{
      for (final e in current.entries)
        if (stillExisting.contains(e.key)) e.key: e.value,
    };
    if (next.length == current.length) return;
    await _writeFileErrors(next);
  }

  // ── Uploaded-but-not-deleted guard ────────────────────────────────────────
  /// Paths whose upload completed, but whose local delete failed. The value is
  /// a lightweight file signature so a replaced file at the same path can
  /// still upload normally.
  Map<String, String> readUploadedFiles() {
    final raw = _prefs.getString(_kUploadedFiles);
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const {};
      return {
        for (final entry in decoded.entries)
          if (entry.key is String && entry.value is String)
            entry.key as String: entry.value as String,
      };
    } catch (_) {
      return const {};
    }
  }

  Future<void> _writeUploadedFiles(Map<String, String> files) async {
    if (files.isEmpty) {
      await _prefs.remove(_kUploadedFiles);
      return;
    }
    await _prefs.setString(_kUploadedFiles, jsonEncode(files));
  }

  Future<void> markUploadedFile(String path, String signature) async {
    final next = Map<String, String>.from(readUploadedFiles());
    next[path] = signature;
    await _writeUploadedFiles(next);
  }

  Future<void> clearUploadedFile(String path) async {
    final current = readUploadedFiles();
    if (!current.containsKey(path)) return;
    final next = Map<String, String>.from(current)..remove(path);
    await _writeUploadedFiles(next);
  }

  /// Keeps markers only for files that still exist with the same signature.
  Future<void> pruneUploadedFiles(Map<String, String> existing) async {
    final current = readUploadedFiles();
    if (current.isEmpty) return;
    final next = <String, String>{
      for (final e in current.entries)
        if (_signaturesMatch(existing[e.key], e.value)) e.key: e.value,
    };
    if (next.length == current.length) return;
    await _writeUploadedFiles(next);
  }

  bool _signaturesMatch(String? current, String stored) {
    if (current == null) return false;
    return stored == current || stored.startsWith('$current:');
  }

  // ── Key migration ─────────────────────────────────────────────────────────
  /// Rewrites per-file keys in both the error map and the uploaded-file
  /// guard. Used when an Android folder moves from a legacy raw path to a
  /// Storage Access Framework tree: entries keyed by
  /// `<oldFolderPath>/<name>` become keyed by the document URI for `<name>`
  /// so the user keeps their error badges and, more importantly, the
  /// "already uploaded, do not upload again" markers.
  ///
  /// [oldToNew] maps the full old key to the full new key. Keys not in the
  /// map are left alone.
  Future<void> remapFileKeys(Map<String, String> oldToNew) async {
    if (oldToNew.isEmpty) return;
    final errors = readFileErrors();
    if (errors.isNotEmpty) {
      await _writeFileErrors({
        for (final e in errors.entries) oldToNew[e.key] ?? e.key: e.value,
      });
    }
    final uploaded = readUploadedFiles();
    if (uploaded.isNotEmpty) {
      await _writeUploadedFiles({
        for (final e in uploaded.entries) oldToNew[e.key] ?? e.key: e.value,
      });
    }
  }

  /// Builds the [remapFileKeys] input for a legacy folder: every stored
  /// key whose directory is [oldFolderPath] and whose basename appears in
  /// [newKeysByName] is mapped to the corresponding new key.
  Map<String, String> legacyKeyRemap(
    String oldFolderPath,
    Map<String, String> newKeysByName,
  ) {
    final normalizedDir = oldFolderPath
        .replaceAll('\\', '/')
        .replaceAll(RegExp(r'/+$'), '');
    final out = <String, String>{};
    for (final key in {...readFileErrors().keys, ...readUploadedFiles().keys}) {
      final normalized = key.replaceAll('\\', '/');
      final slash = normalized.lastIndexOf('/');
      if (slash <= 0) continue;
      if (normalized.substring(0, slash) != normalizedDir) continue;
      final name = normalized.substring(slash + 1);
      final next = newKeysByName[name];
      if (next != null) out[key] = next;
    }
    return out;
  }
}

class AutoUploadLock {
  AutoUploadLock._(this._store, this.token);

  final AutoUploadSettingsStore _store;
  final String token;
  Timer? _heartbeat;

  void startHeartbeat({Duration interval = const Duration(seconds: 20)}) {
    _heartbeat ??= Timer.periodic(interval, (_) {
      unawaited(_store.refreshLock(token));
    });
  }

  Future<void> release() async {
    _heartbeat?.cancel();
    _heartbeat = null;
    await _store.releaseLock(token: token);
  }
}
