import 'package:speakr_app/theme/appearance.dart';
import 'package:speakr_app/l10n/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/models.dart';
import '../../../api/providers.dart';
import '../../../api/speakr_api.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';
import '../../../widgets/folder_chip.dart';
import '../../../widgets/mono_eyebrow.dart';
import '../../../widgets/tag_chip.dart';
import '../../library/library_controller.dart';
import '../detail_controller.dart';

/// Inline folder + tag editor shown above the title on the recording detail
/// screen. Renders a chip row that doubles as the entry point — tapping any
/// chip (or the dashed Edit button) expands the editor card. Each toggle
/// persists immediately with optimistic UI; failures revert and surface via
/// a SnackBar.
class FolderTagsEditor extends ConsumerStatefulWidget {
  const FolderTagsEditor({
    super.key,
    required this.recording,
    this.initiallyEditing = false,
  });
  final Recording recording;
  final bool initiallyEditing;

  @override
  ConsumerState<FolderTagsEditor> createState() => _FolderTagsEditorState();
}

class _FolderTagsEditorState extends ConsumerState<FolderTagsEditor> {
  late bool _editing = widget.initiallyEditing;
  late int? _folderId = widget.recording.folderId;
  late List<Tag> _selectedTags = List.of(widget.recording.tags);

  @override
  void didUpdateWidget(covariant FolderTagsEditor old) {
    super.didUpdateWidget(old);
    // Resync when the parent supplies a fresh Recording after invalidation —
    // otherwise local optimistic state would drift from the server's truth.
    if (old.recording.folderId != widget.recording.folderId) {
      _folderId = widget.recording.folderId;
    }
    final oldIds = old.recording.tags.map((t) => t.id).toSet();
    final newIds = widget.recording.tags.map((t) => t.id).toSet();
    if (oldIds.length != newIds.length || !oldIds.containsAll(newIds)) {
      _selectedTags = List.of(widget.recording.tags);
    }
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    final folders = ref.watch(foldersProvider).value ?? const <Folder>[];
    final allTags = ref.watch(tagsProvider).value ?? const <Tag>[];
    final folderColor = resolveFolderColor(_folderId, folders);
    final folderName = _folderId == null
        ? null
        : folders
              .firstWhere(
                (f) => f.id == _folderId,
                orElse: () => Folder(
                  id: _folderId!,
                  name: widget.recording.folder?.name ?? '',
                ),
              )
              .name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChipRow(
          editing: _editing,
          folderName: folderName,
          folderColor: folderColor,
          tags: _selectedTags,
          onChipTap: () => setState(() => _editing = true),
          onToggleEdit: () => setState(() => _editing = !_editing),
        ),
        if (_editing) ...[
          const SizedBox(height: 4),
          _EditorCard(
            folders: folders,
            folderId: _folderId,
            allTags: allTags,
            selectedTags: _selectedTags,
            onSelectFolder: _setFolder,
            onToggleTag: _toggleTag,
          ),
        ],
      ],
    );
  }

  Future<void> _setFolder(int? newId) async {
    if (newId == _folderId) return;
    final previous = _folderId;
    setState(() => _folderId = newId);
    final container = ProviderScope.containerOf(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final api = container.read(speakrApiProvider);
    try {
      await api.updateRecording(widget.recording.id, {'folder_id': newId});
      container.invalidate(recordingDetailProvider(widget.recording.id));
      container.read(uploadKickProvider.notifier).state++;
    } on SpeakrApiException catch (e) {
      if (!mounted) return;
      setState(() => _folderId = previous);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _folderId = previous);
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _toggleTag(Tag tag) async {
    final wasSelected = _selectedTags.any((t) => t.id == tag.id);
    final previous = List.of(_selectedTags);
    setState(() {
      if (wasSelected) {
        _selectedTags.removeWhere((t) => t.id == tag.id);
      } else {
        _selectedTags.add(tag);
      }
    });
    final container = ProviderScope.containerOf(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final api = container.read(speakrApiProvider);
    try {
      if (wasSelected) {
        await api.removeTagFromRecording(widget.recording.id, tag.id);
      } else {
        await api.addTagsToRecording(widget.recording.id, [tag.id]);
      }
      container.invalidate(recordingDetailProvider(widget.recording.id));
      container.read(uploadKickProvider.notifier).state++;
    } on SpeakrApiException catch (e) {
      if (!mounted) return;
      setState(() => _selectedTags = previous);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _selectedTags = previous);
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.editing,
    required this.folderName,
    required this.folderColor,
    required this.tags,
    required this.onChipTap,
    required this.onToggleEdit,
  });
  final bool editing;
  final String? folderName;
  final Color folderColor;
  final List<Tag> tags;
  final VoidCallback onChipTap;
  final VoidCallback onToggleEdit;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    final hasFolder = folderName != null && folderName!.isNotEmpty;
    final hasContent = hasFolder || tags.isNotEmpty;
    final actionLabel = editing
        ? tr("Done")
        : (hasContent ? tr("Edit") : tr("+ Add"));
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (hasFolder)
          InkWell(
            onTap: onChipTap,
            borderRadius: BorderRadius.circular(3),
            child: FolderChip(label: folderName!, color: folderColor),
          ),
        for (final t in tags)
          InkWell(
            onTap: onChipTap,
            borderRadius: BorderRadius.circular(3),
            child: TagChip(tag: t),
          ),
        _DashedTextButton(label: actionLabel, onTap: onToggleEdit),
      ],
    );
  }
}

