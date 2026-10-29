import 'package:intl/intl.dart';

import 'auto_upload_settings.dart';

/// A regex + format combo that knows how to extract a [DateTime] from a
/// recording filename.
class DateTimePreset {
  const DateTimePreset({
    required this.id,
    required this.label,
    required this.pattern,
    required this.captureGroup,
    required this.format,
  });

  final String id;
  final String label;

  /// Anchored or unanchored regex with at least one capture group.
  final String pattern;
  final int captureGroup;

  /// `intl` [DateFormat] pattern, or the sentinel `'__epoch_ms__'` for
  /// 13-digit Unix millisecond timestamps.
  final String format;

  RegExp get regex => RegExp(pattern);
}

const String kEpochMsFormat = '__epoch_ms__';

const List<DateTimePreset> kDateTimePresets = [
  DateTimePreset(
    id: 'samsung_call_v1',
    label: 'Samsung — _yyMMdd_HHmmss',
    pattern: r'_(\d{6}_\d{6})(?:\.\w+)?$',
    captureGroup: 1,
    format: "yyMMdd'_'HHmmss",
  ),
  DateTimePreset(
    id: 'pixel_call_v1',
    label: 'Pixel — yyyy-MM-dd HH-mm-ss',
    pattern: r'(\d{4}-\d{2}-\d{2} \d{2}-\d{2}-\d{2})',
    captureGroup: 1,
    format: 'yyyy-MM-dd HH-mm-ss',
  ),
  DateTimePreset(
    id: 'generic_compact',
    label: 'Generic — yyyyMMdd_HHmmss',
    pattern: r'(\d{8}_\d{6})',
    captureGroup: 1,
    format: "yyyyMMdd'_'HHmmss",
  ),
  DateTimePreset(
    id: 'iso_basic',
    label: 'ISO 8601 — yyyy-MM-ddTHH:mm:ss',
    pattern: r'(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})',
    captureGroup: 1,
    format: "yyyy-MM-dd'T'HH:mm:ss",
  ),
  DateTimePreset(
    id: 'unix_epoch_ms',
    label: 'Unix epoch ms (13 digits)',
    pattern: r'(\d{13})',
    captureGroup: 1,
    format: kEpochMsFormat,
  ),
  DateTimePreset(
    id: 'coloros_compact_v1',
    label: 'ColorOS — yyMMddHHmm',
    pattern: r'(\d{10})(?:\.\w+)?$',
    captureGroup: 1,
    format: 'yyMMddHHmm',
  ),
];

/// Sentinel id used in [FolderUploadConfig.parsePresetId] when the user
/// supplies their own regex / format.
const String kCustomPresetId = 'custom';

DateTimePreset? presetById(String id) {
  for (final p in kDateTimePresets) {
    if (p.id == id) return p;
  }
  return null;
}

/// Resolves the active parse rule for [s] into a [DateTimePreset], or
/// returns `null` when filename parsing is disabled or misconfigured.
DateTimePreset? activePreset(FolderUploadConfig s) {
  final id = s.parsePresetId;
  if (id == null) return null;
  if (id == kCustomPresetId) {
    final r = s.customRegex;
    final g = s.customCaptureGroup;
    final f = s.customFormat;
    if (r == null || r.isEmpty || g == null || f == null || f.isEmpty) {
      return null;
    }
    return DateTimePreset(
      id: kCustomPresetId,
      label: 'Custom',
      pattern: r,
      captureGroup: g,
      format: f,
    );
  }
  return presetById(id);
}

/// Pure parse: returns null if the regex doesn't match or the captured
/// group fails strict parsing. Throws nothing.
DateTime? parseFromFilename(String filename, DateTimePreset preset) {
  final RegExp re;
  try {
    re = preset.regex;
  } catch (_) {
    return null;
  }
  final match = re.firstMatch(filename);
  if (match == null) return null;
  final raw = preset.captureGroup <= match.groupCount
      ? match.group(preset.captureGroup)
      : null;
  if (raw == null || raw.isEmpty) return null;
  if (preset.format == kEpochMsFormat) {
    final ms = int.tryParse(raw);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }
  // Try the manual width-based parser first. Dart `intl`'s DateFormat
  // can't parse formats with adjacent numeric fields (e.g. `yyMMdd`)
  // even with parseLoose, so we slice the captured group ourselves.
  final manual = _parseByWidths(raw, preset.format);
  if (manual != null) return manual;
  // Fall back to DateFormat for richer locale-specific formats — won't
  // help on compact patterns but does cover anything intl handles.
  try {
    return DateFormat(preset.format).parseStrict(raw);
  } catch (_) {
    return null;
  }
}

