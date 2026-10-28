import 'package:speakr_app/l10n/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../features/detail/detail_controller.dart';
import '../../features/detail/widgets/transcript_copy_menu.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// Compact timestamp, speaker and transcript columns.
class DesktopTranscriptPane extends ConsumerWidget {
  const DesktopTranscriptPane({
    super.key,
    required this.recordingId,
    required this.player,
  });

  final int recordingId;
  final AudioPlayer player;

  static const _palette = [
    SpeakrColors.tagRoadmap,
    SpeakrColors.tagCustomer,
    SpeakrColors.tagEngineering,
    SpeakrColors.tag1on1,
    SpeakrColors.tagDesign,
    SpeakrColors.tagPersonal,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    final async = ref.watch(transcriptProvider(recordingId));
    return async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: SpeakrColors.ink,
          strokeWidth: 2,
        ),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr("COULDN'T LOAD TRANSCRIPT"),
              style: SpeakrText.mono(
                size: 10,
                color: SpeakrColors.danger,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(e.toString(), style: SpeakrText.sans(size: 14)),
          ],
        ),
      ),
      data: (segments) {
        if (segments.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(28),
            child: Text(
              tr("Transcript not available yet."),
              style: SpeakrText.serif(
                size: 15,
                color: SpeakrColors.ink2,
                height: 1.5,
              ),
            ),
          );
        }
        final speakers = <String>[];
        for (final s in segments) {
          final name = s.speaker;
          if (name != null && name.isNotEmpty && !speakers.contains(name)) {
            speakers.add(name);
          }
        }
        Color colorFor(String? name) {
          if (name == null) return SpeakrColors.ink2;
          final i = speakers.indexOf(name);
          if (i < 0) return SpeakrColors.ink2;
          return _palette[i % _palette.length];
        }

        return StreamBuilder<Duration>(
          stream: player.positionStream,
          builder: (context, snap) {
            final pos = snap.data ?? Duration.zero;
            final secs = pos.inMilliseconds / 1000.0;
            // Find the active segment — the latest one whose start_time
            // is <= the current playback time. Falls back to -1 when the
            // playhead is before the first segment.
            int activeIdx = -1;
            for (var i = 0; i < segments.length; i++) {
              final t = segments[i].startTime ?? 0;
              if (t <= secs) {
                activeIdx = i;
              } else {
                break;
              }
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 40),
              itemCount: segments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 2),
              itemBuilder: (context, i) {
                final s = segments[i];
                final speakerName = s.speaker;
                final color = colorFor(speakerName);
                final active = i == activeIdx;
                final ts = s.startTime ?? 0;
                final mm = (ts ~/ 60).toString().padLeft(2, '0');
                final ss = (ts % 60).floor().toString().padLeft(2, '0');

                void seekAndPlay() {
                  final start = s.startTime;
                  if (start == null) return;
                  player.seek(Duration(milliseconds: (start * 1000).round()));
                  player.play();
                }

                void showCopy(Offset globalPosition) {
                  showTranscriptCopyMenu(
                    context,
                    globalPosition,
                    s.sentence ?? '',
                  );
                }

                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: seekAndPlay,
                    onSecondaryTapDown: (d) => showCopy(d.globalPosition),
                    onLongPressStart: (d) => showCopy(d.globalPosition),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? SpeakrColors.accent.withValues(alpha: .09)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 42,
                            child: Text(
                              '$mm:$ss',
                              style: SpeakrText.mono(
                                size: 11,
                                color: SpeakrColors.muted,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 84,
                            child: Tooltip(
                              message: speakerName ?? '—',
                              child: Text(
                                speakerName ?? '—',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: SpeakrText.sans(
                                  size: 11.5,
                                  color: color,
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(0, 1, 0, 1),
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                s.sentence ?? '',
                                style: SpeakrText.serif(
                                  size: 13.5,
                                  height: 1.5,
                                  color: active
                                      ? SpeakrColors.ink
                                      : SpeakrColors.ink2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
