import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../domain/enums/user_role.dart';

class UserSettingsData {
  const UserSettingsData({
    this.pushNotificationsEnabled = true,
    this.languageCode = 'en',
  });

  final bool pushNotificationsEnabled;
  final String languageCode;
}

/// Settings API client that targets the role-specific endpoints:
/// customers use `/api/customer/settings/*`, drivers use the shared
/// `/api/settings/*` endpoints.
class SettingsApiClient {
  SettingsApiClient(this._dio, {required UserRole role}) : _role = role;

  final Dio _dio;
  final UserRole _role;

  String get _settingsPath => _role == UserRole.driver
      ? ApiConstants.settings
      : ApiConstants.customerSettings;

  String get _pushPath => _role == UserRole.driver
      ? ApiConstants.settingsPush
      : ApiConstants.customerSettingsPush;

  String get _languagePath => _role == UserRole.driver
      ? ApiConstants.settingsLanguage
      : ApiConstants.customerSettingsLanguage;

  Future<UserSettingsData> fetchSettings() async {
    final response = await _dio.get<Map<String, dynamic>>(_settingsPath);
    final data = ApiEnvelope.parseData(response.data);
    return UserSettingsData(
      pushNotificationsEnabled:
          data['push_notifications'] as bool? ??
              data['push_notifications_enabled'] as bool? ??
              data['push_notification'] as bool? ??
              true,
      languageCode: data['language']?.toString() ??
          data['language_code']?.toString() ??
          'en',
    );
  }

  Future<void> updatePushNotification(bool enabled) async {
    await _dio.post<void>(
      _pushPath,
      data: {'push_notifications': enabled},
    );
  }

  Future<void> updateLanguage(String languageCode) async {
    await _dio.post<void>(
      _languagePath,
      data: {'language': languageCode},
    );
  }
}
