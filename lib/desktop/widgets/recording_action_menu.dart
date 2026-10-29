import 'package:speakr_app/theme/appearance.dart';
import 'package:speakr_app/widgets/mimio_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/models.dart';
import '../../api/providers.dart';
import '../../features/detail/detail_actions.dart';
import '../../features/detail/detail_controller.dart';
import '../../features/detail/speaker_review_screen.dart';
import '../../features/detail/widgets/folder_tags_editor.dart';
import '../../features/library/library_controller.dart';
import '../../l10n/strings.dart';
import '../../theme/colors.dart';

class RecordingActionMenu extends ConsumerStatefulWidget {
  const RecordingActionMenu({super.key, required this.recording});
  final Recording recording;
  @override
  ConsumerState<RecordingActionMenu> createState() =>
      _RecordingActionMenuState();
}

class _RecordingActionMenuState extends ConsumerState<RecordingActionMenu> {
  bool _busy = false;
  Future<bool> _confirm(String title, String body) async =>
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(tr(title)),
          content: Text(tr(body)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(tr('Cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(tr('Continue')),
            ),
          ],
        ),
      ) ==
      true;
  Future<void> _run(String action) async {
    if (_busy) return;
    setState(() => _busy = true);
    final r = widget.recording;
    final api = ref.read(speakrApiProvider);
    final messenger = ScaffoldMessenger.of(context);
    try {
      switch (action) {
        case 'read':
          await toggleRecordingField(
            context,
            ref,
            recordingId: r.id,
            patch: {'is_inbox': !r.isInbox},
            successMessage: tr('Updated'),
          );
        case 'star':
          await toggleRecordingField(
            context,
            ref,
            recordingId: r.id,
            patch: {'is_highlighted': !r.isHighlighted},
            successMessage: tr('Updated'),
          );
        case 'archive':
          await toggleRecordingField(
            context,
            ref,
            recordingId: r.id,
            patch: {'is_archived': !r.isArchived},
            successMessage: tr('Updated'),
          );
        case 'organize':
          await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(tr('Folder and tags')),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: FolderTagsEditor(recording: r, initiallyEditing: true),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(tr('Done')),
                ),
              ],
            ),
          );
        case 'speakers':
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => SpeakerReviewScreen(recordingId: r.id),
            ),
          );
        case 'transcribe':
          await reprocessRecording(
            context,
            ref,
            recordingId: r.id,
            kind: ReprocessKind.transcription,
          );
        case 'summary':
          await reprocessRecording(
            context,
            ref,
            recordingId: r.id,
            kind: ReprocessKind.summary,
          );
        case 'share':
          if (!await _confirm(
            'Create share link?',
            'Anyone with this link can access this recording and summary. Notes are excluded.',
          )) {
            return;
          }
          final url = await api.createRecordingShare(r.id);
          if (!mounted) return;
          await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(tr('Share recording')),
              content: SelectableText(url),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(tr('Done')),
                ),
                FilledButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: url));
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text(tr('Copy link')),
                ),
              ],
            ),
          );
        case 'audio':
          if (!await _confirm(
            'Delete audio only?',
            'The audio will be permanently deleted. Transcript, summary and notes will be kept.',
          )) {
            return;
          }
          await api.deleteRecordingAudio(r.id);
          ref.invalidate(recordingDetailProvider(r.id));
          ref.read(uploadKickProvider.notifier).state++;
        case 'delete':
          await deleteRecording(context, ref, recordingId: r.id);
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    final r = widget.recording;
    PopupMenuEntry<String> item(
      String value,
      String label,
      IconData icon, {
      bool danger = false,
    }) => MimioMenuItem<String>(
      value: value,
      label: tr(label),
      icon: icon,
      danger: danger,
    );
    return MimioMenuButton<String>(
      color: SpeakrColors.bgAlt,
      surfaceTintColor: Colors.transparent,
      elevation: 12,
      shadowColor: Colors.black54,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 6),
      tooltip: tr('More'),
      enabled: !_busy,
      onSelected: _run,
      icon: const Icon(Icons.more_vert_rounded, size: 20),
      itemBuilder: (_) => [
        item(
          'read',
          r.isInbox ? 'Mark as read' : 'Mark as unread',
          Icons.mark_email_read_outlined,
        ),
        item(
          'star',
          r.isHighlighted ? 'Remove highlight' : 'Highlight recording',
          Icons.star_outline_rounded,
        ),
        item(
          'archive',
          r.isArchived ? 'Unarchive recording' : 'Archive recording',
          Icons.archive_outlined,
        ),
        MimioMenuDivider<String>(),
        item('organize', 'Folder and tags', Icons.folder_outlined),
        item('speakers', 'Edit speakers', Icons.people_outline),
        if (r.audioAvailable != false && !r.status.isInProgress)
          item('transcribe', 'Reprocess transcription', Icons.mic_none),
        item('summary', 'Reprocess summary', Icons.refresh),
        item('share', 'Share recording', Icons.share_outlined),
        MimioMenuDivider<String>(),
        if (r.audioAvailable != false && !r.status.isInProgress)
          item(
            'audio',
            'Delete audio only',
            Icons.music_off_outlined,
            danger: true,
          ),
        item('delete', 'Delete recording', Icons.delete_outline, danger: true),
      ],
    );
  }
}
