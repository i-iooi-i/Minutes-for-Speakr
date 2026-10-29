import 'package:speakr_app/theme/appearance.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:speakr_app/l10n/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/typography.dart';
import 'mini_recorder_screen.dart';
import 'recording_mirror.dart';

/// Root of the always-on-top mini recorder window's Flutter engine. Built
/// via the entry-point dispatch in `lib/main.dart` when the process is
/// launched as a child window by the desktop_multi_window plugin.
class MiniRecorderApp extends ConsumerStatefulWidget {
  const MiniRecorderApp({super.key, required this.windowId});
  final int windowId;

  @override
  ConsumerState<MiniRecorderApp> createState() => _MiniRecorderAppState();
}

class _MiniRecorderAppState extends ConsumerState<MiniRecorderApp> {
  @override
  void initState() {
    super.initState();
    // Eagerly construct the mirror so it registers its IPC handler before
    // the main engine has a chance to push the first state.update.
    ref.read(recordingMirrorProvider.notifier);
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    return LocalizedApp(
      builder: (locale) => MaterialApp(
        locale: locale,
        supportedLocales: appLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        title: tr("Mimio Recording"),
        debugShowCheckedModeBanner: false,
        theme: buildSpeakrTheme(),
        home: const MiniRecorderScreen(),
      ),
    );
  }
}
