import 'package:speakr_app/l10n/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/colors.dart';
import '../../../theme/typography.dart';

/// Shows a single-item "Copy" context menu at [globalPosition]. Selecting it
/// writes [text] to the system clipboard. Used by both the mobile transcript
/// bubbles and the desktop transcript pane as a replacement for inline text
/// selection, since the bubbles themselves are now tap-to-seek.
Future<void> showTranscriptCopyMenu(
  BuildContext context,
  Offset globalPosition,
  String text,
) async {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
  if (overlay == null) return;
  final selected = await showMenu<String>(
    context: context,
    position: RelativeRect.fromLTRB(
      globalPosition.dx,
      globalPosition.dy,
      overlay.size.width - globalPosition.dx,
      overlay.size.height - globalPosition.dy,
    ),
    color: SpeakrColors.bg,
    items: [
      PopupMenuItem<String>(
        value: 'copy',
        child: Text(tr("Copy"), style: SpeakrText.sans(size: 13)),
      ),
    ],
  );
  if (selected == 'copy') {
    await Clipboard.setData(ClipboardData(text: text));
  }
}
