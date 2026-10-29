import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Device-local presentation preference; never sent to Speakr's API.
class LocalAvatarController extends ValueNotifier<String> {
  LocalAvatarController() : super('');
  static const preferenceKey = 'ui.localAvatarUrl';

  static String normalize(String input) {
    final text = input.trim();
    if (text.isEmpty) return '';
    final uri = Uri.tryParse(text);
    if (uri == null ||
        !['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      throw const FormatException('Invalid avatar URL');
    }
    return uri.toString();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      value = normalize(prefs.getString(preferenceKey) ?? '');
    } on FormatException {
      value = '';
    }
  }

  Future<void> save(String input) async {
    final url = normalize(input);
    final prefs = await SharedPreferences.getInstance();
    final saved = url.isEmpty
        ? await prefs.remove(preferenceKey)
        : await prefs.setString(preferenceKey, url);
    if (!saved) throw StateError('Avatar preference could not be saved');
    value = url;
  }
}

final localAvatar = LocalAvatarController();
