import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:speakr_app/l10n/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'routing/router.dart';
import 'services/credentials_store.dart';
import 'theme/colors.dart';
import 'theme/typography.dart';
import 'widgets/auto_record_banner.dart';
import 'widgets/recording_mini_player.dart';

class SpeakrApp extends ConsumerWidget {
  const SpeakrApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    // Wait for the credentials provider to resolve so the router can
    // pick the correct initial location (library vs onboarding).
    final asyncCreds = ref.watch(currentCredentialsProvider);
    return asyncCreds.when(
      loading: () => const _Splash(),
      error: (_, __) => const _Splash(),
      data: (_) {
        final router = ref.watch(routerProvider);
        return LocalizedApp(
          builder: (locale) => MaterialApp.router(
            locale: locale,
            supportedLocales: appLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            title: 'Minutes for Speakr',
            debugShowCheckedModeBanner: false,
            theme: buildSpeakrTheme(),
            routerConfig: router,
            builder: (context, child) => AutoRecordPromptListener(
              child: RecordingMiniPlayer(
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildSpeakrTheme(),
      home: const Scaffold(
        backgroundColor: SpeakrColors.bg,
        body: SizedBox.shrink(),
      ),
    );
  }
}
