import '../../theme/appearance.dart';
import 'package:speakr_app/l10n/strings.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../api/models.dart';
import '../../api/providers.dart';
import '../../services/audio/live_audio_recorder.dart';
import '../../services/audio/live_audio_recorder_factory.dart';
import '../../services/auto_record/auto_record_providers.dart';
import '../../services/auto_record/auto_record_settings.dart';
import '../../routing/router.dart';
import '../library/library_controller.dart';
import 'mini/mini_ipc.dart';
import 'mini/mini_window_native.dart';
import 'recording_state.dart';

/// Events the controller asks the live UI to act on (since notifiers can't
/// hold a [BuildContext]).
enum RecordingNav { toLibrary, pop }

class RecordingController extends StateNotifier<RecordingState> {
  RecordingController(this._ref) : super(const RecordingState()) {
    _registerMainIpcHandler();
    appLanguage.addListener(_pushLanguageToMini);
    appAppearance.addListener(_pushLanguageToMini);
    addListener(_pushStateToMini, fireImmediately: false);
    _ref.listen<AsyncValue<List<Tag>>>(tagsProvider, (_, next) {
      final tags = next.value;
      if (tags == null) return;
      if (state.miniOpen) _pushTagsToMini(tags);
    });
    // Re-push folder list to the mini whenever the main app's folders
    // provider updates (e.g. after a refresh) and a mini window is open.
    _ref.listen<AsyncValue<List<Folder>>>(foldersProvider, (_, next) {
      final list = next.value;
      if (list != null) _pushFoldersToMini(list);
    });
    // Start with a fallback recorder so the controller is usable
    // synchronously; probe for the native pipeline in the background and
    // swap once available. Sets `state.systemAudioSupported` so the UI
    // can enable the System Audio toggle when capable.
    _initRecorder();
  }

  final Ref _ref;
  LiveAudioRecorder _recorder = LiveAudioRecorderFactory.createSync();
  bool _recorderProbed = false;
  Timer? _ticker;
  WindowController? _miniController;
  bool _ipcRegistered = false;
  DateTime? _recordingStartedAt;
  StreamSubscription<double>? _audioLevelSub;
  DateTime _audioLevelLastPush = DateTime.fromMillisecondsSinceEpoch(0);

  /// Invoked when the user clicks "Resume" on the pill's idle
  /// stop-countdown. Wired by the auto-record bootstrap to the
  /// coordinator, which owns the countdown.
  VoidCallback? onResumeAutoStop;

  final _navController = StreamController<RecordingNav>.broadcast();
  Stream<RecordingNav> get navStream => _navController.stream;

  Future<void> _initRecorder() async {
    try {
      final r = await LiveAudioRecorderFactory.createAsync();
      if (_recorderProbed) {
        // Race: controller disposed during probe.
        await r.dispose();
        return;
      }
      final old = _recorder;
      _recorder = r;
      _recorderProbed = true;
      if (state.systemAudioSupported != r.supportsSystemAudio ||
          state.processLoopbackSupported != r.supportsProcessLoopback ||
          state.videoSupported != r.supportsVideo) {
        state = state.copyWith(
          systemAudioSupported: r.supportsSystemAudio,
          processLoopbackSupported: r.supportsProcessLoopback,
          videoSupported: r.supportsVideo,
        );
      }
      // The fallback recorder we constructed synchronously is no longer
      // needed once the native one is wired up.
      if (!identical(old, r)) {
        await old.dispose();
      }
    } catch (e) {
      debugPrint('Recorder probe failed: $e');
    }
  }

  void _registerMainIpcHandler() {
    if (kIsWeb || !Platform.isWindows) return;
    if (_ipcRegistered) return;
    try {
      DesktopMultiWindow.setMethodHandler(_handleMiniCommand);
      _ipcRegistered = true;
    } catch (_) {
      // Embedder not available (tests); silent.
    }
  }

