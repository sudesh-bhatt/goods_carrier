import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_envelope.dart';

class CustomerSettingsData {
  const CustomerSettingsData({
    this.pushNotificationsEnabled = true,
    this.languageCode = 'en',
  });

  final bool pushNotificationsEnabled;
  final String languageCode;
}

class CustomerSettingsApiClient {
  CustomerSettingsApiClient(this._dio);

  final Dio _dio;

  Future<CustomerSettingsData> fetchSettings() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.customerSettings,
    );
    final data = ApiEnvelope.parseData(response.data);
    return CustomerSettingsData(
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
      ApiConstants.customerSettingsPush,
      data: {'push_notifications': enabled},
    );
  }

  Future<void> updateLanguage(String languageCode) async {
    await _dio.post<void>(
      ApiConstants.customerSettingsLanguage,
      data: {'language': languageCode},
    );
  }
}
