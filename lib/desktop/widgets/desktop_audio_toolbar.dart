import 'package:speakr_app/theme/appearance.dart';
import 'package:speakr_app/widgets/mimio_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/library/library_controller.dart';
import '../../features/live/live_controller.dart';
import '../../features/live/recording_state.dart';
import '../../l10n/strings.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// Shared recording controls. The meter shows the recorder's combined signal,
/// never invented per-source amplitudes. Opening this bar does not start capture.
class DesktopAudioToolbar extends ConsumerWidget {
  const DesktopAudioToolbar({
    super.key,
    this.leading,
    this.trailing,
    this.livePage = false,
    this.embedded = false,
  });
  final Widget? leading;
  final Widget? trailing;
  final bool livePage;
  final bool embedded;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    final state = ref.watch(recordingControllerProvider);
    final controller = ref.read(recordingControllerProvider.notifier);
    final folders = ref.watch(foldersProvider).value ?? [];
    final selected = folders.where((f) => f.id == state.folderId).firstOrNull;
    return Container(
      constraints: const BoxConstraints(minHeight: 68),
      padding: embedded
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: embedded
          ? null
          : BoxDecoration(
              border: Border(bottom: BorderSide(color: SpeakrColors.line)),
            ),
      child: LayoutBuilder(
        builder: (context, c) => Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 16)],
            Expanded(
              child: Wrap(
                spacing: 18,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (state.started || state.uploading)
                    AudioSessionReadout(state: state, showSources: false)
                  else if (c.maxWidth > 480)
                    Text(
                      tr('Ready to record'),
                      style: SpeakrText.sans(
                        size: 12,
                        color: SpeakrColors.muted,
                      ),
                    ),
                  if (c.maxWidth > 350)
                    Tooltip(
                      message: tr('Folder for the new recording'),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 190),
                        decoration: BoxDecoration(
                          color: SpeakrColors.surface,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: SpeakrColors.line),
                        ),
                        child: MimioMenuButton<int>(
                          enabled: !state.uploading,
                          tooltip: tr('Folder for the new recording'),
                          color: SpeakrColors.bgAlt,
                          onSelected: (id) =>
                              controller.setFolder(id == -1 ? null : id),
                          itemBuilder: (_) => [
                            MimioMenuItem(
                              value: -1,
                              selected: state.folderId == null,
                              label: tr('No folder'),
                              icon: Icons.folder_outlined,
                            ),
                            for (final f in folders)
                              MimioMenuItem(
                                value: f.id,
                                selected: f.id == state.folderId,
                                label: f.name,
                                icon: Icons.folder_outlined,
                                iconColor: parseHexColor(f.color),
                              ),
                          ],
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.folder_outlined,
                                  size: 16,
                                  color: selected == null
                                      ? SpeakrColors.muted
                                      : parseHexColor(selected.color),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    selected?.name ?? tr('No folder'),
                                    overflow: TextOverflow.ellipsis,
                                    style: SpeakrText.sans(
                                      size: 12,
                                      color: SpeakrColors.ink2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.expand_more,
                                  size: 15,
                                  color: SpeakrColors.muted,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (state.started && !state.uploading) ...[
              IconButton(
                tooltip: tr(state.paused ? 'Resume' : 'Pause'),
                onPressed: controller.togglePause,
                icon: Icon(
                  state.paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  size: 23,
                ),
              ),
              if (!livePage)
                TextButton(
                  onPressed: () => context.push('/live'),
                  child: Text(tr('Open recording')),
                ),
            ] else if (!livePage)
              TextButton.icon(
                onPressed: state.uploading ? null : () => context.push('/live'),
                icon: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: SpeakrColors.recordRed.withValues(alpha: .45),
                      width: 2,
                    ),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: SpeakrColors.recordRed,
                    ),
                  ),
                ),
                label: Text(
                  tr('New recording'),
                  style: SpeakrText.sans(size: 13, weight: FontWeight.w500),
                ),
              ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}

class AudioSessionReadout extends StatelessWidget {
  const AudioSessionReadout({
    super.key,
    required this.state,
    this.showSources = true,
  });
  final RecordingState state;
  final bool showSources;
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    final running = state.started && !state.paused && !state.uploading;
    final color = state.uploading
        ? SpeakrColors.tagDesign
        : state.started
        ? SpeakrColors.recordRed
        : SpeakrColors.muted;
    final label = state.uploading
        ? 'Uploading'
        : state.started
        ? (state.paused ? 'Paused' : 'Capture active')
        : 'Ready to record';
    final level = running && state.audioLevel.isFinite
        ? state.audioLevel.clamp(0.0, 1.0)
        : 0.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          tr(label),
          style: SpeakrText.sans(
            size: 12,
            color: color,
            weight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 15),
        Text(
          state.started || state.uploading ? state.formattedElapsed : '00:00',
          style: SpeakrText.mono(
            size: 13,
            color: state.started ? SpeakrColors.ink : SpeakrColors.muted,
          ),
        ),
        const SizedBox(width: 16),
        Semantics(
          label: tr('Combined input level'),
          value: '${(level * 100).round()}%',
          child: Tooltip(
            message: tr(
              state.started
                  ? 'Combined input level'
                  : 'Audio is not being captured',
            ),
            child: SizedBox(
              height: 24,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  16,
                  (i) => Container(
                    key: ValueKey('input-level-$i'),
                    width: 3,
                    height: 8 + i * .8,
                    margin: const EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: level > i / 16
                          ? (i > 12
                                ? SpeakrColors.tagDesign
                                : SpeakrColors.accent)
                          : SpeakrColors.line,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (showSources) ...[
          const SizedBox(width: 16),
          _source(
            Icons.mic_none_rounded,
            'Microphone',
            state.started && state.micEnabled,
          ),
          const SizedBox(width: 10),
          _source(
            Icons.volume_up_outlined,
            'System audio',
            state.started && state.systemEnabled,
          ),
        ],
      ],
    );
  }

  Widget _source(IconData icon, String name, bool active) => Tooltip(
    message: '${tr(name)} · ${tr(active ? 'On' : 'Off')}',
    child: Icon(
      icon,
      size: 17,
      color: active ? SpeakrColors.accent : SpeakrColors.muted,
    ),
  );
}
