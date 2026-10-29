// Reuses the sidebar M painter. Run: flutter test tools/build_icon_sources.dart
// Then: dart run flutter_launcher_icons (mobile launcher assets).
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:speakr_app/widgets/mimio_logo.dart';

Future<Uint8List> render(int size, {bool transparent = false}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  if (!transparent) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
        Radius.circular(size * .22),
      ),
      Paint()..color = const Color(0xfff6f7f8),
    );
  }
  final width = size * .74;
  final height = width * 84 / 98;
  canvas.translate((size - width) / 2, (size - height) / 2 - size * .025);
  const MimioLogoPainter(
    ink: Color(0xff1b2328),
    accent: Color(0xff065f46),
    compact: true,
  ).paint(canvas, Size(width, height));
  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  picture.dispose();
  return data!.buffer.asUint8List();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('generate Mimio brand assets from the shared M painter', () async {
    final frames = <img.Image>[];
    for (final size in [16, 24, 32, 48, 64, 128, 256]) {
      frames.add(img.decodePng(await render(size))!);
    }
    File('windows/runner/resources/app_icon.ico').writeAsBytesSync(img.IcoEncoder().encodeImages(frames));
    File('assets/icon/icon.png').writeAsBytesSync(await render(1024));
    File(
      'assets/icon/icon_foreground.png',
    ).writeAsBytesSync(await render(1024, transparent: true));
    for (final scale in [1, 2, 3]) {
      final suffix = scale == 1 ? '' : '@${scale}x';
      File(
        'ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage$suffix.png',
      ).writeAsBytesSync(await render(200 * scale, transparent: true));
    }
  });
}
