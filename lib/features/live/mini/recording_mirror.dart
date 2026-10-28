import 'dart:async';
import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../api/models.dart';
import '../../../l10n/strings.dart';
import '../recording_state.dart';
import 'mini_ipc.dart';
import 'mini_window_native.dart';

/// Folder list pushed from the main engine via [MiniIpc.foldersUpdate].
/// Held separately from [RecordingState] because folders are reference
/// data, not per-tick session state.
final miniFoldersProvider = StateProvider<List<Folder>>((_) => const []);

/// Lives in the mini window's Flutter engine. Mirrors [RecordingState]
/// pushed from the main engine and forwards user actions back as
/// command messages.
class RecordingMirror extends StateNotifier<RecordingState> {
  RecordingMirror(this._ref) : super(const RecordingState()) {
    _registerHandler();
  }

  final Ref _ref;

  void _registerHandler() {
    try {
      DesktopMultiWindow.setMethodHandler(_handle);
    } catch (_) {
      // Embedder unavailable (tests); UI will render with default state.
    }
  }

  Future<dynamic> _handle(MethodCall call, int fromWindowId) async {
    switch (call.method) {
      case MiniIpc.stateUpdate:
        try {
          final raw = call.arguments;
          final json = raw is String
              ? jsonDecode(raw) as Map<String, dynamic>
              : Map<String, dynamic>.from(raw as Map);
          if (json['_uiLanguage'] is String) {
            applyLanguage(json['_uiLanguage'] as String);
          }
          state = RecordingState.fromJson(json);
        } catch (_) {}
        return null;
      case MiniIpc.tagsUpdate:
        try {
          final raw = call.arguments;
          final list = raw is String ? jsonDecode(raw) : raw;
          if (list is List) {
            final tags = list
                .whereType<Map>()
                .map((m) => Tag.fromJson(Map<String, dynamic>.from(m)))
                .toList(growable: false);
            _ref.read(miniTagsProvider.notifier).state = tags;
          }
        } catch (_) {}
        return null;
      case MiniIpc.foldersUpdate:
        try {
          final raw = call.arguments;
          final list = raw is String ? jsonDecode(raw) : raw;
          final folders = <Folder>[
            for (final e in (list as List))
              Folder.fromJson(Map<String, dynamic>.from(e as Map)),
          ];
          _ref.read(miniFoldersProvider.notifier).state = folders;
        } catch (_) {}
        return null;
      case MiniIpc.lifecycleClose:
        // Main is closing us; the host window will be destroyed shortly.
        await MiniWindowNative.closeMini();
        return null;
    }
    return null;
  }

  // ----- Forward user actions to the main engine -----

  Future<dynamic> _send(String method, [Map<String, dynamic>? args]) async {
    try {
      return await DesktopMultiWindow.invokeMethod(
        MiniIpc.mainWindowId,
        method,
        args,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> togglePause() => _send(MiniIpc.cmdTogglePause);
  Future<void> stop() => _send(MiniIpc.cmdStop);
  Future<void> cancel() => _send(MiniIpc.cmdCancel);
  Future<void> hideMini() => _send(MiniIpc.cmdHideMini);
  Future<void> setSpeakers(int v) =>
      _send(MiniIpc.cmdSetSpeakers, {'value': v});
  Future<void> toggleTag(String name) =>
      _send(MiniIpc.cmdToggleTag, {'name': name});
  Future<void> setFolder(int? id) => _send(MiniIpc.cmdSetFolder, {'id': id});
  Future<void> setMicEnabled(bool enabled) =>
      _send(MiniIpc.cmdSetMicEnabled, {'enabled': enabled});
  Future<void> setSystemMode(SystemAudioMode mode) =>
      _send(MiniIpc.cmdSetSystemMode, {'mode': _modeToIpc(mode)});

  static String _modeToIpc(SystemAudioMode mode) {
    switch (mode) {
      case SystemAudioMode.off:
        return 'off';
      case SystemAudioMode.allSystem:
        return 'allSystem';
      case SystemAudioMode.processOnly:
        return 'processOnly';
    }
  }

  Future<void> beginDrag() => _send(MiniIpc.cmdBeginDrag);
  Future<void> showMain() => _send(MiniIpc.cmdShowMain);
  Future<void> resumeAutoStop() => _send(MiniIpc.cmdResumeAutoStop);
}

final recordingMirrorProvider =
    StateNotifierProvider<RecordingMirror, RecordingState>(
      (ref) => RecordingMirror(ref),
    );

/// Server tag list pushed from the main engine via [MiniIpc.tagsUpdate].
/// The mini's `MetadataCard` watches this to render the same suggestion
/// list users see on the main live screen.
final miniTagsProvider = StateProvider<List<Tag>>((_) => const <Tag>[]);
