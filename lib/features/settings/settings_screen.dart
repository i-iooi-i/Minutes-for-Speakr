import 'package:speakr_app/widgets/avatar_settings.dart';
import 'package:speakr_app/widgets/appearance_picker.dart';
import 'package:speakr_app/theme/appearance.dart';
import 'package:speakr_app/l10n/strings.dart';

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/models.dart';
import '../../api/providers.dart';
import '../../api/speakr_api.dart';
import '../../services/app_info.dart';
import '../../services/auto_record/auto_record_providers.dart';
import '../../services/auto_record/auto_record_settings.dart'
    show SystemAudioScope;
import '../../services/auto_start/auto_start_providers.dart';
import '../../services/credentials_store.dart';
import '../../services/preferences/time_format_preference.dart';
import '../../services/preferences/time_format_providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../utils/formatters.dart';
import '../../widgets/mono_eyebrow.dart';
import '../../widgets/settings_row.dart';
import '../../widgets/speakr_icons.dart';
import '../auto_upload/auto_upload_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _autoSummarize = true;
  bool _serverOk = true;
  bool _checkingServer = false;
  int? _storageBytes;
  int? _recordingsCount;
  String _baseUrl = '';
  String _maskedToken = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final creds = await ref.read(credentialsStoreProvider).read();
    if (creds != null && mounted) {
      setState(() {
        _baseUrl = creds.baseUrl;
        _maskedToken = _maskToken(creds.token);
      });
    }
    setState(() => _checkingServer = true);

    bool reachable = false;
    StatsResponse? stats;
    try {
      stats = await ref.read(speakrApiProvider).getStats();
      reachable = true;
    } on SpeakrApiException catch (e) {
      // A non-null statusCode means the server replied — still reachable.
      // Otherwise the underlying DioException tells us whether the failure
      // was network-level.
      reachable = e.statusCode != null || !_isNetworkFailure(e.cause);
      debugPrint('Settings status: stats call failed: $e');
    } catch (e, st) {
      // Anything else (e.g. type/cast errors from a payload we cannot parse)
      // means we got past the network — treat the server as reachable.
      reachable = true;
      debugPrint('Settings status: stats parse failed: $e\n$st');
    }

    if (!mounted) return;
    setState(() {
      _serverOk = reachable;
      _storageBytes = stats?.storage?.usedBytes;
      _recordingsCount = stats?.recordings?.total;
      _checkingServer = false;
    });
  }

  bool _isNetworkFailure(Object? cause) {
    if (cause is DioException) {
      switch (cause.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
        case DioExceptionType.badCertificate:
          return true;
        case DioExceptionType.cancel:
        case DioExceptionType.badResponse:
        case DioExceptionType.unknown:
          return cause.error is SocketException;
      }
    }
    return cause is SocketException;
  }

  String _maskToken(String t) {
    if (t.length <= 4) return '••••${t}';
    return '••••••••${t.substring(t.length - 4)}';
  }

  Future<void> _signOut() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: SpeakrColors.bg,
        title: Text(tr("Sign out?"), style: SpeakrText.serif(size: 20)),
        content: Text(
          tr("Disconnects from the server and clears stored credentials."),
          style: SpeakrText.sans(size: 14, color: SpeakrColors.ink2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(tr("Cancel")),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              tr("Sign out"),
              style: SpeakrText.sans(size: 14, color: SpeakrColors.danger),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(credentialsStoreProvider).clear();
    ref.invalidate(currentCredentialsProvider);
    if (!mounted) return;
    context.go('/onboarding');
  }

  Future<void> _toggleAutoStart(bool v) async {
    try {
      await ref.read(autoStartServiceProvider).setEnabled(v);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr("Could not update auto-start: {0}", [e]))),
      );
    } finally {
      ref.invalidate(autoStartEnabledProvider);
    }
  }

  Future<void> _toggleAutoSummarize(bool v) async {
    setState(() => _autoSummarize = v);
    try {
      await ref.read(speakrApiProvider).setAutoSummarization(v);
    } catch (e) {
      if (!mounted) return;
      setState(() => _autoSummarize = !v);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr("Could not update setting: {0}", [e]))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    return Scaffold(
      backgroundColor: SpeakrColors.bg,
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  GhostIconButton(
                    icon: SpeakrIcon.back,
                    onTap: () => context.pop(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: MonoEyebrow(tr("Settings"), size: 10),
                  ),
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.all(20), child: AvatarSettings()),
            SettingsGroup(
              label: tr("Server"),
              children: [
                SettingsRow(
                  label: tr("Server URL"),
                  value: _baseUrl,
                  mono: true,
                ),
                SettingsRow(
                  label: tr("API Token"),
                  value: _maskedToken,
                  mono: true,
                ),
                SettingsRow(
                  label: tr("Status"),
                  value: _checkingServer
                      ? tr("Checking…")
                      : (_serverOk ? tr("Connected") : tr("Unreachable")),
                  valueColor: _checkingServer
                      ? SpeakrColors.muted
                      : (_serverOk ? SpeakrColors.ok : SpeakrColors.danger),
                ),
              ],
            ),
            SettingsGroup(
              label: tr("Recording"),
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final s = ref.watch(autoRecordSettingsProvider);
                    final settings = s.value;
                    final controller = ref.read(
                      autoRecordSettingsControllerProvider,
                    );
                    return SettingsRow(
                      label: tr("Record microphone by default"),
                      subtitle: tr(
                        "New sessions start with the mic source on. Can be toggled mid-recording.",
                      ),
                      toggleValue: settings?.defaultMicEnabled ?? true,
                      onToggle: settings == null
                          ? null
                          : controller.setDefaultMicEnabled,
                    );
                  },
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final s = ref.watch(autoRecordSettingsProvider);
                    final settings = s.value;
                    final controller = ref.read(
                      autoRecordSettingsControllerProvider,
                    );
                    final supported = Platform.isWindows || Platform.isAndroid;
                    return SettingsRow(
                      label: tr("Record system audio by default"),
                      subtitle: supported
                          ? tr(
                              "New sessions start with system (loopback) audio on. Can be toggled mid-recording. Captures audio from other apps that are playing.",
                            )
                          : tr(
                              "System audio capture is only available on Windows and Android 10+.",
                            ),
                      toggleValue: settings?.defaultSystemEnabled ?? false,
                      onToggle: (supported && settings != null)
                          ? controller.setDefaultSystemEnabled
                          : null,
                    );
                  },
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final s = ref.watch(autoRecordSettingsProvider);
                    final settings = s.value;
                    if (settings == null || !settings.defaultSystemEnabled) {
                      return const SizedBox.shrink();
                    }
                    final processSupported =
                        ref.watch(processLoopbackSupportedProvider).value ??
                        false;
                    if (!processSupported) return const SizedBox.shrink();
                    final controller = ref.read(
                      autoRecordSettingsControllerProvider,
                    );
                    final isProcessOnly =
                        settings.defaultSystemScope ==
                        SystemAudioScope.processOnly;
                    return SettingsRow(
                      label: tr("Default system-audio scope"),
                      subtitle: tr(
                        "All-system mixes every app. Trigger-only captures only the auto-record trigger app (Windows 11 / Server 2022). Used when an app has no per-app override.",
                      ),
                      value: isProcessOnly
                          ? tr("Trigger app only")
                          : tr("All system"),
                      onTap: () => controller.setDefaultSystemScope(
                        isProcessOnly
                            ? SystemAudioScope.allSystem
                            : SystemAudioScope.processOnly,
                      ),
                    );
                  },
                ),
                SettingsRow(
                  label: tr("Auto-summarize"),
                  toggleValue: _autoSummarize,
                  onToggle: _toggleAutoSummarize,
                ),
                if (Platform.isWindows)
                  Consumer(
                    builder: (context, ref, _) {
                      final s = ref.watch(autoRecordSettingsProvider);
                      final summary = s.maybeWhen(
                        data: (settings) {
                          if (!settings.enabled) return tr("Off");
                          final n = settings.allowlist.length;
                          if (n == 0) return tr("On · no apps");
                          return n == 1
                              ? tr("On · 1 app")
                              : tr("On · {0} apps", [n]);
                        },
                        orElse: () => '—',
                      );
                      return SettingsRow(
                        label: tr("Auto-record on mic activity"),
                        value: summary,
                        onTap: () => context.push('/settings/auto-record'),
                      );
                    },
                  ),
              ],
            ),
            SettingsGroup(
              label: tr("Display"),
              children: [
                SettingsRow(
                  label: tr("Interface language"),
                  trailing: const LanguagePicker(),
                ),
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: AppearancePicker(),
                ),
                const _TimeFormatRow(),
              ],
            ),
            if (Platform.isWindows)
              Consumer(
                builder: (context, ref, _) {
                  final enabled = ref.watch(autoStartEnabledProvider);
                  return SettingsGroup(
                    label: tr("Startup"),
                    children: [
                      SettingsRow(
                        label: tr("Start with Windows"),
                        subtitle: tr(
                          "Launches Mimio minimized to the tray when you sign in.",
                        ),
                        toggleValue: enabled.maybeWhen(
                          data: (v) => v,
                          orElse: () => false,
                        ),
                        onToggle: enabled.hasValue
                            ? (v) => _toggleAutoStart(v)
                            : null,
                      ),
                    ],
                  );
                },
              ),
            Consumer(
              builder: (context, ref, _) {
                final configs = ref.watch(folderConfigsProvider);
                final summary = configs.maybeWhen(
                  data: (list) {
                    if (list.isEmpty) return tr("Disabled");
                    final enabled = list.where((c) => c.enabled).length;
                    final total = list.length;
                    final word = tr(total == 1 ? 'folder' : 'folders');
                    return tr("{0} of {1} {2} enabled", [enabled, total, word]);
                  },
                  orElse: () => '—',
                );
                return SettingsGroup(
                  label: tr("Auto-upload"),
                  children: [
                    SettingsRow(
                      label: tr("Auto-upload from folders"),
                      value: summary,
                      onTap: () => context.push('/settings/auto-upload'),
                    ),
                  ],
                );
              },
            ),
            SettingsGroup(
              label: tr("Storage"),
              children: [
                SettingsRow(
                  label: tr("Recordings"),
                  value: _recordingsCount?.toString() ?? '—',
                ),
                SettingsRow(
                  label: tr("Storage used"),
                  value: formatBytes(_storageBytes),
                ),
              ],
            ),
            SettingsGroup(
              label: tr("About"),
              children: [
                SettingsRow(
                  label: tr("App version"),
                  value: ref
                      .watch(appVersionProvider)
                      .maybeWhen(data: (v) => v, orElse: () => '—'),
                  mono: true,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _signOut,
                  style: TextButton.styleFrom(
                    foregroundColor: SpeakrColors.danger,
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(tr("Sign out")),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeFormatRow extends ConsumerWidget {
  const _TimeFormatRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    final pref =
        ref.watch(timeFormatPreferenceProvider).asData?.value ??
        TimeFormatPreference.system;
    final systemUses24 = MediaQuery.alwaysUse24HourFormatOf(context);
    final subtitle = pref == TimeFormatPreference.system
        ? (Platform.isWindows
              ? tr(
                  "System (Windows always reports 12-hour — pick 24h to override)",
                )
              : tr("Following system (currently {0})", [
                  systemUses24 ? '24-hour' : '12-hour',
                ]))
        : null;

    Future<void> select(TimeFormatPreference next) =>
        ref.read(timeFormatControllerProvider).set(next);

    return SettingsRow(
      label: tr("Time format"),
      subtitle: subtitle,
      trailing: _TimeFormatSegments(value: pref, onChanged: select),
    );
  }
}

class _TimeFormatSegments extends StatelessWidget {
  const _TimeFormatSegments({required this.value, required this.onChanged});
  final TimeFormatPreference value;
  final ValueChanged<TimeFormatPreference> onChanged;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: SpeakrColors.line),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segment(tr("Auto"), TimeFormatPreference.system),
          _segment(tr("12h"), TimeFormatPreference.twelveHour),
          _segment(tr("24h"), TimeFormatPreference.twentyFourHour),
        ],
      ),
    );
  }

  Widget _segment(String label, TimeFormatPreference pref) {
    final selected = value == pref;
    return GestureDetector(
      onTap: selected ? null : () => onChanged(pref),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? SpeakrColors.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: SpeakrText.mono(
            size: 11,
            color: selected ? SpeakrColors.bg : SpeakrColors.muted,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
