import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speakr_app/desktop/live/live_desktop_screen.dart';
import 'package:speakr_app/features/library/library_controller.dart';
import 'package:speakr_app/features/live/live_controller.dart';
import 'package:speakr_app/features/live/recording_state.dart';

class TestRecorder extends StateNotifier<RecordingState>
    implements RecordingController {
  TestRecorder(super.state);
  RecordingState get current => state;
  int starts = 0;
  bool? requestedMic;
  SystemAudioMode? requestedSystem;
  @override
  Stream<RecordingNav> get navStream => const Stream.empty();
  @override
  Future<void> start({
    bool? micEnabled,
    SystemAudioMode? systemMode,
    String? processSourceName,
    int? processSourcePid,
    bool? videoEnabled,
    List<int>? videoPids,
  }) async {
    starts++;
    requestedMic = micEnabled;
    requestedSystem = systemMode;
    state = state.copyWith(started: true);
  }

  @override
  Future<void> setMicEnabled(bool enabled) async {
    state = state.copyWith(micEnabled: enabled);
  }

  @override
  Future<void> setSystemMode(SystemAudioMode mode) async {
    state = state.copyWith(systemMode: mode);
  }

  @override
  void setSpeakers(int n) {
    state = state.copyWith(speakers: n);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Future<void> show(
    WidgetTester tester,
    TestRecorder recorder,
    Size size,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recordingControllerProvider.overrideWith((ref) => recorder),
          foldersProvider.overrideWith((ref) async => []),
          tagsProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(home: LiveDesktopScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets(
    'opening and preparing never starts capture; explicit start preserves sources',
    (tester) async {
      final recorder = TestRecorder(
        const RecordingState(systemAudioSupported: true),
      );
      await show(tester, recorder, const Size(1100, 800));
      await tester.pump(const Duration(seconds: 3));
      expect(recorder.starts, 0);
      await recorder.setMicEnabled(false);
      await recorder.setSystemMode(SystemAudioMode.allSystem);
      recorder.setSpeakers(4);
      await tester.pump();
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(recorder.starts, 1);
      expect(recorder.requestedMic, false);
      expect(recorder.requestedSystem, SystemAudioMode.allSystem);
      expect(recorder.current.speakers, 4);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'silent source configuration cannot start and narrow preparation has no overflow',
    (tester) async {
      final recorder = TestRecorder(const RecordingState(micEnabled: false));
      await show(tester, recorder, const Size(560, 600));
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(recorder.starts, 0);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('reopening a paused session does not start or resume it', (
    tester,
  ) async {
    final recorder = TestRecorder(
      const RecordingState(started: true, paused: true, elapsedSeconds: 35),
    );
    await show(tester, recorder, const Size(900, 650));
    await tester.pump(const Duration(seconds: 2));
    expect(recorder.starts, 0);
    expect(recorder.current.paused, true);
    expect(recorder.current.elapsedSeconds, 35);
    expect(find.byType(FilledButton), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
