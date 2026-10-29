import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../features/live/recording_state.dart';
import 'auto_record_settings.dart';
import 'auto_record_settings_store.dart';
import 'mic_monitor.dart';
import 'mic_user.dart';
import 'output_meter.dart';

/// Length of the "meeting ended" countdown on the mini pill before an
/// idle auto-recording stops. The pill reads it to scale its progress bar.
const kAutoStopCountdownSeconds = 10;

/// Reason the coordinator wants the UI to ask the user whether to stop.
class StopPromptRequest {
  StopPromptRequest({required this.triggerLabel, required this.elapsed});
  final String triggerLabel;
  final Duration elapsed;
}

/// Owns the auto-record decision logic. Watches mic monitor + settings +
/// recording controller + output meter; calls the controller's
/// [RecordingController.start] / [RecordingController.stopAndUpload] /
/// [RecordingController.cancel] when appropriate and emits
/// [StopPromptRequest]s for the UI to render.
///
/// The coordinator does not own recording state itself — it drives the
/// app-wide [RecordingController] that the live screen also uses. A
/// session started by auto-record is indistinguishable to the rest of
/// the app from a manual session, except for the trigger label which
/// the coordinator tracks internally for the banner + prompt.
class AutoRecordCoordinator {
  AutoRecordCoordinator({
    required this.micMonitor,
    required this.outputMeter,
    required this.recording,
    required this.startRecording,
    required this.stopAndUpload,
    required this.cancelRecording,
    required this.store,
    required this.onSettingsChanged,
    this.applyTriggerMetadata,
    this.findProcessPids,
    this.onStopCountdown,
    this.stopCountdownSeconds = kAutoStopCountdownSeconds,
    this.countdownTick = const Duration(seconds: 1),
  });

  final MicMonitor micMonitor;
  final OutputMeter outputMeter;

  /// State source for the underlying recording session. The bootstrap
  /// passes the app-wide [RecordingController]; tests pass a stub.
  final StateNotifier<RecordingState> recording;

  /// Action callbacks. Provided by the bootstrap; tests pass closures
  /// over a stub controller. Decouples the coordinator from the
  /// concrete plugin-using controller so unit tests don't need
  /// `record` / `permission_handler` / `desktop_multi_window` set up.
  ///
  /// [startRecording] accepts the pre-resolved source flags so the native
  /// recorder can pick them up at boot rather than reconfiguring mid-stream.
  /// [processSourceName] / [processSourcePid] identify the trigger app
  /// so the live screen can render its name as the third pill segment
  /// and the native recorder can target it with process-loopback capture.
  /// [videoEnabled] / [videoPids] ask for the trigger app's window to be
  /// recorded as video.
  final Future<void> Function({
    bool? micEnabled,
    SystemAudioMode? systemMode,
    String? processSourceName,
    int? processSourcePid,
    bool? videoEnabled,
    List<int>? videoPids,
  })
  startRecording;
  final Future<void> Function() stopAndUpload;
  final Future<void> Function() cancelRecording;

  /// Resolve candidate PIDs for a watched process. Bootstrap injects a
  /// closure backed by the recorder's `findProcessPids` method. Returns
  /// an empty list (or `null` when omitted) on platforms / configurations
  /// without process-loopback support, in which case the coordinator
  /// falls back to all-system capture.
  final Future<List<int>> Function({
    String? exePath,
    required String matchKey,
    required AllowlistKind kind,
  })?
  findProcessPids;

  final AutoRecordSettingsStore store;

  /// Optional bridge into the recording controller used to seed the live
  /// session's speaker count and tags from the matched allowlist entry
  /// (with per-app overrides) or, when an entry has no override, from
  /// [AutoRecordSettings.defaultSpeakers] / [AutoRecordSettings.defaultTagIds].
  ///
  /// Tag IDs are resolved to display names by the bootstrap (which has
  /// access to `tagsProvider`); the coordinator hands the resolved IDs
  /// over and lets the closure do the lookup.
  final void Function({
    required int speakers,
    required List<int> tagIds,
    required int? folderId,
  })?
  applyTriggerMetadata;

  /// Publishes the idle stop-countdown to the UI: seconds left while it
  /// runs, `null` once it is cancelled. When provided and the mini pill
  /// is open, an idle meeting starts a countdown on the pill instead of
  /// emitting a [StopPromptRequest] for the main-window dialog. The
  /// bootstrap wires this into [RecordingState.autoStopSecondsLeft].
  final void Function(int? secondsLeft)? onStopCountdown;

