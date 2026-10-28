import 'package:speakr_app/l10n/strings.dart';

import 'dart:async';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../api/auth_interceptor.dart';
import '../../api/models.dart';
import '../../api/speakr_api.dart';
import '../../services/credentials_store.dart';
import 'auto_upload_files.dart';
import 'auto_upload_settings.dart';
import 'auto_upload_settings_store.dart';
import 'datetime_parser.dart';

/// Result of a single file's processing during a scan.
enum AutoUploadOutcome {
  uploaded,
  skippedStillWriting,
  skippedTooRecent,
  failed,
}

class AutoUploadResult {
  AutoUploadResult({required this.trigger});
  final String trigger;
  int uploaded = 0;
  int skipped = 0;
  int failed = 0;

  String? lastError;

  String get summary {
    final base = 'trigger=$trigger ok=$uploaded skipped=$skipped fail=$failed';
    return lastError == null ? base : '$base · $lastError';
  }
}

void _logAutoUpload(String message) {
  debugPrint('[auto-upload] $message');
}

/// Build a fresh [SpeakrApi] for use inside a background isolate (no
/// Riverpod). The interceptor reads credentials from secure storage on
/// each request, so per-isolate construction is correct.
SpeakrApi buildBackgroundApi() {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(minutes: 10),
      contentType: 'application/json',
      responseType: ResponseType.json,
    ),
  );
  dio.interceptors.add(AuthInterceptor(CredentialsStore()));
  return SpeakrApi(dio);
}

/// Decides whether a file is safe to upload right now. Skips files that
/// were modified within the last 30s (likely still being written) and
/// files whose size changes across a 5s re-stat (definitely still being
/// written — covers ongoing call recording).
Future<AutoUploadOutcome> _checkFileStable(
  AutoUploadFile file, {
  Duration grace = const Duration(seconds: 30),
  Duration restatAfter = const Duration(seconds: 5),
}) async {
  final first = await file.stat();
  if (first == null) return AutoUploadOutcome.skippedStillWriting;
  final age = DateTime.now().difference(first.modified);
  if (age < grace) return AutoUploadOutcome.skippedTooRecent;
  await Future<void>.delayed(restatAfter);
  final second = await file.stat();
  if (second == null) return AutoUploadOutcome.skippedStillWriting;
  if (first.size != second.size) return AutoUploadOutcome.skippedStillWriting;
  return AutoUploadOutcome.uploaded; // sentinel — caller does the actual upload
}

/// Outcome of a duration probe. Distinguishes "format not understood by
/// the metadata reader" (benign, fall back to uploading) from "format was
/// recognised but the parse threw" (surface as an error badge).
class _DurationProbe {
  const _DurationProbe._({this.duration, this.error});
  final Duration? duration;
  final String? error;

  /// Duration was successfully read.
  factory _DurationProbe.known(Duration d) => _DurationProbe._(duration: d);

  /// Format wasn't recognised, or the parser couldn't compute a duration.
  /// Treat as "unknown but not broken" — upload normally.
  factory _DurationProbe.unsupported() => const _DurationProbe._();

  /// Format was recognised but parsing threw. The user gets an error badge
  /// with this message.
  factory _DurationProbe.failed(String message) =>
      _DurationProbe._(error: message);

  bool get hasError => error != null;
  bool get isKnown => duration != null;
}

/// Probes the audio duration of [file]. Synchronous I/O is fine in the
/// background isolate where the worker runs. Never throws.
_DurationProbe _probeDuration(File file) {
  final isMp3 = p.extension(file.path).toLowerCase() == '.mp3';
  try {
    final metadata = readMetadata(file, getImage: false);
    final d = metadata.duration;
    if (d != null) return _DurationProbe.known(d);
    if (isMp3) {
      final fallback = _estimateMp3Duration(file);
      if (fallback != null) return _DurationProbe.known(fallback);
    }
    return _DurationProbe.unsupported();
  } on NoMetadataParserException {
    // audio_metadata_reader didn't recognise the file. For raw .aac, .amr,
    // .3gp we have nothing useful to do. For a headerless MP3 (no ID3,
    // no Xing/Info) we can still estimate the duration from the first
    // MPEG frame header — phone recorder apps often ship MP3s like this,
    // and we need the duration so the autoDeleteShorterThanSeconds rule
    // actually applies to them.
    if (isMp3) {
      final fallback = _estimateMp3Duration(file);
      if (fallback != null) return _DurationProbe.known(fallback);
    }
    return _DurationProbe.unsupported();
  } catch (e) {
    return _DurationProbe.failed(e.toString());
  }
}

