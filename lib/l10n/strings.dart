import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'zh_cn.dart';

/// Per-engine locale. Mini windows receive updates through existing state IPC.
final appLanguage = ValueNotifier<String>('zh');
const languagePreferenceKey = 'ui.language';
const appLocales = [Locale('zh', 'CN'), Locale('en')];

String tr(String english, [List<Object?> arguments = const []]) {
  final text = appLanguage.value == 'zh' ? (zhCN[english] ?? english) : english;
  return text.replaceAllMapped(RegExp(r'\{(\d+)\}'), (match) {
    final i = int.parse(match[1]!);
    return i < arguments.length ? '${arguments[i]}' : match[0]!;
  });
}

void applyLanguage(String code) {
  final next = code == 'en' ? 'en' : 'zh';
  Intl.defaultLocale = next == 'zh' ? 'zh_CN' : 'en_US';
  appLanguage.value = next;
}

Future<void> loadLanguage() async {
  await initializeDateFormatting('zh_CN');
  final prefs = await SharedPreferences.getInstance();
  applyLanguage(prefs.getString(languagePreferenceKey) ?? 'zh');
}

Future<void> setLanguage(String code) async {
  final prefs = await SharedPreferences.getInstance();
  if (!await prefs.setString(languagePreferenceKey, code)) {
    throw StateError('Could not save language preference');
  }
  applyLanguage(code);
}

Future<void> syncTrayLanguage() async {
  try {
    await const MethodChannel(
      'speakr/tray',
    ).invokeMethod<void>('setLanguage', appLanguage.value);
  } on MissingPluginException {
    // Non-Windows platforms and widget tests have no tray bridge.
  }
}

class LanguageScope extends InheritedNotifier<ValueNotifier<String>> {
  LanguageScope({super.key, required super.child})
    : super(notifier: appLanguage);

  static void watch(BuildContext context) {
    context.dependOnInheritedWidgetOfExactType<LanguageScope>();
  }
}

/// Rebuilds MaterialApp for native dialogs while LanguageScope preserves
/// existing screen/recording state and invalidates translated UI widgets.
class LocalizedApp extends StatelessWidget {
  const LocalizedApp({super.key, required this.builder});
  final Widget Function(Locale locale) builder;

  @override
  Widget build(BuildContext context) => LanguageScope(
    child: ValueListenableBuilder<String>(
      valueListenable: appLanguage,
      builder: (context, language, _) =>
          builder(language == 'zh' ? appLocales.first : appLocales.last),
    ),
  );
}

class LanguagePicker extends StatelessWidget {
  const LanguagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Align(
      alignment: Alignment.centerLeft,
      widthFactor: 1,
      child: DropdownButton<String>(
        menuWidth: 180,
        value: appLanguage.value,
        underline: const SizedBox.shrink(),
        items: const [
          DropdownMenuItem(value: 'zh', child: Text('简体中文')),
          DropdownMenuItem(value: 'en', child: Text('English')),
        ],
        onChanged: (value) async {
          if (value == null) return;
          try {
            await setLanguage(value);
          } catch (_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tr('Could not save language preference')),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
