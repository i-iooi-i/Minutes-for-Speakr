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
import '../widgets/recording_action_menu.dart';
import '../widgets/recording_title_editor.dart';
import '../../features/detail/tabs/chat_tab.dart';
import '../../features/detail/tabs/notes_tab.dart';
import '../../features/detail/tabs/recording_stats_tab.dart';
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
import '../widgets/desktop_record_button.dart';
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
  int _tab = 0; // Summary, notes, statistics, chat
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
    ref.listen(recordingDetailProvider(widget.recordingId), (_, next) {
      if (next.value?.audioAvailable == false) {
        unawaited(_audioPlayer.stop());
        if (_audioReady) setState(() => _audioReady = false);
      }
    });
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
        audioReady: _audioReady && r.audioAvailable != false,
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
    final highlighted = recording.isHighlighted;

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: SpeakrColors.line)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      height: 56,
      child: Row(
        children: [
          _BackChip(onTap: () => context.pop()),
          const Spacer(),
          DesktopRecordButton(onTap: () => context.push('/live')),
          const SizedBox(width: 12),
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
          RecordingActionMenu(recording: recording),
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
    final date = recording.meetingDate ?? recording.createdAt;
    final pref =
        ref.watch(timeFormatPreferenceProvider).asData?.value ??
        TimeFormatPreference.system;
    final dateLabel = date == null
        ? '—'
        : '${date.toLocal().year}/${date.toLocal().month}/${date.toLocal().day}  ${formatHourMinute(date.toLocal(), use24Hour: resolveUse24Hour(pref, context))}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 18, 28, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RecordingTitleEditor(recording: recording),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _MetadataItem(
                icon: Icons.calendar_today_outlined,
                label: dateLabel,
              ),
              if (recording.audioDuration != null)
                _MetadataItem(
                  icon: Icons.schedule_outlined,
                  label: formatDuration(recording.audioDuration!),
                ),
              if (folder != null)
                _MetadataItem(icon: Icons.folder_outlined, label: folder.name),
              for (final t in recording.tags)
                _MetadataItem(
                  icon: Icons.sell_outlined,
                  label: t.name,
                  color: parseHexColor(t.color),
                ),
              if ((recording.participants ?? '').isNotEmpty)
                _MetadataItem(
                  icon: Icons.people_outline,
                  label: recording.participants!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetadataItem extends StatelessWidget {
  const _MetadataItem({required this.icon, required this.label, this.color});
  final IconData icon;
  final String label;
  final Color? color;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: color ?? SpeakrColors.muted),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          label,
          style: SpeakrText.sans(size: 12, color: color ?? SpeakrColors.muted),
        ),
      ),
    ],
  );
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
                          size: 32,
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
                return StreamBuilder<PlayerState>(
                  stream: player.playerStateStream,
                  builder: (context, state) => DesktopWave(
                    playing:
                        (state.data?.playing ?? player.playing) &&
                        (state.data?.processingState ??
                                player.processingState) ==
                            ProcessingState.ready,
                    progress: progress,
                    seed: recording.id + 3,
                    height: 48,
                    onSeek: (f) {
                      if (dur.inMilliseconds == 0 || !audioReady) return;
                      player.seek(
                        Duration(
                          milliseconds: (dur.inMilliseconds * f).round(),
                        ),
                      );
                    },
                  ),
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
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              const Icon(
                Icons.subject_rounded,
                size: 16,
                color: SpeakrColors.ink2,
              ),
              const SizedBox(width: 7),
              Text(
                tr("TRANSCRIPT"),
                style: SpeakrText.sans(
                  size: 12.5,
                  weight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: tr(
                  ref.watch(transcriptFollowProvider(recordingId))
                      ? 'Disable scrolling'
                      : 'Enable scrolling',
                ),
                isSelected: ref.watch(transcriptFollowProvider(recordingId)),
                icon: const Icon(Icons.unfold_more_rounded, size: 18),
                selectedIcon: const Icon(
                  Icons.unfold_more_rounded,
                  size: 18,
                  color: SpeakrColors.accent,
                ),
                onPressed: () {
                  final p = ref.read(
                    transcriptFollowProvider(recordingId).notifier,
                  );
                  p.state = !p.state;
                },
              ),
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

  static List<String> get _labels => [
    tr("Summary"),
    tr("Notes"),
    tr("Statistics"),
    tr("Chat"),
  ];

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          Container(
            height: 48,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: SpeakrColors.line)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              [
                                Icons.article_outlined,
                                Icons.edit_note_rounded,
                                Icons.bar_chart_rounded,
                                Icons.chat_bubble_outline_rounded,
                              ][i],
                              size: 15,
                              color: selected
                                  ? SpeakrColors.ink
                                  : SpeakrColors.muted,
                            ),
                            const SizedBox(width: 5),
                            Text(
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
                          ],
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
                NotesTab(recordingId: recordingId),
                RecordingStatsTab(recordingId: recordingId),
                ChatTab(recordingId: recordingId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