/// Estimates the duration of an MP3 by parsing the first MPEG audio frame
/// header. Used as a fallback when audio_metadata_reader can't compute it
/// (headerless MP3 from minimal recorder apps). Accurate for CBR; within
/// a few percent for VBR — the autoDeleteShorterThanSeconds check is
/// whole-second granularity so the precision is fine.
///
/// Returns `null` on any parse failure; caller treats that as unsupported.
Duration? _estimateMp3Duration(File file) {
  RandomAccessFile? raf;
  try {
    raf = file.openSync();
    final fileSize = raf.lengthSync();
    if (fileSize < 32) return null;

    var headerOffset = 0;
    final id3Header = raf.readSync(10);
    if (id3Header.length == 10 &&
        id3Header[0] == 0x49 &&
        id3Header[1] == 0x44 &&
        id3Header[2] == 0x33) {
      // ID3v2 size is a 4-byte syncsafe int (each byte uses only 7 bits).
      final size =
          (id3Header[6] << 21) |
          (id3Header[7] << 14) |
          (id3Header[8] << 7) |
          id3Header[9];
      headerOffset = 10 + size;
      // Footer flag (bit 4 of flags byte): ID3v2.4 may append a 10-byte footer.
      if ((id3Header[5] & 0x10) != 0) headerOffset += 10;
    }

    var endOffset = fileSize;
    if (fileSize >= 128) {
      raf.setPositionSync(fileSize - 128);
      final tail = raf.readSync(3);
      if (tail.length == 3 &&
          tail[0] == 0x54 &&
          tail[1] == 0x41 &&
          tail[2] == 0x47) {
        endOffset = fileSize - 128;
      }
    }

    if (headerOffset >= endOffset - 4) return null;

    const scanLimit = 64 * 1024;
    final scanStart = headerOffset;
    final scanEndCap = scanStart + scanLimit;
    final scanEnd = scanEndCap < endOffset ? scanEndCap : endOffset;
    if (scanEnd - scanStart < 4) return null;

    raf.setPositionSync(scanStart);
    final buf = raf.readSync(scanEnd - scanStart);
    if (buf.length < 4) return null;

    for (var i = 0; i + 3 < buf.length; i++) {
      if (buf[i] != 0xFF) continue;
      if ((buf[i + 1] & 0xE0) != 0xE0) continue;
      final header = _decodeMp3FrameHeader(buf, i);
      if (header == null) continue;

      final nextOffset = i + header.frameLength;
      final absoluteNext = scanStart + nextOffset;
      if (absoluteNext + 1 >= endOffset) {
        // File ends inside the second frame — single-frame stream. Trust it.
      } else if (nextOffset + 1 < buf.length) {
        if (buf[nextOffset] != 0xFF || (buf[nextOffset + 1] & 0xE0) != 0xE0) {
          continue;
        }
      } else {
        raf.setPositionSync(absoluteNext);
        final probe = raf.readSync(2);
        if (probe.length < 2 || probe[0] != 0xFF || (probe[1] & 0xE0) != 0xE0) {
          continue;
        }
      }

      final firstFrameAbsolute = scanStart + i;
      final audioBytes = endOffset - firstFrameAbsolute;
      if (audioBytes <= 0 || header.bitrateBps <= 0) return null;
      final seconds = audioBytes * 8 / header.bitrateBps;
      if (seconds.isNaN || seconds.isInfinite || seconds < 0) return null;
      return Duration(milliseconds: (seconds * 1000).round());
    }
    return null;
  } catch (_) {
    return null;
  } finally {
    try {
      raf?.closeSync();
    } catch (_) {}
  }
}

