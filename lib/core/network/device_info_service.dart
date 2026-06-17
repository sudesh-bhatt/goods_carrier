import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/shared_preferences_provider.dart';

/// Persists a stable device id and exposes platform type for API headers.
class DeviceInfoService {
  DeviceInfoService(this._prefs);

  static const _kDeviceIdKey = 'api_device_id_v1';

  final SharedPreferences _prefs;

  String get deviceType => Platform.isIOS ? 'ios' : 'android';

  String get deviceId {
    final existing = _prefs.getString(_kDeviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;

    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    final generated = base64Url.encode(bytes).replaceAll('=', '');
    _prefs.setString(_kDeviceIdKey, generated);
    return generated;
  }
}

final deviceInfoServiceProvider = Provider<DeviceInfoService>((ref) {
  return DeviceInfoService(ref.read(sharedPreferencesProvider));
});
