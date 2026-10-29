import 'package:flutter/material.dart';

class SpeakrSpacing {
  static const double pageH = 24; // horizontal page padding
  static const double pageHTight = 16;
  static const double rowV = 14;
  static const double cardPad = 16;
  static const double gap = 12;
}

class SpeakrRadius {
  static const BorderRadius menu = BorderRadius.all(Radius.circular(12));
  static const BorderRadius control = BorderRadius.all(Radius.circular(100));
  static const Radius xs = Radius.circular(3);
  static const Radius sm = Radius.circular(4);
  static const Radius md = Radius.circular(6);
  static const Radius lg = Radius.circular(16);
  static const Radius pill = Radius.circular(100);
}

class SpeakrDurations {
  static const Duration fade = Duration(milliseconds: 280);
  static const Duration tap = Duration(milliseconds: 120);
  static const Duration pulse = Duration(milliseconds: 1500);
}
