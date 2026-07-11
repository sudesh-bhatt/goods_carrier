import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../api/app/app_config_api_client.dart';

/// Persists remote app config JSON for offline restore.
class AppConfigPreferencesStore {
  AppConfigPreferencesStore(this._prefs);

  static const _kConfigKey = 'app_config_json_v1';

  final SharedPreferences _prefs;

  AppConfigData? load() {
    final raw = _prefs.getString(_kConfigKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      return AppConfigData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(AppConfigData config) async {
    await _prefs.setString(_kConfigKey, jsonEncode(config.toJson()));
  }

  Future<void> clear() async {
    await _prefs.remove(_kConfigKey);
  }
}