class _Mp3FrameHeader {
  const _Mp3FrameHeader({required this.bitrateBps, required this.frameLength});
  final int bitrateBps;
  final int frameLength;
}

// MP3 bitrate tables (kbps). Index 0 = free format, index 15 = bad — both
// rejected by the caller. We only index 1..14.
const List<int> _kV1L1 = [
  0,
  32,
  64,
  96,
  128,
  160,
  192,
  224,
  256,
  288,
  320,
  352,
  384,
  416,
  448,
  -1,
];
const List<int> _kV1L2 = [
  0,
  32,
  48,
  56,
  64,
  80,
  96,
  112,
  128,
  160,
  192,
  224,
  256,
  320,
  384,
  -1,
];
const List<int> _kV1L3 = [
  0,
  32,
  40,
  48,
  56,
  64,
  80,
  96,
  112,
  128,
  160,
  192,
  224,
  256,
  320,
  -1,
];
const List<int> _kV2L1 = [
  0,
  32,
  48,
  56,
  64,
  80,
  96,
  112,
  128,
  144,
  160,
  176,
  192,
  224,
  256,
  -1,
];
const List<int> _kV2L23 = [
  0,
  8,
  16,
  24,
  32,
  40,
  48,
  56,
  64,
  80,
  96,
  112,
  128,
  144,
  160,
  -1,
];

_Mp3FrameHeader? _decodeMp3FrameHeader(List<int> buf, int offset) {
  if (offset + 3 >= buf.length) return null;
  final b1 = buf[offset + 1];
  final b2 = buf[offset + 2];
  if (buf[offset] != 0xFF || (b1 & 0xE0) != 0xE0) return null;

  // versionBits: 00=V2.5, 01=reserved, 10=V2, 11=V1
  final versionBits = (b1 >> 3) & 0x03;
  if (versionBits == 0x01) return null;
  // layerBits:   00=reserved, 01=L3, 10=L2, 11=L1
  final layerBits = (b1 >> 1) & 0x03;
  if (layerBits == 0x00) return null;

  final bitrateIndex = (b2 >> 4) & 0x0F;
  final sampleRateIndex = (b2 >> 2) & 0x03;
  final padding = (b2 >> 1) & 0x01;
  if (bitrateIndex == 0 || bitrateIndex == 15) return null;
  if (sampleRateIndex == 3) return null;

  final isV1 = versionBits == 0x03;
  int bitrateKbps;
  if (isV1) {
    if (layerBits == 0x03) {
      bitrateKbps = _kV1L1[bitrateIndex];
    } else if (layerBits == 0x02) {
      bitrateKbps = _kV1L2[bitrateIndex];
    } else {
      bitrateKbps = _kV1L3[bitrateIndex];
    }
  } else {
    if (layerBits == 0x03) {
      bitrateKbps = _kV2L1[bitrateIndex];
    } else {
      bitrateKbps = _kV2L23[bitrateIndex];
    }
  }
  if (bitrateKbps <= 0) return null;

  const v1Sr = [44100, 48000, 32000];
  const v2Sr = [22050, 24000, 16000];
  const v25Sr = [11025, 12000, 8000];
  int sampleRate;
  if (versionBits == 0x03) {
    sampleRate = v1Sr[sampleRateIndex];
  } else if (versionBits == 0x02) {
    sampleRate = v2Sr[sampleRateIndex];
  } else {
    sampleRate = v25Sr[sampleRateIndex];
  }

  final bitrateBps = bitrateKbps * 1000;
  int frameLength;
  if (layerBits == 0x03) {
    // Layer I
    frameLength = ((12 * bitrateBps ~/ sampleRate) + padding) * 4;
  } else if (layerBits == 0x02) {
    // Layer II
    frameLength = (144 * bitrateBps ~/ sampleRate) + padding;
  } else {
    // Layer III: V1 uses 144, V2/V2.5 use 72.
    final coeff = isV1 ? 144 : 72;
    frameLength = (coeff * bitrateBps ~/ sampleRate) + padding;
  }
  if (frameLength < 4) return null;

  return _Mp3FrameHeader(bitrateBps: bitrateBps, frameLength: frameLength);
}

