import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakr_saf/speakr_saf.dart';

import 'auto_upload_files.dart';
import 'auto_upload_settings.dart';
import 'auto_upload_settings_store.dart';
import 'datetime_parser.dart';

final autoUploadStoreProvider = FutureProvider<AutoUploadSettingsStore>((
  ref,
) async {
  return AutoUploadSettingsStore.open();
});

/// All configured folder entries. Refreshed by writing through
/// [folderConfigsControllerProvider].
final folderConfigsProvider = FutureProvider<List<FolderUploadConfig>>((
  ref,
) async {
  final store = await ref.watch(autoUploadStoreProvider.future);
  return store.readAll();
});

/// Whether the folder behind a config is reachable right now. Always true
/// off Android. On Android it is false for a legacy entry with no tree
/// grant and for a grant the user has since revoked (or that was lost to
/// a clear-data). The UI turns a `false` into a "Re-select folder" prompt.
///
/// Keyed by [FolderUploadConfig.treeUri] (a value type) rather than the
/// config object so rebuilt config instances share one cached answer.
final folderAccessProvider = FutureProvider.autoDispose.family<bool, String?>((
  ref,
  treeUri,
) async {
  if (!Platform.isAndroid) return true;
  if (treeUri == null) return false;
  try {
    return await SpeakrSaf.hasPersistedPermission(treeUri);
  } catch (_) {
    return false;
  }
});

/// Imperative controller used by the Auto-upload list screen and the
/// per-folder edit screen.
class FolderConfigsController {
  FolderConfigsController(this._ref);
  final Ref _ref;

  Future<List<FolderUploadConfig>> _read() =>
      _ref.read(folderConfigsProvider.future);

  Future<void> _writeAll(List<FolderUploadConfig> next) async {
    final store = await _ref.read(autoUploadStoreProvider.future);
    await store.writeAll(next);
    _ref.invalidate(folderConfigsProvider);
    _ref.invalidate(folderAccessProvider);
    _ref.invalidate(pendingFilesProvider);
    _ref.invalidate(pendingFileErrorsProvider);
  }

  /// Adds a folder. On Windows [path] is the real directory. On Android
  /// [tree] carries the persisted grant and [path] is its display form.
  Future<FolderUploadConfig> addFolder(String? path, {SafTree? tree}) async {
    final entry = FolderUploadConfig.newEntry(
      folderPath: tree?.displayPath ?? path,
      treeUri: tree?.uri,
    );
    final list = [...await _read(), entry];
    await _writeAll(list);
    return entry;
  }

  Future<void> removeFolder(String id) async {
    final all = await _read();
    final removed = all.where((c) => c.id == id).firstOrNull;
    final list = all.where((c) => c.id != id).toList();
    await _writeAll(list);
    // Hand the grant back once nothing else points at that tree.
    final tree = removed?.treeUri;
    if (tree != null &&
        Platform.isAndroid &&
        !list.any((c) => c.treeUri == tree)) {
      try {
        await SpeakrSaf.releaseTree(tree);
      } catch (_) {}
    }
  }

  Future<void> updateFolder(FolderUploadConfig next) async {
    final list = await _read();
    final out = [for (final c in list) c.id == next.id ? next : c];
    await _writeAll(out);
  }

  Future<void> _patch(
    String id,
    FolderUploadConfig Function(FolderUploadConfig) patch,
  ) async {
    final list = await _read();
    final out = [for (final c in list) c.id == id ? patch(c) : c];
    await _writeAll(out);
  }

  Future<void> setEnabled(String id, bool v) =>
      _patch(id, (c) => c.copyWith(enabled: v));

  /// Windows: sets the raw directory path (the tree grant is always null
  /// there).
  Future<void> setFolder(String id, String? path) =>
      _patch(id, (c) => c.copyWith(folderPath: path, treeUri: null));

