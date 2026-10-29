import 'package:speakr_app/theme/appearance.dart';
import 'package:speakr_app/l10n/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/models.dart';
import '../../api/providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/mimio_menu.dart';

class ReprocessTranscriptionParams {
  const ReprocessTranscriptionParams({
    this.transcriptionModel,
    this.minSpeakers,
    this.maxSpeakers,
    this.hotwords,
    this.initialPrompt,
  });

  final String? transcriptionModel;
  final int? minSpeakers;
  final int? maxSpeakers;
  final String? hotwords;
  final String? initialPrompt;
}

class ReprocessTranscriptionDialog extends ConsumerStatefulWidget {
  const ReprocessTranscriptionDialog({super.key, required this.recording});

  final Recording recording;

  @override
  ConsumerState<ReprocessTranscriptionDialog> createState() =>
      _ReprocessTranscriptionDialogState();
}

class _ReprocessTranscriptionDialogState
    extends ConsumerState<ReprocessTranscriptionDialog> {
  String? _model;
  late final TextEditingController _minSpeakers;
  late final TextEditingController _maxSpeakers;
  late final TextEditingController _hotwords;
  late final TextEditingController _initialPrompt;

  @override
  void initState() {
    super.initState();
    final r = widget.recording;
    _model = r.transcriptionModel;
    _minSpeakers = TextEditingController(text: r.minSpeakers?.toString() ?? '');
    _maxSpeakers = TextEditingController(text: r.maxSpeakers?.toString() ?? '');
    _hotwords = TextEditingController(text: r.hotwords ?? '');
    _initialPrompt = TextEditingController(text: r.initialPrompt ?? '');
  }

  @override
  void dispose() {
    _minSpeakers.dispose();
    _maxSpeakers.dispose();
    _hotwords.dispose();
    _initialPrompt.dispose();
    super.dispose();
  }

  void _submit(Config? config) {
    String? trim(TextEditingController c) {
      final v = c.text.trim();
      return v.isEmpty ? null : v;
    }

    final showDiarization =
        config?.connectorSupportsDiarization == true ||
        config?.connectorSupportsSpeakerCount == true;
    final showHotwords = config?.connectorSupportsHotwords == true;
    final showInitialPrompt = config?.connectorSupportsInitialPrompt == true;

    Navigator.of(context).pop(
      ReprocessTranscriptionParams(
        transcriptionModel: _model,
        minSpeakers: showDiarization ? int.tryParse(_minSpeakers.text) : null,
        maxSpeakers: showDiarization ? int.tryParse(_maxSpeakers.text) : null,
        hotwords: showHotwords ? trim(_hotwords) : null,
        initialPrompt: showInitialPrompt ? trim(_initialPrompt) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    final configAsync = ref.watch(configProvider);
    return AlertDialog(
      backgroundColor: SpeakrColors.bg,
      title: Text(
        tr("Reprocess transcription"),
        style: SpeakrText.serif(size: 20),
      ),
      content: SizedBox(
        width: 420,
        child: configAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => _ErrorBody(error: e.toString()),
          data: (config) => _Body(
            config: config,
            model: _model,
            onModelChanged: (v) => setState(() => _model = v),
            minSpeakers: _minSpeakers,
            maxSpeakers: _maxSpeakers,
            hotwords: _hotwords,
            initialPrompt: _initialPrompt,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            tr("Cancel"),
            style: SpeakrText.sans(size: 13, color: SpeakrColors.muted),
          ),
        ),
        TextButton(
          onPressed: configAsync.isLoading
              ? null
              : () => _submit(configAsync.value),
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
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.config,
    required this.model,
    required this.onModelChanged,
    required this.minSpeakers,
    required this.maxSpeakers,
    required this.hotwords,
    required this.initialPrompt,
  });

  final Config config;
  final String? model;
  final ValueChanged<String?> onModelChanged;
  final TextEditingController minSpeakers;
  final TextEditingController maxSpeakers;
  final TextEditingController hotwords;
  final TextEditingController initialPrompt;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    final showDiarization =
        config.connectorSupportsDiarization ||
        config.connectorSupportsSpeakerCount;
    final modelValue =
        config.transcriptionModelOptions.any((o) => o.value == model)
        ? model
        : null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          tr(
            "The current transcript and any speaker labels will be replaced. Processing happens on the server and may take a few minutes.",
          ),
          style: SpeakrText.sans(
            size: 13,
            height: 1.4,
            color: SpeakrColors.ink2,
          ),
        ),
        const SizedBox(height: 16),
        if (config.transcriptionModelOptions.isNotEmpty) ...[
          _label(tr("Model")),
          MimioSelect<String>(
            value: modelValue,
            expanded: true,
            placeholder: tr('Server default'),
            tooltip: tr('Model'),
            options: [
              for (final o in config.transcriptionModelOptions)
                MimioSelectOption(value: o.value, label: o.label),
            ],
            onChanged: onModelChanged,
          ),
          const SizedBox(height: 12),
        ],
        if (showDiarization) ...[
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _label(tr("Min speakers")),
                    TextField(
                      controller: minSpeakers,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: SpeakrText.sans(size: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _label(tr("Max speakers")),
                    TextField(
                      controller: maxSpeakers,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: SpeakrText.sans(size: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (config.connectorSupportsHotwords) ...[
          _label(tr("Hotwords")),
          TextField(
            controller: hotwords,
            style: SpeakrText.sans(size: 14),
            decoration: InputDecoration(
              hintText: tr("Comma-separated terms to bias toward"),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (config.connectorSupportsInitialPrompt) ...[
          _label(tr("Initial prompt")),
          TextField(
            controller: initialPrompt,
            maxLines: 4,
            minLines: 2,
            style: SpeakrText.sans(size: 14),
            decoration: InputDecoration(hintText: tr("Free-text context hint")),
          ),
        ],
      ],
    );
  }

  static Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      text,
      style: SpeakrText.sans(
        size: 12,
        weight: FontWeight.w500,
        color: SpeakrColors.muted,
      ),
    ),
  );
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(
            "Couldn't load server config — you can still reprocess with the server defaults.",
          ),
          style: SpeakrText.sans(
            size: 13,
            height: 1.4,
            color: SpeakrColors.ink2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          error,
          style: SpeakrText.mono(size: 11, color: SpeakrColors.danger),
        ),
      ],
    );
  }
}