  Future<dynamic> _handleMiniCommand(MethodCall call, int fromWindowId) async {
    switch (call.method) {
      case MiniIpc.cmdTogglePause:
        await togglePause();
        return null;
      case MiniIpc.cmdStop:
        await stopAndUpload();
        return null;
      case MiniIpc.cmdCancel:
        await cancel();
        return null;
      case MiniIpc.cmdHideMini:
        await hideMini();
        return null;
      case MiniIpc.cmdSetSpeakers:
        final v = (call.arguments as Map?)?['value'];
        if (v is int) setSpeakers(v);
        return null;
      case MiniIpc.cmdToggleTag:
        final name = (call.arguments as Map?)?['name'];
        if (name is String) toggleTag(name);
        return null;
      case MiniIpc.cmdSetFolder:
        final id = (call.arguments as Map?)?['id'];
        if (id == null) {
          setFolder(null);
        } else if (id is int) {
          setFolder(id);
        }
        return null;
      case MiniIpc.cmdSetMicEnabled:
        final v = (call.arguments as Map?)?['enabled'];
        if (v is bool) await setMicEnabled(v);
        return null;
      case MiniIpc.cmdSetSystemMode:
        final raw = (call.arguments as Map?)?['mode'];
        final mode = _systemModeFromIpc(raw);
        if (mode != null) await setSystemMode(mode);
        return null;
      case MiniIpc.cmdBeginDrag:
        await MiniWindowNative.beginMiniDrag();
        return null;
      case MiniIpc.cmdShowMain:
        await MiniWindowNative.focusMain();
        // Route the main app to /live so the user lands on the recording
        // page, not whatever screen they were on before opening the pill.
        try {
          _ref.read(routerProvider).go('/live');
        } catch (_) {}
        return null;
      case MiniIpc.cmdResumeAutoStop:
        onResumeAutoStop?.call();
        return null;
    }
    return null;
  }

  void _pushFoldersToMini(List<Folder> folders) {
    final mini = _miniController;
    if (mini == null || !state.miniOpen) return;
    DesktopMultiWindow.invokeMethod(
      mini.windowId,
      MiniIpc.foldersUpdate,
      jsonEncode([for (final f in folders) f.toJson()]),
    ).catchError((_) => null);
  }

  void _pushLanguageToMini() => _pushStateToMini(state);

  void _pushStateToMini(RecordingState s) {
    final mini = _miniController;
    if (mini == null || !s.miniOpen) return;
    DesktopMultiWindow.invokeMethod(
      mini.windowId,
      MiniIpc.stateUpdate,
      jsonEncode({
        ...s.toJson(),
        '_uiLanguage': appLanguage.value,
        '_appearance': appAppearance.toJson(),
      }),
    ).catchError((_) => null);
  }

  void _pushTagsToMini(List<Tag> tags) {
    final mini = _miniController;
    if (mini == null) return;
    DesktopMultiWindow.invokeMethod(
      mini.windowId,
      MiniIpc.tagsUpdate,
      jsonEncode([for (final t in tags) t.toJson()]),
    ).catchError((_) => null);
  }

  // ---------------- Public actions ----------------