  /// Length of the pill countdown before the session is stopped.
  final int stopCountdownSeconds;

  /// Countdown step. Injectable so tests don't wait real seconds.
  final Duration countdownTick;

  /// Latest state from [recording], mirrored here so the coordinator
  /// can read it synchronously (the underlying [StateNotifier.state]
  /// getter is protected). Updated by [_onRecordingState] via the
  /// listener registered in [start].
  RecordingState _recordingState = const RecordingState();

  /// Called whenever the coordinator writes back to the store (e.g.
  /// updating "recently seen"). The bootstrap wires this to
  /// `container.invalidate(autoRecordSettingsProvider)` so the settings
  /// screen rebuilds.
  final void Function() onSettingsChanged;

  StreamSubscription<List<MicUser>>? _micSub;
  VoidCallback? _removeRecListener;
  StreamSubscription<double>? _meterSub;

  /// True iff the currently-running session was started by the
  /// coordinator (vs. the live screen / user). The banner and the
  /// stop-prompt look at this rather than the controller's state, since
  /// `RecordingState` itself doesn't carry a "source" field.
  bool _autoSession = false;
  bool get isAutoSession => _autoSession;

  /// Allowlist key (case-insensitive) of the app whose mic-acquire
  /// triggered the current auto-recording. Used to decide when "the
  /// trigger app released the mic" for stop-prompt purposes.
  String? _activeTriggerKey;
  AllowlistKind? _activeTriggerKind;
  String? _activeTriggerLabel;
  String? get activeTriggerLabel => _activeTriggerLabel;

  /// Trigger the user explicitly stopped/discarded. Suppresses
  /// auto-restart for the same trigger until it releases the mic
  /// (i.e., the meeting ends). Cleared in [_onMicUpdate].
  String? _dismissedTriggerKey;
  AllowlistKind? _dismissedTriggerKind;

  /// Bookkeeping for the silence/mic-released stop heuristic.
  DateTime? _silentSinceUtc;
  DateTime? _micReleasedSinceUtc;

  /// True after the user picked "Keep recording". Suppresses further
  /// prompts until *either* the trigger app re-acquires the mic or audio
  /// resumes — i.e., a real "activity resumed" boundary. Cleared in
  /// [_trackTriggerRelease] / [_onPeak]; the next time both conditions
  /// go inactive for [AutoRecordSettings.silenceSeconds] again, a fresh
  /// prompt fires.
  bool _waitingForReactivation = false;
  bool _promptOpen = false;

  /// True while a countdown-expired stop is in flight, so peaks arriving
  /// before the session ends don't start another countdown.
  bool _autoStopping = false;

  /// Running idle stop-countdown (see [onStopCountdown]); null when idle.
  Timer? _countdownTimer;
  int _countdownLeft = 0;
  bool get isStopCountdownActive => _countdownTimer != null;

  final _prompts = StreamController<StopPromptRequest>.broadcast();
  Stream<StopPromptRequest> get prompts => _prompts.stream;

  // Self-suppression: don't trigger on Speakr itself when its exe is
  // surfaced via "Recently seen" and added to the allowlist.
  late final String _selfBasename = _basename(Platform.resolvedExecutable);

  /// Used by the UI binding to mark a prompt as currently visible.
  void notePromptShown() => _promptOpen = true;
  void notePromptDismissed({required bool keepRecording}) {
    _promptOpen = false;
    if (keepRecording) {
      // Suppress further prompts until activity resumes (mic re-acquired
      // or audio playback resumes) — only then does another idle window
      // re-arm the prompt. Anchors the next nag to a real meeting-
      // resumed-then-paused boundary rather than a fixed clock.
      _waitingForReactivation = true;
      _silentSinceUtc = null;
      _micReleasedSinceUtc = null;
    }
  }

  bool get isPromptVisible => _promptOpen;

  void start() {
    _micSub = micMonitor.usersStream.listen(_onMicUpdate);
    _removeRecListener = recording.addListener(_onRecordingState);
  }

  Future<void> dispose() async {
    _countdownTimer?.cancel();
    await _micSub?.cancel();
    _removeRecListener?.call();
    await _meterSub?.cancel();
    await _prompts.close();
  }

  // ── Mic-monitor handler ───────────────────────────────────────────────────

