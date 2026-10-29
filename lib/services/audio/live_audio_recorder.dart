import '../auto_record/auto_record_settings.dart';
import '../../features/live/recording_state.dart' show SystemAudioMode;

export '../../features/live/recording_state.dart' show SystemAudioMode;

/// Abstraction over the per-platform recording pipeline used by the
/// live-recording session.
///
/// The Flutter `record` plugin only supports mic and can't change source
/// mid-stream, which doesn't match Speakr's "mic / system / process,
/// switchable during recording" UX. On Windows and Android we ship native
/// pipelines (WASAPI loopback / MediaProjection AudioPlaybackCapture)
/// behind this interface; iOS and web fall back to a mic-only wrapper
/// over `record`.
abstract class LiveAudioRecorder {
  /// Whether the host platform can capture system (loopback) audio in
  /// addition to mic. UI must hide / disable the system toggle when false.
  bool get supportsSystemAudio;

  /// Whether the host platform can capture audio from a specific
  /// process tree (Windows ≥ build 20348 via
  /// `ActivateAudioInterfaceAsync` + `PROCESS_LOOPBACK`). When false,
  /// only [SystemAudioMode.off] / [SystemAudioMode.allSystem] are valid;
  /// requests for [SystemAudioMode.processOnly] degrade to `allSystem`.
  bool get supportsProcessLoopback;

  /// Whether the recorder can also capture a window into an H.264
  /// video stream (Windows 10 1903+ via Windows.Graphics.Capture). When
  /// true, [start] accepts a `videoHwnd` and the output must be `.mp4`.
  bool get supportsVideo;

  /// Linear audio level [0.0, 1.0] of the captured mix, emitted ~20 Hz
  /// while a recording is active. Implementations should clamp samples
  /// into range and emit `0` while paused or before [start] is called.
  /// Subscribers must tolerate gaps and silent platforms (the stream may
  /// emit nothing if the underlying pipeline can't report a level).
  Stream<double> get audioLevel;

  /// Whether the mic source can be muted live (zero-filled into the
  /// output file) without pausing the encoder. When false, the live
  /// screen should treat mic-off as a pause/resume rather than a per-source
  /// gate.
  bool get supportsLiveMicToggle;

  /// True if the recorder is currently writing to a file.
  Future<bool> isRecording();

  /// Check (without prompting) whether mic permission is granted.
  Future<bool> hasMicPermission();

  /// Request mic permission (no-op on platforms where capture
  /// implementations request it directly).
  Future<bool> requestMicPermission();

  /// Ask the OS for permission to capture system audio. On Android this
  /// shows the per-session `MediaProjection` consent dialog. On Windows
  /// it's a no-op (returns true). On unsupported platforms returns false.
  Future<bool> requestSystemPermission();

  /// Resolve candidate PIDs for a watched process, sorted from most
  /// specific to least specific. Used by the auto-record coordinator
  /// when an [AllowlistEntry] with [SystemAudioScope.processOnly]
  /// triggers a session — the native side tries each PID in order
  /// when activating the process-loopback client.
  ///
  /// Always returns an empty list on platforms without process-loopback
  /// support.
  Future<List<int>> findProcessPids({
    String? exePath,
    required String matchKey,
    required AllowlistKind kind,
  });

  /// Capturable top-level windows, front-most first. Restricted to
  /// [pids] when non-empty. Empty on platforms without [supportsVideo].
  Future<List<CaptureWindow>> findCaptureWindows({List<int> pids = const []});

  /// Begin a new recording. [systemMode] decides whether the system
  /// source is included and, if so, whether it's an all-system mix or
  /// scoped to a process tree (in which case [processLoopbackPid] is
  /// the target root PID). The mic flag controls the secondary source.
  /// A non-null [videoHwnd] also records that window as video; [path]
  /// must then end in `.mp4`.
  Future<void> start({
    required String path,
    required bool micEnabled,
    required SystemAudioMode systemMode,
    int? processLoopbackPid,
    int? videoHwnd,
  });

  /// Pause/resume the encoder. While paused, no frames (silence or audio)
  /// are appended to the file; on resume the timeline continues from
  /// where it left off, with PTS rewritten so there's no synthetic gap.
  Future<void> pause();
  Future<void> resume();

  /// Toggle the microphone source. Effective immediately; while disabled,
  /// the mixer substitutes zero-filled PCM blocks for the mic stream so
  /// the encoded file stays continuous.
  Future<void> setMicEnabled(bool enabled);

  /// Change the system-audio source mode mid-recording. When [mode] is
  /// [SystemAudioMode.processOnly], [processLoopbackPid] must be a valid
  /// candidate root PID (resolve via [findProcessPids] first).
  ///
  /// Throws [UnsupportedError] when the recorder lacks the requested
  /// capability ([SystemAudioMode.processOnly] without process-loopback
  /// support, or any non-`off` mode on a recorder without system audio).
  Future<void> setSystemMode(SystemAudioMode mode, {int? processLoopbackPid});

  /// Point the video stream of a recording started with a `videoHwnd`
  /// at another window. `null` records black frames.
  Future<void> setVideoTarget(int? hwnd);

  /// Finalise the recording and return the file path, or `null` if the
  /// recording could not be saved (in which case any partial file has
  /// already been deleted by the implementation).
  Future<String?> stop();

  /// Release any held resources. Idempotent.
  Future<void> dispose();
}

/// A window that can be recorded as video.
class CaptureWindow {
  const CaptureWindow({
    required this.hwnd,
    required this.pid,
    required this.title,
    required this.width,
    required this.height,
  });

  factory CaptureWindow.fromChannel(Map<Object?, Object?> m) => CaptureWindow(
    hwnd: (m['hwnd'] as num).toInt(),
    pid: (m['pid'] as num).toInt(),
    title: m['title'] as String? ?? '',
    width: (m['width'] as num?)?.toInt() ?? 0,
    height: (m['height'] as num?)?.toInt() ?? 0,
  );

  final int hwnd;
  final int pid;
  final String title;
  final int width;
  final int height;
}
