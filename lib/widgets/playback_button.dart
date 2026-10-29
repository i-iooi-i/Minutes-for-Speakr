import 'package:flutter/material.dart';
import '../theme/appearance.dart';
import '../theme/colors.dart';
import 'speakr_icons.dart';

/// Shared playback control for library rows and the detail player.
class PlaybackButton extends StatelessWidget {
  const PlaybackButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = 44,
    this.playing = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final double size;
  final bool playing;

  @override
  Widget build(BuildContext context) {
    AppearanceScope.watch(context);
    final enabled = onPressed != null;
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        tooltip: label,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: SpeakrColors.accent,
          foregroundColor: SpeakrColors.onAccent,
          disabledBackgroundColor: SpeakrColors.bgAlt,
          disabledForegroundColor: SpeakrColors.muted,
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        icon: SpeakrIconView(
          playing ? SpeakrIcon.pause : SpeakrIcon.play,
          size: size * 0.57,
          color: enabled ? SpeakrColors.onAccent : SpeakrColors.muted,
        ),
      ),
    );
  }
}
