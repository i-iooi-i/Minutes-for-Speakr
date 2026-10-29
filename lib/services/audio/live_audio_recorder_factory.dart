import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'live_audio_recorder.dart';
import 'native_live_audio_recorder.dart';
import 'record_plugin_audio_recorder.dart';

/// Chooses the right [LiveAudioRecorder] implementation for the host
/// platform. Windows and Android use the native pipeline (mic + system
/// loopback, live source toggling); iOS and web fall back to the
/// `record` plugin (mic only).
class LiveAudioRecorderFactory {
  LiveAudioRecorderFactory._();

  /// Returns immediately with a fallback recorder, then upgrades to
  /// the native one in the background if available. Most code paths
  /// only need [createAsync]; this synchronous variant exists so the
  /// `RecordingController` can be constructed at app start without
  /// awaiting platform-channel handshakes.
  static LiveAudioRecorder createSync() {
    return RecordPluginAudioRecorder();
  }

  /// Asynchronously instantiates the best available recorder. Probes
  /// the native channel on Windows/Android to confirm system-audio
  /// support before reporting it through `supportsSystemAudio`.
  static Future<LiveAudioRecorder> createAsync() async {
    if (kIsWeb) return RecordPluginAudioRecorder();
    if (Platform.isWindows || Platform.isAndroid) {
      try {
        return await NativeLiveAudioRecorder.probe();
      } catch (e) {
        debugPrint(
          'LiveAudioRecorderFactory: native probe failed: $e — '
          'falling back to mic-only recorder.',
        );
        return RecordPluginAudioRecorder();
      }
    }
    return RecordPluginAudioRecorder();
  }
}