class _EditorCard extends StatelessWidget {
  const _EditorCard({
    required this.folders,
    required this.folderId,
    required this.allTags,
    required this.selectedTags,
    required this.onSelectFolder,
    required this.onToggleTag,
  });
  final List<Folder> folders;
  final int? folderId;
  final List<Tag> allTags;
  final List<Tag> selectedTags;
  final ValueChanged<int?> onSelectFolder;
  final ValueChanged<Tag> onToggleTag;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    final selectedIds = selectedTags.map((t) => t.id).toSet();
    final suggested = allTags
        .where((t) => !selectedIds.contains(t.id))
        .toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: SpeakrColors.bgAlt,
        border: Border.all(color: SpeakrColors.line),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonoEyebrow(tr("Folder"), size: 9),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              _NoneFolderChip(
                selected: folderId == null,
                onTap: () => onSelectFolder(null),
              ),
              for (final f in folders)
                InkWell(
                  onTap: () => onSelectFolder(f.id),
                  borderRadius: BorderRadius.circular(3),
                  child: FolderChip(
                    label: f.name,
                    color: parseHexColor(f.color),
                    filled: folderId == f.id,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          MonoEyebrow(tr("Tags"), size: 9),
          const SizedBox(height: 8),
          if (selectedTags.isEmpty && suggested.isEmpty)
            Text(
              tr("No tags configured"),
              style: SpeakrText.sans(
                size: 12,
                color: SpeakrColors.muted,
              ).copyWith(fontStyle: FontStyle.italic),
            )
          else ...[
            if (selectedTags.isNotEmpty)
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (final t in selectedTags)
                    CustomColorTagChip(
                      label: t.name,
                      color: parseHexColor(t.color),
                      filled: true,
                      onTap: () => onToggleTag(t),
                      trailing: Text(
                        '×',
                        style: SpeakrText.serif(
                          size: 11,
                          color: parseHexColor(t.color).withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                ],
              ),
            if (selectedTags.isNotEmpty && suggested.isNotEmpty)
              const SizedBox(height: 8),
            if (suggested.isNotEmpty)
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (final t in suggested)
                    DashedTagChip(
                      label: t.name,
                      color: parseHexColor(t.color),
                      onTap: () => onToggleTag(t),
                    ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}

class _NoneFolderChip extends StatelessWidget {
  const _NoneFolderChip({required this.selected, required this.onTap});
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: selected ? SpeakrColors.ink : Colors.transparent,
          border: Border.all(color: SpeakrColors.line),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          tr("NONE"),
          style: SpeakrText.mono(
            size: 10,
            color: selected ? SpeakrColors.bg : SpeakrColors.muted,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _DashedTextButton extends StatelessWidget {
  const _DashedTextButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3),
      child: CustomPaint(
        painter: _DashedRectPainter(color: SpeakrColors.line),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: Text(
            label.toUpperCase(),
            style: SpeakrText.mono(
              size: 9,
              color: SpeakrColors.muted,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  _DashedRectPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const dash = 3.0;
    const gap = 2.0;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      const Radius.circular(3),
    );
    final path = Path()..addRRect(rrect);
    for (final m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        final next = d + dash;
        canvas.drawPath(
          m.extractPath(d, next.clamp(0, m.length).toDouble()),
          paint,
        );
        d = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter old) => old.color != color;
}
