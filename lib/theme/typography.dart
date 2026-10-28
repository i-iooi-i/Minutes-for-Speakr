import 'package:flutter/material.dart';

import 'colors.dart';

/// Typography helpers matching Direction A.
/// Three families, all bundled as assets under `assets/fonts/` and declared in
/// `pubspec.yaml` — nothing is fetched at runtime:
///  - Source Serif 4 — display, headlines, transcript bubbles
///  - Inter Tight — UI body / buttons
///  - JetBrains Mono — eyebrows, timestamps, server URL fields
///
/// The family strings below must match the `family:` keys in `pubspec.yaml`
/// exactly; a typo silently falls back to the platform default font.
const String kSerifFamily = 'Source Serif 4';
const String kSansFamily = 'Inter Tight';
const String kMonoFamily = 'JetBrains Mono';

class SpeakrText {
  static TextStyle serif({
    double? size,
    FontWeight weight = FontWeight.w400,
    FontStyle? style,
    Color color = SpeakrColors.ink,
    double height = 1.2,
    double letterSpacing = 0,
  }) => TextStyle(
    fontFamily: kSerifFamily,
    fontFamilyFallback: const ['Noto Serif SC', 'SimSun', 'Microsoft YaHei'],
    fontSize: size,
    fontWeight: weight,
    fontStyle: style,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );

  static TextStyle sans({
    double? size,
    FontWeight weight = FontWeight.w400,
    Color color = SpeakrColors.ink,
    double height = 1.4,
    double letterSpacing = 0,
  }) => TextStyle(
    fontFamily: kSansFamily,
    fontFamilyFallback: const [
      'Microsoft YaHei',
      'PingFang SC',
      'Noto Sans CJK SC',
    ],
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );

  static TextStyle mono({
    double size = 11,
    FontWeight weight = FontWeight.w500,
    Color color = SpeakrColors.muted,
    double letterSpacing = 1.5,
  }) => TextStyle(
    fontFamily: kMonoFamily,
    fontFamilyFallback: const [
      'Microsoft YaHei',
      'PingFang SC',
      'Noto Sans CJK SC',
    ],
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
  );
}

ThemeData buildSpeakrTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: SpeakrColors.bg,
    colorScheme: const ColorScheme.light(
      surface: SpeakrColors.bg,
      surfaceContainerHighest: SpeakrColors.bgAlt,
      onSurface: SpeakrColors.ink,
      primary: SpeakrColors.ink,
      onPrimary: SpeakrColors.bg,
      secondary: SpeakrColors.ink2,
      onSecondary: SpeakrColors.bg,
      error: SpeakrColors.danger,
      onError: SpeakrColors.bg,
      outline: SpeakrColors.line,
    ),
    splashFactory: InkRipple.splashFactory,
  );

  return base.copyWith(
    textTheme: TextTheme(
      displayLarge: SpeakrText.serif(size: 38, height: 1.05),
      headlineLarge: SpeakrText.serif(size: 32, height: 1.15),
      headlineMedium: SpeakrText.serif(size: 26, height: 1.15),
      titleLarge: SpeakrText.serif(size: 17, height: 1.25),
      titleMedium: SpeakrText.sans(
        size: 14,
        weight: FontWeight.w600,
        color: SpeakrColors.ink,
      ),
      bodyLarge: SpeakrText.serif(size: 14.5, height: 1.45),
      bodyMedium: SpeakrText.sans(size: 14, height: 1.4),
      bodySmall: SpeakrText.sans(
        size: 13,
        height: 1.4,
        color: SpeakrColors.ink2,
      ),
      labelLarge: SpeakrText.sans(
        size: 13,
        weight: FontWeight.w500,
        color: SpeakrColors.ink,
      ),
      labelMedium: SpeakrText.sans(size: 12, color: SpeakrColors.muted),
      labelSmall: SpeakrText.mono(size: 10, letterSpacing: 1.5),
    ),
    iconTheme: const IconThemeData(color: SpeakrColors.ink, size: 20),
    dividerColor: SpeakrColors.line,
    appBarTheme: const AppBarTheme(
      backgroundColor: SpeakrColors.bg,
      foregroundColor: SpeakrColors.ink,
      elevation: 0,
      surfaceTintColor: SpeakrColors.bg,
      centerTitle: false,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: SpeakrColors.ink,
      foregroundColor: SpeakrColors.bg,
      elevation: 8,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: SpeakrText.sans(size: 14, color: SpeakrColors.muted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: SpeakrColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: SpeakrColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: SpeakrColors.ink, width: 1.2),
      ),
    ),
  );
}
