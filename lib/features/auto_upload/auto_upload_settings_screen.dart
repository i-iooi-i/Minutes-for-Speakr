import 'package:speakr_app/l10n/strings.dart';

import 'dart:async';
import 'dart:io' show Platform;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speakr_saf/speakr_saf.dart';

import '../../services/preferences/time_format_preference.dart';
import '../../services/preferences/time_format_providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../utils/formatters.dart';
import '../../widgets/mono_eyebrow.dart';
import '../../widgets/settings_row.dart';
import '../../widgets/speakr_icons.dart';
import '../library/library_controller.dart';
import 'auto_upload_controller.dart';
import 'auto_upload_settings.dart';
import 'auto_upload_worker.dart';
import 'datetime_parser.dart';

// ── List screen ───────────────────────────────────────────────────────────────

class AutoUploadSettingsScreen extends ConsumerStatefulWidget {
  const AutoUploadSettingsScreen({super.key});

  @override
  ConsumerState<AutoUploadSettingsScreen> createState() =>
      _AutoUploadSettingsScreenState();
}

class _AutoUploadSettingsScreenState
    extends ConsumerState<AutoUploadSettingsScreen> {
  bool _scanning = false;
  Timer? _diagnosticsRefreshTimer;

  @override
  void initState() {
    super.initState();
    // The Android PhoneStateReceiver writes breadcrumbs to the same
    // SharedPreferences file as the Dart store, but the Flutter plugin
    // caches values in this isolate's memory and won't pick up cross-
    // isolate writes until reload() is called. Poll the file every 2s
    // while the screen is mounted so the diagnostic rows update live.
    _diagnosticsRefreshTimer = Timer.periodic(const Duration(seconds: 2), (
      _,
    ) async {
      final store = await ref.read(autoUploadStoreProvider.future);
      await store.reload();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _diagnosticsRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _addFolder() async {
    final controller = ref.read(folderConfigsControllerProvider);
    final FolderUploadConfig entry;
    if (Platform.isAndroid) {
      // Storage Access Framework: the picker result is a persisted tree
      // grant, which is what the worker enumerates and deletes through.
      final tree = await SpeakrSaf.pickTree();
      if (tree == null) return;
      entry = await controller.addFolder(null, tree: tree);
    } else {
      final picked = await FilePicker.getDirectoryPath();
      if (picked == null || picked.isEmpty) return;
      entry = await controller.addFolder(picked);
    }
    if (!mounted) return;
    _openEditor(entry.id);
  }

  void _openEditor(String configId) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => FolderUploadEditScreen(configId: configId),
      ),
    );
  }

  Future<void> _scanNow() async {
    setState(() => _scanning = true);
    try {
      await runAutoUploadScan(trigger: 'manual');
      ref.invalidate(folderConfigsProvider);
      ref.invalidate(pendingFilesProvider);
      ref.invalidate(pendingFileErrorsProvider);
      ref.read(uploadKickProvider.notifier).state++;
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final configsAsync = ref.watch(folderConfigsProvider);
    return Scaffold(
      backgroundColor: SpeakrColors.bg,
      body: SafeArea(
        child: configsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: SpeakrColors.ink),
          ),
          error: (e, _) =>
              Center(child: Text(tr("Could not load settings: {0}", [e]))),
          data: (configs) {
            final canScan = configs.any((c) => c.enabled && c.hasFolder);
            return ListView(
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
                        child: MonoEyebrow(tr("Auto-upload"), size: 10),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr("Auto-upload from folders"),
                        style: SpeakrText.serif(size: 28, height: 1.1),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tr(
                          "Watch one or more folders for new audio recordings and upload them to Speakr. Each folder has its own tag, language, and parsing rules. Files are deleted locally once they reach the server.",
                        ),
                        style: SpeakrText.sans(
                          size: 13,
                          color: SpeakrColors.ink2,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                if (Platform.isAndroid) const _PermissionsBanner(),
                SettingsGroup(
                  label: tr("Folders"),
                  children: [
                    for (final c in configs) _FolderListRow(c, _openEditor),
                    SettingsRow(
                      label: tr("Add folder…"),
                      trailing: const Icon(
                        Icons.add,
                        size: 20,
                        color: SpeakrColors.ink,
                      ),
                      onTap: _addFolder,
                    ),
                  ],
                ),
                SettingsGroup(
                  label: tr("Run"),
                  children: [
                    SettingsRow(
                      label: _scanning ? tr("Scanning…") : tr("Scan now"),
                      trailing: _scanning
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: SpeakrColors.ink,
                              ),
                            )
                          : Icon(
                              Icons.play_arrow_rounded,
                              size: 22,
                              color: canScan
                                  ? SpeakrColors.ink
                                  : SpeakrColors.muted,
                            ),
                      onTap: (canScan && !_scanning) ? _scanNow : null,
                    ),
                    _LastScanRow(),
                  ],
                ),
                if (Platform.isAndroid)
                  SettingsGroup(
                    label: tr("Call-end diagnostics"),
                    children: const [
                      _LastPhoneStateRow(),
                      _LastPhoneStateDecisionRow(),
                      _LastCallEndEnqueueRow(),
                    ],
                  ),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }
}

String _folderLabel(FolderUploadConfig c) {
  if (!c.hasFolder) return tr("New folder (no path set)");
  final path = c.folderPath ?? c.treeUri!;
  final parts = path.split(RegExp(r'[\\/]'));
  final last = parts.where((s) => s.isNotEmpty).toList();
  return last.isEmpty ? path : last.last;
}

/// One watched folder in the list. On Android the trailing value flips to
/// "Needs access" when the entry has no usable tree grant (legacy raw
/// path, or a grant the user revoked) so the problem is visible before
/// the user wonders why nothing uploads.
class _FolderListRow extends ConsumerWidget {
  const _FolderListRow(this.config, this.onOpen);
  final FolderUploadConfig config;
  final void Function(String id) onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    final access =
        !config.hasFolder ||
        (ref.watch(folderAccessProvider(config.treeUri)).asData?.value ?? true);
    final String value;
    final Color color;
    if (!access) {
      value = tr("Needs access");
      color = SpeakrColors.danger;
    } else if (config.enabled) {
      value = tr("On");
      color = SpeakrColors.ok;
    } else {
      value = tr("Off");
      color = SpeakrColors.muted;
    }
    return SettingsRow(
      label: _folderLabel(config),
      subtitle: config.folderPath,
      value: value,
      valueColor: color,
      mono: false,
      onTap: () => onOpen(config.id),
    );
  }
}

// ── Editor screen ─────────────────────────────────────────────────────────────

class FolderUploadEditScreen extends ConsumerStatefulWidget {
  const FolderUploadEditScreen({super.key, required this.configId});
  final String configId;

  @override
  ConsumerState<FolderUploadEditScreen> createState() =>
      _FolderUploadEditScreenState();
}

class _FolderUploadEditScreenState
    extends ConsumerState<FolderUploadEditScreen> {
  Future<void> _pickFolder({FolderUploadConfig? current}) async {
    final controller = ref.read(folderConfigsControllerProvider);
    if (Platform.isAndroid) {
      final tree = await SpeakrSaf.pickTree(initialUri: current?.treeUri);
      if (tree == null) return;
      await controller.setFolderTree(widget.configId, tree);
      return;
    }
    final picked = await FilePicker.getDirectoryPath();
    if (picked == null || picked.isEmpty) return;
    await controller.setFolder(widget.configId, picked);
  }

  Future<void> _typeFolder(FolderUploadConfig current) async {
    final ctrl = TextEditingController(text: current.folderPath ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: SpeakrColors.bg,
        title: Text(tr("Folder path"), style: SpeakrText.serif(size: 20)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: SpeakrText.mono(size: 13, color: SpeakrColors.ink),
          decoration: const InputDecoration(
            hintText: r'C:\Users\you\Recordings',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr("Cancel")),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: Text(tr("Save")),
          ),
        ],
      ),
    );
    if (result == null) return;
    await ref
        .read(folderConfigsControllerProvider)
        .setFolder(widget.configId, result.isEmpty ? null : result);
  }

  Future<void> _confirmDelete(FolderUploadConfig config) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: SpeakrColors.bg,
        title: Text(tr("Delete folder?"), style: SpeakrText.serif(size: 20)),
        content: Text(
          tr(
            "Stop watching this folder. Files already on disk are not touched. You can re-add the folder later.",
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
            child: Text(tr("Delete")),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(folderConfigsControllerProvider).removeFolder(config.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final configsAsync = ref.watch(folderConfigsProvider);
    return Scaffold(
      backgroundColor: SpeakrColors.bg,
      body: SafeArea(
        child: configsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: SpeakrColors.ink),
          ),
          error: (e, _) =>
              Center(child: Text(tr("Could not load settings: {0}", [e]))),
          data: (configs) {
            FolderUploadConfig? c;
            for (final entry in configs) {
              if (entry.id == widget.configId) {
                c = entry;
                break;
              }
            }
            if (c == null) {
              return const _MissingConfigView();
            }
            final config = c;
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    children: [
                      GhostIconButton(
                        icon: SpeakrIcon.back,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: MonoEyebrow(tr("Folder"), size: 10),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.hasFolder
                            ? config.folderPath!
                                  .split(RegExp(r'[\\/]'))
                                  .where((s) => s.isNotEmpty)
                                  .last
                            : tr("New folder"),
                        style: SpeakrText.serif(size: 24, height: 1.1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (config.folderPath != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          config.folderPath!,
                          style: SpeakrText.mono(
                            size: 12,
                            color: SpeakrColors.muted,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (Platform.isAndroid) ...[
                  const _PermissionsBanner(),
                  _FolderAccessBanner(
                    config: config,
                    onReselect: () => _pickFolder(current: config),
                  ),
                ],
                SettingsGroup(
                  label: tr("Watcher"),
                  children: [
                    SettingsRow(
                      label: tr("Enabled"),
                      toggleValue: config.enabled,
                      onToggle: (v) => ref
                          .read(folderConfigsControllerProvider)
                          .setEnabled(config.id, v),
                    ),
                    SettingsRow(
                      label: tr("Folder"),
                      value: config.folderPath == null
                          ? tr("Not set")
                          : config.folderPath!.split(RegExp(r'[\\/]')).last,
                      subtitle: config.folderPath,
                      mono: false,
                      onTap: () => _pickFolder(current: config),
                    ),
                    // A typed path has no Storage Access Framework grant
                    // behind it, so this only exists off Android.
                    if (!Platform.isAndroid)
                      SettingsRow(
                        label: tr("Type folder path manually"),
                        trailing: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: SpeakrColors.muted,
                        ),
                        onTap: () => _typeFolder(config),
                      ),
                  ],
                ),
                SettingsGroup(
                  label: tr("Datetime parsing"),
                  children: [
                    SettingsRow(
                      label: tr("Pattern"),
                      value: _parseLabel(config),
                      onTap: () => _showPresetSheet(config),
                    ),
                  ],
                ),
                SettingsGroup(
                  label: tr("Defaults applied to uploads"),
                  children: [
                    SettingsRow(
                      label: tr("Tag"),
                      value: _TagLabel.of(ref, config.tagId),
                      onTap: () => _showTagSheet(config),
                    ),
                    SettingsRow(
                      label: tr("Folder"),
                      value: _FolderLabel.of(ref, config.folderId),
                      onTap: () => _showFolderSheet(config),
                    ),
                    SettingsRow(
                      label: tr("Language"),
                      value: config.language ?? 'auto',
                      onTap: () => _editLanguage(config),
                    ),
                    SettingsRow(
                      label: tr("Min speakers"),
                      trailing: _Stepper(
                        value: config.minSpeakers ?? 1,
                        min: 1,
                        max: 12,
                        onChanged: (v) => ref
                            .read(folderConfigsControllerProvider)
                            .setMinSpeakers(config.id, v),
                      ),
                    ),
                    SettingsRow(
                      label: tr("Max speakers"),
                      trailing: _Stepper(
                        value: config.maxSpeakers ?? 1,
                        min: 1,
                        max: 12,
                        onChanged: (v) => ref
                            .read(folderConfigsControllerProvider)
                            .setMaxSpeakers(config.id, v),
                      ),
                    ),
                  ],
                ),
                SettingsGroup(
                  label: tr("Filtering"),
                  children: [
                    SettingsRow(
                      label: tr("Auto-delete shorter than"),
                      value: config.autoDeleteShorterThanSeconds == null
                          ? tr("Off")
                          : tr("{0} s", [config.autoDeleteShorterThanSeconds]),
                      subtitle: tr(
                        "Recordings under this length are deleted from disk instead of being uploaded.",
                      ),
                      onTap: () => _editAutoDeleteThreshold(config),
                    ),
                  ],
                ),
                SettingsGroup(
                  label: tr("Danger zone"),
                  children: [
                    SettingsRow(
                      label: tr("Delete folder"),
                      valueColor: SpeakrColors.danger,
                      trailing: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: SpeakrColors.danger,
                      ),
                      onTap: () => _confirmDelete(config),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }

  String _parseLabel(FolderUploadConfig s) {
    if (s.parsePresetId == null) return tr("Off (use file mtime)");
    if (s.parsePresetId == kCustomPresetId) return tr("Custom regex");
    return tr(presetById(s.parsePresetId!)?.label ?? "Off (use file mtime)");
  }

  Future<void> _editLanguage(FolderUploadConfig s) async {
    final ctrl = TextEditingController(text: s.language ?? '');
    final result = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: SpeakrColors.bg,
        title: Text(tr("Language"), style: SpeakrText.serif(size: 20)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(hintText: tr("auto, en, da, …")),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr("Cancel")),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: Text(tr("Save")),
          ),
        ],
      ),
    );
    if (result == null) return;
    await ref
        .read(folderConfigsControllerProvider)
        .setLanguage(s.id, result.isEmpty ? null : result);
  }

  Future<void> _editAutoDeleteThreshold(FolderUploadConfig s) async {
    final ctrl = TextEditingController(
      text: s.autoDeleteShorterThanSeconds?.toString() ?? '',
    );

    // Three-way result: 'save' with new value (or null = Off), or null = cancel.
    final result = await showDialog<int?>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: SpeakrColors.bg,
        title: Text(
          tr("Auto-delete shorter than"),
          style: SpeakrText.serif(size: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr(
                "Recordings under this many seconds are deleted from disk instead of being uploaded. Leave blank or set 0 to disable.",
              ),
              style: SpeakrText.sans(
                size: 12,
                color: SpeakrColors.ink2,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(),
              decoration: InputDecoration(
                hintText: tr("e.g. 5"),
                suffixText: tr("seconds"),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(tr("Cancel")),
          ),
          TextButton(
            onPressed: () => Navigator.pop<int?>(dialogCtx, 0),
            child: Text(tr("Off")),
          ),
          TextButton(
            onPressed: () {
              final n = int.tryParse(ctrl.text.trim());
              if (n == null) {
                Navigator.pop<int?>(dialogCtx, 0);
              } else {
                Navigator.pop<int?>(dialogCtx, n);
              }
            },
            child: Text(tr("Save")),
          ),
        ],
      ),
    );
    if (result == null) return; // cancelled
    final value = result <= 0 ? null : result;
    await ref
        .read(folderConfigsControllerProvider)
        .setAutoDeleteShorterThanSeconds(s.id, value);
  }

  Future<void> _showPresetSheet(FolderUploadConfig s) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: SpeakrColors.bg,
      isScrollControlled: true,
      builder: (_) => _PresetSheet(current: s),
    );
  }

  Future<void> _showTagSheet(FolderUploadConfig s) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: SpeakrColors.bg,
      isScrollControlled: true,
      builder: (_) => _TagSheet(configId: s.id, currentId: s.tagId),
    );
  }

  Future<void> _showFolderSheet(FolderUploadConfig s) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: SpeakrColors.bg,
      isScrollControlled: true,
      builder: (_) => _FolderSheet(configId: s.id, currentId: s.folderId),
    );
  }
}