  /// Start a new recording. When [micEnabled] / [systemMode] are
  /// passed (auto-record coordinator path), those values win; otherwise
  /// the controller falls back to [AutoRecordSettings.defaultMicEnabled]
  /// / [AutoRecordSettings.defaultSystemEnabled] +
  /// [AutoRecordSettings.defaultSystemScope]. The system mode is
  /// silently downgraded to `off` on platforms where the recorder can't
  /// capture system audio, and from [SystemAudioMode.processOnly] to
  /// [SystemAudioMode.allSystem] on Windows builds without process
  /// loopback support.
  ///
  /// [processSourceName] / [processSourcePid] identify the auto-record
  /// trigger process when the coordinator is the caller — they enable
  /// the 3-segment pill on the live screen and feed the native
  /// process-loopback client. Both are `null` for manual recordings.
  ///
  /// [videoEnabled] (default: [AutoRecordSettings.defaultVideoEnabled])
  /// also records a window as video: the front-most window of
  /// [videoPids], or for manual recordings of any allowlisted app.
  Future<void> start({
    bool? micEnabled,
    SystemAudioMode? systemMode,
    String? processSourceName,
    int? processSourcePid,
    bool? videoEnabled,
    List<int>? videoPids,
  }) async {
    if (state.started) return;
    state = state.copyWith(error: null);

    AutoRecordSettings? loadedSettings;
    Future<AutoRecordSettings> settingsOrDefault() async {
      final cached = loadedSettings;
      if (cached != null) return cached;
      AutoRecordSettings settings;
      try {
        settings = await _ref.read(autoRecordSettingsProvider.future);
      } catch (_) {
        settings = const AutoRecordSettings();
      }
      return loadedSettings = settings;
    }

    bool mic;
    SystemAudioMode sysMode;
    if (micEnabled != null && systemMode != null) {
      mic = micEnabled;
      sysMode = systemMode;
    } else {
      final settings = await settingsOrDefault();
      mic = micEnabled ?? settings.defaultMicEnabled;
      if (systemMode != null) {
        sysMode = systemMode;
      } else if (!settings.defaultSystemEnabled) {
        sysMode = SystemAudioMode.off;
      } else {
        sysMode = settings.defaultSystemScope == SystemAudioScope.processOnly
            ? SystemAudioMode.processOnly
            : SystemAudioMode.allSystem;
      }
    }
    // Downgrade chain: processOnly → allSystem → off when the host
    // doesn't support the higher tier.
    if (sysMode == SystemAudioMode.processOnly &&
        !_recorder.supportsProcessLoopback) {
      sysMode = SystemAudioMode.allSystem;
    }
    if (sysMode != SystemAudioMode.off && !_recorder.supportsSystemAudio) {
      sysMode = SystemAudioMode.off;
    }
    // Manual sessions can't keep the process-only mode (no trigger PID).
    if (sysMode == SystemAudioMode.processOnly && processSourcePid == null) {
      sysMode = SystemAudioMode.allSystem;
    }
    // At least one source must be on at session start, so the user
    // gets a meaningful recording. If both got resolved to off, fall
    // back to mic on — that matches the prior plugin behavior.
    if (!mic && sysMode == SystemAudioMode.off) mic = true;

    CaptureWindow? videoWindow;
    String? videoNote;
    final wantVideo =
        videoEnabled ?? (await settingsOrDefault()).defaultVideoEnabled;
    if (wantVideo && _recorder.supportsVideo) {
      if (!await _serverKeepsVideo()) {
        videoNote = tr(
          "Video retention is off on the Speakr server, so this recording is audio only.",
        );
      } else {
        videoWindow = await _findMeetingWindow(
          videoPids ?? await _allowlistPids(await settingsOrDefault()),
        );
        if (videoWindow == null) {
          videoNote = tr(
            "No meeting window found, so this recording is audio only.",
          );
        }
      }
    }

    state = state.copyWith(
      micEnabled: mic,
      systemMode: sysMode,
      systemAudioSupported: _recorder.supportsSystemAudio,
      processLoopbackSupported: _recorder.supportsProcessLoopback,
      processSourceName: processSourceName,
      processSourcePid: processSourcePid,
      videoSupported: _recorder.supportsVideo,
      videoRecording: videoWindow != null,
      videoWindowHwnd: videoWindow?.hwnd,
      videoWindowTitle: videoWindow?.title,
      error: videoNote,
    );

    if (mic) {
      final granted = await _recorder.requestMicPermission();
      if (!granted) {
        state = state.copyWith(
          error: tr("Microphone permission is required to record."),
        );
        return;
      }
    }
    await _requestNotificationPermission();
    if (sysMode != SystemAudioMode.off) {
      final ok = await _recorder.requestSystemPermission();
      if (!ok) {
        if (!mic) {
          state = state.copyWith(
            error: tr("System-audio permission was denied."),
          );
          return;
        }
        // Continue mic-only.
        sysMode = SystemAudioMode.off;
        state = state.copyWith(
          systemMode: SystemAudioMode.off,
          error: tr(
            "System-audio permission was denied — continuing with mic only.",
          ),
        );
      }
    }

    final dir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final ext = videoWindow != null ? 'mp4' : 'm4a';
    final path = '${dir.path}${Platform.pathSeparator}speakr_$ts.$ext';
    try {
      await _recorder.start(
        path: path,
        micEnabled: mic,
        systemMode: sysMode,
        processLoopbackPid: sysMode == SystemAudioMode.processOnly
            ? processSourcePid
            : null,
        videoHwnd: videoWindow?.hwnd,
      );
      _recordingStartedAt = DateTime.now();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!state.paused) {
          state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
        }
      });
      _subscribeAudioLevel();
      state = state.copyWith(started: true);
      if (!kIsWeb && Platform.isWindows) {
        await _openMiniWindow();
      }
    } catch (e) {
      state = state.copyWith(error: tr("Could not start recording: {0}", [e]));
      await _cleanupAfterFailure();
    }
  }

  /// Android 13+ hides the recording foreground-service notification
  /// unless POST_NOTIFICATIONS is granted, so ask for it when a live
  /// recording starts. Best-effort: the service runs either way, so a
  /// denial (or any plugin error) never blocks the recording.
  Future<void> _requestNotificationPermission() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      final status = await Permission.notification.status;
      if (status.isGranted || status.isPermanentlyDenied) return;
      await Permission.notification.request();
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
    }
  }

  /// Resolve candidate PIDs for a process the auto-record coordinator
  /// is about to trigger on. Returns an empty list when process
  /// loopback isn't supported or no matching process is alive.
  Future<List<int>> findProcessPids({
    String? exePath,
    required String matchKey,
    required AllowlistKind kind,
  }) => _recorder.findProcessPids(
    exePath: exePath,
    matchKey: matchKey,
    kind: kind,
  );

  /// Whether the server keeps uploaded video. Unknown (offline, older
  /// server) counts as yes: the server reduces video to audio on its
  /// own when it doesn't keep it.
  Future<bool> _serverKeepsVideo() async {
    try {
      final config = await _ref
          .read(speakrApiProvider)
          .getConfig()
          .timeout(const Duration(seconds: 5));
      return config.videoRetention;
    } catch (_) {
      return true;
    }
  }

  Future<List<int>> _allowlistPids(AutoRecordSettings settings) async {
    final pids = <int>[];
    for (final e in settings.allowlist) {
      pids.addAll(
        await _recorder.findProcessPids(matchKey: e.key, kind: e.kind),
      );
    }
    return pids;
  }

  /// The front-most window of [pids]. Windows come back in Z order and
  /// the meeting window is raised when a call starts, so this beats
  /// guessing from titles (which are localised and vary by client).
  Future<CaptureWindow?> _findMeetingWindow(List<int> pids) async {
    if (pids.isEmpty) return null;
    final windows = await _recorder.findCaptureWindows(pids: pids);
    return windows.isEmpty ? null : windows.first;
  }

  /// Capturable windows for the live screen's window picker.
  Future<List<CaptureWindow>> listCaptureWindows() =>
      _recorder.findCaptureWindows();

  /// Point this session's video at another window, or at none (black).
  /// Only for sessions that started with video.
  Future<void> selectVideoWindow(CaptureWindow? window) async {
    if (!state.started || !state.videoRecording) return;
    try {
      await _recorder.setVideoTarget(window?.hwnd);
      state = state.copyWith(
        videoWindowHwnd: window?.hwnd,
        videoWindowTitle: window?.title,
      );
    } catch (e) {
      state = state.copyWith(
        error: tr("Failed to switch video window: {0}", [e]),
      );
    }
  }

  Future<void> togglePause() async {
    if (!state.started) return;
    try {
      if (state.paused) {
        await _recorder.resume();
      } else {
        await _recorder.pause();
      }
      final nextPaused = !state.paused;
      // Snap the meter to zero immediately when paused so the breathing
      // dot collapses without waiting for the recorder to emit a new
      // level sample. The recorder's stream is the source of truth once
      // we resume.
      state = state.copyWith(
        paused: nextPaused,
        audioLevel: nextPaused ? 0.0 : state.audioLevel,
      );
    } catch (e) {
      state = state.copyWith(error: tr("Failed to toggle pause: {0}", [e]));
    }
  }

  void _subscribeAudioLevel() {
    _audioLevelSub?.cancel();
    try {
      _audioLevelSub = _recorder.audioLevel.listen(
        (level) {
          if (state.paused) return;
          final now = DateTime.now();
          if (now.difference(_audioLevelLastPush).inMilliseconds < 45) {
            return;
          }
          _audioLevelLastPush = now;
          final clamped = level.isFinite ? level.clamp(0.0, 1.0) : 0.0;
          if ((clamped - state.audioLevel).abs() < 0.005) return;
          state = state.copyWith(audioLevel: clamped);
        },
        onError: (_) {
          /* ignore — meter is best-effort */
        },
      );
    } catch (_) {
      // Platforms that don't expose a level stream: leave dot at the floor.
      _audioLevelSub = null;
    }
  }

  void _unsubscribeAudioLevel() {
    _audioLevelSub?.cancel();
    _audioLevelSub = null;
  }

  /// Toggle the mic source. Effective immediately on platforms with
  /// live mic-mute support (Windows, Android); on the fallback path
  /// (iOS / web) this is mapped to pause/resume and the [state.paused]
  /// flag tracks the effect.
  Future<void> setMicEnabled(bool v) async {
    if (state.micPending) return;
    if (state.micEnabled == v && state.started) return;
    if (!state.started) {
      // Pre-start: just stash the choice for the next [start] call.
      state = state.copyWith(micEnabled: v);
      return;
    }
    state = state.copyWith(micPending: true);
    try {
      await _recorder.setMicEnabled(v);
      if (_recorder.supportsLiveMicToggle) {
        state = state.copyWith(micEnabled: v, micPending: false);
      } else {
        // Fallback: mic-off implies paused.
        state = state.copyWith(micEnabled: v, micPending: false, paused: !v);
      }
    } catch (e) {
      state = state.copyWith(
        micPending: false,
        error: tr("Failed to toggle mic: {0}", [e]),
      );
    }
  }

  /// Change the system-audio source mode. Session-only — the new mode
  /// is never written back to [AutoRecordSettings], so a mid-recording
  /// switch from "Teams" → "System" won't change next session's default.
  ///
  /// Effective immediately on platforms with live source-mute support
  /// (Windows, Android); surfaces an error state on platforms where
  /// the requested mode isn't supported.
  Future<void> setSystemMode(SystemAudioMode mode) async {
    if (state.systemPending) return;
    if (mode != SystemAudioMode.off && !_recorder.supportsSystemAudio) {
      state = state.copyWith(
        error: tr("System audio capture isn't supported on this device."),
      );
      return;
    }
    if (mode == SystemAudioMode.processOnly) {
      if (!_recorder.supportsProcessLoopback) {
        state = state.copyWith(
          error: tr(
            "Per-process audio capture requires Windows 11 / Server 2022.",
          ),
        );
        return;
      }
      if (state.processSourcePid == null) {
        state = state.copyWith(
          error: tr("No trigger process available — pick \"System\" instead."),
        );
        return;
      }
    }
    if (state.systemMode == mode && state.started) return;
    if (!state.started) {
      state = state.copyWith(systemMode: mode);
      return;
    }
    state = state.copyWith(systemPending: true);
    try {
      if (mode != SystemAudioMode.off) {
        final ok = await _recorder.requestSystemPermission();
        if (!ok) {
          state = state.copyWith(
            systemPending: false,
            error: tr("System-audio permission was denied."),
          );
          return;
        }
      }
      await _recorder.setSystemMode(
        mode,
        processLoopbackPid: mode == SystemAudioMode.processOnly
            ? state.processSourcePid
            : null,
      );
      state = state.copyWith(systemMode: mode, systemPending: false);
    } catch (e) {
      state = state.copyWith(
        systemPending: false,
        error: tr("Failed to switch system audio mode: {0}", [e]),
      );
    }
  }

  Future<void> stopAndUpload() async {
    if (!state.started || state.uploading) return;
    state = state.copyWith(uploading: true);
    try {
      final path = await _recorder.stop();
      _ticker?.cancel();
      _ticker = null;
      _unsubscribeAudioLevel();
      if (path == null) {
        throw Exception(tr("Recorder returned no file path."));
      }
      final file = File(path);
      final api = _ref.read(speakrApiProvider);

      // Map active tag names → ids when known; otherwise upload still
      // succeeds and the user can attach tags from Detail.
      final tagsAsync = _ref.read(tagsProvider);
      final knownTags = tagsAsync.value ?? const [];
      final tagIds = <int>[
        for (final name in state.activeTags)
          for (final t in knownTags)
            if (t.name.toLowerCase() == name.toLowerCase()) t.id,
      ];

      final stat = await file.stat();
      final recording = await api.uploadRecording(
        file: file,
        minSpeakers: state.speakers,
        maxSpeakers: state.speakers,
        tagIds: tagIds,
        folderId: state.folderId,
        fileLastModified: stat.modified,
        // ~0.7 GB per hour of video; the default 5 min would cut off
        // all but short recordings on a slow uplink.
        sendTimeout: state.videoRecording ? const Duration(hours: 2) : null,
      );
      final startedAt = _recordingStartedAt;
      if (startedAt != null) {
        try {
          await api.updateRecording(recording.id, {
            'meeting_date': startedAt.toUtc().toIso8601String(),
          });
        } catch (e) {
          debugPrint('meeting_date PATCH failed for ${recording.id}: $e');
        }
      }
      _ref.read(uploadKickProvider.notifier).state++;
      try {
        await file.delete();
      } catch (_) {}

      await _closeMiniWindow();
      _resetSession();
      _navController.add(RecordingNav.toLibrary);
    } catch (e) {
      state = state.copyWith(
        uploading: false,
        error: tr("Upload failed: {0}", [e]),
      );
    }
  }

  Future<void> cancel() async {
    _ticker?.cancel();
    _ticker = null;
    _unsubscribeAudioLevel();
    try {
      if (await _recorder.isRecording()) {
        final path = await _recorder.stop();
        if (path != null) {
          try {
            await File(path).delete();
          } catch (_) {}
        }
      }
    } catch (_) {}

    await _closeMiniWindow();
    _resetSession();
    _navController.add(RecordingNav.pop);
  }

  void setSpeakers(int v) {
    state = state.copyWith(speakers: v.clamp(1, 12));
  }

  void setFolder(int? id) {
    state = state.copyWith(folderId: id);
  }

  void toggleTag(String name) {
    final tags = [...state.activeTags];
    if (tags.contains(name)) {
      tags.remove(name);
    } else {
      tags.add(name);
    }
    state = state.copyWith(activeTags: tags);
  }

  void setAutoStopCountdown(int? secondsLeft) {
    state = state.copyWith(autoStopSecondsLeft: secondsLeft);
  }

  void setActiveTags(List<String> names) {
    state = state.copyWith(activeTags: List.unmodifiable(names));
  }

  Future<void> _cleanupAfterFailure() async {
    _ticker?.cancel();
    _ticker = null;
    _unsubscribeAudioLevel();
    try {
      if (await _recorder.isRecording()) {
        final path = await _recorder.stop();
        if (path != null) {
          try {
            await File(path).delete();
          } catch (_) {}
        }
      }
    } catch (_) {}
    await _closeMiniWindow();
  }

  // ---------------- Mini window lifecycle ----------------

  /// Hide the mini-window without touching the recorder. Recording, ticker
  /// and `/live` route stay live; the user can bring the mini back via
  /// [openMini].
  Future<void> hideMini() async {
    await _closeMiniWindow();
    state = state.copyWith(miniOpen: false, miniWindowId: null);
  }

  /// (Re)open the mini-window while a recording is active. Windows-only.
  Future<void> openMini() async {
    if (kIsWeb || !Platform.isWindows) return;
    if (!state.started) return;
    if (state.miniOpen) return;
    await _openMiniWindow();
  }

  Future<void> _openMiniWindow() async {
    if (_miniController != null) return;
    try {
      final c = await DesktopMultiWindow.createWindow(
        jsonEncode({'role': MiniIpc.argRoleMini}),
      );
      _miniController = c;
      await c.setTitle(tr("Mimio Recording"));
      await c.show();
      // Update state — listener will push the current snapshot to the mini.
      state = state.copyWith(miniOpen: true, miniWindowId: c.windowId);
      // Push initial server tags so the mini's suggestion list matches main.
      final initialTags = _ref.read(tagsProvider).value;
      if (initialTags != null) _pushTagsToMini(initialTags);
      // Push the folder list so the mini can render its picker. Reference
      // data isn't part of RecordingState, so it goes via its own IPC call.
      final folders = _ref.read(foldersProvider).value ?? const <Folder>[];
      _pushFoldersToMini(folders);
      // Apply always-on-top + tool-window styles + initial frame via the
      // native helper (the package doesn't expose these on Windows).
      await MiniWindowNative.applyMiniChrome();
    } catch (_) {
      // If we can't open, recording still proceeds in the main window.
      _miniController = null;
      state = state.copyWith(miniOpen: false, miniWindowId: null);
    }
  }

  Future<void> _closeMiniWindow() async {
    final mini = _miniController;
    if (mini == null) return;
    try {
      // Tell the mini to tear down its UI before we close the host window.
      await DesktopMultiWindow.invokeMethod(
        mini.windowId,
        MiniIpc.lifecycleClose,
        null,
      );
    } catch (_) {}
    try {
      await mini.close();
    } catch (_) {}
    // Belt-and-braces: kill via native too.
    await MiniWindowNative.closeMini();
    _miniController = null;
  }

  void _resetSession() {
    _recordingStartedAt = null;
    state = RecordingState(
      // Preserve capability flags across sessions — they don't change
      // at runtime and re-probing would waste a round trip.
      systemAudioSupported: state.systemAudioSupported,
      processLoopbackSupported: state.processLoopbackSupported,
      videoSupported: state.videoSupported,
    );
  }

  /// Decode the on-the-wire system mode string used by the mini IPC.
  /// Returns null for unrecognized values so the caller can no-op safely.
  static SystemAudioMode? _systemModeFromIpc(Object? raw) {
    if (raw is! String) return null;
    switch (raw) {
      case 'off':
        return SystemAudioMode.off;
      case 'allSystem':
      case 'all':
        return SystemAudioMode.allSystem;
      case 'processOnly':
      case 'process':
        return SystemAudioMode.processOnly;
      default:
        return null;
    }
  }

  @override
  void dispose() {
    appLanguage.removeListener(_pushLanguageToMini);
    appAppearance.removeListener(_pushLanguageToMini);
    _ticker?.cancel();
    _unsubscribeAudioLevel();
    _recorder.dispose();
    _navController.close();
    super.dispose();
  }
}

final recordingControllerProvider =
    StateNotifierProvider<RecordingController, RecordingState>(
      (ref) => RecordingController(ref),
    );