  Future<void> _onMicUpdate(List<MicUser> users) async {
    final settings = store.read();

    // Always update "recently seen" — even when disabled — so the user
    // can browse what's happening when they later open settings.
    await _recordRecentlySeen(users, settings);

    // While a non-auto recording is in progress, do nothing.
    if (_recordingState.started && !_autoSession) return;
    if (!settings.enabled) return;

    if (_autoSession &&
        (_recordingState.started || _recordingState.uploading)) {
      // We're already auto-recording. Track the trigger app's release
      // for the stop heuristic.
      _trackTriggerRelease(users);
      return;
    }

    // Clear a pending dismissal once the trigger app has released the
    // mic — that's the "this meeting ended" boundary, after which a new
    // acquisition should auto-start as before.
    if (_dismissedTriggerKey != null && _dismissedTriggerKind != null) {
      final stillInUse = users.any(
        (u) =>
            u.isInUse &&
            _userMatchesTrigger(
              u,
              _dismissedTriggerKey!,
              _dismissedTriggerKind!,
            ),
      );
      if (!stillInUse) {
        _dismissedTriggerKey = null;
        _dismissedTriggerKind = null;
      }
    }

    // Idle: try to find a fresh allowlist match to start.
    final cutoff = DateTime.now().subtract(const Duration(hours: 12));
    for (final user in users) {
      if (!user.isInUse) continue;
      if (user.lastStart.isBefore(cutoff)) continue;
      if (_isSelf(user)) continue;
      if (_dismissedTriggerKey != null &&
          _dismissedTriggerKind != null &&
          _userMatchesTrigger(
            user,
            _dismissedTriggerKey!,
            _dismissedTriggerKind!,
          )) {
        continue;
      }
      final entry = _firstAllowlistMatch(settings.allowlist, user);
      if (entry == null) continue;
      await _startAutoRecording(user, entry);
      return; // first match wins
    }
  }

  void _trackTriggerRelease(List<MicUser> users) {
    final key = _activeTriggerKey;
    final kind = _activeTriggerKind;
    if (key == null || kind == null) return;
    MicUser? trigger;
    for (final u in users) {
      if (_userMatchesTrigger(u, key, kind)) {
        trigger = u;
        break;
      }
    }
    final now = DateTime.now().toUtc();
    if (trigger != null && trigger.isInUse) {
      // Trigger app re-acquired the mic. Reset the released window and
      // dismiss any visible prompt — the meeting resumed. Mic activity
      // also re-arms the prompt after the user picked "Keep recording".
      _micReleasedSinceUtc = null;
      _waitingForReactivation = false;
      if (_promptOpen) _promptOpen = false;
      _cancelStopCountdown();
    } else {
      _micReleasedSinceUtc ??= now;
    }
  }

  // ── Recording-state handler ───────────────────────────────────────────────

  void _onRecordingState(RecordingState state) {
    final wasStarted = _recordingState.started;
    _recordingState = state;
    if (_autoSession && state.started && !state.uploading) {
      _meterSub ??= outputMeter.peaks.listen(_onPeak);
    } else if (wasStarted && !state.started && !state.uploading) {
      // Session finished (or was cancelled). Clear auto-session state.
      _meterSub?.cancel();
      _meterSub = null;
      if (_autoSession) {
        // Remember the trigger so we don't auto-restart for the same
        // meeting if the user just stopped/discarded. Cleared once the
        // trigger app releases the mic (see [_onMicUpdate]).
        _dismissedTriggerKey = _activeTriggerKey;
        _dismissedTriggerKind = _activeTriggerKind;
      }
      _autoSession = false;
      _activeTriggerKey = null;
      _activeTriggerKind = null;
      _activeTriggerLabel = null;
      _silentSinceUtc = null;
      _micReleasedSinceUtc = null;
      _waitingForReactivation = false;
      _promptOpen = false;
      _autoStopping = false;
      // No onStopCountdown(null) here: the controller already reset its
      // state, and writing back from inside its listener would re-enter.
      _countdownTimer?.cancel();
      _countdownTimer = null;
    }
  }

  void _onPeak(double peak) {
    final settings = store.read();
    const silenceThreshold = 0.005;
    final now = DateTime.now().toUtc();

    if (peak < silenceThreshold) {
      _silentSinceUtc ??= now;
    } else {
      _silentSinceUtc = null;
      // Audio resumed counts as activity — re-arm the prompt if the user
      // had previously picked "Keep recording".
      _waitingForReactivation = false;
      _cancelStopCountdown();
    }

    _maybeFireStopPrompt(settings, now);
  }

