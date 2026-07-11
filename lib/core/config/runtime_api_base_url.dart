import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'env_config.dart';

/// Mutable effective API base URL, bootstrapped from prefs or [EnvConfig].
///
/// Task 4 ([AppConfigNotifier]) must refresh the live Dio instance after
/// [set]: `ref.read(dioProvider).options.baseUrl = RuntimeApiBaseUrl.current`.
abstract final class RuntimeApiBaseUrl {
  static const prefsKey = 'runtime_api_base_url_v1';

  static String _current = '';

  static String get current {
    if (_current.isNotEmpty) return _current;
    return EnvConfig.apiBaseUrl;
  }

  static String normalize(String raw) =>
      raw.trim().replaceAll(RegExp(r'/+$'), '');

  static void initFromPrefs(SharedPreferences prefs) {
    final saved = prefs.getString(prefsKey)?.trim();
    if (saved != null && saved.isNotEmpty) {
      _current = normalize(saved);
    } else {
      _current = EnvConfig.apiBaseUrl;
    }
  }

  static Future<void> set(String? url, {SharedPreferences? prefs}) async {
    final trimmed = url?.trim() ?? '';
    if (trimmed.isEmpty) return;
    _current = normalize(trimmed);
    if (prefs != null) {
      await prefs.setString(prefsKey, _current);
    }
  }

  @visibleForTesting
  static void resetForTest({required String bootstrap}) {
    _current = normalize(bootstrap);
  }
}
