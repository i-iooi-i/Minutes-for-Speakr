import 'package:speakr_app/l10n/strings.dart';

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/models.dart';
import '../../features/auto_upload/auto_upload_controller.dart';
import '../../features/auto_upload/auto_upload_settings_store.dart';
import '../../features/auto_upload/auto_upload_worker.dart';
import '../../features/library/library_controller.dart';
import '../../services/preferences/time_format_preference.dart';
import '../../services/preferences/time_format_providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../utils/formatters.dart';
import '../../widgets/speakr_icons.dart';
import '../../widgets/tag_chip.dart';
import '../widgets/recording_action_menu.dart';
import '../widgets/desktop_controls.dart';
import '../widgets/desktop_wave.dart';
import '../widgets/desktop_record_button.dart';

enum _SortMode { newest, oldest, longest, title }

enum _ViewMode { list, grid }

class LibraryDesktopScreen extends ConsumerStatefulWidget {
  const LibraryDesktopScreen({super.key});

  @override
  ConsumerState<LibraryDesktopScreen> createState() =>
      _LibraryDesktopScreenState();
}

class _LibraryDesktopScreenState extends ConsumerState<LibraryDesktopScreen> {
  _SortMode _sort = _SortMode.newest;
  _ViewMode _view = _ViewMode.list;
  Timer? _pollTimer;
  static const _pollInterval = Duration(seconds: 5);

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _evaluatePolling(List<LibraryItem>? items) {
    final inFlight =
        items != null &&
        items.any(
          (it) =>
              it is PendingLibraryItem ||
              (it is RemoteLibraryItem && it.recording.status.isInProgress),
        );
    if (inFlight && _pollTimer == null) {
      _pollTimer = Timer.periodic(_pollInterval, (_) {
        ref.invalidate(pendingFilesProvider);
        ref.invalidate(pendingFileErrorsProvider);
        ref.read(uploadKickProvider.notifier).state++;
      });
    } else if (!inFlight && _pollTimer != null) {
      _pollTimer!.cancel();
      _pollTimer = null;
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(pendingFilesProvider);
    ref.invalidate(pendingFileErrorsProvider);
    ref.read(uploadKickProvider.notifier).state++;
    await ref.read(libraryItemsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final filter = ref.watch(libraryFilterProvider);
    final folders = ref.watch(foldersProvider).value ?? const <Folder>[];
    final asyncItems = ref.watch(libraryItemsProvider);
    _evaluatePolling(asyncItems.value);

    final activeFolder = filter.folderId == null
        ? null
        : folders.firstWhereOrNull((f) => f.id == filter.folderId);

    return Container(
      color: SpeakrColors.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            activeFolder: activeFolder,
            items: asyncItems.value ?? const [],
            sort: _sort,
            view: _view,
            onSort: (m) => setState(() => _sort = m),
            onView: (m) => setState(() => _view = m),
            onRefresh: _refresh,
          ),
          Expanded(
            child: asyncItems.when(
              skipLoadingOnReload: true,
              loading: () => const _Loading(),
              error: (e, _) => _ErrorView(
                message: e.toString(),
                onRetry: () => ref.invalidate(libraryRecordingsProvider),
              ),
              data: (items) {
                if (items.isEmpty) return const SizedBox.shrink();
                final sorted = _applySort(items, _sort);
                return _view == _ViewMode.list
                    ? _ListView(items: sorted, folders: folders)
                    : _GridView(items: sorted, folders: folders);
              },
            ),
          ),
        ],
      ),
    );
  }
}

List<LibraryItem> _applySort(List<LibraryItem> items, _SortMode mode) {
  final sorted = [...items];
  switch (mode) {
    case _SortMode.newest:
      sorted.sort((a, b) => b.when.compareTo(a.when));
      break;
    case _SortMode.oldest:
      sorted.sort((a, b) => a.when.compareTo(b.when));
      break;
    case _SortMode.longest:
      double d(LibraryItem i) =>
          i is RemoteLibraryItem ? (i.recording.audioDuration ?? 0) : 0;
      sorted.sort((a, b) => d(b).compareTo(d(a)));
      break;
    case _SortMode.title:
      String t(LibraryItem i) {
        if (i is RemoteLibraryItem) {
          return (i.recording.title ?? '').toLowerCase();
        }
        return (i is PendingLibraryItem ? i.pending.file.name : '')
            .toLowerCase();
      }
      sorted.sort((a, b) => t(a).compareTo(t(b)));
      break;
  }
  return sorted;
}

