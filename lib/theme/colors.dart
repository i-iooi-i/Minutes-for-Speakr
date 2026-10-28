import 'package:flutter/material.dart';

/// Neutral audio workspace. Color is reserved for signal and status.
class SpeakrColors {
  static const surface = Color(0xFF191D20);
  static const accent = Color(0xFF70C9AC);
  static const bg = Color(0xFF111416);
  static const bgAlt = Color(0xFF202529);
  static const ink = Color(0xFFF1F2EF);
  static const ink2 = Color(0xFFC4CACD);
  static const muted = Color(0xFF969EA3);
  static const line = Color(0xFF2C3236);

  // Accents pulled from the design's tag colors and indicators.
  static const recordingDot = Color(0xFFF0806E);
  static const ok = Color(0xFF70C9AC);
  static const danger = Color(0xFFF0806E);

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
