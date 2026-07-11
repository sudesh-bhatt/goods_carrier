import 'package:flutter_test/flutter_test.dart';
import 'package:goods_carrier/core/utils/app_version_utils.dart';

void main() {
  group('AppVersionUtils.isBelowMinimum', () {
    test('null minimum is not below', () {
      expect(
        AppVersionUtils.isBelowMinimum(installed: '1.0.0', minimum: null),
        false,
      );
    });

    test('equal versions are not below', () {
      expect(
        AppVersionUtils.isBelowMinimum(installed: '1.0.0', minimum: '1.0.0'),
        false,
      );
    });

    test('patch below minimum', () {
      expect(
        AppVersionUtils.isBelowMinimum(installed: '1.0.0', minimum: '1.0.1'),
        true,
      );
    });

    test('double-digit segment greater than single-digit', () {
      expect(
        AppVersionUtils.isBelowMinimum(installed: '1.10.0', minimum: '1.2.0'),
        false,
      );
    });

    test('double-digit minimum segment', () {
      expect(
        AppVersionUtils.isBelowMinimum(installed: '1.2.0', minimum: '1.10.0'),
        true,
      );
    });
  });
}
