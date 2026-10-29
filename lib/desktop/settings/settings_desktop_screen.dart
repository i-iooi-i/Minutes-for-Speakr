import 'package:speakr_app/widgets/avatar_settings.dart';
import 'package:speakr_app/widgets/appearance_picker.dart';
import 'package:speakr_app/theme/appearance.dart';
import 'package:speakr_app/l10n/strings.dart';

import 'dart:io' show Platform, SocketException;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
import '../../theme/tokens.dart';
import '../../utils/formatters.dart';
import '../../widgets/speakr_icons.dart';
import '../shell/desktop_shortcuts.dart';

enum _SettingsSection {
  profile,
  server,
  recording,
  transcription,
  appearance,
  shortcuts,
  about,
}

class SettingsDesktopScreen extends ConsumerStatefulWidget {
  const SettingsDesktopScreen({super.key});
  @override
  ConsumerState<SettingsDesktopScreen> createState() =>
      _SettingsDesktopScreenState();
}

class _SettingsDesktopScreenState extends ConsumerState<SettingsDesktopScreen> {
  _SettingsSection _section = _SettingsSection.server;
  bool _serverChecking = false;
  bool _serverOk = false;
  int? _storageBytes;
  int? _recordingsCount;
  bool _autoSummarize = true;

  @override
  void initState() {
    super.initState();
    _probeServer();
  }

  Future<void> _probeServer() async {
    setState(() => _serverChecking = true);
    bool ok = false;
    StatsResponse? stats;
    try {
      stats = await ref.read(speakrApiProvider).getStats();
      ok = true;
    } on SpeakrApiException catch (e) {
      ok = e.statusCode != null || !_isNetworkFailure(e.cause);
    } catch (_) {
      ok = true;
    }
    if (!mounted) return;
    setState(() {
      _serverChecking = false;
      _serverOk = ok;
      _storageBytes = stats?.storage?.usedBytes;
      _recordingsCount = stats?.recordings?.total;
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

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    return Scaffold(
      backgroundColor: SpeakrColors.bg,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SubSidebar(
            current: _section,
            onChange: (s) => setState(() => _section = s),
            onBack: () => context.go('/library'),
          ),
          VerticalDivider(width: 1, color: SpeakrColors.line),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(60, 40, 60, 60),
              child: _content(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    switch (_section) {
      case _SettingsSection.profile:
        return _ProfileSection();
      case _SettingsSection.server:
        return _ServerSection(
          checking: _serverChecking,
          serverOk: _serverOk,
          onRefresh: _probeServer,
        );
      case _SettingsSection.recording:
        return _RecordingSection(
          autoSummarize: _autoSummarize,
          onAutoSummarize: (v) async {
            final prev = _autoSummarize;
            setState(() => _autoSummarize = v);
            try {
              await ref.read(speakrApiProvider).setAutoSummarization(v);
            } catch (e) {
              if (!mounted) return;
              setState(() => _autoSummarize = prev);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tr("Could not update setting: {0}", [e])),
                ),
              );
            }
          },
        );
      case _SettingsSection.transcription:
        return const _TranscriptionSection();
      case _SettingsSection.appearance:
        return const _AppearanceSection();
      case _SettingsSection.shortcuts:
        return const _ShortcutsSection();
      case _SettingsSection.about:
        return _AboutSection(
          storageBytes: _storageBytes,
          recordingsCount: _recordingsCount,
          onSignOut: _signOut,
        );
    }
  }
}

// ─────────────────────────────────────────────────────────
// Sidebar
// ─────────────────────────────────────────────────────────

class _SubSidebar extends StatelessWidget {
  const _SubSidebar({
    required this.current,
    required this.onChange,
    required this.onBack,
  });
  final _SettingsSection current;
  final ValueChanged<_SettingsSection> onChange;
  final VoidCallback onBack;

