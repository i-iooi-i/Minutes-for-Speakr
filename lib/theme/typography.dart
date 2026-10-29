import 'package:flutter/material.dart';

import 'colors.dart';
import 'tokens.dart';

/// Bundled Latin faces with native Chinese sans fallbacks. The legacy `serif`
/// helper is retained for callers, but uses the same readable sans family.
const String kSerifFamily = 'Source Serif 4';
const String kSansFamily = 'Inter Tight';
const String kMonoFamily = 'JetBrains Mono';

class SpeakrText {
  static TextStyle serif({
    double? size,
    FontWeight weight = FontWeight.w400,
    FontStyle? style,
    Color? color,
    double height = 1.2,
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
    fontStyle: FontStyle.normal,
    color: color ?? SpeakrColors.ink,
    height: height,
    letterSpacing: letterSpacing,
  );

  static TextStyle sans({
    double? size,
    FontWeight weight = FontWeight.w400,
    Color? color,
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
    color: color ?? SpeakrColors.ink,
    height: height,
    letterSpacing: letterSpacing,
  );

  static TextStyle mono({
    double size = 11,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double letterSpacing = 0.3,
  }) => TextStyle(
    fontFamily: kMonoFamily,
    fontFamilyFallback: const [
      'Microsoft YaHei',
      'PingFang SC',
      'Noto Sans CJK SC',
    ],
    fontSize: size,
    fontWeight: weight,
    color: color ?? SpeakrColors.muted,
    letterSpacing: letterSpacing,
  );
}

ThemeData buildSpeakrTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: SpeakrColors.isDark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: SpeakrColors.bg,
    colorScheme: ColorScheme(
      brightness: SpeakrColors.isDark ? Brightness.dark : Brightness.light,
      surface: SpeakrColors.bg,
      surfaceContainerHighest: SpeakrColors.bgAlt,
      onSurface: SpeakrColors.ink,
      primary: SpeakrColors.ink,
      onPrimary: SpeakrColors.bg,
      secondary: SpeakrColors.accent,
      onSecondary: SpeakrColors.bg,
      error: SpeakrColors.danger,
      onError: SpeakrColors.bg,
      outline: SpeakrColors.line,
    ),
    splashFactory: InkRipple.splashFactory,
  );

  return base.copyWith(
    iconButtonTheme: const IconButtonThemeData(
      style: ButtonStyle(shape: WidgetStatePropertyAll(CircleBorder())),
    ),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        ...base.pageTransitionsTheme.builders,
        TargetPlatform.windows: const _DesktopPageTransition(),
        TargetPlatform.linux: const _DesktopPageTransition(),
        TargetPlatform.macOS: const _DesktopPageTransition(),
      },
    ),
    dividerTheme: DividerThemeData(color: SpeakrColors.line, thickness: 1),
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
    snackBarTheme: SnackBarThemeData(
      backgroundColor: SpeakrColors.bgAlt,
      contentTextStyle: SpeakrText.sans(size: 13, color: SpeakrColors.ink),
      actionTextColor: SpeakrColors.ink,
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: SpeakrRadius.menu,
        side: BorderSide(color: SpeakrColors.line),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: SpeakrColors.bgAlt,
      surfaceTintColor: Colors.transparent,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: SpeakrRadius.menu,
        side: BorderSide(color: SpeakrColors.line),
      ),
      textStyle: TextStyle(fontSize: 13, color: SpeakrColors.ink),
    ),
    iconTheme: IconThemeData(color: SpeakrColors.ink, size: 20),
    dividerColor: SpeakrColors.line,
    appBarTheme: AppBarTheme(
      backgroundColor: SpeakrColors.bg,
      foregroundColor: SpeakrColors.ink,
      elevation: 0,
      surfaceTintColor: SpeakrColors.bg,
      centerTitle: false,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: SpeakrColors.ink,
      foregroundColor: SpeakrColors.bg,
      elevation: 8,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: SpeakrColors.surface,
      hintStyle: SpeakrText.sans(size: 14, color: SpeakrColors.muted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: SpeakrColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: SpeakrColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: SpeakrColors.ink, width: 1.2),
      ),
    ),
  );
}

class _DesktopPageTransition extends PageTransitionsBuilder {
  const _DesktopPageTransition();
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => child;
}
