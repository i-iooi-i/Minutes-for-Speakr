import 'package:speakr_app/l10n/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../desktop/detail/detail_desktop_screen.dart';
import '../desktop/library/library_desktop_screen.dart';
import '../desktop/live/live_desktop_screen.dart';
import '../desktop/onboarding/onboarding_desktop_screen.dart';
import '../desktop/settings/settings_desktop_screen.dart';
import '../desktop/shell/desktop_shell.dart';
import '../features/auto_upload/auto_upload_settings_screen.dart';
import '../features/detail/detail_screen.dart';
import '../features/library/library_screen.dart';
import '../features/live/live_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/settings/auto_record_settings_screen.dart';
import '../features/settings/settings_screen.dart';
import '../responsive/breakpoints.dart';
import '../services/credentials_store.dart';
import '../theme/colors.dart';

/// Root navigator key. Exposed so non-widget code (e.g. the auto-record
/// stop-prompt listener, which sits in `MaterialApp.builder` and therefore
/// above the Navigator) can reach a context that's a descendant of the
/// Navigator for [showDialog] / [Navigator.of] calls.
final speakrNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: speakrNavigatorKey,
    initialLocation: '/onboarding',
    redirect: (context, state) {
      // While the FutureProvider resolves, leave wherever the user is and
      // let the SplashGate cover the gap.
      final asyncCreds = ref.read(currentCredentialsProvider);
      if (asyncCreds.isLoading) return null;
      final creds = asyncCreds.value;
      final loc = state.uri.path;
      final atOnboarding = loc == '/onboarding';
      if (creds == null) {
        return atOnboarding ? null : '/onboarding';
      }
      if (atOnboarding || loc == '/') return '/library';
      return null;
    },
    refreshListenable: _CredentialsListenable(ref),
    routes: [
      GoRoute(path: '/', redirect: (_, __) => '/library'),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => LayoutBuilder(
          builder: (_, c) => isDesktopConstraints(c)
              ? const OnboardingDesktopScreen()
              : const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/library',
        builder: (_, __) => LayoutBuilder(
          builder: (_, c) => isDesktopConstraints(c)
              ? const DesktopShell(
                  active: DesktopShellRoute.library,
                  child: LibraryDesktopScreen(),
                )
              : const LibraryScreen(),
        ),
      ),
      GoRoute(
        path: '/recording/:id',
        builder: (_, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return LayoutBuilder(
            builder: (_, c) => isDesktopConstraints(c)
                ? DesktopShell(
                    active: DesktopShellRoute.library,
                    child: DetailDesktopScreen(
                      recordingId: id,
                      autoplay: state.uri.queryParameters['play'] == '1',
                    ),
                  )
                : DetailScreen(recordingId: id),
          );
        },
      ),
      GoRoute(
        path: '/live',
        builder: (_, __) => LayoutBuilder(
          builder: (_, c) =>
              (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) ||
                  isDesktopConstraints(c)
              ? const DesktopShell(
                  active: DesktopShellRoute.recording,
                  child: LiveDesktopScreen(),
                )
              : const LiveScreen(),
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => LayoutBuilder(
          builder: (_, c) => isDesktopConstraints(c)
              ? const SettingsDesktopScreen()
              : const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/settings/auto-upload',
        builder: (_, __) => const AutoUploadSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/auto-record',
        builder: (_, __) => const AutoRecordSettingsScreen(),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      backgroundColor: SpeakrColors.bg,
      body: Center(child: Text(tr("Route not found: {0}", [state.uri.path]))),
    ),
  );
});

class _CredentialsListenable extends ChangeNotifier {
  _CredentialsListenable(this._ref) {
    _ref.listen<AsyncValue<SpeakrCredentials?>>(
      currentCredentialsProvider,
      (_, __) => notifyListeners(),
    );
  }
  final Ref _ref;
}
