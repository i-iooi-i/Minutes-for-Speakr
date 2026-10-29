import 'package:speakr_app/theme/appearance.dart';
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

class NotesTab extends ConsumerStatefulWidget {
  const NotesTab({super.key, required this.recordingId});
  final int recordingId;
  @override
  ConsumerState<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends ConsumerState<NotesTab> {
  bool _editing = false;
  int get recordingId => widget.recordingId;
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    final result = ref.watch(recordingNotesProvider(recordingId));
    if (_editing) {
      return _NotesEditor(
        recordingId: recordingId,
        initial: result.value ?? '',
        onDone: () => setState(() => _editing = false),
      );
    }
    return result.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: TextButton(
          onPressed: () => ref.invalidate(recordingNotesProvider(recordingId)),
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
                    style: SpeakrText.sans(size: 11, color: SpeakrColors.muted),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _editing = true),
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
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                        .copyWith(
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
  const _NotesEditor({
    required this.recordingId,
    required this.initial,
    required this.onDone,
  });
  final int recordingId;
  final String initial;
  final VoidCallback onDone;
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
      if (mounted) {
        setState(() => _saving = false);
        widget.onDone();
      }
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
    AppearanceScope.watch(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              tr('Markdown supported'),
              style: SpeakrText.sans(size: 11, color: SpeakrColors.muted),
            ),
          ),
          const SizedBox(height: 10),
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
                hintText: tr('Add your meeting notes here.'),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                _error!,
                style: SpeakrText.sans(size: 12, color: SpeakrColors.danger),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _saving ? null : widget.onDone,
                child: Text(tr('Cancel')),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(tr(_saving ? 'Saving…' : 'Save')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