class _MissingConfigView extends StatelessWidget {
  const _MissingConfigView();

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GhostIconButton(
                icon: SpeakrIcon.back,
                onTap: () => Navigator.of(context).pop(),
              ),
              Padding(
                padding: EdgeInsets.only(left: 4),
                child: MonoEyebrow(tr("Folder"), size: 10),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 18),
            child: Text(
              tr("This folder no longer exists."),
              style: SpeakrText.serif(size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Permissions banner ────────────────────────────────────────────────────────

class _PermissionsBanner extends StatefulWidget {
  const _PermissionsBanner();

  @override
  State<_PermissionsBanner> createState() => _PermissionsBannerState();
}

class _PermissionsBannerState extends State<_PermissionsBanner> {
  List<Permission> _missing = const [];
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    // Permission.audio (READ_MEDIA_AUDIO) is deliberately absent: on
    // Android the watched folder is read through a persisted Storage
    // Access Framework tree grant, which needs no storage permission, and
    // the manifest no longer declares one. Asking for an undeclared
    // permission returns permanentlyDenied, so the banner would never
    // clear.
    final wanted = <Permission>[Permission.phone, Permission.notification];
    final missing = <Permission>[];
    for (final p in wanted) {
      final status = await p.status;
      if (!status.isGranted) missing.add(p);
    }
    if (mounted) {
      setState(() {
        _missing = missing;
        _checked = true;
      });
    }
  }

  Future<void> _grant() async {
    await _missing.request();
    await _check();
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    if (!_checked || _missing.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 4, 24, 14),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E0),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE8C97A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr("Permissions needed"),
            style: SpeakrText.sans(
              size: 13,
              weight: FontWeight.w600,
              color: SpeakrColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _description(_missing),
            style: SpeakrText.sans(
              size: 12,
              color: SpeakrColors.ink2,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _grant,
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: Text(tr("Grant permissions")),
            ),
          ),
        ],
      ),
    );
  }

  String _description(List<Permission> missing) {
    final parts = <String>[];
    if (missing.contains(Permission.phone)) {
      parts.add(tr("Phone state — to detect when calls end."));
    }
    if (missing.contains(Permission.notification)) {
      parts.add(tr("Notifications — required for background uploads."));
    }
    return parts.join(' ');
  }
}

