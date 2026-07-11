import 'package:flutter_test/flutter_test.dart';
import 'package:goods_carrier/core/branding/app_branding.dart';
import 'package:goods_carrier/l10n/app_localizations_en.dart';
import 'package:goods_carrier/shared/data/api/app/app_config_api_client.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('resolveAppName', () {
    test('returns remote when non-empty', () {
      const config = AppConfigData(appName: 'Remote Name');
      expect(resolveAppName(config, l10n), 'Remote Name');
    });

    test('falls back to l10n when config is null', () {
      expect(resolveAppName(null, l10n), l10n.appName);
    });

    test('falls back to l10n when remote is empty or whitespace', () {
      expect(resolveAppName(const AppConfigData(appName: ''), l10n), l10n.appName);
      expect(resolveAppName(const AppConfigData(appName: '   '), l10n), l10n.appName);
    });

    test('trims remote value', () {
      const config = AppConfigData(appName: '  Remote Name  ');
      expect(resolveAppName(config, l10n), 'Remote Name');
    });
  });

  group('resolveAppTagline', () {
    test('returns remote when non-empty', () {
      const config = AppConfigData(appTagline: 'Remote tagline');
      expect(resolveAppTagline(config, l10n), 'Remote tagline');
    });

    test('falls back to l10n when config is null', () {
      expect(resolveAppTagline(null, l10n), l10n.appTagline);
    });

    test('falls back to l10n when remote is empty or whitespace', () {
      expect(
        resolveAppTagline(const AppConfigData(appTagline: ''), l10n),
        l10n.appTagline,
      );
      expect(
        resolveAppTagline(const AppConfigData(appTagline: '  '), l10n),
        l10n.appTagline,
      );
    });

    test('trims remote value', () {
      const config = AppConfigData(appTagline: '  Remote tagline  ');
      expect(resolveAppTagline(config, l10n), 'Remote tagline');
    });
  });

  group('AppBranding', () {
    test('delegates to resolve helpers', () {
      const branding = AppBranding(AppConfigData(
        appName: 'Remote Name',
        appTagline: 'Remote tagline',
      ));
      expect(branding.appName(l10n), 'Remote Name');
      expect(branding.appTagline(l10n), 'Remote tagline');
    });
  });
}
