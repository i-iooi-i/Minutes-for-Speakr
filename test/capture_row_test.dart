import 'package:flutter/material.dart';
import 'package:speakr_app/l10n/strings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speakr_app/features/live/recording_state.dart';
import 'package:speakr_app/features/live/widgets/recording_widgets.dart';

MetadataCard _card({
  required bool micEnabled,
  required SystemAudioMode systemMode,
  required bool systemAudioSupported,
  bool processLoopbackSupported = false,
  String? processSourceName,
  int? processSourcePid,
  bool micPending = false,
  bool systemPending = false,
  ValueChanged<bool>? onMicChanged,
  ValueChanged<SystemAudioMode>? onSystemModeChanged,
}) {
  return MetadataCard(
    speakers: 1,
    onSpeakersChanged: (_) {},
    activeTags: const [],
    tagPickerOpen: false,
    onToggleTag: (_) {},
    onToggleEdit: () {},
    micEnabled: micEnabled,
    systemMode: systemMode,
    systemAudioSupported: systemAudioSupported,
    processLoopbackSupported: processLoopbackSupported,
    processSourceName: processSourceName,
    processSourcePid: processSourcePid,
    micPending: micPending,
    systemPending: systemPending,
    onMicChanged: onMicChanged ?? (_) {},
    onSystemModeChanged: onSystemModeChanged ?? (_) {},
  );
}

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  setUp(() => applyLanguage('en'));
  tearDown(() => applyLanguage('zh'));
  group('MetadataCard capture pill', () {
    testWidgets('renders 2-segment system pill for manual recordings', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          _card(
            micEnabled: true,
            systemMode: SystemAudioMode.allSystem,
            systemAudioSupported: true,
          ),
        ),
      );
      expect(find.text('CAPTURE'), findsOneWidget);
      expect(find.text('MIC'), findsOneWidget);
      expect(find.text('OFF'), findsNWidgets(2)); // mic + system "Off"
      expect(find.text('SYSTEM'), findsOneWidget);
    });

    testWidgets('hides the System pill when system audio is unsupported', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          _card(
            micEnabled: true,
            systemMode: SystemAudioMode.off,
            systemAudioSupported: false,
          ),
        ),
      );
      expect(find.text('MIC'), findsOneWidget);
      expect(find.text('SYSTEM'), findsNothing);
    });

    testWidgets('renders 3-segment pill with process name when triggered', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          _card(
            micEnabled: true,
            systemMode: SystemAudioMode.processOnly,
            systemAudioSupported: true,
            processLoopbackSupported: true,
            processSourceName: 'Microsoft Teams',
            processSourcePid: 1234,
          ),
        ),
      );
      expect(find.text('SYSTEM'), findsOneWidget);
      expect(find.text('MICROSOFT TEAMS'), findsOneWidget);
    });

    testWidgets('omits 3rd segment when process loopback unsupported', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          _card(
            micEnabled: true,
            systemMode: SystemAudioMode.allSystem,
            systemAudioSupported: true,
            processLoopbackSupported: false,
            processSourceName: 'Microsoft Teams',
            processSourcePid: 1234,
          ),
        ),
      );
      expect(find.text('MICROSOFT TEAMS'), findsNothing);
    });

    testWidgets('omits 3rd segment when trigger pid is unknown', (
      tester,
    ) async {
      // Auto-record can land in a state where the trigger app's name is
      // known (used in the subtitle) but the PID couldn't be resolved.
      // Showing the per-app pill in that state would let the user click
      // it and immediately hit a "no trigger process available" error
      // from the controller — so the pill must collapse to two segments.
      await tester.pumpWidget(
        _wrap(
          _card(
            micEnabled: true,
            systemMode: SystemAudioMode.allSystem,
            systemAudioSupported: true,
            processLoopbackSupported: true,
            processSourceName: 'Microsoft Teams',
            processSourcePid: null,
          ),
        ),
      );
      expect(find.text('MICROSOFT TEAMS'), findsNothing);
    });

    testWidgets('shows a spinner while pending', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _card(
            micEnabled: true,
            systemMode: SystemAudioMode.allSystem,
            systemAudioSupported: true,
            micPending: true,
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('tapping the OFF mic segment toggles mic off', (tester) async {
      bool? lastValue;
      await tester.pumpWidget(
        _wrap(
          _card(
            micEnabled: true,
            systemMode: SystemAudioMode.allSystem,
            systemAudioSupported: true,
            onMicChanged: (v) => lastValue = v,
          ),
        ),
      );
      // Two "OFF" labels — the first (top card) is the mic pill.
      await tester.tap(find.text('OFF').first);
      await tester.pump();
      expect(lastValue, isFalse);
    });

    testWidgets('tapping a system segment emits the matching mode', (
      tester,
    ) async {
      SystemAudioMode? lastMode;
      await tester.pumpWidget(
        _wrap(
          _card(
            micEnabled: true,
            systemMode: SystemAudioMode.off,
            systemAudioSupported: true,
            processLoopbackSupported: true,
            processSourceName: 'Teams',
            processSourcePid: 1234,
            onSystemModeChanged: (v) => lastMode = v,
          ),
        ),
      );
      await tester.tap(find.text('SYSTEM'));
      await tester.pump();
      expect(lastMode, SystemAudioMode.allSystem);

      await tester.tap(find.text('TEAMS'));
      await tester.pump();
      expect(lastMode, SystemAudioMode.processOnly);
    });

    testWidgets('pending mic pill ignores taps', (tester) async {
      bool? lastValue;
      await tester.pumpWidget(
        _wrap(
          _card(
            micEnabled: true,
            systemMode: SystemAudioMode.allSystem,
            systemAudioSupported: true,
            micPending: true,
            onMicChanged: (v) => lastValue = v,
          ),
        ),
      );
      // Two OFF labels — try the first (mic's). The pending state should
      // suppress the change callback.
      await tester.tap(find.text('OFF').first);
      await tester.pump();
      expect(lastValue, isNull);
    });
  });
}