  void _maybeFireStopPrompt(AutoRecordSettings settings, DateTime now) {
    if (_promptOpen || _autoStopping || _countdownTimer != null) return;
    if (!_autoSession) return;
    if (_waitingForReactivation) return;

    final silentSince = _silentSinceUtc;
    final releasedSince = _micReleasedSinceUtc;
    if (silentSince == null || releasedSince == null) return;

    // Fire only when both the trigger app's mic and the system audio
    // output have been simultaneously inactive for [silenceSeconds] — the
    // later of the two "since" timestamps is when both became idle.
    final bothInactiveSince = silentSince.isAfter(releasedSince)
        ? silentSince
        : releasedSince;
    final inactiveFor = now.difference(bothInactiveSince);
    if (inactiveFor < Duration(seconds: settings.silenceSeconds)) return;

    if (onStopCountdown != null && _recordingState.miniOpen) {
      _startStopCountdown();
      return;
    }

    _prompts.add(
      StopPromptRequest(
        triggerLabel: _activeTriggerLabel ?? 'recording',
        elapsed: Duration(seconds: _recordingState.elapsedSeconds),
      ),
    );
  }

  // ── Pill stop-countdown ───────────────────────────────────────────────────

  void _startStopCountdown() {
    debugPrint('[auto-record] idle — stopping in ${stopCountdownSeconds}s');
    _countdownLeft = stopCountdownSeconds;
    onStopCountdown?.call(_countdownLeft);
    _countdownTimer = Timer.periodic(countdownTick, (timer) {
      _countdownLeft--;
      onStopCountdown?.call(_countdownLeft);
      if (_countdownLeft > 0) return;
      // Leave the pill on "Stopping…" — the session teardown closes it.
      timer.cancel();
      _countdownTimer = null;
      _autoStopping = true;
      unawaited(stopAutoSession());
    });
  }

  /// Activity resumed (mic re-acquired or audio playing) — drop the
  /// countdown without the "Keep recording" suppression.
  void _cancelStopCountdown() {
    if (_countdownTimer == null) return;
    _countdownTimer!.cancel();
    _countdownTimer = null;
    onStopCountdown?.call(null);
  }

  /// User clicked "Resume" on the pill during the countdown. Behaves like
  /// "Continue recording" on the dialog: no further countdown until
  /// activity resumes and goes idle again.
  void resumeFromStopCountdown() {
    if (_countdownTimer == null) return;
    _cancelStopCountdown();
    notePromptDismissed(keepRecording: true);
  }

  // ── User-confirmed stop ───────────────────────────────────────────────────

  /// Stops the in-progress auto session. If the recording is shorter
  /// than [AutoRecordSettings.minKeepSeconds], the file is discarded
  /// silently via [RecordingController.cancel] — no library entry.
  Future<void> stopAutoSession() async {
    if (!_autoSession) return;
    final settings = store.read();
    final elapsed = _recordingState.elapsedSeconds;
    if (elapsed < settings.minKeepSeconds) {
      debugPrint(
        '[auto-record] discarded short clip (${elapsed}s < ${settings.minKeepSeconds}s)',
      );
      await cancelRecording();
    } else {
      await stopAndUpload();
    }
  }

