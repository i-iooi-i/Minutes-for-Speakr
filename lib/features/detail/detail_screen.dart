import 'package:speakr_app/l10n/strings.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

import '../../api/models.dart';
import '../../services/credentials_store.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../utils/formatters.dart';
import '../../widgets/mono_eyebrow.dart';
import '../../widgets/speakr_icons.dart';
import 'detail_actions.dart';
import 'detail_controller.dart';
import 'speaker_review_screen.dart';
import 'tabs/chat_tab.dart';
import 'tabs/summary_tab.dart';
import 'tabs/transcript_tab.dart';
import 'widgets/folder_tags_editor.dart';

class DetailScreen extends ConsumerStatefulWidget {
  const DetailScreen({super.key, required this.recordingId});
  final int recordingId;

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  int _tab = 0;
  final _audioPlayer = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSub;
  bool _audioReady = false;

  @override
  void initState() {
    super.initState();
    // Drive readiness from the player's own state stream rather than the
    // setUrl() future. just_audio_android (ExoPlayer) sometimes throws or
    // stalls on setUrl() even when the player ultimately reaches a playable
    // state — gating the UI on the future leaves the play button disabled.
    _playerStateSub = _audioPlayer.playerStateStream.listen((state) {
      final ready =
          state.processingState == ProcessingState.ready ||
          state.processingState == ProcessingState.buffering;
      if (ready && !_audioReady && mounted) {
        setState(() => _audioReady = true);
      }
    });
    _initAudio();
  }

  Future<void> _initAudio() async {
    final creds = await ref.read(credentialsStoreProvider).read();
    if (creds == null) return;
    final url =
        '${creds.baseUrl}/api/v1/recordings/${widget.recordingId}/audio';
    try {
      await _audioPlayer.setUrl(url, headers: {'X-API-Token': creds.token});
    } catch (e, st) {
      debugPrint(
        'Speakr audio: setUrl failed for recording ${widget.recordingId}: $e\n$st',
      );
    }
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final asyncR = ref.watch(recordingDetailProvider(widget.recordingId));
    return Scaffold(
      backgroundColor: SpeakrColors.bg,
      body: SafeArea(
        bottom: false,
        child: asyncR.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: SpeakrColors.ink,
              strokeWidth: 2,
            ),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBar(date: '', onBack: () => context.pop(), recording: null),
                const SizedBox(height: 12),
                MonoEyebrow(tr("Couldn’t load recording")),
                const SizedBox(height: 8),
                Text(e.toString(), style: SpeakrText.sans(size: 14)),
              ],
            ),
          ),
          data: (r) => _DetailBody(
            recording: r,
            tab: _tab,
            onTabChanged: (i) => setState(() => _tab = i),
            audioPlayer: _audioPlayer,
            audioReady: _audioReady,
          ),
        ),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({
    required this.recording,
    required this.tab,
    required this.onTabChanged,
    required this.audioPlayer,
    required this.audioReady,
  });
  final Recording recording;
  final int tab;
  final ValueChanged<int> onTabChanged;
  final AudioPlayer audioPlayer;
  final bool audioReady;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    return Column(
      children: [
        _TopBar(
          date: formatRelativeDay(
            recording.meetingDate ?? recording.createdAt ?? DateTime.now(),
          ),
          onBack: () => context.pop(),
          recording: recording,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FolderTagsEditor(recording: recording),
              ),
              Text(
                recording.title?.isNotEmpty == true
                    ? recording.title!
                    : tr("Untitled recording"),
                style: SpeakrText.serif(size: 26, height: 1.15),
              ),
              if ((recording.participants ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  recording.participants!,
                  style: SpeakrText.sans(size: 12, color: SpeakrColors.muted),
                ),
              ],
            ],
          ),
        ),
        _AudioPlayerBar(
          player: audioPlayer,
          ready: audioReady,
          totalLabel: formatDuration(recording.audioDuration ?? 0),
        ),
        _TabBar(tab: tab, onChanged: onTabChanged),
        Expanded(
          child: IndexedStack(
            index: tab,
            children: [
              SummaryTab(recordingId: recording.id),
              TranscriptTab(recordingId: recording.id, player: audioPlayer),
              ChatTab(recordingId: recording.id),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.date,
    required this.onBack,
    required this.recording,
  });
  final String date;
  final VoidCallback onBack;
  final Recording? recording;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final r = recording;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          GhostIconButton(icon: SpeakrIcon.back, onTap: onBack),
          Expanded(child: Center(child: MonoEyebrow(date, size: 10))),
          GhostIconButton(
            icon: SpeakrIcon.more,
            onTap: r == null
                ? null
                : () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: SpeakrColors.bg,
                      builder: (_) => _MoreSheet(recording: r),
                    );
                  },
          ),
        ],
      ),
    );
  }
}

