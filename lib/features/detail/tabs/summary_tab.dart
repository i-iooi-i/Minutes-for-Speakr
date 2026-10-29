import 'package:speakr_app/theme/appearance.dart';
import 'package:speakr_app/l10n/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/colors.dart';
import '../../../theme/typography.dart';
import '../../../widgets/mono_eyebrow.dart';
import '../detail_controller.dart';

class SummaryTab extends ConsumerWidget {
  const SummaryTab({super.key, required this.recordingId});
  final int recordingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    final async = ref.watch(summaryProvider(recordingId));
    return async.when(
      loading: () => Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: SpeakrColors.ink,
          ),
        ),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MonoEyebrow(tr("Couldn’t load summary")),
            const SizedBox(height: 8),
            Text(e.toString(), style: SpeakrText.sans(size: 14)),
          ],
        ),
      ),
      data: (md) {
        if (md.trim().isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MonoEyebrow(tr("TL;DR")),
                const SizedBox(height: 8),
                Text(
                  tr("No summary yet. Run summarize from the menu."),
                  style: SpeakrText.serif(
                    size: 13.5,
                    color: SpeakrColors.ink2,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 60),
          child: Markdown(
            data: md,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            styleSheet: _markdownStyles(context),
          ),
        );
      },
    );
  }

  MarkdownStyleSheet _markdownStyles(BuildContext context) {
    final base = MarkdownStyleSheet.fromTheme(Theme.of(context));
    return base.copyWith(
      p: SpeakrText.serif(size: 13.5, height: 1.55, color: SpeakrColors.ink),
      h1: SpeakrText.serif(size: 20, height: 1.2, weight: FontWeight.w500),
      h2: SpeakrText.serif(size: 17, height: 1.3, weight: FontWeight.w500),
      h3: SpeakrText.serif(size: 13.5, height: 1.3, weight: FontWeight.w600),
      blockquote: SpeakrText.serif(
        size: 13.5,
        color: SpeakrColors.ink2,
        style: FontStyle.italic,
      ),
      listBullet: SpeakrText.sans(size: 13.5, color: SpeakrColors.ink),
      code: SpeakrText.mono(size: 12, color: SpeakrColors.ink2),
      codeblockDecoration: BoxDecoration(
        color: SpeakrColors.bgAlt,
        borderRadius: BorderRadius.circular(4),
      ),
      a: SpeakrText.sans(
        size: 13.5,
        color: SpeakrColors.ink,
        weight: FontWeight.w500,
      ),
    );
  }
}
