import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speakr_app/desktop/widgets/desktop_audio_toolbar.dart';
import 'package:speakr_app/features/live/recording_state.dart';
import 'package:speakr_app/theme/colors.dart';

void main() {
  Future<void> show(WidgetTester tester, RecordingState state) => tester.pumpWidget(
    MaterialApp(home: Scaffold(body: AudioSessionReadout(state: state, showSources: false))));
  Color? bar(WidgetTester tester, int i) => (tester.widget<Container>(find.byKey(ValueKey('input-level-$i'))).decoration as BoxDecoration).color;
  testWidgets('idle and paused do not display stale input levels', (tester) async {
    await show(tester, const RecordingState(audioLevel: .8));
    expect(bar(tester, 0), SpeakrColors.line);
    await show(tester, const RecordingState(started: true, paused: true, audioLevel: .8, elapsedSeconds: 65));
    expect(bar(tester, 0), SpeakrColors.line);
    expect(find.text('1:05'), findsOneWidget);
  });
  testWidgets('meter follows actual level and handles invalid samples', (tester) async {
    await show(tester, const RecordingState(started: true, audioLevel: .5));
    expect(bar(tester, 7), SpeakrColors.accent);
    expect(bar(tester, 8), SpeakrColors.line);
    await show(tester, const RecordingState(started: true, audioLevel: double.nan));
    expect(bar(tester, 0), SpeakrColors.line);
    expect(tester.takeException(), isNull);
  });
}