/// Builds the user-facing error message stored against a file when its
/// duration couldn't be read. Includes the filename so the dialog text
/// makes sense without extra context.
String _durationErrorMessage(AutoUploadFile file, String detail) {
  return tr(
    "Couldn't read the duration of {0}. The file may be corrupt or use an unsupported codec.\n\n{1}",
    [file.name, detail],
  );
}

Future<String?> _fileSignature(AutoUploadFile file) async {
  try {
    final stat = await file.stat();
    return stat?.size.toString();
  } catch (_) {
    return null;
  }
}

bool _signatureMatches(String? stored, String current) {
  return stored == current || (stored?.startsWith('$current:') ?? false);
}

String _deleteAfterUploadErrorMessage(AutoUploadFile file, Object detail) {
  return tr(
    "{0} was uploaded to Speakr, but the app could not delete the local copy. Automatic scans will skip this exact file to avoid duplicate uploads.\n\nDelete it manually, or tap this item and choose Delete file.\n\n{1}",
    [file.name, detail],
  );
}

/// Deletes the source recording with a short retry ladder (call-recorder
/// apps sometimes hold the file open for a moment after they finish).
/// Returns null on success, otherwise the last error.
Future<Object?> deleteLocalAutoUploadFile(
  AutoUploadFile file, {
  int attempts = 5,
  Duration initialDelay = const Duration(milliseconds: 200),
}) async {
  Object? lastError;
  for (var attempt = 0; attempt < attempts; attempt++) {
    try {
      await file.delete();
      return null;
    } catch (e) {
      lastError = e;
    }
    if (attempt < attempts - 1) {
      await Future<void>.delayed(initialDelay * (attempt + 1));
    }
  }
  return lastError ?? tr("File still exists after delete");
}

Future<void> _deleteUploadCopy(File copy) async {
  try {
    final parent = copy.parent;
    if (await parent.exists()) {
      await parent.delete(recursive: true);
    } else if (await copy.exists()) {
      await copy.delete();
    }
  } catch (e) {
    _logAutoUpload('could not delete temp upload copy ${copy.path}: $e');
  }
}

Future<DateTime> _resolveDateTime(
  AutoUploadFile file,
  FolderUploadConfig config,
) async {
  final stat = await file.stat();
  return resolveDateTime(file.name, stat?.modified ?? DateTime.now(), config);
}

class _UploadAndDeleteResult {
  const _UploadAndDeleteResult({
    required this.recording,
    required this.deleted,
    this.deleteError,
  });

  final Recording recording;
  final bool deleted;
  final Object? deleteError;
}

/// Uploads one file via [api], using [config] to derive datetime and
/// other multipart fields. Deletes the local file on success.
///
/// The upload always goes through a staged temp copy ([staged] if the
/// caller already made one for the duration probe, otherwise a fresh
/// one). The copy is removed here regardless of outcome.
Future<_UploadAndDeleteResult> _uploadAndDelete(
  AutoUploadFile file,
  FolderUploadConfig config,
  SpeakrApi api,
  AutoUploadSettingsStore? store, {
  File? staged,
}) async {
  Recording recording;
  final signature = await _fileSignature(file);
  try {
    final dt = await _resolveDateTime(file, config);
    final tagIds = config.tagId == null ? const <int>[] : <int>[config.tagId!];
    staged ??= await file.stageCopy();
    recording = await api.uploadRecording(
      file: staged,
      language: config.language,
      minSpeakers: config.minSpeakers,
      maxSpeakers: config.maxSpeakers,
      tagIds: tagIds,
      folderId: config.folderId,
      fileLastModified: dt,
    );
    try {
      await api.updateRecording(recording.id, {
        'meeting_date': dt.toUtc().toIso8601String(),
      });
    } catch (e) {
      _logAutoUpload('meeting_date PATCH failed for ${recording.id}: $e');
    }
  } finally {
    if (staged != null) await _deleteUploadCopy(staged);
  }
  final deleteError = await deleteLocalAutoUploadFile(file);
  if (deleteError == null) {
    if (store != null) {
      await store.clearUploadedFile(file.key);
      await store.clearFileError(file.key);
    }
    _logAutoUpload('uploaded and deleted ${file.displayPath}');
  } else if (store != null && signature != null) {
    await store.markUploadedFile(file.key, signature);
    await store.setFileError(
      file.key,
      _deleteAfterUploadErrorMessage(file, deleteError),
    );
    _logAutoUpload(
      'uploaded but could not delete ${file.displayPath}; '
      'signature=$signature error=$deleteError',
    );
  }
  return _UploadAndDeleteResult(
    recording: recording,
    deleted: deleteError == null,
    deleteError: deleteError,
  );
}