// ── Folder access banner ──────────────────────────────────────────────────────

/// Android only. Shown on the folder editor when the entry has no usable
/// Storage Access Framework grant: either it predates the migration and
/// still carries only a raw path, or the user revoked the grant (Settings
/// > Apps, or a clear-data). Re-selecting the folder re-takes the grant and
/// migrates the per-file bookkeeping.
class _FolderAccessBanner extends ConsumerWidget {
  const _FolderAccessBanner({required this.config, required this.onReselect});
  final FolderUploadConfig config;
  final VoidCallback onReselect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    if (!config.hasFolder) return const SizedBox.shrink();
    final access = ref.watch(folderAccessProvider(config.treeUri));
    if (access.asData?.value != false) return const SizedBox.shrink();
    final legacy = config.treeUri == null;
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 4, 24, 14),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E0),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE8C97A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr("Folder access needed"),
            style: SpeakrText.sans(
              size: 13,
              weight: FontWeight.w600,
              color: SpeakrColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            legacy
                ? tr(
                    "Minutes now reads this folder through Android's folder picker instead of \"All files access\". Re-select the folder once to keep auto-upload running; your upload history is kept.",
                  )
                : tr(
                    "Minutes no longer has permission to read this folder. Re-select it to grant access again.",
                  ),
            style: SpeakrText.sans(
              size: 12,
              color: SpeakrColors.ink2,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onReselect,
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: Text(tr("Re-select folder")),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stepper ───────────────────────────────────────────────────────────────────

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 12,
  });
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepperBtn(
          label: '−',
          onTap: value > min ? () => onChanged(value - 1) : null,
        ),
        SizedBox(
          width: 30,
          child: Text(
            value.toString(),
            textAlign: TextAlign.center,
            style: SpeakrText.serif(size: 16),
          ),
        ),
        _StepperBtn(
          label: '+',
          onTap: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}