  /// Stops the in-progress auto session and discards the recording
  /// unconditionally — no library entry regardless of duration. Used
  /// when the user picks "Discard" on the idle stop-prompt.
  Future<void> discardAutoSession() async {
    if (!_autoSession) return;
    debugPrint('[auto-record] user discarded auto session');
    await cancelRecording();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _startAutoRecording(MicUser user, AllowlistEntry entry) async {
    debugPrint(
      '[auto-record] start trigger=${user.key} kind=${user.kind.name}',
    );
    _autoSession = true;
    _activeTriggerKey = entry.key;
    _activeTriggerKind = entry.kind;
    _activeTriggerLabel = entry.displayName;
    _silentSinceUtc = null;
    _micReleasedSinceUtc = null;

    // Resolve source flags *before* start — these are passed to the
    // recorder at boot so it can negotiate the right capture pipeline
    // (and run the Android MediaProjection consent flow up front if
    // system audio is requested). Speakers / tags / folder don't affect
    // the recorder, so they're applied after start succeeds.
    final preStartSettings = store.read();
    final micEnabled = entry.micEnabled ?? preStartSettings.defaultMicEnabled;
    final systemOn =
        entry.systemEnabled ?? preStartSettings.defaultSystemEnabled;
    final scope = entry.systemScope ?? preStartSettings.defaultSystemScope;
    final videoOn = entry.videoEnabled ?? preStartSettings.defaultVideoEnabled;

    // Resolve the trigger process PIDs when system audio is on — even
    // when the configured scope is allSystem. The PID doesn't affect the
    // initial mode, but storing it in state lets the user promote to
    // processOnly mid-session via the third pill. Without this,
    // allSystem auto-records of a Teams call show the trigger name but
    // no per-app option. Video needs every PID: the meeting window can
    // belong to any process of the app, not just the first.
    var pids = const <int>[];
    if ((systemOn || videoOn) && findProcessPids != null) {
      pids = await findProcessPids!(
        exePath: user.exePath,
        matchKey: user.key,
        kind: user.kind,
      );
    }

    SystemAudioMode systemMode;
    int? processPid;
    if (!systemOn) {
      systemMode = SystemAudioMode.off;
    } else {
      if (pids.isNotEmpty) processPid = pids.first;
      if (scope == SystemAudioScope.processOnly && processPid != null) {
        systemMode = SystemAudioMode.processOnly;
      } else {
        systemMode = SystemAudioMode.allSystem;
        if (scope == SystemAudioScope.processOnly) {
          debugPrint(
            '[auto-record] processOnly requested but no PIDs found for '
            '${user.displayName} (matchKey=${user.key} '
            'exe=${user.exePath ?? '<unset>'}) — falling back to allSystem',
          );
        }
      }
    }

    await startRecording(
      micEnabled: micEnabled,
      systemMode: systemMode,
      processSourceName: entry.displayName,
      processSourcePid: processPid,
      videoEnabled: videoOn,
      videoPids: pids,
    );
    if (!_recordingState.started) {
      // Permission denied or another error — bail.
      _autoSession = false;
      _activeTriggerKey = null;
      _activeTriggerKind = null;
      _activeTriggerLabel = null;
      return;
    }

    // Seed speakers + tags + folder from the entry's per-app overrides,
    // falling back to the global defaults. Re-read the store here so we
    // pick up the freshest values (in case the user just edited them).
    final settings = store.read();
    final speakers = entry.speakers ?? settings.defaultSpeakers;
    final tagIds = entry.tagIds.isNotEmpty
        ? List<int>.unmodifiable(entry.tagIds)
        : List<int>.unmodifiable(settings.defaultTagIds);
    final folderId = entry.folderId ?? settings.defaultFolderId;
    applyTriggerMetadata?.call(
      speakers: speakers,
      tagIds: tagIds,
      folderId: folderId,
    );

    await store.recordLastTrigger(entry.displayName);
  }

  Future<void> _recordRecentlySeen(
    List<MicUser> users,
    AutoRecordSettings settings,
  ) async {
    if (users.isEmpty) return;
    final byKey = <(String, AllowlistKind), RecentlySeenEntry>{
      for (final r in settings.recentlySeen) (r.key.toLowerCase(), r.kind): r,
    };
    var dirty = false;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    for (final u in users) {
      if (_isSelf(u)) continue;
      final id = (u.key.toLowerCase(), u.kind);
      final existing = byKey[id];
      if (existing == null) {
        byKey[id] = RecentlySeenEntry(
          key: u.key,
          displayName: u.displayName,
          kind: u.kind,
          lastSeenMs: nowMs,
        );
        dirty = true;
      } else if (u.isInUse) {
        byKey[id] = RecentlySeenEntry(
          key: existing.key,
          displayName: existing.displayName,
          kind: existing.kind,
          lastSeenMs: nowMs,
        );
        dirty = true;
      }
    }
    if (!dirty) return;
    // Keep at most the 30 most recent.
    final list = byKey.values.toList()
      ..sort((a, b) => b.lastSeenMs.compareTo(a.lastSeenMs));
    final trimmed = list.length > 30 ? list.sublist(0, 30) : list;
    await store.write(settings.copyWith(recentlySeen: trimmed));
    onSettingsChanged();
  }

  AllowlistEntry? _firstAllowlistMatch(
    List<AllowlistEntry> allowlist,
    MicUser user,
  ) {
    for (final e in allowlist) {
      if (user.matches(e)) return e;
    }
    return null;
  }

  bool _isSelf(MicUser user) {
    if (user.kind != AllowlistKind.exeBasename) return false;
    return user.key.toLowerCase() == _selfBasename.toLowerCase();
  }

  bool _userMatchesTrigger(MicUser u, String key, AllowlistKind kind) {
    if (u.kind != kind) return false;
    final mine = u.key.toLowerCase();
    final theirs = key.toLowerCase();
    return kind == AllowlistKind.packagedPrefix
        ? mine.startsWith(theirs)
        : mine == theirs;
  }

  static String _basename(String path) {
    var sep = path.lastIndexOf('\\');
    if (sep < 0) sep = path.lastIndexOf('/');
    return sep < 0 ? path : path.substring(sep + 1);
  }
}
