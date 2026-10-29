import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../services/preferences/local_avatar.dart';
import '../theme/appearance.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/tokens.dart';
import 'user_avatar.dart';

class AvatarSettings extends StatefulWidget {
  const AvatarSettings({super.key, this.controller});
  final LocalAvatarController? controller;
  @override
  State<AvatarSettings> createState() => _AvatarSettingsState();
}

class _AvatarSettingsState extends State<AvatarSettings> {
  LocalAvatarController get _avatar => widget.controller ?? localAvatar;
  late final _url = TextEditingController(text: _avatar.value);
  bool _saving = false;
  bool _focused = false;
  String? _error;

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  Future<void> _save({bool reset = false}) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _avatar.save(reset ? '' : _url.text);
      if (!mounted) return;
      _url.text = _avatar.value;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(reset ? 'Default avatar restored.' : 'Avatar link saved.'),
          ),
        ),
      );
    } on FormatException {
      if (mounted) {
        setState(
          () => _error =
              'Enter a valid HTTP or HTTPS image URL without account credentials.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not save avatar. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('Local avatar'),
          style: SpeakrText.sans(size: 15, weight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Text(
          tr(
            'Use a direct image link. Saved only on this device and used in Mimio; your Speakr account is unchanged.',
          ),
          style: SpeakrText.sans(size: 13, color: SpeakrColors.ink2),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            UserAvatar(size: 64, controller: _avatar),
            const SizedBox(width: 16),
            Expanded(
              child: Focus(
                onFocusChange: (focused) => setState(() => _focused = focused),
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: SpeakrColors.surface,
                    borderRadius: SpeakrRadius.menu,
                    border: Border.all(color: _focused ? SpeakrColors.accent : SpeakrColors.line),
                  ),
                  child: TextField(
                    controller: _url,
                    enabled: !_saving,
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    textAlignVertical: TextAlignVertical.center,
                    style: SpeakrText.sans(size: 13),
                    decoration: InputDecoration(
                      hintText: tr('Avatar image URL'),
                      hintStyle: SpeakrText.sans(size: 13, color: SpeakrColors.muted),
                      isCollapsed: true,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                    onSubmitted: (_) => _save(),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            tr(_error!),
            style: SpeakrText.sans(size: 12, color: SpeakrColors.danger),
          ),
        ],
        const SizedBox(height: 10),
        Text(
          tr('If the image cannot load, Mimio shows your default avatar.'),
          style: SpeakrText.sans(size: 12, color: SpeakrColors.muted),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(
              onPressed: _saving ? null : () => _save(),
              child: Text(tr(_saving ? 'Saving…' : 'Apply avatar')),
            ),
            TextButton(
              onPressed: _saving ? null : () => _save(reset: true),
              child: Text(tr('Restore default avatar')),
            ),
          ],
        ),
      ],
    );
  }
}
