import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goods_carrier/core/router/app_routes.dart';
import 'package:goods_carrier/features/auth/presentation/screens/splash_screen.dart';
import 'package:goods_carrier/l10n/app_localizations.dart';
import 'package:goods_carrier/shared/data/api/app/app_config_api_client.dart';

void main() {
  group('splash config gates', () {
    test('maintenance mode blocks splash flow with maintenance route', () {
      expect(
        splashGateRedirectForConfig(
          const AppConfigData(maintenanceMode: true),
        ),
        AppRoutes.maintenance,
      );
    });

    test('non-maintenance config does not block splash flow', () {
      expect(
        splashGateRedirectForConfig(const AppConfigData()),
        isNull,
      );
    });

    test('prompts for update only when current version is below minimum', () {
      expect(shouldPromptUpdate(isBelowPlatformMinimum: true), isTrue);
      expect(shouldPromptUpdate(isBelowPlatformMinimum: false), isFalse);
    });
  });

  group('update dialog', () {
    test('force update disallows Later', () {
      expect(updateDialogAllowsLater(force: true), isFalse);
    });

    test('optional update allows Later', () {
      expect(updateDialogAllowsLater(force: false), isTrue);
    });

    test('force update repeats dialog after update starts', () {
      expect(
        shouldRepeatUpdateDialog(force: true, updateStarted: true),
        isTrue,
      );
      expect(
        shouldRepeatUpdateDialog(force: false, updateStarted: true),
        isFalse,
      );
      expect(
        shouldRepeatUpdateDialog(force: true, updateStarted: false),
        isFalse,
      );
    });

    testWidgets('force update dialog has no Later action and cannot pop', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              return buildUpdateDialogContent(
                context: context,
                force: true,
                onLater: () {},
                onUpdate: () async {},
              );
            },
          ),
        ),
      );

      expect(find.text('Later'), findsNothing);
      expect(find.text('Update'), findsOneWidget);
      expect(tester.widget<PopScope>(find.byType(PopScope)).canPop, isFalse);
    });

    testWidgets('optional update dialog has Later action and can pop', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              return buildUpdateDialogContent(
                context: context,
                force: false,
                onLater: () {},
                onUpdate: () async {},
              );
            },
          ),
        ),
      );

      expect(find.text('Later'), findsOneWidget);
      expect(find.text('Update'), findsOneWidget);
      expect(tester.widget<PopScope>(find.byType(PopScope)).canPop, isTrue);
    });
  });

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