  static List<(_SettingsSection, String)> get _items => [
    (_SettingsSection.profile, tr("Profile")),
    (_SettingsSection.server, tr("Server")),
    (_SettingsSection.recording, tr("Recording")),
    (_SettingsSection.transcription, tr("Transcription")),
    (_SettingsSection.appearance, tr("Appearance")),
    if (supportsKeyboardShortcuts)
      (_SettingsSection.shortcuts, tr("Shortcuts")),
    (_SettingsSection.about, tr("About")),
  ];

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    return SizedBox(
      width: 220,
      child: Material(
        color: SpeakrColors.bg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 20, 14, 16),
              child: _BackChip(onTap: onBack),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 14),
              child: Text(tr("Settings"), style: SpeakrText.serif(size: 26)),
            ),
            for (final (sec, label) in _items)
              InkWell(
                borderRadius: SpeakrRadius.menu,
                onTap: () => onChange(sec),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: sec == current
                            ? SpeakrColors.ink
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    label,
                    style: SpeakrText.sans(
                      size: 13,
                      weight: sec == current
                          ? FontWeight.w500
                          : FontWeight.w400,
                      color: sec == current
                          ? SpeakrColors.ink
                          : SpeakrColors.ink2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BackChip extends StatelessWidget {
  const _BackChip({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    return Material(
      color: SpeakrColors.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: SpeakrColors.line),
        borderRadius: SpeakrRadius.control,
      ),
      child: InkWell(
        borderRadius: SpeakrRadius.control,
        onTap: onTap,
        child: Container(
          height: 28,
          padding: const EdgeInsets.fromLTRB(6, 0, 10, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SpeakrIconView(
                SpeakrIcon.back,
                size: 16,
                color: SpeakrColors.ink2,
              ),
              const SizedBox(width: 2),
              Text(
                tr("Back"),
                style: SpeakrText.sans(size: 12, color: SpeakrColors.ink2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Section shared bits
// ─────────────────────────────────────────────────────────

class _SectionHead extends StatelessWidget {
  const _SectionHead({required this.title, this.sub});
  final String title;
  final String? sub;
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: SpeakrColors.line)),
              ),
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: SpeakrText.serif(size: 32)),
                  if (sub != null) ...[
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Text(
                        sub!,
                        style: SpeakrText.sans(
                          size: 13,
                          color: SpeakrColors.muted,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, this.hint, required this.child});
  final String label;
  final String? hint;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: SpeakrColors.line)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: SpeakrText.sans(
                      size: 13,
                      weight: FontWeight.w500,
                      color: SpeakrColors.ink,
                    ),
                  ),
                  if (hint != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      hint!,
                      style: SpeakrText.sans(
                        size: 11.5,
                        color: SpeakrColors.muted,
                        height: 1.4,
                      ).copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 30),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _TextValue extends StatelessWidget {
  const _TextValue({required this.text, this.mono = false});
  final String text;
  final bool mono;
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: SpeakrColors.surface,
        border: Border.all(color: SpeakrColors.line),
        borderRadius: SpeakrRadius.menu,
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: mono
            ? SpeakrText.mono(
                size: 12,
                color: SpeakrColors.ink,
                letterSpacing: 0,
              )
            : SpeakrText.sans(size: 13, color: SpeakrColors.ink),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.on, this.onTap});
  final bool on;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 20,
          decoration: BoxDecoration(
            color: on ? SpeakrColors.ink : SpeakrColors.line,
            borderRadius: BorderRadius.circular(100),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 180),
            alignment: on ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: SpeakrColors.bg,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownStub extends StatelessWidget {
  const _DropdownStub({required this.value});
  final String value;
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: SpeakrColors.surface,
        border: Border.all(color: SpeakrColors.line),
        borderRadius: SpeakrRadius.menu,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: SpeakrText.sans(size: 13, color: SpeakrColors.ink),
          ),
          const SizedBox(width: 10),
          CustomPaint(
            size: const Size(10, 10),
            painter: _ChevPainter(SpeakrColors.ink2),
          ),
        ],
      ),
    );
  }
}

class _ChevPainter extends CustomPainter {
  _ChevPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * 0.25, size.height * 0.4)
      ..lineTo(size.width * 0.5, size.height * 0.65)
      ..lineTo(size.width * 0.75, size.height * 0.4);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _ChevPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────
// Sections
// ─────────────────────────────────────────────────────────

class _ProfileSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHead(
          title: tr("Profile"),
          sub: tr("Customize your profile on this device."),
        ),
        const AvatarSettings(),
        const SizedBox(height: 24),
        _Field(
          label: tr("Display name"),
          child: _TextValue(text: tr("Speakr user")),
        ),
        _Field(
          label: tr("Default speaker label"),
          hint: tr("What 'me' is named in transcripts."),
          child: _TextValue(text: tr("Speakr user")),
        ),
      ],
    );
  }
}

