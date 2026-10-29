import 'package:speakr_app/theme/appearance.dart';
import 'package:speakr_app/l10n/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/models.dart';
import '../../../api/providers.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';
import '../../../widgets/mono_eyebrow.dart';
import '../../../widgets/speakr_icons.dart';
import '../../../widgets/user_avatar.dart';

class ChatTab extends ConsumerStatefulWidget {
  const ChatTab({super.key, required this.recordingId});
  final int recordingId;

  @override
  ConsumerState<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends ConsumerState<ChatTab> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;
    final history = List<ChatMessage>.from(_messages);
    setState(() {
      _messages.add(ChatMessage(role: 'user', text: text));
      _ctrl.clear();
      _sending = true;
      _error = null;
    });
    _scrollSoon();
    try {
      final res = await ref
          .read(speakrApiProvider)
          .chat(widget.recordingId, text, history: history);
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(role: 'assistant', text: res.response));
        _sending = false;
      });
      _scrollSoon();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = e.toString();
      });
    }
  }

  void _scrollSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: _scrollCtrl,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SpeakrColors.bgAlt,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: SpeakrColors.line,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Text(
                  tr(
                    "Ask anything about this recording — decisions, action items, who said what.",
                  ),
                  style: SpeakrText.serif(
                    size: 13,
                    height: 1.45,
                    style: FontStyle.italic,
                    color: SpeakrColors.ink2,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              for (final m in _messages) ...[
                _Message(message: m),
                const SizedBox(height: 14),
              ],
              if (_sending)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const MonoEyebrow('Speakr', size: 9),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: SpeakrColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_error != null) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _error!,
                    style: SpeakrText.sans(
                      size: 13,
                      color: SpeakrColors.danger,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SpeakrColors.bg,
            border: Border(top: BorderSide(color: SpeakrColors.line)),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    onSubmitted: (_) => _send(),
                    style: SpeakrText.sans(size: 13),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: tr("Ask about this recording…"),
                      hintStyle: SpeakrText.sans(
                        size: 13,
                        color: SpeakrColors.muted,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                        borderSide: BorderSide(color: SpeakrColors.line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                        borderSide: BorderSide(color: SpeakrColors.line),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                        borderSide: BorderSide(color: SpeakrColors.ink),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _sending ? null : _send,
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: SpeakrColors.ink,
                      shape: BoxShape.circle,
                    ),
                    child: SpeakrIconView(
                      SpeakrIcon.send,
                      size: 18,
                      color: SpeakrColors.bg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.86,
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (isUser) const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: UserAvatar(size: 24),
            ),
            if (!isUser) ...[
              const Padding(
                padding: EdgeInsets.only(bottom: 4, left: 4),
                child: MonoEyebrow('Speakr', size: 9),
              ),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? SpeakrColors.ink : Colors.transparent,
                border: isUser ? null : Border.all(color: SpeakrColors.line),
                borderRadius: BorderRadius.circular(isUser ? 14 : 6),
              ),
              child: Text(
                message.text,
                style: SpeakrText.serif(
                  size: 13.5,
                  height: 1.5,
                  color: isUser ? SpeakrColors.bg : SpeakrColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