class _StepperBtn extends StatelessWidget {
  const _StepperBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: SpeakrColors.line),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: SpeakrText.serif(
            size: 16,
            color: onTap == null ? SpeakrColors.muted : SpeakrColors.ink,
            height: 1,
          ),
        ),
      ),
    );
  }
}

// ── Last scan row ─────────────────────────────────────────────────────────────

class _LastScanRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    final storeAsync = ref.watch(autoUploadStoreProvider);
    final pref =
        ref.watch(timeFormatPreferenceProvider).asData?.value ??
        TimeFormatPreference.system;
    final use24 = resolveUse24Hour(pref, context);
    return storeAsync.maybeWhen(
      data: (store) {
        final at = store.lastScanAt;
        final result = store.lastScanResult;
        // Timestamp goes in `value` (single-line, right-aligned). The
        // trigger/result summary goes in `subtitle` so it can wrap onto
        // multiple lines instead of being clipped with an ellipsis —
        // useful both for normal info ("trigger=… ok=… skipped=…") and
        // for diagnosing why a scan didn't behave as expected.
        return SettingsRow(
          label: tr("Last scan"),
          value: at == null ? '—' : formatHourMinute(at, use24Hour: use24),
          subtitle: result,
        );
      },
      orElse: () => SettingsRow(label: tr("Last scan"), value: '—'),
    );
  }
}