// ─────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────

class _Header extends ConsumerWidget {
  const _Header({
    required this.activeFolder,
    required this.items,
    required this.sort,
    required this.view,
    required this.onSort,
    required this.onView,
    required this.onRefresh,
  });

  final Folder? activeFolder;
  final List<LibraryItem> items;
  final _SortMode sort;
  final _ViewMode view;
  final ValueChanged<_SortMode> onSort;
  final ValueChanged<_ViewMode> onView;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    final totalSecs = items.fold<double>(0, (acc, it) {
      if (it is RemoteLibraryItem) {
        return acc + (it.recording.audioDuration ?? 0);
      }
      return acc;
    });
    final hrs = totalSecs ~/ 3600;
    final mins = (totalSecs % 3600) ~/ 60;
    final folder = activeFolder;
    final folderColor = folder == null ? null : parseHexColor(folder.color);

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: SpeakrColors.line)),
      ),
      padding: const EdgeInsets.fromLTRB(28, 22, 28, 18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final title = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (folder != null) ...[
                    Icon(
                      Icons.graphic_eq_rounded,
                      color: folderColor ?? SpeakrColors.ink2,
                      size: 26,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    ref.watch(libraryFilterProvider).statusKey == 'archived'
                        ? tr("Archived")
                        : folder?.name ?? tr("Recordings"),
                    style: SpeakrText.serif(
                      size: 28,
                      height: 1,
                      weight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              if (folder == null && items.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  items.isEmpty
                      ? tr("No recordings yet")
                      : tr("{0} {1} · {2}h {3}m of audio", [
                          items.length,
                          tr(items.length == 1 ? "recording" : "recordings"),
                          hrs,
                          mins,
                        ]),
                  style: SpeakrText.sans(size: 13, color: SpeakrColors.muted),
                ),
              ],
            ],
          );
          final controls = Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DesktopRecordButton(onTap: () => context.push('/live')),
              DesktopToolButton(
                icon: SpeakrIcon.refresh,
                tooltip: tr("Refresh"),
                onTap: onRefresh,
              ),
              const DesktopDivider(),
              DesktopDropdown<_SortMode>(
                value: sort,
                onChanged: onSort,
                options: [
                  DropdownOption(value: _SortMode.newest, label: tr("Newest")),
                  DropdownOption(value: _SortMode.oldest, label: tr("Oldest")),
                  DropdownOption(
                    value: _SortMode.longest,
                    label: tr("Longest"),
                  ),
                  DropdownOption(value: _SortMode.title, label: tr("Title")),
                ],
              ),
              const DesktopDivider(),
              DesktopSegment<_ViewMode>(
                value: view,
                onChanged: onView,
                options: [
                  SegmentOption(value: _ViewMode.list, icon: const _ListIcon()),
                  SegmentOption(value: _ViewMode.grid, icon: const _GridIcon()),
                ],
              ),
            ],
          );
          return constraints.maxWidth >= 800
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: title),
                    const SizedBox(width: 20),
                    controls,
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 20), controls],
                );
        },
      ),
    );
  }
}

class _ListIcon extends StatelessWidget {
  const _ListIcon();
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return CustomPaint(
      size: const Size(14, 14),
      painter: _StrokeIconPainter((c) {
        c.drawLine(
          const Offset(2, 3.5),
          const Offset(12, 3.5),
          _stroke(SpeakrColors.ink2),
        );
        c.drawLine(
          const Offset(2, 7),
          const Offset(12, 7),
          _stroke(SpeakrColors.ink2),
        );
        c.drawLine(
          const Offset(2, 10.5),
          const Offset(12, 10.5),
          _stroke(SpeakrColors.ink2),
        );
      }),
    );
  }
}

