import 'package:speakr_app/l10n/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../api/models.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/mono_eyebrow.dart';
import '../detail_controller.dart';
import '../widgets/transcript_copy_menu.dart';

class TranscriptTab extends ConsumerWidget {
  const TranscriptTab({
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
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: SpeakrColors.ink,
          ),
        ),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MonoEyebrow(tr("Couldn’t load transcript")),
            const SizedBox(height: 8),
            Text(e.toString(), style: SpeakrText.sans(size: 14)),
          ],
        ),
      ),
      data: (segments) {
        if (segments.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
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
        // Map distinct speakers to colors. The first speaker is treated as
        // "you" (right-aligned, ink) — matches the React mock convention.
        final speakers = <String>{};
        for (final s in segments) {
          if (s.speaker != null && s.speaker!.isNotEmpty) {
            speakers.add(s.speaker!);
          }
        }
        final speakerList = speakers.toList();
        final me = speakerList.isNotEmpty ? speakerList.first : null;
        Color colorFor(String? name) {
          if (name == null) return SpeakrColors.ink2;
          final i = speakerList.indexOf(name);
          if (i < 0) return SpeakrColors.ink2;
          return _palette[i % _palette.length];
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
          itemCount: segments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (_, i) {
            final s = segments[i];
            final isMe = s.speaker != null && s.speaker == me;
            return _Bubble(
              segment: s,
              isMe: isMe,
              speakerColor: colorFor(s.speaker),
              player: player,
            );
          },
        );
      },
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.segment,
    required this.isMe,
    required this.speakerColor,
    required this.player,
  });
  final TranscriptSegment segment;
  final bool isMe;
  final Color speakerColor;
  final AudioPlayer player;

  void _seekAndPlay() {
    final start = segment.startTime;
    if (start == null) return;
    player.seek(Duration(milliseconds: (start * 1000).round()));
    player.play();
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final timestamp = segment.startTime == null
        ? ''
        : formatDuration(segment.startTime!);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _seekAndPlay,
      onLongPressStart: (details) => showTranscriptCopyMenu(
        context,
        details.globalPosition,
        segment.sentence ?? '',
      ),
      child: Column(
        crossAxisAlignment: align,
        children: [
          if (segment.speaker != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    segment.speaker!.toUpperCase(),
                    style: SpeakrText.sans(
                      size: 11,
                      weight: FontWeight.w600,
                      color: speakerColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                  if (timestamp.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Text(
                      timestamp,
                      style: SpeakrText.mono(
                        size: 10,
                        color: SpeakrColors.muted,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 4),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.82,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? SpeakrColors.ink : Colors.white,
                border: isMe ? null : Border.all(color: SpeakrColors.line),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: isMe
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
              ),
              child: Text(
                segment.sentence ?? '',
                style: SpeakrText.serif(
                  size: 14.5,
                  height: 1.45,
                  color: isMe ? SpeakrColors.bg : SpeakrColors.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
