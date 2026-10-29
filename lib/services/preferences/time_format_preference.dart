import 'package:flutter/widgets.dart';

/// User preference for how clock-time is rendered. `system` means follow the
/// platform — `MediaQuery.alwaysUse24HourFormatOf` on Android/iOS. The
/// 12/24-hour overrides exist mostly for Windows, where Flutter does not
/// reliably reflect the OS short-time format.
enum TimeFormatPreference {
  system,
  twelveHour,
  twentyFourHour;

  String get storageValue => switch (this) {
    TimeFormatPreference.system => 'system',
    TimeFormatPreference.twelveHour => 'twelve',
    TimeFormatPreference.twentyFourHour => 'twentyFour',
  };

  static TimeFormatPreference fromStorage(String? raw) => switch (raw) {
    'twelve' => TimeFormatPreference.twelveHour,
    'twentyFour' => TimeFormatPreference.twentyFourHour,
    _ => TimeFormatPreference.system,
  };

  bool resolve(bool systemUses24Hour) => switch (this) {
    TimeFormatPreference.system => systemUses24Hour,
    TimeFormatPreference.twelveHour => false,
    TimeFormatPreference.twentyFourHour => true,
  };
}

bool resolveUse24Hour(TimeFormatPreference pref, BuildContext context) =>
    pref.resolve(MediaQuery.alwaysUse24HourFormatOf(context));