// ── Call-end diagnostic rows ──────────────────────────────────────────────────
//
// These three rows surface breadcrumbs the Android PhoneStateReceiver
// writes on every PHONE_STATE broadcast. They tell us, in order, whether:
//   1. the receiver is firing at all (Last phone-state event),
//   2. the OFFHOOK→IDLE state machine reached the enqueue branch (Last
//      decision),
//   3. WorkManager actually accepted the call-end job (Last call-end
//      enqueue) — compare against "Last scan" above to tell whether the
//      job ran or got deferred by Doze/battery optimization.

class _LastPhoneStateRow extends ConsumerWidget {
  const _LastPhoneStateRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    final storeAsync = ref.watch(autoUploadStoreProvider);
    final pref =
        ref.watch(timeFormatPreferenceProvider).asData?.value ??
        TimeFormatPreference.system;
    final use24 = resolveUse24Hour(pref, context);
    return storeAsync.maybeWhen(
      data: (store) {
        final at = store.lastPhoneStateAt;
        final state = store.lastPhoneState;
        final prev = store.lastPhoneStatePrevious;
        final subtitle = at == null
            ? tr(
                "never — receiver hasn't fired since install. READ_PHONE_STATE may be denied, or the OEM is suppressing manifest receivers (check OnePlus auto-launch / battery).",
              )
            : tr("state={0} · prev={1}", [state ?? '—', prev ?? '—']);
        return SettingsRow(
          label: tr("Last phone-state event"),
          value: at == null ? '—' : formatHourMinute(at, use24Hour: use24),
          subtitle: subtitle,
        );
      },
      orElse: () =>
          SettingsRow(label: tr("Last phone-state event"), value: '—'),
    );
  }
}

