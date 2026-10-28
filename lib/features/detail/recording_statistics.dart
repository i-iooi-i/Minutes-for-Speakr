import '../../api/models.dart';

class SpeakerActivity {
  SpeakerActivity(this.name);
  final String name;
  int segments = 0;
  int timedSegments = 0;
  final List<(double, double)> _ranges = [];
  double get seconds {
    final ranges = [..._ranges]..sort((a, b) => a.$1.compareTo(b.$1));
    double total = 0, end = 0;
    for (final r in ranges) {
      final start = r.$1 > end ? r.$1 : end;
      if (r.$2 > start) total += r.$2 - start;
      if (r.$2 > end) end = r.$2;
    }
    return total;
  }
}

List<SpeakerActivity> recordingSpeakerActivity(
  List<TranscriptSegment> segments,
) {
  final speakers = <String, SpeakerActivity>{};
  for (final s in segments) {
    if ((s.sentence ?? '').trim().isEmpty) continue;
    final name = (s.speaker ?? '').trim();
    final activity = speakers.putIfAbsent(name, () => SpeakerActivity(name));
    activity.segments++;
    final start = s.startTime, end = s.endTime;
    if (start != null &&
        end != null &&
        start.isFinite &&
        end.isFinite &&
        start >= 0 &&
        end >= start) {
      activity.timedSegments++;
      activity._ranges.add((start, end));
    }
  }
  return speakers.values.toList()
    ..sort((a, b) => b.seconds.compareTo(a.seconds));
}
