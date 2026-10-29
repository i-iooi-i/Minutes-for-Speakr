import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// CoPage's @univerjs/themes palettes. Deep blue uses its normalized scale.
enum MimioPalette {
  blue('Blue', 0xFF143EE3, 0xFFBAC6F8),
  darkBlue('Deep blue', 0xFF1D4ED8, 0xFF93C5FD),
  green('Green', 0xFF065F46, 0xFF6EE7B7),
  orange('Orange', 0xFF9A3412, 0xFFFDBA74),
  purple('Purple', 0xFF6D28D9, 0xFFC4B5FD),
  red('Red', 0xFFBE123C, 0xFFFDA4AF),
  yellow('Yellow', 0xFF854D0E, 0xFFFDE047);

  const MimioPalette(this.label, this.light, this.dark);
  final String label;
  final int light;
  final int dark;
  Color accent(Brightness brightness) =>
      Color(brightness == Brightness.dark ? dark : light);
}

/// One palette per Flutter engine, also sent to the recorder's child engine.
/// Existing widgets subscribe through AppearanceScope without replacing routes
/// or losing unsaved notes, playback position, or a live recording session.
class AppearanceController extends ChangeNotifier {
  ThemeMode mode =
      ThemeMode.dark; // Preserve the existing installation default.
  MimioPalette palette = MimioPalette.green;
  Brightness systemBrightness = Brightness.dark;
  Brightness get brightness => mode == ThemeMode.system
      ? systemBrightness
      : mode == ThemeMode.dark
      ? Brightness.dark
      : Brightness.light;

  Map<String, String> toJson() => {'mode': mode.name, 'palette': palette.name};

  void apply(Map<String, dynamic> json) {
    final nextMode =
        ThemeMode.values.where((v) => v.name == json['mode']).firstOrNull ??
        ThemeMode.dark;
    final nextPalette =
        MimioPalette.values
            .where((v) => v.name == json['palette'])
            .firstOrNull ??
        MimioPalette.green;
    if (mode == nextMode && palette == nextPalette) return;
    mode = nextMode;
    palette = nextPalette;
    notifyListeners();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    apply({
      'mode': prefs.getString('ui.appearance.mode'),
      'palette': prefs.getString('ui.appearance.palette'),
    });
  }

  Future<void> set({ThemeMode? mode, MimioPalette? palette}) async {
    final nextMode = mode ?? this.mode;
    final nextPalette = palette ?? this.palette;
    final prefs = await SharedPreferences.getInstance();
    final savedMode = await prefs.setString(
      'ui.appearance.mode',
      nextMode.name,
    );
    final savedPalette = await prefs.setString(
      'ui.appearance.palette',
      nextPalette.name,
    );
    if (!savedMode || !savedPalette) throw StateError('Appearance save failed');
    apply({'mode': nextMode.name, 'palette': nextPalette.name});
  }

  void updateSystemBrightness(Brightness next) {
    if (next == systemBrightness) return;
    systemBrightness = next;
    if (mode == ThemeMode.system) notifyListeners();
  }
}

final appAppearance = AppearanceController();

class AppearanceScope extends InheritedNotifier<AppearanceController> {
  AppearanceScope({super.key, required super.child})
    : super(notifier: appAppearance);
  static void watch(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppearanceScope>();
}

class AppearanceApp extends StatefulWidget {
  const AppearanceApp({super.key, required this.builder});
  final Widget Function() builder;
  @override
  State<AppearanceApp> createState() => _AppearanceAppState();
}

class _AppearanceAppState extends State<AppearanceApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    appAppearance.addListener(_syncWindowTheme);
    appAppearance.updateSystemBrightness(
      WidgetsBinding.instance.platformDispatcher.platformBrightness,
    );
    _syncWindowTheme();
  }

  Future<void> _syncWindowTheme() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.windows) return;
    try {
      await const MethodChannel('speakr/tray').invokeMethod<void>(
        'setAppearance',
        appAppearance.brightness == Brightness.dark,
      );
    } on MissingPluginException {
      // The floating recorder engine has no native title bar.
    }
  }

  @override
  void didChangePlatformBrightness() => appAppearance.updateSystemBrightness(
    WidgetsBinding.instance.platformDispatcher.platformBrightness,
  );
  @override
  void dispose() {
    appAppearance.removeListener(_syncWindowTheme);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppearanceScope(
    child: ListenableBuilder(
      listenable: appAppearance,
      builder: (context, _) => widget.builder(),
    ),
  );
}
