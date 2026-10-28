import 'package:speakr_app/l10n/strings.dart';

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:speakr_saf/speakr_saf.dart';

import 'auto_upload_settings.dart';

/// Audio extensions the watcher picks up. Lowercase, with leading dot.
const Set<String> kAutoUploadAudioExtensions = {
  '.m4a',
  '.mp3',
  '.wav',
  '.ogg',
  '.aac',
  '.opus',
  '.amr',
  '.3gp',
  '.flac',
};

/// Size + mtime snapshot of a candidate file.
class AutoUploadFileStat {
  const AutoUploadFileStat({required this.size, required this.modified});
  final int size;
  final DateTime modified;
}

/// One candidate recording in a watched folder, independent of how the
/// platform exposes it. Windows entries wrap a `dart:io` [File]; Android
/// entries wrap a Storage Access Framework document URI.
///
/// [key] is the identity the store uses for per-file errors and the
/// uploaded-but-not-deleted guard. It is the absolute path on Windows and
/// the document URI on Android — both stable for the same file across
/// scans.
abstract class AutoUploadFile {
  String get key;
  String get name;

  /// Filesystem-looking location for logs and dialogs. Never used for I/O.
  String get displayPath;

  /// Fresh metadata, or null when the file is gone.
  Future<AutoUploadFileStat?> stat();

  Future<bool> exists() async => await stat() != null;

  /// Copies the content into a fresh temp directory and returns the copy.
  /// Every downstream step (duration probe, multipart upload) works on a
  /// plain [File], so this is the single seam where SAF content enters
  /// `dart:io` land.
  Future<File> stageCopy() async {
    final tempDir = await Directory.systemTemp.createTemp('speakr_upload_');
    final target = File(p.join(tempDir.path, name));
    await copyTo(target);
    return target;
  }

  @protected
  Future<void> copyTo(File target);

  /// Deletes the source. Throws on failure; returns normally if the file
  /// is already gone.
  Future<void> delete();

  @override
  String toString() => displayPath;
}

/// `dart:io` implementation used on Windows (and any platform without a
/// tree grant).
class LocalAutoUploadFile extends AutoUploadFile {
  LocalAutoUploadFile(this.file);
  final File file;

  @override
  String get key => file.path;

  @override
  String get name => p.basename(file.path);

  @override
  String get displayPath => file.path;

  @override
  Future<AutoUploadFileStat?> stat() async {
    if (!await file.exists()) return null;
    final s = await file.stat();
    return AutoUploadFileStat(size: s.size, modified: s.modified);
  }

  @override
  Future<void> copyTo(File target) => file.copy(target.path);

  @override
  Future<void> delete() async {
    if (!await file.exists()) return;
    await _clearWindowsReadOnlyAttribute(file);
    await file.delete();
    if (await file.exists()) {
      throw FileSystemException(
        tr("File still exists after delete"),
        file.path,
      );
    }
  }
}

Future<void> _clearWindowsReadOnlyAttribute(File file) async {
  if (!Platform.isWindows) return;
  try {
    final result = await Process.run('attrib', ['-R', file.path]);
    if (result.exitCode != 0) {
      debugPrint(
        '[auto-upload] could not clear read-only attribute for ${file.path}: '
        '${result.stderr}${result.stdout}',
      );
    }
  } catch (e) {
    debugPrint(
      '[auto-upload] could not clear read-only attribute for ${file.path}: $e',
    );
  }
}

/// Storage Access Framework implementation used on Android.
class SafAutoUploadFile extends AutoUploadFile {
  SafAutoUploadFile(this.document, {required this.folderDisplayPath});
  final SafDocument document;
  final String folderDisplayPath;

  @override
  String get key => document.uri;

  @override
  String get name => document.name;

  @override
  String get displayPath => '$folderDisplayPath/${document.name}';

  @override
  Future<AutoUploadFileStat?> stat() async {
    final d = await SpeakrSaf.stat(document.uri);
    if (d == null) return null;
    return AutoUploadFileStat(size: d.size, modified: d.lastModified);
  }

  @override
  Future<void> copyTo(File target) =>
      SpeakrSaf.copyToFile(document.uri, target.path);

  @override
  Future<void> delete() async {
    final ok = await SpeakrSaf.delete(document.uri);
    if (!ok) {
      throw FileSystemException(tr("Provider refused to delete"), displayPath);
    }
  }
}

/// Thrown by [listCandidateFiles] when an Android folder's persisted grant
/// is gone. The worker reports it; the UI offers "Re-select folder".
class AutoUploadFolderAccessException implements Exception {
  AutoUploadFolderAccessException(this.config, this.message);
  final FolderUploadConfig config;
  final String message;
  @override
  String toString() => message;
}

bool _isAudioName(String name) =>
    kAutoUploadAudioExtensions.contains(p.extension(name).toLowerCase());

/// Lists eligible audio files in the configured folder. Used by both the
/// worker and the Library screen's "pending files" provider.
///
/// On Android the config must carry a tree grant; an entry that only has a
/// legacy raw path yields nothing (the UI flags it for re-selection).
Future<List<AutoUploadFile>> listCandidateFiles(
  FolderUploadConfig config,
) async {
  if (Platform.isAndroid) {
    final tree = config.treeUri;
    if (tree == null) return const [];
    try {
      final docs = await SpeakrSaf.listChildren(tree);
      return [
        for (final d in docs)
          if (_isAudioName(d.name))
            SafAutoUploadFile(d, folderDisplayPath: config.folderPath ?? tree),
      ];
    } on SafPermissionLostException catch (e) {
      throw AutoUploadFolderAccessException(
        config,
        tr(
          "Access to {0} was lost. Re-select it in Auto-upload settings. ({1})",
          [config.folderPath ?? 'the folder', e],
        ),
      );
    }
  }
  final path = config.folderPath;
  if (path == null || path.isEmpty) return const [];
  final dir = Directory(path);
  if (!dir.existsSync()) return const [];
  return dir
      .listSync(followLinks: false)
      .whereType<File>()
      .where((f) => _isAudioName(f.path))
      .map(LocalAutoUploadFile.new)
      .toList();
}
