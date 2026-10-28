import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/strings.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';
import '../detail_controller.dart';
import '../recording_statistics.dart';

class RecordingStatsTab extends ConsumerWidget {
  const RecordingStatsTab({super.key, required this.recordingId});
  final int recordingId;
  String _clock(double seconds) =>
      '${seconds ~/ 60}:${(seconds.toInt() % 60).toString().padLeft(2, '0')}';
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    return ref
        .watch(transcriptProvider(recordingId))
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: TextButton(
              onPressed: () =>
                  ref.invalidate(recordingDetailProvider(recordingId)),
              child: Text(tr('Could not load statistics. Retry')),
            ),
          ),
          data: (segments) {
            final rows = recordingSpeakerActivity(segments);
            final total = rows.fold<double>(0, (sum, s) => sum + s.seconds);
            final count = rows.fold<int>(0, (sum, s) => sum + s.segments);
            final complete = rows.every((s) => s.timedSegments == s.segments);
            final duration = ref
                .watch(recordingDetailProvider(recordingId))
                .value
                ?.audioDuration;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  tr('Recording overview'),
                  style: SpeakrText.sans(size: 15, weight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                _metric(
                  tr('Duration'),
                  duration == null ? '—' : _clock(duration),
                ),
                _metric(tr('Speakers'), '${rows.length}'),
                _metric(tr('Transcript segments'), '$count'),
                const Divider(height: 32, color: SpeakrColors.line),
                Text(
                  tr('Speaker activity'),
                  style: SpeakrText.sans(size: 14, weight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  tr(
                    complete
                        ? 'Share of measured speech; simultaneous speakers may overlap.'
                        : 'Some timestamps are missing. Durations and shares are unavailable.',
                  ),
                  style: SpeakrText.sans(
                    size: 11,
                    color: SpeakrColors.muted,
                    height: 1.5,
                  ),
                ),
                if (rows.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(tr('Transcript not available yet.')),
                  ),
                for (final row in rows)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.name.isEmpty ? tr('Unknown speaker') : row.name,
                          style: SpeakrText.sans(
                            size: 13,
                            weight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${tr('{0} segments', [row.segments])}${complete ? ' · ${_clock(row.seconds)} · ${total > 0 ? (row.seconds / total * 100).round() : 0}%' : ''}',
                          style: SpeakrText.sans(
                            size: 11,
                            color: SpeakrColors.muted,
                          ),
                        ),
                        if (complete && total > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: LinearProgressIndicator(
                              value: row.seconds / total,
                              minHeight: 4,
                              borderRadius: BorderRadius.circular(4),
                              color: SpeakrColors.accent,
                              backgroundColor: SpeakrColors.line,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            );
          },
        );
  }

  Widget _metric(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: SpeakrText.sans(size: 12, color: SpeakrColors.muted),
          ),
        ),
        Text(value, style: SpeakrText.mono(size: 12)),
      ],
    ),
  );
}
