import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/providers/shared_preferences_provider.dart';

const _kPushNotificationsKey = 'push_notifications_enabled_v1';

class PushNotificationsNotifier extends StateNotifier<bool> {
  PushNotificationsNotifier(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static bool _load(SharedPreferences prefs) =>
      prefs.getBool(_kPushNotificationsKey) ?? true;

  Future<void> setEnabled(bool value) async {
    state = value;
    await _prefs.setBool(_kPushNotificationsKey, value);
  }
}

final pushNotificationsProvider =
    StateNotifierProvider<PushNotificationsNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PushNotificationsNotifier(prefs);
});
