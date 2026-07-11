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
}
