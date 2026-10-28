import 'package:speakr_app/l10n/strings.dart';
import 'package:flutter/material.dart';

import '../../../api/models.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';
import '../../../widgets/folder_chip.dart';
import '../../../widgets/mono_eyebrow.dart';
import '../../../widgets/speakr_icons.dart';
import '../../../widgets/tag_chip.dart';
import '../recording_state.dart' show SystemAudioMode;

class LiveIndicator extends StatefulWidget {
  const LiveIndicator({super.key, required this.paused});
  final bool paused;
  @override
  State<LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<LiveIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat(reverse: true);
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.paused
              ? const _Dot()
              : FadeTransition(
                  opacity: Tween(begin: 1.0, end: 0.3).animate(_ctrl),
                  child: const _Dot(),
                ),
          const SizedBox(width: 8),
          Text(
            widget.paused ? tr("PAUSED") : tr("LIVE"),
            style: SpeakrText.mono(
              size: 11,
              color: SpeakrColors.recordingDot,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) => Container(
    width: 8,
    height: 8,
    decoration: const BoxDecoration(
      color: SpeakrColors.recordingDot,
      shape: BoxShape.circle,
    ),
  );
}

/// Single calm dot that breathes with the captured audio level. Floor
/// is 0.18 (per design) so the dot never collapses to nothing while
/// active. When paused or before recording starts, the dot/mid ring
/// soften to the line colour and the caption flips to "NO SIGNAL".
class BreathingDot extends StatelessWidget {
  const BreathingDot({
    super.key,
    required this.paused,
    required this.level,
    this.compact = false,
  });
  final bool paused;
  final double level;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final clamped = paused
        ? 0.05
        : (level.isFinite ? level.clamp(0.18, 1.0) : 0.18);
    final scale = compact ? 0.75 : 1.0;
    final coreSize = (28.0 + clamped * 36.0) * scale; // 28→64 px, scaled
    final ringSize = coreSize + 26.0 * scale;
    final outerSize = 110.0 * scale;
    final frameSize = 120.0 * scale;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          SizedBox(
            width: frameSize,
            height: frameSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Static outer ring — fixed max bound.
                Container(
                  width: outerSize,
                  height: outerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: SpeakrColors.line),
                  ),
                ),
                // Mid breathing ring — tracks the level, ink-tinted while
                // recording and line-tinted while paused.
                AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.linear,
                  width: ringSize,
                  height: ringSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: (paused ? SpeakrColors.line : SpeakrColors.ink)
                          .withValues(alpha: paused ? 0.25 : 0.18),
                    ),
                  ),
                ),
                // Core dot.
                AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.linear,
                  width: coreSize,
                  height: coreSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: paused ? SpeakrColors.line : SpeakrColors.ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            paused ? tr("NO SIGNAL") : tr("AUDIO LEVEL"),
            style: SpeakrText.mono(
              size: 10,
              color: SpeakrColors.muted,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class RecordingTimer extends StatelessWidget {
  const RecordingTimer({super.key, required this.text, this.compact = false});
  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Column(
      children: [
        Text(
          text,
          style: SpeakrText.serif(
            size: compact ? 36 : 56,
            weight: FontWeight.w300,
            height: 1,
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: compact ? 6 : 10),
        MonoEyebrow(
          tr("New recording · {0}", [_today()]),
          size: compact ? 9 : 11,
        ),
      ],
    );
  }

  static String _today() {
    final d = DateTime.now();
    final months = [
      tr("Jan"),
      tr("Feb"),
      tr("Mar"),
      tr("Apr"),
      tr("May"),
      tr("Jun"),
      tr("Jul"),
      tr("Aug"),
      tr("Sep"),
      tr("Oct"),
      tr("Nov"),
      tr("Dec"),
    ];
    return '${months[d.month - 1]} ${d.day}';
  }
}

class MetadataCard extends StatelessWidget {
  const MetadataCard({
    super.key,
    required this.speakers,
    required this.onSpeakersChanged,
    required this.activeTags,
    required this.tagPickerOpen,
    required this.onToggleTag,
    required this.onToggleEdit,
    required this.micEnabled,
    required this.systemMode,
    required this.systemAudioSupported,
    required this.processLoopbackSupported,
    required this.micPending,
    required this.systemPending,
    required this.onMicChanged,
    required this.onSystemModeChanged,
    this.processSourceName,
    this.processSourcePid,
    this.tags = const <Tag>[],
    this.folders = const <Folder>[],
    this.folderId,
    this.folderPickerOpen = false,
    this.onToggleFolderEdit,
    this.onFolderChanged,
    this.compact = false,
  });
  final int speakers;
  final ValueChanged<int> onSpeakersChanged;
  final List<String> activeTags;
  final bool tagPickerOpen;
  final ValueChanged<String> onToggleTag;
  final VoidCallback onToggleEdit;
  final bool micEnabled;
  final SystemAudioMode systemMode;
  final bool systemAudioSupported;
  final bool processLoopbackSupported;
  final bool micPending;
  final bool systemPending;
  final ValueChanged<bool> onMicChanged;
  final ValueChanged<SystemAudioMode> onSystemModeChanged;

  /// When non-null, the System-audio pill *subtitle* mentions this name
  /// (the trigger process). The third "this app" segment additionally
  /// requires [processSourcePid] — without a captured PID the controller
  /// can't honor a switch to processOnly mode, so the pill collapses to
  /// two segments to keep the visible options and the action guard in
  /// sync.
  final String? processSourceName;
  final int? processSourcePid;
  final List<Tag> tags;
  final List<Folder> folders;
  final int? folderId;
  final bool folderPickerOpen;
  final VoidCallback? onToggleFolderEdit;
  final ValueChanged<int?>? onFolderChanged;
  final bool compact;

  Color _colorFor(String name) {
    final lower = name.toLowerCase();
    for (final t in tags) {
      if (t.name.toLowerCase() == lower) return parseHexColor(t.color);
    }
    return SpeakrColors.ink;
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final hPad = compact ? 12.0 : 16.0;
    final vPad = compact ? 10.0 : 12.0;
    final hMargin = compact ? 12.0 : 20.0;
    final activeLower = activeTags.map((n) => n.toLowerCase()).toSet();
    final suggestable = [
      for (final t in tags)
        if (!activeLower.contains(t.name.toLowerCase())) t,
    ];
    return Container(
      margin: EdgeInsets.symmetric(horizontal: hMargin),
      decoration: BoxDecoration(
        border: Border.all(color: SpeakrColors.line),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, vPad, hPad, vPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MonoEyebrow(tr("Capture"), size: 9),
                const SizedBox(height: 10),
                PillSourceCard<bool>(
                  label: tr("Microphone"),
                  sub: micEnabled
                      ? tr("Capturing voice")
                      : tr("Not capturing voice"),
                  value: micEnabled,
                  pending: micPending,
                  onChanged: onMicChanged,
                  options: [
                    PillSourceOption(id: false, label: tr("Off")),
                    PillSourceOption(
                      id: true,
                      label: tr("Mic"),
                      icon: SpeakrIcon.mic,
                    ),
                  ],
                ),
                if (systemAudioSupported) ...[
                  const SizedBox(height: 8),
                  PillSourceCard<SystemAudioMode>(
                    label: tr("System audio"),
                    sub: _systemAudioSubtitle(systemMode, processSourceName),
                    value: systemMode,
                    pending: systemPending,
                    onChanged: onSystemModeChanged,
                    options: [
                      PillSourceOption(
                        id: SystemAudioMode.off,
                        label: tr("Off"),
                      ),
                      PillSourceOption(
                        id: SystemAudioMode.allSystem,
                        label: tr("System"),
                        icon: SpeakrIcon.speaker,
                      ),
                      if (processSourceName != null &&
                          processSourcePid != null &&
                          processLoopbackSupported)
                        PillSourceOption(
                          id: SystemAudioMode.processOnly,
                          label: processSourceName!,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(hPad, vPad, hPad, vPad),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: SpeakrColors.line)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MonoEyebrow(tr("Speakers"), size: 9),
                      const SizedBox(height: 2),
                      Text(
                        tr("Helps separate voices."),
                        style: SpeakrText.sans(
                          size: 11,
                          color: SpeakrColors.muted,
                          weight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                _StepperButton(
                  child: '−',
                  onTap: () => onSpeakersChanged((speakers - 1).clamp(1, 12)),
                ),
                SizedBox(width: compact ? 10 : 14),
                SizedBox(
                  width: 22,
                  child: Center(
                    child: Text(
                      '$speakers',
                      style: SpeakrText.serif(
                        size: compact ? 20 : 24,
                        height: 1,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: compact ? 10 : 14),
                _StepperButton(
                  child: '+',
                  onTap: () => onSpeakersChanged((speakers + 1).clamp(1, 12)),
                ),
              ],
            ),
          ),
          if (onFolderChanged != null && folders.isNotEmpty)
            _FolderSection(
              hPad: hPad,
              vPad: vPad,
              folders: folders,
              folderId: folderId,
              pickerOpen: folderPickerOpen,
              onToggleEdit: onToggleFolderEdit ?? () {},
              onChanged: onFolderChanged!,
            ),
          Container(
            padding: EdgeInsets.fromLTRB(hPad, vPad, hPad, vPad),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: SpeakrColors.line)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MonoEyebrow(tr("Tags"), size: 9),
                    InkWell(
                      onTap: onToggleEdit,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: MonoEyebrow(
                          tagPickerOpen ? tr("Done") : tr("Edit"),
                          size: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    if (activeTags.isEmpty && !tagPickerOpen)
                      Text(
                        tr("None yet"),
                        style: SpeakrText.sans(
                          size: 12,
                          color: SpeakrColors.muted,
                        ),
                      ),
                    for (final name in activeTags)
                      CustomColorTagChip(
                        label: name,
                        color: _colorFor(name),
                        filled: true,
                        onTap: tagPickerOpen ? () => onToggleTag(name) : null,
                        trailing: tagPickerOpen
                            ? Text(
                                '×',
                                style: SpeakrText.serif(
                                  size: 11,
                                  color: _colorFor(name).withValues(alpha: 0.6),
                                ),
                              )
                            : null,
                      ),
                  ],
                ),
                if (tagPickerOpen && suggestable.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Divider(
                    color: SpeakrColors.line,
                    thickness: 1,
                    height: 1,
                  ),
                  const SizedBox(height: 10),
                  MonoEyebrow(tr("Suggested"), size: 9),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (final t in suggestable)
                        DashedTagChip(
                          label: t.name,
                          color: parseHexColor(t.color),
                          onTap: () => onToggleTag(t.name),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FolderSection extends StatelessWidget {
  const _FolderSection({
    required this.hPad,
    required this.vPad,
    required this.folders,
    required this.folderId,
    required this.pickerOpen,
    required this.onToggleEdit,
    required this.onChanged,
  });
  final double hPad;
  final double vPad;
  final List<Folder> folders;
  final int? folderId;
  final bool pickerOpen;
  final VoidCallback onToggleEdit;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final selected = folders.firstWhere(
      (f) => f.id == folderId,
      orElse: () => const Folder(id: -1, name: ''),
    );
    final hasSelection = selected.id != -1;
    return Container(
      padding: EdgeInsets.fromLTRB(hPad, vPad, hPad, vPad),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: SpeakrColors.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MonoEyebrow(tr("Folder"), size: 9),
              InkWell(
                onTap: onToggleEdit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: MonoEyebrow(
                    pickerOpen ? tr("Done") : tr("Change"),
                    size: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!pickerOpen)
            hasSelection
                ? FolderChip(
                    label: selected.name,
                    color: parseHexColor(selected.color),
                  )
                : Text(
                    tr("No folder"),
                    style: SpeakrText.sans(
                      size: 12,
                      color: SpeakrColors.muted,
                    ).copyWith(fontStyle: FontStyle.italic),
                  ),
          if (pickerOpen)
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                FolderFilterChip(
                  label: tr("None"),
                  color: SpeakrColors.muted,
                  selected: folderId == null,
                  onTap: () => onChanged(null),
                  showSwatch: false,
                ),
                for (final f in folders)
                  FolderFilterChip(
                    label: f.name,
                    color: parseHexColor(f.color),
                    selected: folderId == f.id,
                    onTap: () => onChanged(f.id),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.child, required this.onTap});
  final String child;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: SpeakrColors.line),
        ),
        alignment: Alignment.center,
        child: Text(
          child,
          style: SpeakrText.serif(size: 18, weight: FontWeight.w300, height: 1),
        ),
      ),
    );
  }
}

/// One segment inside [PillSourceCard]'s segmented control.
class PillSourceOption<T> {
  const PillSourceOption({required this.id, required this.label, this.icon});
  final T id;
  final String label;
  final SpeakrIcon? icon;
}

/// Segmented capture-source toggle modeled after `desktop-more.jsx:407`
/// ("Shared capture-source card"). Renders a header (status pip + label
/// + subtext) above a 2- or 3-segment radio-style control. The card
/// gains a white background and border whenever the active option is
/// not the "off" option (i.e. [value] != [options.first.id]); the
/// inactive state is flat and dimmed.
class PillSourceCard<T> extends StatelessWidget {
  const PillSourceCard({
    super.key,
    required this.label,
    required this.sub,
    required this.value,
    required this.options,
    required this.onChanged,
    this.pending = false,
  });

  final String label;
  final String sub;
  final T value;
  final List<PillSourceOption<T>> options;
  final ValueChanged<T> onChanged;
  final bool pending;

  static const _onPip = Color(0xFF3A8A5A);

  bool get _on => options.isNotEmpty && value != options.first.id;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final on = _on;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: on ? Colors.white : Colors.transparent,
        border: Border.all(color: on ? SpeakrColors.line : Colors.transparent),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Opacity(
            opacity: on ? 1.0 : 0.55,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: on ? _onPip : SpeakrColors.line,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
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
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        style: SpeakrText.sans(
                          size: 11,
                          color: SpeakrColors.muted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (pending) ...[
                  const SizedBox(width: 6),
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.4,
                      color: SpeakrColors.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          _Segments<T>(
            value: value,
            options: options,
            onChanged: pending ? null : onChanged,
            label: label,
          ),
        ],
      ),
    );
  }
}

class _Segments<T> extends StatelessWidget {
  const _Segments({
    required this.value,
    required this.options,
    required this.onChanged,
    required this.label,
  });
  final T value;
  final List<PillSourceOption<T>> options;
  final ValueChanged<T>? onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Semantics(
      label: label,
      container: true,
      child: Container(
        height: 30,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: SpeakrColors.bg,
          border: Border.all(color: SpeakrColors.line),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            for (final opt in options)
              Expanded(
                child: _Segment<T>(
                  option: opt,
                  active: opt.id == value,
                  onTap: onChanged == null ? null : () => onChanged!(opt.id),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Segment<T> extends StatelessWidget {
  const _Segment({
    required this.option,
    required this.active,
    required this.onTap,
  });
  final PillSourceOption<T> option;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    final fg = active ? SpeakrColors.bg : SpeakrColors.ink2;
    return Semantics(
      selected: active,
      button: true,
      child: Material(
        color: active ? SpeakrColors.ink : Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (option.icon != null) ...[
                  SpeakrIconView(option.icon!, size: 12, color: fg),
                  const SizedBox(width: 5),
                ],
                Flexible(
                  child: Text(
                    option.label.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: SpeakrText.mono(
                      size: 10,
                      color: fg,
                      letterSpacing: 1,
                      weight: active ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _systemAudioSubtitle(SystemAudioMode mode, String? processSourceName) {
  switch (mode) {
    case SystemAudioMode.off:
      return tr("Not capturing app audio");
    case SystemAudioMode.allSystem:
      return tr("All apps · system mix");
    case SystemAudioMode.processOnly:
      return processSourceName != null
          ? tr("{0} only", [processSourceName])
          : tr("Process-only");
  }
}

class RecordingControls extends StatelessWidget {
  const RecordingControls({
    super.key,
    required this.paused,
    required this.busy,
    required this.onTogglePause,
    required this.onStop,
    required this.onDiscard,
  });
  final bool paused;
  final bool busy;
  final VoidCallback? onTogglePause;
  final VoidCallback? onStop;
  final VoidCallback? onDiscard;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _outlinedPill(
            onTap: busy ? null : onDiscard,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SpeakrIconView(
                  SpeakrIcon.trash,
                  size: 12,
                  color: SpeakrColors.muted,
                ),
                const SizedBox(width: 8),
                Text(
                  tr("Discard").toUpperCase(),
                  style: SpeakrText.mono(
                    size: 11,
                    color: SpeakrColors.muted,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          _pauseCircle(),
          const SizedBox(width: 18),
          _outlinedPill(
            horizontalPadding: 18,
            onTap: busy ? null : onStop,
            child: busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: SpeakrColors.ink,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: SpeakrColors.recordingDot,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        tr("Save").toUpperCase(),
                        style: SpeakrText.mono(
                          size: 11,
                          color: SpeakrColors.ink,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _outlinedPill({
    required Widget child,
    required VoidCallback? onTap,
    double horizontalPadding = 16,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: SpeakrColors.line),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _pauseCircle() {
    return GestureDetector(
      onTap: onTogglePause,
      child: Container(
        width: 84,
        height: 84,
        decoration: const BoxDecoration(
          color: SpeakrColors.ink,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Center(
          child: SpeakrIconView(
            paused ? SpeakrIcon.play : SpeakrIcon.pause,
            size: 28,
            color: SpeakrColors.bg,
          ),
        ),
      ),
    );
  }
}