/// Parses [raw] against [format] by walking the format string left-to-right
/// and slicing fixed-width fields out of [raw] one at a time. Supports
/// `yyyy`, `yy`, `MM`, `dd`, `HH`, `mm`, `ss`, and quoted literals (in
/// single quotes), plus any non-letter character treated as a literal.
///
/// Returns null if any field is out of range or the input doesn't line up
/// with the format. This is the engine for compact patterns like
/// `yyMMdd_HHmmss` that DateFormat refuses to parse.
DateTime? _parseByWidths(String raw, String format) {
  int year = 1970, month = 1, day = 1, hour = 0, minute = 0, second = 0;
  bool seenAnyField = false;
  int fp = 0; // format pointer
  int rp = 0; // raw pointer

  while (fp < format.length) {
    final ch = format[fp];

    // Quoted literal: 'abc'
    if (ch == "'") {
      final end = format.indexOf("'", fp + 1);
      if (end == -1) return null;
      final literal = format.substring(fp + 1, end);
      if (literal.isEmpty) {
        // '' = literal apostrophe.
        if (rp >= raw.length || raw[rp] != "'") return null;
        rp++;
      } else {
        if (rp + literal.length > raw.length) return null;
        if (raw.substring(rp, rp + literal.length) != literal) return null;
        rp += literal.length;
      }
      fp = end + 1;
      continue;
    }

    // Field tokens — grouped by repeated letter.
    if (_isLetter(ch)) {
      var run = 1;
      while (fp + run < format.length && format[fp + run] == ch) {
        run++;
      }
      final width = _fieldWidth(ch, run);
      if (width == null) return null;
      if (rp + width > raw.length) return null;
      final chunk = raw.substring(rp, rp + width);
      final n = int.tryParse(chunk);
      if (n == null) return null;
      switch (ch) {
        case 'y':
          year = run == 2 ? 2000 + n : n;
          seenAnyField = true;
          break;
        case 'M':
          if (n < 1 || n > 12) return null;
          month = n;
          seenAnyField = true;
          break;
        case 'd':
          if (n < 1 || n > 31) return null;
          day = n;
          seenAnyField = true;
          break;
        case 'H':
          if (n < 0 || n > 23) return null;
          hour = n;
          break;
        case 'm':
          if (n < 0 || n > 59) return null;
          minute = n;
          break;
        case 's':
          if (n < 0 || n > 59) return null;
          second = n;
          break;
        default:
          return null;
      }
      rp += width;
      fp += run;
      continue;
    }

    // Any other character is a literal in the format — must match raw.
    if (rp >= raw.length || raw[rp] != ch) return null;
    rp++;
    fp++;
  }

  if (rp != raw.length) return null;
  if (!seenAnyField) return null;
  return _safeDateTime(year, month, day, hour, minute, second);
}

bool _isLetter(String ch) {
  if (ch.length != 1) return false;
  final c = ch.codeUnitAt(0);
  return (c >= 0x41 && c <= 0x5A) || (c >= 0x61 && c <= 0x7A);
}

int? _fieldWidth(String letter, int run) {
  switch (letter) {
    case 'y':
      if (run == 2) return 2;
      if (run == 4) return 4;
      return null;
    case 'M':
    case 'd':
    case 'H':
    case 'm':
    case 's':
      return run == 2 ? 2 : null;
    default:
      return null;
  }
}

DateTime? _safeDateTime(
  int year,
  int month,
  int day,
  int hour,
  int minute,
  int second,
) {
  // Reject date-out-of-range (e.g. February 30) by round-tripping.
  final dt = DateTime(year, month, day, hour, minute, second);
  if (dt.year != year ||
      dt.month != month ||
      dt.day != day ||
      dt.hour != hour ||
      dt.minute != minute ||
      dt.second != second) {
    return null;
  }
  return dt;
}

/// Returns the best available timestamp for a file: the parsed filename if
/// parsing is configured and matches, otherwise [modified] (the file's
/// mtime, which always works locally).
DateTime resolveDateTime(
  String basename,
  DateTime modified,
  FolderUploadConfig settings,
) {
  final preset = activePreset(settings);
  if (preset != null) {
    final parsed = parseFromFilename(basename, preset);
    if (parsed != null) return parsed;
  }
  return modified;
}
