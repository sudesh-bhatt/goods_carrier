import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_envelope.dart';

class AppConfigData {
  const AppConfigData({
    this.minAppVersion,
    this.maintenanceMode = false,
    this.termsUrl,
    this.privacyUrl,
  });

  final String? minAppVersion;
  final bool maintenanceMode;
  final String? termsUrl;
  final String? privacyUrl;
}

class AppConfigApiClient {
  AppConfigApiClient(this._dio);

  final Dio _dio;

  Future<AppConfigData> fetchConfig() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.appConfig,
    );
    final data = ApiEnvelope.parseData(response.data);
    return AppConfigData(
      minAppVersion: data['min_app_version']?.toString() ??
          data['minimum_version']?.toString(),
      maintenanceMode: data['maintenance_mode'] as bool? ?? false,
      termsUrl: data['terms_url']?.toString(),
      privacyUrl: data['privacy_url']?.toString(),
    );
  }
}
