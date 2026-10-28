import 'package:speakr_app/l10n/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/live/mini/mini_window_native.dart';
import '../routing/router.dart';
import '../services/auto_record/auto_record_bootstrap.dart';
import '../services/auto_record/auto_record_coordinator.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

/// Imperative coordinator that listens to the auto-record prompt stream
/// and shows a non-blocking dialog. Mounted once near the app root.
class AutoRecordPromptListener extends ConsumerStatefulWidget {
  const AutoRecordPromptListener({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<AutoRecordPromptListener> createState() =>
      _AutoRecordPromptListenerState();
}

class _AutoRecordPromptListenerState
    extends ConsumerState<AutoRecordPromptListener> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    ref.listen(autoRecordPromptsProvider, (_, next) {
      next.whenData((req) => _show(req));
    });
    return widget.child;
  }

  Future<void> _show(StopPromptRequest req) async {
    if (_open || !mounted) return;
    // Surface the main window first — the app may be closed-to-tray or
    // minimized while auto-record runs in the background. Done before
    // grabbing the Navigator context so the lookup sees the live tree.
    await MiniWindowNative.focusMain();
    if (!mounted) return;
    // This widget is mounted in MaterialApp.builder — *above* the
    // Navigator — so its own `context` has no Navigator ancestor.
    // Route the dialog through the router's navigatorKey instead.
    final navCtx = speakrNavigatorKey.currentContext;
    if (navCtx == null) return;
    final coord = ref.read(autoRecordCoordinatorProvider);
    coord?.notePromptShown();
    _open = true;
    try {
      // navCtx is a fresh lookup from speakrNavigatorKey *after* the
      // focusMain await; analyzer's flow check can't see that.
      final choice = await showDialog<_StopPromptChoice>(
        // ignore: use_build_context_synchronously
        context: navCtx,
        barrierDismissible: false,
        builder: (_) => _StopPromptDialog(req: req),
      );
      // Null = dialog dismissed without a choice; treat as "keep" so the
      // session continues until the next idle window re-arms a prompt.
      final resolved = choice ?? _StopPromptChoice.keep;
      coord?.notePromptDismissed(
        keepRecording: resolved == _StopPromptChoice.keep,
      );
      if (coord != null) {
        switch (resolved) {
          case _StopPromptChoice.keep:
            break;
          case _StopPromptChoice.stop:
            await coord.stopAutoSession();
          case _StopPromptChoice.discard:
            await coord.discardAutoSession();
        }
      }
    } finally {
      _open = false;
    }
  }
}

enum _StopPromptChoice { keep, stop, discard }

class _StopPromptDialog extends StatelessWidget {
  const _StopPromptDialog({required this.req});
  final StopPromptRequest req;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return AlertDialog(
      backgroundColor: SpeakrColors.bg,
      title: Text(tr("Stop recording?"), style: SpeakrText.serif(size: 20)),
      content: Text(
        tr(
          "Minutes has been auto-recording {0} for {1}. The mic and audio output have been idle.",
          [req.triggerLabel, _formatElapsed(req.elapsed)],
        ),
        style: SpeakrText.sans(size: 14, color: SpeakrColors.ink2),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(_StopPromptChoice.keep),
          child: Text(
            tr("Continue recording"),
            style: SpeakrText.sans(size: 14, color: SpeakrColors.ink),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_StopPromptChoice.discard),
          child: Text(
            tr("Discard"),
            style: SpeakrText.sans(size: 14, color: SpeakrColors.danger),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_StopPromptChoice.stop),
          child: Text(
            tr("Stop & save"),
            style: SpeakrText.sans(size: 14, color: SpeakrColors.ink),
          ),
        ),
      ],
    );
  }

  static String _formatElapsed(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
