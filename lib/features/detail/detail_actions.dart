import 'package:speakr_app/l10n/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/models.dart';
import '../../api/providers.dart';
import '../../api/speakr_api.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../library/library_controller.dart';
import 'detail_controller.dart';
import 'reprocess_transcription_dialog.dart';

enum ReprocessKind { transcription, summary }

Future<void> toggleRecordingField(
  BuildContext context,
  WidgetRef ref, {
  required int recordingId,
  required Map<String, dynamic> patch,
  required String successMessage,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final container = ProviderScope.containerOf(context, listen: false);
  final api = container.read(speakrApiProvider);
  try {
    await api.updateRecording(recordingId, patch);
    container.read(uploadKickProvider.notifier).state++;
    container.invalidate(recordingDetailProvider(recordingId));
    messenger.showSnackBar(SnackBar(content: Text(successMessage)));
  } on SpeakrApiException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.toString())));
  }
}

Future<void> reprocessRecording(
  BuildContext context,
  WidgetRef ref, {
  required int recordingId,
  required ReprocessKind kind,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final container = ProviderScope.containerOf(context, listen: false);
  final api = container.read(speakrApiProvider);

  ReprocessTranscriptionParams? transcriptionParams;
  if (kind == ReprocessKind.transcription) {
    // Pre-fill from the already-loaded recording when available; fall back to
    // an empty Recording shell so the dialog still opens if detail hasn't
    // been fetched yet.
    final cached = container.read(recordingDetailProvider(recordingId)).value;
    transcriptionParams = await showDialog<ReprocessTranscriptionParams>(
      context: context,
      builder: (ctx) => ReprocessTranscriptionDialog(
        recording: cached ?? Recording(id: recordingId),
      ),
    );
    if (transcriptionParams == null) return;
  } else {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SpeakrColors.bg,
        title: Text(
          tr("Reprocess summary?"),
          style: SpeakrText.serif(size: 20),
        ),
        content: Text(
          tr(
            "The current summary will be replaced. Processing happens on the server and may take a few minutes.",
          ),
          style: SpeakrText.sans(size: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              tr("Cancel"),
              style: SpeakrText.sans(size: 13, color: SpeakrColors.muted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              tr("Reprocess"),
              style: SpeakrText.sans(
                size: 13,
                weight: FontWeight.w600,
                color: SpeakrColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
  }

  try {
    if (kind == ReprocessKind.transcription) {
      final p = transcriptionParams!;
      await api.reprocessTranscription(
        recordingId,
        transcriptionModel: p.transcriptionModel,
        minSpeakers: p.minSpeakers,
        maxSpeakers: p.maxSpeakers,
        hotwords: p.hotwords,
        initialPrompt: p.initialPrompt,
      );
    } else {
      await api.reprocessSummary(recordingId);
    }
    container.invalidate(recordingDetailProvider(recordingId));
    container.read(uploadKickProvider.notifier).state++;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          kind == ReprocessKind.transcription
              ? tr("Transcription queued — refresh in a moment")
              : tr("Summary queued — refresh in a moment"),
        ),
      ),
    );
  } on SpeakrApiException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.toString())));
  }
}

Future<void> deleteRecording(
  BuildContext context,
  WidgetRef ref, {
  required int recordingId,
}) async {
  final goRouter = GoRouter.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final container = ProviderScope.containerOf(context, listen: false);
  final api = container.read(speakrApiProvider);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: SpeakrColors.bg,
      title: Text(tr("Delete recording?"), style: SpeakrText.serif(size: 20)),
      content: Text(
        tr(
          "This permanently deletes the recording, its transcript, and its audio. This cannot be undone.",
        ),
        style: SpeakrText.sans(size: 14, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(
            tr("Cancel"),
            style: SpeakrText.sans(size: 13, color: SpeakrColors.muted),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: TextButton.styleFrom(foregroundColor: SpeakrColors.danger),
          child: Text(
            tr("Delete"),
            style: SpeakrText.sans(
              size: 13,
              weight: FontWeight.w600,
              color: SpeakrColors.danger,
            ),
          ),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  try {
    await api.deleteRecording(recordingId);
    container.read(uploadKickProvider.notifier).state++;
    container.invalidate(recordingDetailProvider(recordingId));
    if (goRouter.canPop()) goRouter.pop();
    messenger.showSnackBar(SnackBar(content: Text(tr("Recording deleted"))));
  } on SpeakrApiException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.toString())));
  }
}