class _GridIcon extends StatelessWidget {
  const _GridIcon();
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return CustomPaint(
      size: const Size(14, 14),
      painter: _StrokeIconPainter((c) {
        final p = _stroke(SpeakrColors.ink2);
        for (final r in const [
          Rect.fromLTWH(2, 2, 4, 4),
          Rect.fromLTWH(8, 2, 4, 4),
          Rect.fromLTWH(2, 8, 4, 4),
          Rect.fromLTWH(8, 8, 4, 4),
        ]) {
          c.drawRRect(
            RRect.fromRectAndRadius(r, const Radius.circular(0.5)),
            p,
          );
        }
      }),
    );
  }
}

Paint _stroke(Color c) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeWidth = 1.3
  ..strokeCap = StrokeCap.round;

class _StrokeIconPainter extends CustomPainter {
  _StrokeIconPainter(this.draw);
  final void Function(Canvas) draw;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 14.0);
    draw(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────
// List view
// ─────────────────────────────────────────────────────────

class _ListView extends StatelessWidget {
  const _ListView({required this.items, required this.folders});
  final List<LibraryItem> items;
  final List<Folder> folders;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final groups = groupBy<LibraryItem, String>(
      items,
      (i) => formatRelativeDay(i.when),
    );
    final entries = groups.entries.toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in entries) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 18, 40, 8),
              child: Text(
                entry.key.toUpperCase(),
                style: SpeakrText.mono(
                  size: 10,
                  color: SpeakrColors.muted,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            for (final it in entry.value)
              switch (it) {
                RemoteLibraryItem(:final recording) => _ListRow(
                  recording: recording,
                  folders: folders,
                ),
                PendingLibraryItem(:final pending) => _PendingListRow(
                  pending: pending,
                ),
              },
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _ListRow extends ConsumerStatefulWidget {
  const _ListRow({required this.recording, required this.folders});
  final Recording recording;
  final List<Folder> folders;

  @override
  ConsumerState<_ListRow> createState() => _ListRowState();
}

class _ListRowState extends ConsumerState<_ListRow> {
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final r = widget.recording;
    final completed = r.status == RecordingStatus.completed;
    final enterable = completed || r.status == RecordingStatus.failed;
    final folder = widget.folders.firstWhereOrNull((f) => f.id == r.folderId);
    final date = r.meetingDate ?? r.createdAt ?? DateTime.now();
    final pref =
        ref.watch(timeFormatPreferenceProvider).asData?.value ??
        TimeFormatPreference.system;
    final use24 = resolveUse24Hour(pref, context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 4),
      child: Material(
        color: SpeakrColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: SpeakrColors.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enterable ? () => context.push('/recording/${r.id}') : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 700;
                return Row(
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: IconButton.outlined(
                        tooltip: tr('Play'),
                        onPressed: completed
                            ? () => context.push('/recording/${r.id}?play=1')
                            : null,
                        icon: Icon(
                          completed
                              ? Icons.play_arrow_rounded
                              : Icons.graphic_eq_rounded,
                          size: 24,
                        ),
                        style: IconButton.styleFrom(
                          foregroundColor: SpeakrColors.ink,
                          side: const BorderSide(color: SpeakrColors.muted),
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (r.isHighlighted) ...[
                                const Icon(
                                  Icons.star_rounded,
                                  color: SpeakrColors.tagDesign,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                              ],
                              Expanded(
                                child: Text(
                                  r.title?.isNotEmpty == true
                                      ? r.title!
                                      : tr('Untitled recording'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: SpeakrText.sans(
                                    size: 16,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (completed)
                            Text(
                              [
                                formatDuration(r.audioDuration ?? 0),
                                if ((r.participants ?? '').isNotEmpty)
                                  r.participants!,
                                if (folder != null) folder.name,
                              ].join('  ·  '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: SpeakrText.sans(
                                size: 12,
                                color: SpeakrColors.muted,
                              ),
                            )
                          else
                            _StatusChip(status: r.status),
                        ],
                      ),
                    ),
                    if (wide) ...[
                      const SizedBox(width: 24),
                      ExcludeSemantics(
                        child: SizedBox(
                          width: (constraints.maxWidth * .22).clamp(
                            140.0,
                            300.0,
                          ),
                          child: DesktopWave(seed: r.id, height: 34),
                        ),
                      ),
                      const SizedBox(width: 24),
                      SizedBox(
                        width: 120,
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            for (final t in r.tags.take(2)) TagChip(tag: t),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(width: 18),
                    SizedBox(
                      width: 70,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _shortDate(date),
                            style: SpeakrText.sans(
                              size: 12,
                              color: SpeakrColors.muted,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            formatHourMinute(date, use24Hour: use24),
                            style: SpeakrText.mono(size: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    RecordingActionMenu(recording: r),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

enum _PendingErrorAction { delete, forceUpload }

/// Shared upload/retry/delete behavior for the desktop pending row and card.
/// Mirrors `_PendingTileState` in `lib/features/library/library_screen.dart`.
mixin _PendingActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  bool _uploading = false;

  PendingFile get pendingFile;

  Future<void> _confirmAndUpload({bool forceFromError = false}) async {
    if (!forceFromError) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: SpeakrColors.bg,
          title: Text(
            tr("Upload this recording?"),
            style: SpeakrText.serif(size: 20),
          ),
          content: Text(
            tr(
              "{0}\n\nThe file will be uploaded to your Speakr server and removed from this device.",
              [pendingFile.file.name],
            ),
            style: SpeakrText.sans(size: 13, color: SpeakrColors.ink2),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(tr("Cancel")),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(tr("Upload")),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    setState(() => _uploading = true);
    try {
      await uploadOneFile(pendingFile.file, pendingFile.config);
      final store = await AutoUploadSettingsStore.open();
      final fileStillExists = await pendingFile.file.exists();
      if (!fileStillExists) {
        await store.clearFileError(pendingFile.file.key);
        await store.clearUploadedFile(pendingFile.file.key);
      }
      ref.invalidate(pendingFilesProvider);
      ref.invalidate(pendingFileErrorsProvider);
      ref.read(uploadKickProvider.notifier).state++;
      if (mounted && fileStillExists) {
        setState(() => _uploading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _showScanError(String errorMessage) async {
    final action = await showDialog<_PendingErrorAction>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: SpeakrColors.bg,
        title: Text(
          tr("Couldn't process recording"),
          style: SpeakrText.serif(size: 20),
        ),
        content: Text(
          errorMessage,
          style: SpeakrText.sans(
            size: 13,
            color: SpeakrColors.ink2,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(tr("Cancel")),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogCtx, _PendingErrorAction.delete),
            style: TextButton.styleFrom(foregroundColor: SpeakrColors.danger),
            child: Text(tr("Delete file")),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogCtx, _PendingErrorAction.forceUpload),
            child: Text(tr("Force upload")),
          ),
        ],
      ),
    );
    if (action == null) return;
    switch (action) {
      case _PendingErrorAction.delete:
        await _deleteLocalFile();
        break;
      case _PendingErrorAction.forceUpload:
        await _confirmAndUpload(forceFromError: true);
        break;
    }
  }

  Future<void> _deleteLocalFile() async {
    final deleteError = await deleteLocalAutoUploadFile(pendingFile.file);
    if (deleteError != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr("Could not delete file: {0}", [deleteError])),
        ),
      );
      return;
    }
    final store = await AutoUploadSettingsStore.open();
    await store.clearFileError(pendingFile.file.key);
    await store.clearUploadedFile(pendingFile.file.key);
    if (!mounted) return;
    ref.invalidate(pendingFilesProvider);
    ref.invalidate(pendingFileErrorsProvider);
  }

  VoidCallback? _tapHandler({required String? scanError}) {
    if (_uploading) return null;
    if (scanError != null) return () => _showScanError(scanError);
    return () => _confirmAndUpload();
  }
}

class _PendingListRow extends ConsumerStatefulWidget {
  const _PendingListRow({required this.pending});
  final PendingFile pending;

  @override
  ConsumerState<_PendingListRow> createState() => _PendingListRowState();
}

class _PendingListRowState extends ConsumerState<_PendingListRow>
    with _PendingActionsMixin<_PendingListRow> {
  bool _hovered = false;

  @override
  PendingFile get pendingFile => widget.pending;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final name = widget.pending.file.name;
    final errors =
        ref.watch(pendingFileErrorsProvider).asData?.value ??
        const <String, String>{};
    final scanError = errors[widget.pending.file.key];
    final onTap = _tapHandler(scanError: scanError);
    final tappable = onTap != null;

    return MouseRegion(
      cursor: tappable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _hovered && tappable
                ? SpeakrColors.bgAlt
                : Colors.transparent,
            border: const Border(top: BorderSide(color: SpeakrColors.line)),
          ),
          padding: const EdgeInsets.fromLTRB(40, 14, 40, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SpeakrText.serif(
                    size: 17,
                    height: 1.2,
                    color: SpeakrColors.ink2,
                    style: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 160,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _PendingStatusBadge(
                    uploading: _uploading,
                    hasError: scanError != null,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const SizedBox(width: 220),
              const SizedBox(width: 16),
              SizedBox(
                width: 90,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    formatBytes(widget.pending.size),
                    style: SpeakrText.mono(
                      size: 11,
                      color: SpeakrColors.muted,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 90,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _shortDate(widget.pending.dateTime),
                    style: SpeakrText.mono(
                      size: 11,
                      color: SpeakrColors.muted,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingStatusBadge extends StatelessWidget {
  const _PendingStatusBadge({required this.uploading, required this.hasError});

  final bool uploading;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    if (uploading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: SpeakrColors.ink,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            tr("UPLOADING"),
            style: SpeakrText.mono(
              size: 9,
              color: SpeakrColors.ink2,
              letterSpacing: 1,
            ),
          ),
        ],
      );
    }
    final color = hasError ? SpeakrColors.danger : SpeakrColors.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            hasError ? tr("ERROR") : tr("NOT UPLOADED"),
            style: SpeakrText.mono(size: 9, letterSpacing: 1, color: color),
          ),
        ],
      ),
    );
  }
}

/// Duration-column stand-in for recordings that aren't completed. Pulses
/// while the server is still working; failed gets a static danger dot.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final RecordingStatus status;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final failed = status == RecordingStatus.failed;
    final color = failed ? SpeakrColors.danger : SpeakrColors.recordingDot;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (failed)
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          )
        else
          _PulsingDot(color: color, size: 6),
        const SizedBox(width: 5),
        Text(
          status.displayLabel.toUpperCase(),
          style: SpeakrText.mono(size: 9, color: color, letterSpacing: 1),
        ),
      ],
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color, required this.size});
  final Color color;
  final double size;
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Opacity(
        opacity: 0.3 + 0.7 * (1 - _c.value),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

String _shortDate(DateTime when) {
  final w = when.toLocal();
  final months = [
    tr("Jan"),
    tr("Feb"),
    tr("Mar"),
    tr("Apr"),
    tr("May"),
    tr("Jun"),
    tr("Jul"),
    tr("Aug"),
    tr("Sep"),
    tr("Oct"),
    tr("Nov"),
    tr("Dec"),
  ];
  return '${months[w.month - 1]} ${w.day}';
}

// ─────────────────────────────────────────────────────────
// Grid view
// ─────────────────────────────────────────────────────────

class _GridView extends StatelessWidget {
  const _GridView({required this.items, required this.folders});
  final List<LibraryItem> items;
  final List<Folder> folders;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        const minTile = 280.0;
        const gap = 14.0;
        const hPad = 40.0;
        final w = constraints.maxWidth - hPad * 2;
        var cols = (w / (minTile + gap)).floor();
        if (cols < 1) cols = 1;
        final tileW = (w - gap * (cols - 1)) / cols;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(hPad, 28, hPad, 40),
          child: Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final it in items)
                SizedBox(
                  width: tileW,
                  child: switch (it) {
                    RemoteLibraryItem(:final recording) => _GridCard(
                      recording: recording,
                      folders: folders,
                    ),
                    PendingLibraryItem(:final pending) => _PendingGridCard(
                      pending: pending,
                    ),
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _GridCard extends ConsumerStatefulWidget {
  const _GridCard({required this.recording, required this.folders});
  final Recording recording;
  final List<Folder> folders;
  @override
  ConsumerState<_GridCard> createState() => _GridCardState();
}

class _GridCardState extends ConsumerState<_GridCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final r = widget.recording;
    final completed = r.status == RecordingStatus.completed;
    final enterable = completed || r.status == RecordingStatus.failed;
    final folder = widget.folders.firstWhereOrNull((f) => f.id == r.folderId);
    final folderColor = folder == null ? null : parseHexColor(folder.color);
    final date = r.meetingDate ?? r.createdAt ?? DateTime.now();
    final pref =
        ref.watch(timeFormatPreferenceProvider).asData?.value ??
        TimeFormatPreference.system;
    final use24 = resolveUse24Hour(pref, context);

    return MouseRegion(
      cursor: enterable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: enterable ? () => context.push('/recording/${r.id}') : null,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          constraints: const BoxConstraints.tightFor(height: 180),
          decoration: BoxDecoration(
            color: SpeakrColors.surface,
            border: Border.all(
              color: _hovered ? SpeakrColors.ink : SpeakrColors.line,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (folder != null && folderColor != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: folderColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          folder.name.toUpperCase(),
                          style: SpeakrText.mono(
                            size: 9,
                            color: folderColor,
                            letterSpacing: 1.3,
                          ),
                        ),
                      ],
                    ),
                  const Spacer(),
                  Text(
                    '${formatRelativeDay(date)} · '
                    '${formatHourMinute(date, use24Hour: use24)}',
                    style: SpeakrText.mono(
                      size: 10,
                      color: SpeakrColors.muted,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                r.title?.isNotEmpty == true
                    ? r.title!
                    : tr("Untitled recording"),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: SpeakrText.serif(size: 17, height: 1.25),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  (r.summary?.isNotEmpty ?? false) ? r.summary! : '—',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: SpeakrText.sans(
                    size: 12,
                    color: SpeakrColors.muted,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  RecordingActionMenu(recording: r),
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        for (final t in r.tags.take(2)) TagChip(tag: t),
                      ],
                    ),
                  ),
                  Text(
                    completed
                        ? formatDuration(r.audioDuration ?? 0)
                        : r.status.displayLabel,
                    style: SpeakrText.mono(
                      size: 11,
                      color: SpeakrColors.muted,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingGridCard extends ConsumerStatefulWidget {
  const _PendingGridCard({required this.pending});
  final PendingFile pending;

  @override
  ConsumerState<_PendingGridCard> createState() => _PendingGridCardState();
}

class _PendingGridCardState extends ConsumerState<_PendingGridCard>
    with _PendingActionsMixin<_PendingGridCard> {
  bool _hovered = false;

  @override
  PendingFile get pendingFile => widget.pending;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final name = widget.pending.file.name;
    final errors =
        ref.watch(pendingFileErrorsProvider).asData?.value ??
        const <String, String>{};
    final scanError = errors[widget.pending.file.key];
    final hasError = scanError != null;
    final onTap = _tapHandler(scanError: scanError);
    final tappable = onTap != null;
    final eyebrowColor = hasError ? SpeakrColors.danger : SpeakrColors.muted;
    final eyebrow = _uploading
        ? tr("UPLOADING")
        : hasError
        ? tr("ERROR")
        : tr("NOT UPLOADED");

    return MouseRegion(
      cursor: tappable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          constraints: const BoxConstraints.tightFor(height: 180),
          decoration: BoxDecoration(
            color: SpeakrColors.surface,
            border: Border.all(
              color: _hovered && tappable
                  ? SpeakrColors.ink
                  : hasError
                  ? SpeakrColors.danger
                  : SpeakrColors.line,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (_uploading)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: SpeakrColors.ink,
                        ),
                      ),
                    ),
                  Text(
                    eyebrow,
                    style: SpeakrText.mono(
                      size: 9,
                      color: eyebrowColor,
                      letterSpacing: 1.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: SpeakrText.serif(
                  size: 17,
                  height: 1.25,
                  color: SpeakrColors.ink2,
                  style: FontStyle.italic,
                ),
              ),
              const Spacer(),
              Text(
                formatBytes(widget.pending.size),
                style: SpeakrText.mono(
                  size: 11,
                  color: SpeakrColors.muted,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Empty / Loading / Error
// ─────────────────────────────────────────────────────────

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return const Center(
      child: CircularProgressIndicator(color: SpeakrColors.ink, strokeWidth: 2),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr("COULDN'T LOAD"),
            style: SpeakrText.mono(
              size: 10,
              color: SpeakrColors.danger,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(message, style: SpeakrText.sans(size: 14)),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: Text(tr("Retry"))),
        ],
      ),
    );
  }
}