class _LastPhoneStateDecisionRow extends ConsumerWidget {
  const _LastPhoneStateDecisionRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    final storeAsync = ref.watch(autoUploadStoreProvider);
    return storeAsync.maybeWhen(
      data: (store) {
        final decision = store.lastPhoneStateDecision;
        return SettingsRow(
          label: tr("Last decision"),
          value: decision == null ? '—' : '',
          subtitle: decision,
        );
      },
      orElse: () => SettingsRow(label: tr("Last decision"), value: '—'),
    );
  }
}

class _LastCallEndEnqueueRow extends ConsumerWidget {
  const _LastCallEndEnqueueRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    final storeAsync = ref.watch(autoUploadStoreProvider);
    final pref =
        ref.watch(timeFormatPreferenceProvider).asData?.value ??
        TimeFormatPreference.system;
    final use24 = resolveUse24Hour(pref, context);
    return storeAsync.maybeWhen(
      data: (store) {
        final at = store.lastCallEndEnqueueAt;
        return SettingsRow(
          label: tr("Last call-end enqueue"),
          value: at == null
              ? tr("never")
              : formatHourMinute(at, use24Hour: use24),
          subtitle: at == null
              ? tr(
                  "No OFFHOOK→IDLE transition has reached the enqueue branch since install. If \"Last phone-state event\" shows IDLE with prev=null, the app process was killed between OFFHOOK and IDLE.",
                )
              : null,
        );
      },
      orElse: () => SettingsRow(label: tr("Last call-end enqueue"), value: '—'),
    );
  }
}

