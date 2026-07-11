import 'package:flutter_test/flutter_test.dart';
import 'package:goods_carrier/shared/data/api/app/app_config_api_client.dart';
import 'package:goods_carrier/shared/data/local/app_config_preferences_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('round-trips AppConfigData through SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = AppConfigPreferencesStore(prefs);

    expect(store.load(), isNull);

    const config = AppConfigData(
      appName: 'Goods Carrier',
      appTagline: 'Your logistics partner',
      supportedLanguages: [
        AppConfigLanguage(code: 'en', name: 'English'),
      ],
      defaultLanguage: 'en',
      minimumIosVersion: '1.2.0',
      maintenanceMode: true,
      appUrl: 'https://goodscarrier.ajonetech.com',
      appIcon: 'app_settings/x.png',
      appIconUrl: '/storage/app_settings/x.png',
    );

    await store.save(config);

    final loaded = store.load();
    expect(loaded, isNotNull);
    expect(loaded!.appName, config.appName);
    expect(loaded.appTagline, config.appTagline);
    expect(loaded.defaultLanguage, config.defaultLanguage);
    expect(loaded.minimumIosVersion, config.minimumIosVersion);
    expect(loaded.maintenanceMode, config.maintenanceMode);
    expect(loaded.appUrl, config.appUrl);
    expect(loaded.appIcon, config.appIcon);
    expect(loaded.appIconUrl, config.appIconUrl);
    expect(loaded.supportedLanguages.single.code, 'en');
    expect(loaded.supportedLanguages.single.name, 'English');
  });
}
