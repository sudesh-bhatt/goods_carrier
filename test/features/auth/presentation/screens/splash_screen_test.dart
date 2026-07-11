import 'package:flutter_test/flutter_test.dart';
import 'package:goods_carrier/features/auth/presentation/screens/splash_screen.dart';
import 'package:goods_carrier/shared/data/api/app/app_config_api_client.dart';

void main() {
  group('minimumVersionForCurrentPlatform', () {
    const config = AppConfigData(
      minimumAndroidVersion: '2.0.0',
      minimumIosVersion: '3.0.0',
    );

    test('uses Android minimum only on Android', () {
      expect(
        minimumVersionForCurrentPlatform(
          config,
          isAndroid: true,
          isIOS: false,
        ),
        '2.0.0',
      );
    });

    test('uses iOS minimum only on iOS', () {
      expect(
        minimumVersionForCurrentPlatform(
          config,
          isAndroid: false,
          isIOS: true,
        ),
        '3.0.0',
      );
    });

    test('ignores minimum versions on unsupported platforms', () {
      expect(
        minimumVersionForCurrentPlatform(
          config,
          isAndroid: false,
          isIOS: false,
        ),
        isNull,
      );
    });
  });
}
