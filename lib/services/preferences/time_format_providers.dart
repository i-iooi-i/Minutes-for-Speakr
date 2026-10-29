import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'time_format_preference.dart';
import 'time_format_store.dart';

final timeFormatStoreProvider = FutureProvider<TimeFormatStore>((ref) async {
  return TimeFormatStore.open();
});

final timeFormatPreferenceProvider = FutureProvider<TimeFormatPreference>((
  ref,
) async {
  final store = await ref.watch(timeFormatStoreProvider.future);
  return store.read();
});

class TimeFormatController {
  TimeFormatController(this._ref);
  final Ref _ref;

  Future<void> set(TimeFormatPreference next) async {
    final store = await _ref.read(timeFormatStoreProvider.future);
    await store.write(next);
    _ref.invalidate(timeFormatPreferenceProvider);
  }
}

final timeFormatControllerProvider = Provider<TimeFormatController>(
  (ref) => TimeFormatController(ref),
);
