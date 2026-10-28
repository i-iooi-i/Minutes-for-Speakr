import 'package:speakr_app/l10n/strings.dart';

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

import '../../api/models.dart';
import '../../features/detail/detail_actions.dart';
import '../../features/detail/detail_controller.dart';
import '../../features/detail/speaker_review_screen.dart';
import '../../features/detail/tabs/chat_tab.dart';
import '../../features/detail/tabs/summary_tab.dart';
import '../../features/library/library_controller.dart';
import '../../services/credentials_store.dart';
import '../../services/preferences/time_format_preference.dart';
import '../../services/preferences/time_format_providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../utils/formatters.dart';
import '../../widgets/speakr_icons.dart';
import '../widgets/desktop_controls.dart';
import '../widgets/desktop_wave.dart';
import 'desktop_transcript_pane.dart';

class DetailDesktopScreen extends ConsumerStatefulWidget {
  const DetailDesktopScreen({
    super.key,
    required this.recordingId,
    this.autoplay = false,
  });
  final int recordingId;
  final bool autoplay;

  @override
  ConsumerState<DetailDesktopScreen> createState() =>
      _DetailDesktopScreenState();
}

class _DetailDesktopScreenState extends ConsumerState<DetailDesktopScreen> {
  final _audioPlayer = AudioPlayer();
  StreamSubscription<PlayerState>? _stateSub;
  bool _audioReady = false;
  int _tab = 0; // 0 = summary, 1 = chat
  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    _stateSub = _audioPlayer.playerStateStream.listen((s) {
      final ready =
          s.processingState == ProcessingState.ready ||
          s.processingState == ProcessingState.buffering;
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
      if (mounted && widget.autoplay) unawaited(_audioPlayer.play());
    } catch (e, st) {
      debugPrint('Speakr desktop audio: setUrl failed: $e\n$st');
    }
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _cycleSpeed() {
    const cycle = [1.0, 1.25, 1.5, 2.0, 0.75];
    final i = cycle.indexOf(_speed);
    final next = cycle[(i + 1) % cycle.length];
    setState(() => _speed = next);
    _audioPlayer.setSpeed(next);
  }

  Future<void> _skip(int seconds) async {
    final pos = _audioPlayer.position;
    final target = pos + Duration(seconds: seconds);
    final dur = _audioPlayer.duration;
    final clamped = dur == null
        ? target
        : Duration(
            milliseconds: target.inMilliseconds
                .clamp(0, dur.inMilliseconds)
                .toInt(),
          );
    await _audioPlayer.seek(clamped);
  }

  Future<void> _copyTranscript(Recording r) async {
    final segments = await ref.read(
      transcriptProvider(widget.recordingId).future,
    );
    if (segments.isEmpty) return;
    final buf = StringBuffer();
    for (final s in segments) {
      final t = s.startTime ?? 0;
      final mm = (t ~/ 60).toString().padLeft(2, '0');
      final ss = (t % 60).floor().toString().padLeft(2, '0');
      buf.writeln('${s.speaker ?? "—"} [$mm:$ss]');
      buf.writeln(s.sentence ?? '');
      buf.writeln();
    }
    await Clipboard.setData(ClipboardData(text: buf.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr("Transcript copied to clipboard"))),
    );
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final asyncR = ref.watch(recordingDetailProvider(widget.recordingId));
    return asyncR.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: SpeakrColors.ink,
          strokeWidth: 2,
        ),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr("COULDN'T LOAD RECORDING"),
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
      data: (r) => _Body(
        recording: r,
        player: _audioPlayer,
        audioReady: _audioReady,
        speed: _speed,
        tab: _tab,
        onTab: (i) => setState(() => _tab = i),
        onCycleSpeed: _cycleSpeed,
        onSkip: _skip,
        onCopyTranscript: () => _copyTranscript(r),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.recording,
    required this.player,
    required this.audioReady,
    required this.speed,
    required this.tab,
    required this.onTab,
    required this.onCycleSpeed,
    required this.onSkip,
    required this.onCopyTranscript,
  });

  final Recording recording;
  final AudioPlayer player;
  final bool audioReady;
  final double speed;
  final int tab;
  final ValueChanged<int> onTab;
  final VoidCallback onCycleSpeed;
  final ValueChanged<int> onSkip;
  final VoidCallback onCopyTranscript;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Container(
      color: SpeakrColors.bg,
      child: Column(
        children: [
          _BreadcrumbBar(recording: recording),
          _TitleBlock(recording: recording),
          _PlayerBar(
            recording: recording,
            player: player,
            audioReady: audioReady,
            speed: speed,
            onCycleSpeed: onCycleSpeed,
            onSkip: onSkip,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 7,
                    child: _DetailPanel(
                      child: _TranscriptColumn(
                        recordingId: recording.id,
                        player: player,
                        onCopy: onCopyTranscript,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 4,
                    child: _DetailPanel(
                      child: _RightColumn(
                        recordingId: recording.id,
                        tab: tab,
                        onTab: onTab,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: SpeakrColors.surface,
      border: Border.all(color: SpeakrColors.line),
      borderRadius: BorderRadius.circular(12),
    ),
    child: child,
  );
}

class _BreadcrumbBar extends ConsumerWidget {
  const _BreadcrumbBar({required this.recording});
  final Recording recording;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    final date = recording.meetingDate ?? recording.createdAt;
    final dayLabel = date == null ? '—' : formatRelativeDay(date).toUpperCase();
    final pref =
        ref.watch(timeFormatPreferenceProvider).asData?.value ??
        TimeFormatPreference.system;
    final use24 = resolveUse24Hour(pref, context);
    final time = date == null
        ? ''
        : formatHourMinute(date.toLocal(), use24Hour: use24).toUpperCase();
    final duration = recording.audioDuration == null
        ? ''
        : formatDuration(recording.audioDuration!);
    final parts = [
      dayLabel,
      if (duration.isNotEmpty) duration,
      time,
    ].where((p) => p.isNotEmpty).join(' · ');

    final highlighted = recording.isHighlighted;
    final inInbox = recording.isInbox;

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: SpeakrColors.line)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      height: 56,
      child: Row(
        children: [
          _BackChip(onTap: () => context.pop()),
          const SizedBox(width: 14),
          Text(
            parts,
            style: SpeakrText.mono(
              size: 10,
              color: SpeakrColors.muted,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          DesktopToolButton(
            icon: SpeakrIcon.star,
            tooltip: highlighted ? tr("Highlighted") : tr("Highlight"),
            selected: highlighted,
            onTap: () => toggleRecordingField(
              context,
              ref,
              recordingId: recording.id,
              patch: {'is_highlighted': !highlighted},
              successMessage: highlighted
                  ? tr("Highlight removed")
                  : tr("Highlighted"),
            ),
          ),
          const SizedBox(width: 6),
          DesktopActionMenu(
            items: [
              DesktopActionItem(
                icon: SpeakrIcon.star,
                label: highlighted
                    ? tr("Remove highlight")
                    : tr("Highlight recording"),
                onTap: () => toggleRecordingField(
                  context,
                  ref,
                  recordingId: recording.id,
                  patch: {'is_highlighted': !highlighted},
                  successMessage: highlighted
                      ? tr("Highlight removed")
                      : tr("Highlighted"),
                ),
              ),
              DesktopActionItem(
                icon: SpeakrIcon.flag,
                label: inInbox ? tr("Remove from inbox") : tr("Move to inbox"),
                onTap: () => toggleRecordingField(
                  context,
                  ref,
                  recordingId: recording.id,
                  patch: {'is_inbox': !inInbox},
                  successMessage: inInbox
                      ? tr("Removed from inbox")
                      : tr("Moved to inbox"),
                ),
              ),
              DesktopActionItem(
                dividerAbove: true,
                icon: SpeakrIcon.search,
                label: tr("Edit speakers"),
                subtitle: tr("Rename detected speakers"),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        SpeakerReviewScreen(recordingId: recording.id),
                  ),
                ),
              ),
              DesktopActionItem(
                icon: SpeakrIcon.mic,
                label: tr("Reprocess transcription"),
                subtitle: tr("Replaces the current transcript"),
                onTap: () => reprocessRecording(
                  context,
                  ref,
                  recordingId: recording.id,
                  kind: ReprocessKind.transcription,
                ),
              ),
              DesktopActionItem(
                icon: SpeakrIcon.flagBookmark,
                label: tr("Reprocess summary"),
                subtitle: tr("Regenerates the summary from the transcript"),
                onTap: () => reprocessRecording(
                  context,
                  ref,
                  recordingId: recording.id,
                  kind: ReprocessKind.summary,
                ),
              ),
              DesktopActionItem(
                dividerAbove: true,
                icon: SpeakrIcon.trash,
                label: tr("Delete recording"),
                subtitle: tr("Removes the recording, transcript, and audio"),
                danger: true,
                onTap: () =>
                    deleteRecording(context, ref, recordingId: recording.id),
              ),
            ],
            builder: (context, toggle) => DesktopToolButton(
              icon: SpeakrIcon.more,
              tooltip: tr("More"),
              onTap: toggle,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackChip extends StatelessWidget {
  const _BackChip({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Material(
      color: SpeakrColors.surface,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: SpeakrColors.line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 34,
          padding: const EdgeInsets.fromLTRB(6, 0, 10, 0),
          child: Row(
            children: [
              const SpeakrIconView(
                SpeakrIcon.back,
                size: 16,
                color: SpeakrColors.ink2,
              ),
              const SizedBox(width: 2),
              Text(
                tr("Recordings"),
                style: SpeakrText.sans(size: 12, color: SpeakrColors.ink2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleBlock extends ConsumerWidget {
  const _TitleBlock({required this.recording});
  final Recording recording;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    // The recording's embedded folder is a stub without a color (and the
    // detail endpoint may omit it), so resolve against /folders like the
    // library does.
    final folders = ref.watch(foldersProvider).value ?? const <Folder>[];
    final folder =
        folders.firstWhereOrNull((f) => f.id == recording.folderId) ??
        recording.folder;
    final folderColor = folder?.color == null
        ? null
        : parseHexColor(folder!.color);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (folder != null && folderColor != null)
                Container(
                  padding: const EdgeInsets.fromLTRB(9, 3, 9, 3),
                  decoration: BoxDecoration(
                    color: folderColor.withValues(alpha: 0.05),
                    border: Border.all(
                      color: folderColor.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: folderColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        folder.name.toUpperCase(),
                        style: SpeakrText.mono(
                          size: 10,
                          color: folderColor,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              for (final t in recording.tags)
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: parseHexColor(t.color).withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    t.name.toUpperCase(),
                    style: SpeakrText.mono(
                      size: 10,
                      color: parseHexColor(t.color),
                      letterSpacing: 1,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Text(
              recording.title?.isNotEmpty == true
                  ? recording.title!
                  : tr("Untitled recording"),
              style: SpeakrText.serif(
                size: 28,
                height: 1.1,
                weight: FontWeight.w400,
              ),
            ),
          ),
          if ((recording.participants ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              recording.participants!,
              style: SpeakrText.sans(size: 13, color: SpeakrColors.muted),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlayerBar extends StatelessWidget {
  const _PlayerBar({
    required this.recording,
    required this.player,
    required this.audioReady,
    required this.speed,
    required this.onCycleSpeed,
    required this.onSkip,
  });
  final Recording recording;
  final AudioPlayer player;
  final bool audioReady;
  final double speed;
  final VoidCallback onCycleSpeed;
  final ValueChanged<int> onSkip;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(32, 0, 32, 18),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: SpeakrColors.surface,
        border: Border.all(color: SpeakrColors.line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Play / pause
          StreamBuilder<PlayerState>(
            stream: player.playerStateStream,
            builder: (context, snap) {
              final playing = snap.data?.playing ?? false;
              return SizedBox(
                width: 56,
                height: 56,
                child: Material(
                  color: audioReady
                      ? SpeakrColors.ink
                      : SpeakrColors.muted.withValues(alpha: 0.5),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: !audioReady
                        ? null
                        : () => playing ? player.pause() : player.play(),
                    child: Semantics(
                      button: true,
                      label: playing ? tr("Pause") : tr("Play"),
                      child: Center(
                        child: SpeakrIconView(
                          playing ? SpeakrIcon.pause : SpeakrIcon.play,
                          size: 20,
                          color: SpeakrColors.bg,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 18),
          // Current time
          StreamBuilder<Duration>(
            stream: player.positionStream,
            builder: (context, snap) {
              final pos = snap.data ?? Duration.zero;
              return SizedBox(
                width: 50,
                child: Text(
                  _format(pos),
                  style: SpeakrText.mono(
                    size: 12,
                    color: SpeakrColors.ink,
                    letterSpacing: 0,
                  ),
                ),
              );
            },
          ),
          // Waveform
          Expanded(
            child: StreamBuilder<Duration>(
              stream: player.positionStream,
              builder: (context, snap) {
                final pos = snap.data ?? Duration.zero;
                final dur = player.duration ?? Duration.zero;
                final progress = dur.inMilliseconds == 0
                    ? 0.0
                    : (pos.inMilliseconds / dur.inMilliseconds)
                          .clamp(0.0, 1.0)
                          .toDouble();
                return DesktopWave(
                  progress: progress,
                  seed: recording.id + 3,
                  height: 48,
                  onSeek: (f) {
                    if (dur.inMilliseconds == 0 || !audioReady) return;
                    player.seek(
                      Duration(milliseconds: (dur.inMilliseconds * f).round()),
                    );
                  },
                );
              },
            ),
          ),
          // Duration label
          SizedBox(
            width: 50,
            child: Text(
              formatDuration(recording.audioDuration ?? 0),
              textAlign: TextAlign.right,
              style: SpeakrText.mono(
                size: 12,
                color: SpeakrColors.muted,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(width: 14),
          DesktopSmallButton(
            label: speed == 1.0
                ? '1×'
                : '${speed.toStringAsFixed(speed.truncateToDouble() == speed ? 0 : 2)}×',
            onTap: audioReady ? onCycleSpeed : null,
          ),
          const SizedBox(width: 6),
          DesktopSmallButton(
            label: '−15',
            onTap: audioReady ? () => onSkip(-15) : null,
          ),
          const SizedBox(width: 6),
          DesktopSmallButton(
            label: '+15',
            onTap: audioReady ? () => onSkip(15) : null,
          ),
        ],
      ),
    );
  }

  String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    String two(int n) => n.toString().padLeft(2, '0');
    if (h > 0) return '$h:${two(m)}:${two(s)}';
    return '${two(m)}:${two(s)}';
  }
}

class _TranscriptColumn extends ConsumerWidget {
  const _TranscriptColumn({
    required this.recordingId,
    required this.player,
    required this.onCopy,
  });
  final int recordingId;
  final AudioPlayer player;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: SpeakrColors.line)),
          ),
          padding: const EdgeInsets.fromLTRB(28, 14, 28, 14),
          child: Row(
            children: [
              Text(
                tr("TRANSCRIPT"),
                style: SpeakrText.mono(
                  size: 10,
                  color: SpeakrColors.muted,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              DesktopSmallButton(label: tr("Copy"), onTap: onCopy),
            ],
          ),
        ),
        Expanded(
          child: DesktopTranscriptPane(
            recordingId: recordingId,
            player: player,
          ),
        ),
      ],
    );
  }
}

class _RightColumn extends StatelessWidget {
  const _RightColumn({
    required this.recordingId,
    required this.tab,
    required this.onTab,
  });
  final int recordingId;
  final int tab;
  final ValueChanged<int> onTab;

  static List<String> get _labels => [tr("Summary"), tr("Chat")];

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: SpeakrColors.line)),
            ),
            child: Row(
              children: List.generate(_labels.length, (i) {
                final selected = i == tab;
                return Expanded(
                  child: InkWell(
                    onTap: () => onTab(i),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: selected
                                ? SpeakrColors.ink
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: Text(
                            _labels[i],
                            style: SpeakrText.sans(
                              size: 12.5,
                              weight: FontWeight.w500,
                              color: selected
                                  ? SpeakrColors.ink
                                  : SpeakrColors.muted,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: tab,
              children: [
                SummaryTab(recordingId: recordingId),
                ChatTab(recordingId: recordingId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