class AutoUploadStillWritingException implements Exception {
  AutoUploadStillWritingException(this.message);
  final String message;
  @override
  String toString() => message;
}

Future<AutoUploadLock> _acquireAutoUploadLock(
  AutoUploadSettingsStore store, {
  Duration waitFor = Duration.zero,
}) async {
  final deadline = DateTime.now().add(waitFor);
  while (true) {
    final lock = await store.tryAcquireLock();
    if (lock != null) return lock;
    if (!DateTime.now().isBefore(deadline)) {
      throw AutoUploadStillWritingException(
        tr("A scan is already in progress. Try again in a moment."),
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 750));
  }
}

/// Single-file upload entry point used by the Library "Upload now" tap.
/// Returns the new server-side [Recording] on success. Throws on failure.
///
/// Acquires the same SharedPreferences lock as the batch worker so a
/// background scan and a manual tap can't race.
Future<Recording> uploadOneFile(
  AutoUploadFile file,
  FolderUploadConfig config,
) async {
  final store = await AutoUploadSettingsStore.open();
  final lock = await _acquireAutoUploadLock(
    store,
    waitFor: const Duration(seconds: 20),
  );
  lock.startHeartbeat();
  try {
    final stable = await _checkFileStable(file);
    if (stable != AutoUploadOutcome.uploaded) {
      throw AutoUploadStillWritingException(
        tr("This recording is still being written. Try again shortly."),
      );
    }
    final api = buildBackgroundApi();
    final result = await _uploadAndDelete(file, config, api, store);
    return result.recording;
  } finally {
    await lock.release();
  }
}

