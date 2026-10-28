import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speakr_app/desktop/widgets/desktop_wave.dart';
void main() {
 testWidgets('wave animates only during playback and respects reduced motion', (tester) async {
 Widget scene(bool playing, bool reduced) => MaterialApp(home: MediaQuery(data: MediaQueryData(disableAnimations: reduced), child: Scaffold(body: DesktopWave(playing: playing))));
 await tester.pumpWidget(scene(false,false)); await tester.pumpAndSettle();
 expect(tester.binding.transientCallbackCount,0);
 await tester.pumpWidget(scene(true,false)); await tester.pump(const Duration(milliseconds: 100));
 expect(tester.binding.transientCallbackCount,greaterThan(0));
 await tester.pumpWidget(scene(false,false)); await tester.pumpAndSettle();
 expect(tester.binding.transientCallbackCount,0);
 await tester.pumpWidget(scene(true,true)); await tester.pumpAndSettle();
 expect(tester.binding.transientCallbackCount,0);
 expect(tester.takeException(),isNull);
 });
}
