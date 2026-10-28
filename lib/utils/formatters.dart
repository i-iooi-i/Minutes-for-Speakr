import 'package:speakr_app/l10n/strings.dart';
import 'package:intl/intl.dart';

/// "Today" / "Yesterday" / weekday / "Mon D" — matches `fmtDate`
/// in direction-a-2.jsx (lines 5-13). Uses the device timezone.
String formatRelativeDay(DateTime when, {DateTime? today}) {
  final w = when.toLocal();
  final now = today ?? DateTime.now();
  final tDay = DateTime(now.year, now.month, now.day);
  final wDay = DateTime(w.year, w.month, w.day);
  final diff = tDay.difference(wDay).inDays;
  if (diff <= 0) return tr("Today");
  if (diff == 1) return tr("Yesterday");
  if (diff < 7) return DateFormat.EEEE().format(w);
  return DateFormat.MMMd().format(w);
}

/// Clock-time. `use24Hour: false` (default) → `9:41 AM`;
/// `use24Hour: true` → `09:41`.
String formatHourMinute(DateTime when, {bool use24Hour = false}) {
  final fmt = use24Hour
      ? DateFormat.Hm()
      : (appLanguage.value == 'zh'
            ? DateFormat('a h:mm', 'zh_CN')
            : DateFormat('h:mm a', 'en_US'));
  return fmt.format(when.toLocal());
}

/// "47:12" / "01:18" duration. Accepts seconds.
String formatDuration(double seconds) {
  if (seconds.isNaN || seconds.isNegative) return '00:00';
  final total = seconds.floor();
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final s = total % 60;
  String two(int n) => n.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
}

String formatBytes(int? bytes) {
  if (bytes == null || bytes <= 0) return '—';
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var v = bytes.toDouble();
  var i = 0;
  while (v >= 1024 && i < units.length - 1) {
    v /= 1024;
    i++;
  }
  return v >= 10
      ? '${v.toStringAsFixed(0)} ${units[i]}'
      : '${v.toStringAsFixed(1)} ${units[i]}';
}