/// Top-level entry point used by every batch trigger: WorkManager
/// periodic, phone-state-fired one-off, "Scan now" button, Windows
/// foreground polling timer.
///
/// Returns true on a clean run. WorkManager treats a `false` return as a
/// retry signal, but we deliberately return `true` even when individual
/// files failed — failed files stay on disk and the next scan re-tries
/// them, so a `Result.retry()` would just double-schedule.
Future<bool> runAutoUploadScan({required String trigger}) async {
  final store = await AutoUploadSettingsStore.open();
  await store.reload();
  final configs = store
      .readAll()
      .where((c) => c.enabled && c.hasFolder)
      .toList(growable: false);
  if (configs.isEmpty) {
    await store.pruneFileErrors(const {});
    return true;
  }

  final lock = await store.tryAcquireLock();
  if (lock == null) {
    _logAutoUpload('skip trigger=$trigger; scan already in progress');
    return true;
  }
  lock.startHeartbeat();

  final result = AutoUploadResult(trigger: trigger);
  try {
    await store.reload();
    final api = buildBackgroundApi();

    // Enumerate each folder once; the listing feeds both the stale-entry
    // prune and the processing loop below.
    final listings = <String, List<AutoUploadFile>>{};
    var listingFailed = false;
    for (final config in configs) {
      if (config.needsAndroidGrant) {
        listingFailed = true;
        result.lastError = tr(
          "{0} must be re-selected in Auto-upload settings before it can be scanned.",
          [config.folderPath],
        );
        _logAutoUpload('skip ${config.folderPath}: no folder grant');
        continue;
      }
      try {
        listings[config.id] = await listCandidateFiles(config);
      } on AutoUploadFolderAccessException catch (e) {
        listingFailed = true;
        result.lastError = e.message;
        _logAutoUpload(e.message);
      }
    }

    // Drop persisted errors for files the user has deleted or moved away
    // since the last scan, so stale badges don't linger. Skipped when a
    // folder could not be listed — its entries are not stale, just
    // unreachable right now.
    if (!listingFailed) {
      final seenKeys = <String>{};
      final seenSignatures = <String, String>{};
      for (final files in listings.values) {
        for (final file in files) {
          seenKeys.add(file.key);
          final signature = await _fileSignature(file);
          if (signature != null) seenSignatures[file.key] = signature;
        }
      }
      await store.pruneFileErrors(seenKeys);
      await store.pruneUploadedFiles(seenSignatures);
    }
    final uploadedFiles = store.readUploadedFiles();
    final processedKeys = <String>{};

    for (final config in configs) {
      final files = listings[config.id];
      if (files == null) continue;
      for (final file in files) {
        if (!processedKeys.add(file.key)) continue;
        File? staged;
        try {
          final signature = await _fileSignature(file);
          if (signature != null &&
              _signatureMatches(uploadedFiles[file.key], signature)) {
            final deleteError = await deleteLocalAutoUploadFile(file);
            if (deleteError == null) {
              await store.clearUploadedFile(file.key);
              await store.clearFileError(file.key);
              _logAutoUpload(
                'deleted already-uploaded local copy ${file.displayPath}',
              );
              result.skipped++;
              continue;
            }
            _logAutoUpload(
              'skip already-uploaded local copy ${file.displayPath}; '
              'signature=$signature deleteError=$deleteError',
            );
            result.skipped++;
            continue;
          }
          final stable = await _checkFileStable(file);
          if (stable != AutoUploadOutcome.uploaded) {
            result.skipped++;
            continue;
          }
          if (config.autoDeleteShorterThanSeconds != null) {
            // The probe needs a dart:io File; stage the copy now and hand
            // it on to the upload so the content is read only once.
            staged = await file.stageCopy();
            final probe = _probeDuration(staged);
            if (probe.hasError) {
              await store.setFileError(
                file.key,
                _durationErrorMessage(file, probe.error!),
              );
              result.failed++;
              result.lastError = probe.error;
              continue;
            }
            if (probe.isKnown &&
                probe.duration!.inSeconds <
                    config.autoDeleteShorterThanSeconds!) {
              final deleteError = await deleteLocalAutoUploadFile(file);
              if (deleteError == null) {
                await store.clearFileError(file.key);
              } else {
                await store.setFileError(
                  file.key,
                  tr(
                    "Could not delete {0} after the auto-delete duration rule matched.\n\n{1}",
                    [file.name, deleteError],
                  ),
                );
                result.failed++;
                result.lastError = deleteError.toString();
                continue;
              }
              result.skipped++;
              continue;
            }
            // Format not supported by reader, or duration above threshold:
            // fall through to upload normally.
          }
          final handoff = staged;
          staged = null; // _uploadAndDelete owns the copy from here.
          final upload = await _uploadAndDelete(
            file,
            config,
            api,
            store,
            staged: handoff,
          );
          result.uploaded++;
          if (!upload.deleted) {
            result.failed++;
            result.lastError = tr("Uploaded but could not delete {0}: {1}", [
              file.name,
              upload.deleteError,
            ]);
          }
        } catch (e) {
          result.failed++;
          result.lastError = e.toString();
        } finally {
          if (staged != null) await _deleteUploadCopy(staged);
        }
      }
    }
    await store.recordScanResult(result.summary);
    _logAutoUpload(result.summary);
    return true;
  } finally {
    await lock.release();
  }
}