// ── Preset sheet ──────────────────────────────────────────────────────────────

class _PresetSheet extends ConsumerStatefulWidget {
  const _PresetSheet({required this.current});
  final FolderUploadConfig current;

  @override
  ConsumerState<_PresetSheet> createState() => _PresetSheetState();
}

class _PresetSheetState extends ConsumerState<_PresetSheet> {
  late String? _selected = widget.current.parsePresetId;
  late final _regex = TextEditingController(
    text: widget.current.customRegex ?? '',
  );
  late final _group = TextEditingController(
    text: (widget.current.customCaptureGroup ?? 1).toString(),
  );
  late final _format = TextEditingController(
    text: widget.current.customFormat ?? '',
  );
  String? _customError;

  @override
  void dispose() {
    _regex.dispose();
    _group.dispose();
    _format.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ctrl = ref.read(folderConfigsControllerProvider);
    final id = widget.current.id;
    if (_selected == null) {
      await ctrl.setPreset(id, null);
    } else if (_selected == kCustomPresetId) {
      final regex = _regex.text.trim();
      final groupStr = _group.text.trim();
      final format = _format.text.trim();
      if (regex.isEmpty || format.isEmpty) {
        setState(() => _customError = tr("Regex and format are required."));
        return;
      }
      final group = int.tryParse(groupStr);
      if (group == null || group < 1) {
        setState(
          () => _customError = tr("Capture group must be a positive integer."),
        );
        return;
      }
      try {
        RegExp(regex);
      } catch (_) {
        setState(() => _customError = tr("Invalid regex syntax."));
        return;
      }
      await ctrl.setCustomParse(
        id: id,
        regex: regex,
        captureGroup: group,
        format: format,
      );
    } else {
      await ctrl.setPreset(id, _selected);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                tr("Datetime pattern"),
                style: SpeakrText.serif(size: 22),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                tr(
                  "Parse the recording datetime out of the filename. Falls back to file modification time if the pattern doesn't match.",
                ),
                style: SpeakrText.sans(
                  size: 12,
                  color: SpeakrColors.ink2,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _PresetTile(
              label: tr("Off — use file modification time"),
              selected: _selected == null,
              onTap: () => setState(() => _selected = null),
            ),
            for (final p in kDateTimePresets)
              _PresetTile(
                label: tr(p.label),
                selected: _selected == p.id,
                onTap: () => setState(() => _selected = p.id),
              ),
            _PresetTile(
              label: tr("Custom regex…"),
              selected: _selected == kCustomPresetId,
              onTap: () => setState(() => _selected = kCustomPresetId),
            ),
            if (_selected == kCustomPresetId) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CustomField(label: tr("Regex"), controller: _regex),
                    const SizedBox(height: 10),
                    _CustomField(
                      label: tr("Capture group (1-based)"),
                      controller: _group,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    _CustomField(
                      label: tr("DateFormat pattern"),
                      controller: _format,
                      hint: 'yyyy-MM-dd HH-mm-ss',
                    ),
                    if (_customError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _customError!,
                        style: SpeakrText.sans(
                          size: 12,
                          color: SpeakrColors.danger,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(tr("Cancel")),
                  ),
                  const Spacer(),
                  FilledButton(onPressed: _save, child: Text(tr("Save"))),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _PresetTile extends StatelessWidget {
  const _PresetTile({
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
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: SpeakrColors.line)),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? SpeakrColors.ink : SpeakrColors.line,
                  width: selected ? 6 : 1,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: SpeakrText.sans(size: 14))),
          ],
        ),
      ),
    );
  }
}

