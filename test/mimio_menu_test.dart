import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speakr_app/theme/typography.dart';
import 'package:speakr_app/widgets/mimio_menu.dart';

void main() {
  testWidgets(
    'selectors and actions share menu geometry and trailing selection',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildSpeakrTheme(),
          home: Scaffold(
            body: MimioMenuButton<int>(
              itemBuilder: (_) => [
                MimioMenuItem(
                  value: 1,
                  label: '文件夹',
                  icon: Icons.folder_outlined,
                ),
                MimioMenuItem(
                  value: 2,
                  label: '标签',
                  icon: Icons.sell_outlined,
                  selected: true,
                ),
                MimioMenuDivider<int>(),
                MimioMenuItem(
                  value: 3,
                  label: '删除录音',
                  icon: Icons.delete_outline,
                  danger: true,
                ),
              ],
              child: const Text('打开'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();
      final items = find.byType(MimioMenuItem<int>);
      for (var i = 0; i < 3; i++) {
        expect(tester.getSize(items.at(i)), const Size(224, 40));
      }
      expect(
        tester.getTopLeft(find.text('文件夹')).dx,
        tester.getTopLeft(find.text('标签')).dx,
      );
      expect(
        tester.getTopLeft(find.byIcon(Icons.check_rounded)).dx,
        greaterThan(tester.getTopLeft(find.text('标签')).dx),
      );
      expect(tester.takeException(), isNull);
    },
  );

  test('desktop routes have no zoom or fade transition', () {
    final builders = buildSpeakrTheme().pageTransitionsTheme.builders;
    expect(
      builders[TargetPlatform.windows],
      isNot(isA<ZoomPageTransitionsBuilder>()),
    );
    expect(
      builders[TargetPlatform.windows].runtimeType,
      builders[TargetPlatform.macOS].runtimeType,
    );
  });
}
