import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speakr_app/theme/appearance.dart';
import 'package:speakr_app/theme/colors.dart';

class _Draft extends StatefulWidget {
  const _Draft();
  @override
  State<_Draft> createState() => _DraftState();
}

class _DraftState extends State<_Draft> {
  final draft = TextEditingController();
  @override
  void dispose() {
    draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppearanceScope.watch(context);
    return ColoredBox(
      color: SpeakrColors.bg,
      child: TextField(controller: draft),
    );
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'preferences survive controller recreation and mirror transfer',
    () async {
      final first = AppearanceController();
      await first.set(mode: ThemeMode.system, palette: MimioPalette.orange);
      final restored = AppearanceController();
      await restored.load();
      expect(restored.toJson(), first.toJson());
      final mirror = AppearanceController()..apply(first.toJson());
      expect(mirror.toJson(), first.toJson());
      restored.apply({'mode': 'bad', 'palette': 'bad'});
      expect(restored.mode, ThemeMode.dark);
      expect(restored.palette, MimioPalette.green);
    },
  );
  test('system changes affect only follow-system mode', () {
    final controller = AppearanceController();
    controller.updateSystemBrightness(Brightness.light);
    expect(controller.brightness, Brightness.dark);
    controller.apply({'mode': 'system', 'palette': 'green'});
    expect(controller.brightness, Brightness.light);
    controller.updateSystemBrightness(Brightness.dark);
    expect(controller.brightness, Brightness.dark);
    controller.apply({'mode': 'light', 'palette': 'green'});
    expect(controller.brightness, Brightness.light);
  });
  test('all seven accents remain legible on both surfaces', () {
    expect(MimioPalette.values.length, 7);
    for (final palette in MimioPalette.values) {
      for (final brightness in Brightness.values) {
        final fg = palette.accent(brightness).computeLuminance();
        final bg =
            (brightness == Brightness.dark
                    ? const Color(0xFF202529)
                    : const Color(0xFFECEFF1))
                .computeLuminance();
        final ratio =
            (fg > bg ? fg + .05 : bg + .05) / (fg > bg ? bg + .05 : fg + .05);
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: '${palette.name} $brightness',
        );
      }
    }
  });
  testWidgets('native titlebar follows explicit and system brightness', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    final calls = <bool>[];
    const channel = MethodChannel('speakr/tray');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      if (call.method == 'setAppearance') calls.add(call.arguments as bool);
      return null;
    });
    addTearDown(() {
      debugDefaultTargetPlatformOverride = null;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      );
      tester.platformDispatcher.clearPlatformBrightnessTestValue();
    });
    appAppearance.apply({'mode': 'light', 'palette': 'green'});
    await tester.pumpWidget(AppearanceApp(builder: () => const SizedBox()));
    expect(calls.last, false);
    appAppearance.apply({'mode': 'dark', 'palette': 'green'});
    await tester.pump();
    expect(calls.last, true);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    appAppearance.apply({'mode': 'system', 'palette': 'green'});
    await tester.pump();
    expect(calls.last, false);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pump();
    expect(calls.last, true);
    appAppearance.apply({'mode': 'light', 'palette': 'green'});
    await tester.pump();
    expect(calls.last, false);
    await tester.pumpWidget(const SizedBox());
    debugDefaultTargetPlatformOverride = null;
  });
  testWidgets('theme updates const descendants without losing draft state', (
    tester,
  ) async {
    appAppearance.apply({'mode': 'dark', 'palette': 'green'});
    await tester.pumpWidget(
      AppearanceApp(
        builder: () => const MaterialApp(home: Scaffold(body: _Draft())),
      ),
    );
    await tester.enterText(find.byType(TextField), 'unsaved note');
    final state = tester.state(find.byType(_Draft));
    appAppearance.apply({'mode': 'light', 'palette': 'orange'});
    await tester.pump();
    expect(tester.state(find.byType(_Draft)), same(state));
    expect(find.text('unsaved note'), findsOneWidget);
    final box = tester.widget<ColoredBox>(
      find
          .descendant(
            of: find.byType(_Draft),
            matching: find.byType(ColoredBox),
          )
          .first,
    );
    expect(box.color, const Color(0xFFF6F7F8));
    appAppearance.apply({'mode': 'dark', 'palette': 'green'});
  });
}