class _CustomField extends StatelessWidget {
  const _CustomField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.hint,
  });
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: SpeakrText.sans(size: 12, color: SpeakrColors.muted),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: SpeakrText.mono(size: 13, color: SpeakrColors.ink),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

// ── Tag sheet ─────────────────────────────────────────────────────────────────

class _TagLabel {
  static String of(WidgetRef ref, int? tagId) {
    if (tagId == null) return tr("None");
    final tagsAsync = ref.read(tagsProvider);
    final tags = tagsAsync.value;
    if (tags == null) return tr("Tag #{0}", [tagId]);
    for (final t in tags) {
      if (t.id == tagId) return t.name;
    }
    return tr("Tag #{0}", [tagId]);
  }
}

class _TagSheet extends ConsumerWidget {
  const _TagSheet({required this.configId, required this.currentId});
  final String configId;
  final int? currentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    final tagsAsync = ref.watch(tagsProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(tr("Default tag"), style: SpeakrText.serif(size: 22)),
          ),
          const SizedBox(height: 12),
          tagsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(color: SpeakrColors.ink),
              ),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                tr("Could not load tags: {0}", [e]),
                style: SpeakrText.sans(size: 13),
              ),
            ),
            data: (tags) => Column(
              children: [
                _TagOption(
                  label: tr("None"),
                  selected: currentId == null,
                  onTap: () async {
                    await ref
                        .read(folderConfigsControllerProvider)
                        .setTagId(configId, null);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                for (final t in tags)
                  _TagOption(
                    label: t.name,
                    color: parseHexColor(t.color),
                    selected: currentId == t.id,
                    onTap: () async {
                      await ref
                          .read(folderConfigsControllerProvider)
                          .setTagId(configId, t.id);
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Folder sheet ──────────────────────────────────────────────────────────────

class _FolderLabel {
  static String of(WidgetRef ref, int? folderId) {
    if (folderId == null) return tr("None");
    final foldersAsync = ref.read(foldersProvider);
    final folders = foldersAsync.value;
    if (folders == null) return tr("Folder #{0}", [folderId]);
    for (final f in folders) {
      if (f.id == folderId) return f.name;
    }
    return tr("Folder #{0}", [folderId]);
  }
}

class _FolderSheet extends ConsumerWidget {
  const _FolderSheet({required this.configId, required this.currentId});
  final String configId;
  final int? currentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    final foldersAsync = ref.watch(foldersProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              tr("Default folder"),
              style: SpeakrText.serif(size: 22),
            ),
          ),
          const SizedBox(height: 12),
          foldersAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(color: SpeakrColors.ink),
              ),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                tr("Could not load folders: {0}", [e]),
                style: SpeakrText.sans(size: 13),
              ),
            ),
            data: (folders) => Column(
              children: [
                _TagOption(
                  label: tr("None"),
                  selected: currentId == null,
                  onTap: () async {
                    await ref
                        .read(folderConfigsControllerProvider)
                        .setFolderId(configId, null);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                for (final f in folders)
                  _TagOption(
                    label: f.name,
                    color: parseHexColor(f.color),
                    selected: currentId == f.id,
                    onTap: () async {
                      await ref
                          .read(folderConfigsControllerProvider)
                          .setFolderId(configId, f.id);
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TagOption extends StatelessWidget {
  const _TagOption({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: SpeakrColors.line)),
        ),
        child: Row(
          children: [
            if (color != null) ...[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(label, style: SpeakrText.sans(size: 14))),
            if (selected)
              const Icon(Icons.check, size: 18, color: SpeakrColors.ink),
          ],
        ),
      ),
    );
  }
}
