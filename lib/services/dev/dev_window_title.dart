import 'dart:io' show Platform, Process, ProcessException;

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;

import '../../features/live/mini/mini_window_native.dart';

/// Rewrites the main window title on Windows.
///
/// In Flutter debug mode the title becomes `Speakr — <branch>` so
/// simultaneously-running worktree instances are distinguishable in the
/// taskbar. In release builds it becomes `Mimio`. No-op on web and non-Windows platforms. Failure is silent —
/// the title is cosmetic and must never break startup, so the default native
/// title simply stays.
Future<void> applyDevBranchTitleIfDebug() async {
  if (kIsWeb || !Platform.isWindows) return;

  try {
    if (kDebugMode) {
      final res = Process.runSync('git', [
        'rev-parse',
        '--abbrev-ref',
        'HEAD',
      ], runInShell: true);
      if (res.exitCode != 0) return;
      final branch = (res.stdout as String).trim();
      if (branch.isEmpty || branch == 'HEAD') return;
      await MiniWindowNative.setMainWindowTitle('Mimio — $branch');
    } else {
      await MiniWindowNative.setMainWindowTitle('Mimio');
    }
  } on ProcessException {
    // git not on PATH — leave default title.
  } catch (_) {
    // Anything else is non-fatal; title is cosmetic.
  }
}