class _MoreSheet extends ConsumerWidget {
  const _MoreSheet({required this.recording});
  final Recording recording;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    final inInbox = recording.isInbox;
    final highlighted = recording.isHighlighted;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const SpeakrIconView(SpeakrIcon.star),
              title: Text(
                highlighted
                    ? tr("Remove highlight")
                    : tr("Highlight recording"),
                style: SpeakrText.sans(size: 14),
              ),
              onTap: () {
                Navigator.of(context).pop();
                toggleRecordingField(
                  context,
                  ref,
                  recordingId: recording.id,
                  patch: {'is_highlighted': !highlighted},
                  successMessage: highlighted
                      ? tr("Highlight removed")
                      : tr("Highlighted"),
                );
              },
            ),
            ListTile(
              leading: const SpeakrIconView(SpeakrIcon.flag),
              title: Text(
                inInbox ? tr("Remove from inbox") : tr("Move to inbox"),
                style: SpeakrText.sans(size: 14),
              ),
              onTap: () {
                Navigator.of(context).pop();
                toggleRecordingField(
                  context,
                  ref,
                  recordingId: recording.id,
                  patch: {'is_inbox': !inInbox},
                  successMessage: inInbox
                      ? tr("Removed from inbox")
                      : tr("Moved to inbox"),
                );
              },
            ),
            const Divider(color: SpeakrColors.line, height: 1),
            ListTile(
              leading: const SpeakrIconView(SpeakrIcon.search),
              title: Text(
                tr("Edit speakers"),
                style: SpeakrText.sans(size: 14),
              ),
              subtitle: Text(
                tr("Rename detected speakers"),
                style: SpeakrText.sans(size: 12, color: SpeakrColors.muted),
              ),
              onTap: () {
                final navigator = Navigator.of(context);
                navigator.pop();
                navigator.push(
                  MaterialPageRoute(
                    builder: (_) =>
                        SpeakerReviewScreen(recordingId: recording.id),
                  ),
                );
              },
            ),
            ListTile(
              leading: const SpeakrIconView(SpeakrIcon.mic),
              title: Text(
                tr("Reprocess transcription"),
                style: SpeakrText.sans(size: 14),
              ),
              subtitle: Text(
                tr("Replaces the current transcript"),
                style: SpeakrText.sans(size: 12, color: SpeakrColors.muted),
              ),
              onTap: () {
                Navigator.of(context).pop();
                reprocessRecording(
                  context,
                  ref,
                  recordingId: recording.id,
                  kind: ReprocessKind.transcription,
                );
              },
            ),
            ListTile(
              leading: const SpeakrIconView(SpeakrIcon.flagBookmark),
              title: Text(
                tr("Reprocess summary"),
                style: SpeakrText.sans(size: 14),
              ),
              subtitle: Text(
                tr("Regenerates the summary from the transcript"),
                style: SpeakrText.sans(size: 12, color: SpeakrColors.muted),
              ),
              onTap: () {
                Navigator.of(context).pop();
                reprocessRecording(
                  context,
                  ref,
                  recordingId: recording.id,
                  kind: ReprocessKind.summary,
                );
              },
            ),
            const Divider(color: SpeakrColors.line, height: 1),
            ListTile(
              leading: const SpeakrIconView(SpeakrIcon.trash),
              title: Text(
                tr("Delete recording"),
                style: SpeakrText.sans(size: 14, color: SpeakrColors.danger),
              ),
              subtitle: Text(
                tr("Removes the recording, transcript, and audio"),
                style: SpeakrText.sans(size: 12, color: SpeakrColors.muted),
              ),
              onTap: () {
                Navigator.of(context).pop();
                deleteRecording(context, ref, recordingId: recording.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioPlayerBar extends StatefulWidget {
  const _AudioPlayerBar({
    required this.player,
    required this.ready,
    required this.totalLabel,
  });
  final AudioPlayer player;
  final bool ready;
  final String totalLabel;

  @override
  State<_AudioPlayerBar> createState() => _AudioPlayerBarState();
}

class _AudioPlayerBarState extends State<_AudioPlayerBar> {
  double? _dragFraction;

  void _seekToFraction(double f, Duration dur, {bool drag = false}) {
    if (!widget.ready || dur.inMilliseconds == 0) return;
    final clamped = f.clamp(0.0, 1.0);
    if (drag) {
      setState(() => _dragFraction = clamped);
    }
    widget.player.seek(
      Duration(milliseconds: (dur.inMilliseconds * clamped).round()),
    );
  }

  void _clearDrag() {
    if (_dragFraction != null) {
      setState(() => _dragFraction = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: SpeakrColors.bgAlt,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          StreamBuilder<PlayerState>(
            stream: widget.player.playerStateStream,
            builder: (context, snap) {
              final playing = snap.data?.playing ?? false;
              return InkWell(
                customBorder: const CircleBorder(),
                onTap: !widget.ready
                    ? null
                    : () => playing
                          ? widget.player.pause()
                          : widget.player.play(),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.ready
                        ? SpeakrColors.ink
                        : SpeakrColors.muted.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: SpeakrIconView(
                    playing ? SpeakrIcon.pause : SpeakrIcon.play,
                    size: 16,
                    color: SpeakrColors.bg,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 14),
          Expanded(
            child: StreamBuilder<Duration>(
              stream: widget.player.positionStream,
              builder: (context, posSnap) {
                final pos = posSnap.data ?? Duration.zero;
                final dur = widget.player.duration ?? Duration.zero;
                final streamProgress = dur.inMilliseconds == 0
                    ? 0.0
                    : (pos.inMilliseconds / dur.inMilliseconds)
                          .clamp(0.0, 1.0)
                          .toDouble();
                final progress = _dragFraction ?? streamProgress;
                final displayedMs = _dragFraction != null
                    ? (dur.inMilliseconds * _dragFraction!).round()
                    : pos.inMilliseconds;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        return MouseRegion(
                          cursor: widget.ready
                              ? SystemMouseCursors.click
                              : MouseCursor.defer,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTapDown: (d) => _seekToFraction(
                              d.localPosition.dx / width,
                              dur,
                            ),
                            onHorizontalDragStart: (d) => _seekToFraction(
                              d.localPosition.dx / width,
                              dur,
                              drag: true,
                            ),
                            onHorizontalDragUpdate: (d) => _seekToFraction(
                              d.localPosition.dx / width,
                              dur,
                              drag: true,
                            ),
                            onHorizontalDragEnd: (_) => _clearDrag(),
                            onHorizontalDragCancel: _clearDrag,
                            child: SizedBox(
                              width: width,
                              height: 24,
                              child: Center(
                                child: SizedBox(
                                  height: 4,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: SpeakrColors.line,
                                      valueColor: const AlwaysStoppedAnimation(
                                        SpeakrColors.ink,
                                      ),
                                      minHeight: 4,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatDuration(displayedMs / 1000.0),
                          style: SpeakrText.mono(
                            size: 10,
                            color: SpeakrColors.muted,
                            letterSpacing: 0,
                          ),
                        ),
                        Text(
                          dur.inMilliseconds > 0
                              ? formatDuration(dur.inMilliseconds / 1000.0)
                              : widget.totalLabel,
                          style: SpeakrText.mono(
                            size: 10,
                            color: SpeakrColors.muted,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.tab, required this.onChanged});
  final int tab;
  final ValueChanged<int> onChanged;
  static List<String> get _labels => [
    tr("Summary"),
    tr("Transcript"),
    tr("Chat"),
  ];

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Container(
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: SpeakrColors.line),
        ),
      ),
      child: Row(
        children: List.generate(_labels.length, (i) {
          final selected = i == tab;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(i),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected ? SpeakrColors.ink : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 1),
                      child: Text(
                        _labels[i],
                        style: SpeakrText.sans(
                          size: 13,
                          weight: FontWeight.w500,
                          color: selected
                              ? SpeakrColors.ink
                              : SpeakrColors.muted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