  /// Android: points the entry at a freshly granted tree. If the entry
  /// previously carried a legacy raw path, or a different tree, the
  /// per-file bookkeeping keyed by the old identity is migrated to the
  /// new document URIs by file name, so the user keeps their upload
  /// history and does not re-upload files the old install already sent.
  Future<void> setFolderTree(String id, SafTree tree) async {
    final store = await _ref.read(autoUploadStoreProvider.future);
    final current = store.findById(id);
    final oldPath = current?.folderPath;
    final oldTree = current?.treeUri;

    await _patch(
      id,
      (c) => c.copyWith(folderPath: tree.displayPath, treeUri: tree.uri),
    );

    if (oldTree == tree.uri) return;
    try {
      final files = await listCandidateFiles(
        FolderUploadConfig(
          id: id,
          folderPath: tree.displayPath,
          treeUri: tree.uri,
        ),
      );
      final newKeysByName = {for (final f in files) f.name: f.key};
      final remap = <String, String>{};
      if (oldPath != null && oldPath.isNotEmpty) {
        remap.addAll(store.legacyKeyRemap(oldPath, newKeysByName));
      }
      if (oldTree != null) {
        // Same folder re-granted under a different tree URI (e.g. the
        // user picked a parent). Old document URIs share the tree prefix,
        // so remap by basename via the display path as well.
        remap.addAll(store.legacyKeyRemap(oldTree, newKeysByName));
      }
      await store.remapFileKeys(remap);
    } catch (_) {
      // Migration is best-effort: a failed listing just means the old
      // keys stay as they are and get pruned on the next clean scan.
    }
    _ref.invalidate(pendingFileErrorsProvider);
    _ref.invalidate(pendingFilesProvider);
  }

  Future<void> setPreset(String id, String? presetId) =>
      _patch(id, (c) => c.copyWith(parsePresetId: presetId));

  Future<void> setCustomParse({
    required String id,
    required String regex,
    required int captureGroup,
    required String format,
  }) => _patch(
    id,
    (c) => c.copyWith(
      parsePresetId: kCustomPresetId,
      customRegex: regex,
      customCaptureGroup: captureGroup,
      customFormat: format,
    ),
  );

  Future<void> setTagId(String id, int? tagId) =>
      _patch(id, (c) => c.copyWith(tagId: tagId));

  Future<void> setFolderId(String id, int? folderId) =>
      _patch(id, (c) => c.copyWith(folderId: folderId));

  Future<void> setLanguage(String id, String? lang) =>
      _patch(id, (c) => c.copyWith(language: lang));

  Future<void> setMinSpeakers(String id, int? n) =>
      _patch(id, (c) => c.copyWith(minSpeakers: n));

  Future<void> setMaxSpeakers(String id, int? n) =>
      _patch(id, (c) => c.copyWith(maxSpeakers: n));

  Future<void> setAutoDeleteShorterThanSeconds(String id, int? seconds) =>
      _patch(id, (c) => c.copyWith(autoDeleteShorterThanSeconds: seconds));
}

final folderConfigsControllerProvider = Provider<FolderConfigsController>(
  (ref) => FolderConfigsController(ref),
);

/// One pending file in the Library list, paired with the folder config
/// it was discovered under so per-folder defaults flow through to the
/// upload call.
class PendingFile {
  PendingFile({
    required this.file,
    required this.dateTime,
    required this.size,
    required this.config,
  });
  final AutoUploadFile file;
  final DateTime dateTime;
  final int size;
  final FolderUploadConfig config;
}

/// Per-file errors recorded by the auto-upload worker (currently:
/// duration-read failures). Keyed by [AutoUploadFile.key]. Watched by the
/// Library's pending tile to switch from the "not uploaded" badge to an
/// error badge with a Delete / Force-upload dialog.
final pendingFileErrorsProvider = FutureProvider<Map<String, String>>((
  ref,
) async {
  final store = await ref.watch(autoUploadStoreProvider.future);
  return store.readFileErrors();
});

/// Files in any enabled folder that haven't been uploaded yet. Lists
/// them sorted desc by parsed-or-mtime datetime. If two configs share a
/// folder, files are deduplicated on [AutoUploadFile.key] (first config
/// wins). A folder whose grant is gone contributes nothing here; the
/// settings screen surfaces that state.
final pendingFilesProvider = FutureProvider<List<PendingFile>>((ref) async {
  final configs = await ref.watch(folderConfigsProvider.future);
  final out = <PendingFile>[];
  final seen = <String>{};
  for (final config in configs) {
    if (!config.enabled || !config.hasFolder) continue;
    List<AutoUploadFile> files;
    try {
      files = await listCandidateFiles(config);
    } catch (_) {
      continue;
    }
    for (final f in files) {
      if (!seen.add(f.key)) continue;
      try {
        final stat = await f.stat();
        if (stat == null) continue;
        out.add(
          PendingFile(
            file: f,
            dateTime: resolveDateTime(f.name, stat.modified, config),
            size: stat.size,
            config: config,
          ),
        );
      } catch (_) {
        // Permission error or transient filesystem issue — skip silently.
      }
    }
  }
  out.sort((a, b) => b.dateTime.compareTo(a.dateTime));
  return out;
});
