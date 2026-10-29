import 'package:speakr_app/theme/appearance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/models.dart';
import '../../api/providers.dart';
import '../../features/detail/detail_controller.dart';
import '../../features/library/library_controller.dart';
import '../../l10n/strings.dart';
import '../../theme/typography.dart';

class RecordingTitleEditor extends ConsumerStatefulWidget {
  const RecordingTitleEditor({super.key, required this.recording});
  final Recording recording;
  @override
  ConsumerState<RecordingTitleEditor> createState() =>
      _RecordingTitleEditorState();
}

class _RecordingTitleEditorState extends ConsumerState<RecordingTitleEditor> {
  final _text = TextEditingController();
  bool _editing = false;
  bool _busy = false;
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(RecordingTitleEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recording.id != widget.recording.id) {
      _editing = false;
      _text.clear();
    }
  }

  Future<void> _save({bool generate = false}) async {
    if (_busy || (!generate && _text.text.trim().isEmpty)) return;
    if (generate) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(tr('Regenerate title?')),
          content: Text(
            tr(
              'The current title will be replaced using the existing transcript.',
            ),
          ),
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
      );
      if (confirmed != true || !mounted) return;
    }
    final id = widget.recording.id;
    setState(() => _busy = true);
    try {
      final api = ref.read(speakrApiProvider);
      if (generate) {
        await api.regenerateRecordingTitle(id);
      } else {
        await api.updateRecording(id, {'title': _text.text.trim()});
      }
      if (!mounted) return;
      ref.invalidate(recordingDetailProvider(id));
      ref.read(uploadKickProvider.notifier).state++;
      setState(() => _editing = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    return Row(
      children: [
        Expanded(
          child: _editing
              ? TextField(
                  controller: _text,
                  autofocus: true,
                  enabled: !_busy,
                  style: SpeakrText.sans(size: 25),
                  onSubmitted: (_) => _save(),
                  decoration: InputDecoration(
                    hintText: tr('Title'),
                    isDense: true,
                  ),
                )
              : Text(
                  widget.recording.title?.isNotEmpty == true
                      ? widget.recording.title!
                      : tr('Untitled recording'),
                  style: SpeakrText.serif(size: 25, height: 1.2),
                ),
        ),
        const SizedBox(width: 8),
        if (_busy)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else if (_editing) ...[
          IconButton(
            tooltip: tr('Cancel'),
            onPressed: () => setState(() => _editing = false),
            icon: const Icon(Icons.close, size: 18),
          ),
          IconButton(
            tooltip: tr('Save'),
            onPressed: () => _save(),
            icon: const Icon(Icons.check, size: 18),
          ),
        ] else ...[
          IconButton(
            tooltip: tr('Edit title'),
            onPressed: () => setState(() {
              _text.text = widget.recording.title ?? '';
              _editing = true;
            }),
            icon: const Icon(Icons.edit_outlined, size: 18),
          ),
          IconButton(
            tooltip: tr('Regenerate AI title'),
            onPressed: widget.recording.status.isInProgress
                ? null
                : () => _save(generate: true),
            icon: const Icon(Icons.autorenew_rounded, size: 18),
          ),
        ],
      ],
    );
  }
}
