import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/models.dart';
import '../../api/providers.dart';

final recordingDetailProvider = FutureProvider.autoDispose
    .family<Recording, int>((ref, id) async {
      return ref.watch(speakrApiProvider).getRecording(id);
    });

final summaryProvider = FutureProvider.autoDispose.family<String, int>((
  ref,
  id,
) async {
  final r = await ref.watch(recordingDetailProvider(id).future);
  return r.summary ?? '';
});

final allSpeakersProvider = FutureProvider.autoDispose<List<Speaker>>((
  ref,
) async {
  final list = await ref.watch(speakrApiProvider).listSpeakers();
  // Most-used first, then alphabetical for stable ordering across the dropdown.
  final sorted = [...list]
    ..sort((a, b) {
      final byCount = b.useCount.compareTo(a.useCount);
      return byCount != 0
          ? byCount
          : a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  return sorted;
});

final speakerSuggestionsProvider = FutureProvider.autoDispose
    .family<Map<String, List<SpeakerSuggestion>>, int>((ref, id) async {
      return ref.watch(speakrApiProvider).getSpeakerSuggestions(id);
    });

final transcriptProvider = FutureProvider.autoDispose
    .family<List<TranscriptSegment>, int>((ref, id) async {
      final r = await ref.watch(recordingDetailProvider(id).future);
      final raw = r.transcription;
      if (raw == null || raw.trim().isEmpty) return const [];
      // The unofficial detail endpoint serializes transcription as a JSON-encoded
      // string of segment objects ({speaker, sentence, start_time, end_time}).
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded
              .whereType<Map<String, dynamic>>()
              .map(TranscriptSegment.fromJson)
              .toList(growable: false);
        }
      } on FormatException {
        // Not JSON — render the raw text as a single segment.
        return [TranscriptSegment(sentence: raw)];
      }
      return const [];
    });
