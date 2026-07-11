import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_envelope.dart';

class AppConfigLanguage {
  const AppConfigLanguage({required this.code, required this.name});

  final String code;
  final String name;

  Map<String, dynamic> toJson() => {'code': code, 'name': name};

  factory AppConfigLanguage.fromJson(Map<String, dynamic> json) =>
      AppConfigLanguage(
        code: json['code']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
      );
}

class AppConfigData {
  const AppConfigData({
    this.appName,
    this.appTagline,
    this.logoUrl,
    this.supportedLanguages = const [],
    this.defaultLanguage,
    this.minimumAndroidVersion,
    this.minimumIosVersion,
    this.forceUpdate = false,
    this.maintenanceMode = false,
    this.appUrl,
    this.appIcon,
    this.appIconUrl,
  });

  final String? appName;
  final String? appTagline;
  final String? logoUrl;
  final List<AppConfigLanguage> supportedLanguages;
  final String? defaultLanguage;
  final String? minimumAndroidVersion;
  final String? minimumIosVersion;
  final bool forceUpdate;
  final bool maintenanceMode;
  final String? appUrl;
  final String? appIcon;
  final String? appIconUrl;

  factory AppConfigData.fromJson(Map<String, dynamic> data) {
    final languagesRaw = data['supported_languages'];
    final languages = languagesRaw is List
        ? languagesRaw
            .whereType<Map<String, dynamic>>()
            .map(AppConfigLanguage.fromJson)
            .toList()
        : <AppConfigLanguage>[];

    return AppConfigData(
      appName: data['app_name']?.toString(),
      appTagline: data['app_tagline']?.toString(),
      logoUrl: data['logo_url']?.toString(),
      supportedLanguages: languages,
      defaultLanguage: data['default_language']?.toString(),
      minimumAndroidVersion: data['minimum_android_version']?.toString(),
      minimumIosVersion: data['minimum_ios_version']?.toString(),
      forceUpdate: data['force_update'] as bool? ?? false,
      maintenanceMode: data['maintenance_mode'] as bool? ?? false,
      appUrl: data['app_url']?.toString(),
      appIcon: data['app_icon']?.toString(),
      appIconUrl: data['app_icon_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'app_name': appName,
        'app_tagline': appTagline,
        'logo_url': logoUrl,
        'supported_languages':
            supportedLanguages.map((language) => language.toJson()).toList(),
        'default_language': defaultLanguage,
        'minimum_android_version': minimumAndroidVersion,
        'minimum_ios_version': minimumIosVersion,
        'force_update': forceUpdate,
        'maintenance_mode': maintenanceMode,
        'app_url': appUrl,
        'app_icon': appIcon,
        'app_icon_url': appIconUrl,
      };
}

class AppConfigApiClient {
  AppConfigApiClient(this._dio);

  final Dio _dio;

  Future<AppConfigData> fetchConfig() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.appConfig,
    );
    final data = ApiEnvelope.parseData(response.data);
    return AppConfigData.fromJson(data);
  }
}
