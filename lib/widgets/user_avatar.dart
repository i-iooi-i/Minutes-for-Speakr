import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../services/preferences/local_avatar.dart';
import '../theme/appearance.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, this.size = 30, this.controller});
  final double size;
  final LocalAvatarController? controller;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    AppearanceScope.watch(context);
    final fallback = ColoredBox(
      color: SpeakrColors.accent,
      child: Center(
        child: Text(
          tr('ME'),
          style: SpeakrText.sans(
            size: size * .34,
            color: SpeakrColors.onAccent,
            weight: FontWeight.w500,
          ),
        ),
      ),
    );
    return Semantics(
      image: true,
      label: tr('Your avatar'),
      child: SizedBox.square(
        dimension: size,
        child: ClipOval(
          child: ValueListenableBuilder<String>(
            valueListenable: controller ?? localAvatar,
            builder: (_, url, _) => url.isEmpty
                ? fallback
                : Image.network(
                    url,
                    key: ValueKey(url),
                    fit: BoxFit.cover,
                    width: size,
                    height: size,
                    excludeFromSemantics: true,
                    loadingBuilder: (_, child, progress) =>
                        progress == null ? child : fallback,
                    errorBuilder: (_, _, _) => Tooltip(
                      message: tr(
                        'Could not load avatar. Showing the default avatar.',
                      ),
                      child: fallback,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
