import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/providers.dart';
import '../../../l10n/strings.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';

final recordingNotesProvider = FutureProvider.autoDispose.family<String, int>(
  (ref, id) => ref.watch(speakrApiProvider).getRecordingNotes(id),
);

class NotesTab extends ConsumerWidget {
  const NotesTab({super.key, required this.recordingId});
  final int recordingId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    return ref
        .watch(recordingNotesProvider(recordingId))
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: TextButton(
              onPressed: () =>
                  ref.invalidate(recordingNotesProvider(recordingId)),
              child: Text(tr('Could not load notes. Retry')),
            ),
          ),
          data: (notes) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        tr('Markdown supported'),
                        style: SpeakrText.sans(
                          size: 11,
                          color: SpeakrColors.muted,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => _NotesEditor(
                          recordingId: recordingId,
                          initial: notes,
                        ),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: Text(tr('Edit')),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: notes.trim().isEmpty
                    ? Center(
                        child: Text(
                          tr('Add your meeting notes here.'),
                          style: SpeakrText.sans(
                            size: 13,
                            color: SpeakrColors.muted,
                          ),
                        ),
                      )
                    : Markdown(
                        data: notes,
                        selectable: true,
                        padding: const EdgeInsets.all(20),
                        styleSheet:
                            MarkdownStyleSheet.fromTheme(
                              Theme.of(context),
                            ).copyWith(
                              p: SpeakrText.sans(size: 13.5, height: 1.55),
                              h1: SpeakrText.sans(size: 20),
                              h2: SpeakrText.sans(size: 17),
                              h3: SpeakrText.sans(size: 15),
                            ),
                      ),
              ),
            ],
          ),
        );
  }
}

class _NotesEditor extends ConsumerStatefulWidget {
  const _NotesEditor({required this.recordingId, required this.initial});
  final int recordingId;
  final String initial;
  @override
  ConsumerState<_NotesEditor> createState() => _NotesEditorState();
}

class _NotesEditorState extends ConsumerState<_NotesEditor> {
  late final TextEditingController _text = TextEditingController(
    text: widget.initial,
  );
  bool _saving = false;
  String? _error;
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(speakrApiProvider)
          .saveRecordingNotes(widget.recordingId, _text.text);
      ref.invalidate(recordingNotesProvider(widget.recordingId));
      if (mounted) { setState(() => _saving = false); Navigator.pop(context); }
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = tr('Could not save. Your edits are still here.');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return PopScope(
      canPop: !_saving,
      child: AlertDialog(
        title: Text(tr('Notes')),
        content: SizedBox(
          width: 560,
          height: MediaQuery.sizeOf(context).height * .48,
          child: Column(
            children: [
              Expanded(
                child: TextField(
                  controller: _text,
                  enabled: !_saving,
                  expands: true,
                  minLines: null,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  style: SpeakrText.sans(size: 13.5, height: 1.5),
                  decoration: InputDecoration(
                    hintText: tr('Markdown supported'),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _error!,
                    style: SpeakrText.sans(
                      size: 12,
                      color: SpeakrColors.danger,
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: Text(tr('Cancel')),
          ),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(tr(_saving ? 'Saving…' : 'Save')),
          ),
        ],
      ),
    );
  }
}
