import 'package:flutter_test/flutter_test.dart';
import 'package:goods_carrier/shared/data/api/app/app_config_api_client.dart';

void main() {
  test('parses live payload and defaults force_update', () {
    final data = AppConfigData.fromJson({
      'app_name': 'Goods Carrier',
      'app_tagline': 'Your logistics partner',
      'logo_url': null,
      'supported_languages': [
        {'code': 'en', 'name': 'English'},
      ],
      'default_language': 'en',
      'minimum_android_version': null,
      'minimum_ios_version': '1.2.0',
      'maintenance_mode': true,
      'app_url': 'https://goodscarrier.ajonetech.com',
      'app_icon': 'app_settings/x.png',
      'app_icon_url': '/storage/app_settings/x.png',
    });
    expect(data.appName, 'Goods Carrier');
    expect(data.forceUpdate, isFalse);
    expect(data.maintenanceMode, isTrue);
    expect(data.appIconUrl, '/storage/app_settings/x.png');
    expect(data.supportedLanguages.single.code, 'en');
  });

  test('parses boolean flags from tolerant wire formats', () {
    final truthyValues = [true, 1, 'true', 'TRUE', '1'];
    for (final value in truthyValues) {
      final data = AppConfigData.fromJson({
        'force_update': value,
        'maintenance_mode': value,
      });

      expect(data.forceUpdate, isTrue, reason: 'force_update: $value');
      expect(
        data.maintenanceMode,
        isTrue,
        reason: 'maintenance_mode: $value',
      );
    }

    final falseyValues = [false, 0, 'false', 'FALSE', '0', null, 'yes', 2];
    for (final value in falseyValues) {
      final data = AppConfigData.fromJson({
        'force_update': value,
        'maintenance_mode': value,
      });

      expect(data.forceUpdate, isFalse, reason: 'force_update: $value');
      expect(
        data.maintenanceMode,
        isFalse,
        reason: 'maintenance_mode: $value',
      );
    }
  });
}
