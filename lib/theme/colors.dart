import 'package:flutter/material.dart';
import 'appearance.dart';

/// Neutral audio workspace. Color is reserved for signal and status.
class SpeakrColors {
  static bool get isDark => appAppearance.brightness == Brightness.dark;
  static const recordRed = Color(0xFFFF453A);
  static Color get surface =>
      isDark ? const Color(0xFF191D20) : const Color(0xFFFFFFFF);
  static Color get accent =>
      appAppearance.palette.accent(appAppearance.brightness);
  static Color get onAccent =>
      accent.computeLuminance() > 0.179 ? Colors.black : Colors.white;
  static Color get navHover => accent.withValues(alpha: isDark ? 0.08 : 0.06);
  static Color get navSelected =>
      accent.withValues(alpha: isDark ? 0.16 : 0.12);
  static Color get bg =>
      isDark ? const Color(0xFF111416) : const Color(0xFFF6F7F8);
  static Color get bgAlt =>
      isDark ? const Color(0xFF202529) : const Color(0xFFECEFF1);
  static Color get ink =>
      isDark ? const Color(0xFFF1F2EF) : const Color(0xFF1B2328);
  static Color get ink2 =>
      isDark ? const Color(0xFFC4CACD) : const Color(0xFF414C53);
  static Color get muted =>
      isDark ? const Color(0xFF969EA3) : const Color(0xFF626D75);
  static Color get line =>
      isDark ? const Color(0xFF2C3236) : const Color(0xFFD9DFE3);

  // Accents pulled from the design's tag colors and indicators.
  static const recordingDot = Color(0xFFF0806E);
  static Color get ok =>
      isDark ? const Color(0xFF70C9AC) : const Color(0xFF087950);
  static Color get danger =>
      isDark ? const Color(0xFFF0806E) : const Color(0xFFBC3529);

  // Tag preset colors (tags from data.js / direction-a-3.jsx)
  static const tagRoadmap = Color(0xFFF0806E);
  static const tagEngineering = Color(0xFF70C9AC);
  static const tag1on1 = Color(0xFFBD9BCC);
  static const tagCustomer = Color(0xFF8DB7D3);
  static const tagDesign = Color(0xFFD3B779);
  static const tagPersonal = Color(0xFFA8BD8C);
  static const tagInternal = Color(0xFF70C9AC);
}

/// Convert a hex string from the API (`#c2562b`, `c2562b`, `#c2562bff`)
/// into a [Color]. Returns [SpeakrColors.muted] on parse failure.
Color parseHexColor(String? hex) {
  if (hex == null || hex.isEmpty) return SpeakrColors.muted;
  var v = hex.replaceAll('#', '').trim();
  if (v.length == 6) v = 'FF$v';
  if (v.length != 8) return SpeakrColors.muted;
  final n = int.tryParse(v, radix: 16);
  if (n == null) return SpeakrColors.muted;
  return Color(n);
}