class _ServerSection extends ConsumerWidget {
  const _ServerSection({
    required this.checking,
    required this.serverOk,
    required this.onRefresh,
  });
  final bool checking;
  final bool serverOk;
  final Future<void> Function() onRefresh;

  String _maskToken(String t) {
    if (t.length <= 4) return '•••• $t';
    return '••••••••${t.substring(t.length - 4)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    final asyncCreds = ref.watch(currentCredentialsProvider);
    final creds = asyncCreds.value;
    final url = creds?.baseUrl ?? '—';
    final token = creds?.token == null ? '—' : _maskToken(creds!.token);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHead(
          title: tr("Server"),
          sub: tr(
            "Speakr is self-hosted. Audio and transcripts stay on the machine you point this app at.",
          ),
        ),
        _Field(
          label: tr("Server URL"),
          child: _TextValue(text: url, mono: true),
        ),
        _Field(
          label: tr("API token"),
          hint: tr("Generated in Settings → API Tokens on your server."),
          child: _TextValue(text: token, mono: true),
        ),
        _Field(
          label: tr("Connection"),
          hint: tr("Last verified just now."),
          child: Row(
            children: [
              if (checking)
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: SpeakrColors.ink,
                  ),
                )
              else
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: serverOk ? SpeakrColors.ok : SpeakrColors.danger,
                    shape: BoxShape.circle,
                  ),
                ),
              const SizedBox(width: 7),
              Text(
                checking
                    ? tr("CHECKING…")
                    : (serverOk ? tr("CONNECTED") : tr("UNREACHABLE")),
                style: SpeakrText.mono(
                  size: 11,
                  color: serverOk ? SpeakrColors.ok : SpeakrColors.danger,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              Material(
                color: SpeakrColors.surface,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: SpeakrColors.line),
                  borderRadius: SpeakrRadius.control,
                ),
                child: InkWell(
                  borderRadius: SpeakrRadius.control,
                  onTap: checking ? null : onRefresh,
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    child: Text(
                      tr("Test connection"),
                      style: SpeakrText.sans(
                        size: 12,
                        color: SpeakrColors.ink2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecordingSection extends ConsumerWidget {
  const _RecordingSection({
    required this.autoSummarize,
    required this.onAutoSummarize,
  });
  final bool autoSummarize;
  final ValueChanged<bool> onAutoSummarize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    final settingsAsync = ref.watch(autoRecordSettingsProvider);
    final controller = ref.read(autoRecordSettingsControllerProvider);
    final settings = settingsAsync.value;
    final supportsSystem =
        !kIsWeb && (Platform.isWindows || Platform.isAndroid);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHead(
          title: tr("Recording"),
          sub: tr("Defaults for new recordings."),
        ),
        _Field(
          label: tr("Record microphone by default"),
          hint: tr("New sessions start with the mic source on."),
          child: _Toggle(
            on: settings?.defaultMicEnabled ?? true,
            onTap: settings == null
                ? null
                : () => controller.setDefaultMicEnabled(
                    !settings.defaultMicEnabled,
                  ),
          ),
        ),
        _Field(
          label: tr("Record system audio by default"),
          hint: supportsSystem
              ? tr("Captures audio from other apps that are playing.")
              : tr("Available on Windows and Android 10+ only."),
          child: _Toggle(
            on: settings?.defaultSystemEnabled ?? false,
            onTap: (settings != null && supportsSystem)
                ? () => controller.setDefaultSystemEnabled(
                    !settings.defaultSystemEnabled,
                  )
                : null,
          ),
        ),
        Consumer(
          builder: (context, ref, _) {
            if (settings == null || !settings.defaultSystemEnabled) {
              return const SizedBox.shrink();
            }
            final processSupported =
                ref.watch(processLoopbackSupportedProvider).value ?? false;
            if (!processSupported) return const SizedBox.shrink();
            final isProcessOnly =
                settings.defaultSystemScope == SystemAudioScope.processOnly;
            return _Field(
              label: tr("Default system-audio scope"),
              hint: tr(
                "All-system mixes every app's output. Trigger-only captures only the auto-record trigger app and its children. Used when an app has no per-app override.",
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: SpeakrColors.surface,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: SpeakrColors.line),
                    borderRadius: SpeakrRadius.control,
                  ),
                  child: InkWell(
                    borderRadius: SpeakrRadius.control,
                    onTap: () => controller.setDefaultSystemScope(
                      isProcessOnly
                          ? SystemAudioScope.allSystem
                          : SystemAudioScope.processOnly,
                    ),
                    child: Container(
                      height: 34,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        isProcessOnly
                            ? tr("Trigger app only")
                            : tr("All system"),
                        style: SpeakrText.sans(
                          size: 12,
                          color: SpeakrColors.ink,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        Consumer(
          builder: (context, ref, _) {
            final videoSupported =
                ref.watch(videoCaptureSupportedProvider).value ?? false;
            if (!videoSupported) return const SizedBox.shrink();
            return _Field(
              label: tr("Record video by default"),
              hint: tr(
                "Records the meeting app's window (cameras, shared screens) as video, about 0.7 GB per hour. Needs VIDEO_RETENTION on the Speakr server.",
              ),
              child: _Toggle(
                on: settings?.defaultVideoEnabled ?? false,
                onTap: settings == null
                    ? null
                    : () => controller.setDefaultVideoEnabled(
                        !settings.defaultVideoEnabled,
                      ),
              ),
            );
          },
        ),
        _Field(
          label: tr("Auto-summarize"),
          hint: tr("Generate a TL;DR after each recording completes."),
          child: _Toggle(
            on: autoSummarize,
            onTap: () => onAutoSummarize(!autoSummarize),
          ),
        ),
        if (!kIsWeb && Platform.isWindows)
          _Field(
            label: tr("Auto-record on mic activity"),
            hint: tr(
              "Start recording automatically when a listed app uses the mic.",
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Material(
                color: SpeakrColors.surface,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: SpeakrColors.line),
                  borderRadius: SpeakrRadius.control,
                ),
                child: InkWell(
                  borderRadius: SpeakrRadius.control,
                  onTap: () => context.push('/settings/auto-record'),
                  child: Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tr("Configure…"),
                          style: SpeakrText.sans(
                            size: 12,
                            color: SpeakrColors.ink2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SpeakrIconView(
                          SpeakrIcon.chev,
                          size: 14,
                          color: SpeakrColors.ink2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (!kIsWeb && Platform.isWindows) const _AutoStartField(),
        const _AutoUploadField(),
      ],
    );
  }
}

class _AutoStartField extends ConsumerWidget {
  const _AutoStartField();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    final asyncEnabled = ref.watch(autoStartEnabledProvider);
    final service = ref.read(autoStartServiceProvider);
    return _Field(
      label: tr("Start with Windows"),
      hint: tr("Launches Mimio minimized to the tray when you sign in."),
      child: _Toggle(
        on: asyncEnabled.maybeWhen(data: (v) => v, orElse: () => false),
        onTap: asyncEnabled.hasValue
            ? () async {
                final current = asyncEnabled.value ?? false;
                try {
                  await service.setEnabled(!current);
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        tr("Could not update auto-start: {0}", [e]),
                      ),
                    ),
                  );
                } finally {
                  ref.invalidate(autoStartEnabledProvider);
                }
              }
            : null,
      ),
    );
  }
}

class _AutoUploadField extends StatelessWidget {
  const _AutoUploadField();
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    return _Field(
      label: tr("Auto-upload from folders"),
      hint: tr(
        "Watch device folders and upload new recordings as they appear.",
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: SpeakrColors.surface,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: SpeakrColors.line),
            borderRadius: SpeakrRadius.control,
          ),
          child: InkWell(
            borderRadius: SpeakrRadius.control,
            onTap: () => context.push('/settings/auto-upload'),
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tr("Configure…"),
                    style: SpeakrText.sans(size: 12, color: SpeakrColors.ink2),
                  ),
                  const SizedBox(width: 8),
                  SpeakrIconView(
                    SpeakrIcon.chev,
                    size: 14,
                    color: SpeakrColors.ink2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TranscriptionSection extends StatelessWidget {
  const _TranscriptionSection();
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHead(
          title: tr("Transcription"),
          sub: tr(
            "How Speakr turns audio into words. These settings live on the server — change them in the Speakr web admin.",
          ),
        ),
        _Field(
          label: tr("Model"),
          child: _DropdownStub(value: tr("Server default")),
        ),
        _Field(
          label: tr("Language"),
          child: _DropdownStub(value: tr("Auto-detect")),
        ),
        _Field(
          label: tr("Speaker diarization"),
          hint: tr("Separate voices into labeled speakers."),
          child: const _Toggle(on: true),
        ),
        _Field(
          label: tr("Filter filler words"),
          hint: tr("Remove 'um', 'uh', 'like' from the readable transcript."),
          child: const _Toggle(on: false),
        ),
      ],
    );
  }
}

class _AppearanceSection extends ConsumerWidget {
  const _AppearanceSection();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    final pref =
        ref.watch(timeFormatPreferenceProvider).asData?.value ??
        TimeFormatPreference.system;
    final controller = ref.read(timeFormatControllerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHead(title: tr("Appearance")),
        _Field(label: tr("Interface language"), child: const LanguagePicker()),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: AppearancePicker(),
        ),
        _Field(
          label: tr("Time format"),
          hint: tr("Affects timestamps, list dates and transcript markers."),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TimeChip(
                label: tr("Auto"),
                selected: pref == TimeFormatPreference.system,
                onTap: () => controller.set(TimeFormatPreference.system),
              ),
              const SizedBox(width: 6),
              _TimeChip(
                label: tr("12h"),
                selected: pref == TimeFormatPreference.twelveHour,
                onTap: () => controller.set(TimeFormatPreference.twelveHour),
              ),
              const SizedBox(width: 6),
              _TimeChip(
                label: tr("24h"),
                selected: pref == TimeFormatPreference.twentyFourHour,
                onTap: () =>
                    controller.set(TimeFormatPreference.twentyFourHour),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: selected ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? SpeakrColors.ink : Colors.transparent,
          border: Border.all(color: SpeakrColors.line),
          borderRadius: BorderRadius.circular(100),
        ),
        alignment: Alignment.center,
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

class _ShortcutsSection extends StatelessWidget {
  const _ShortcutsSection();

  static List<(String, String)> _buildRows() {
    final isMac = Platform.isMacOS;
    String combo(String key) => isMac ? '$modLabel $key' : '$modLabel$key';
    return [
      (tr("New recording"), combo('R')),
      (tr("Pause / resume"), combo('.')),
      (tr("Stop & save"), combo(returnKeyLabel)),
      (tr("Search library"), combo('K')),
      (tr("Open settings"), combo(',')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    if (!supportsKeyboardShortcuts) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHead(
          title: tr("Shortcuts"),
          sub: tr(
            "System-wide hotkeys live on the roadmap. Today's shortcuts are active only while Mimio is focused.",
          ),
        ),
        for (final (label, key) in _buildRows())
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: SpeakrColors.line)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: SpeakrText.sans(size: 13, color: SpeakrColors.ink),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: SpeakrColors.surface,
                    border: Border.all(color: SpeakrColors.line),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    key,
                    style: SpeakrText.mono(
                      size: 11,
                      color: SpeakrColors.ink2,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({
    required this.storageBytes,
    required this.recordingsCount,
    required this.onSignOut,
  });
  final int? storageBytes;
  final int? recordingsCount;
  final VoidCallback onSignOut;
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHead(title: tr("About")),
        _Field(
          label: tr("App version"),
          child: Consumer(
            builder: (context, ref, _) => _TextValue(
              text: ref
                  .watch(appVersionProvider)
                  .maybeWhen(data: (v) => v, orElse: () => '—'),
              mono: true,
            ),
          ),
        ),
        _Field(
          label: tr("Storage used"),
          child: _TextValue(
            text: tr("{0} · {1} recordings", [
              formatBytes(storageBytes),
              recordingsCount ?? '—',
            ]),
          ),
        ),
        const SizedBox(height: 30),
        TextButton(
          onPressed: onSignOut,
          style: TextButton.styleFrom(
            foregroundColor: SpeakrColors.danger,
            padding: EdgeInsets.zero,
          ),
          child: Text(
            tr("Sign out"),
            style: SpeakrText.sans(size: 13, color: SpeakrColors.danger),
          ),
        ),
      ],
    );
  }
}
