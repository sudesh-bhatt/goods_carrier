// Smoke test — verifies the app boots without throwing.
//
// Full integration tests live in test/integration/ (added in Session 7).
// This file is intentionally minimal: it just ensures [GoodsCarrierApp] mounts
// without errors, which catches broken provider graphs and missing
// ThemeExtension registrations early.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:goods_carrier/app.dart';
import 'package:goods_carrier/core/providers/shared_preferences_provider.dart';
import 'package:goods_carrier/features/settings/presentation/providers/locale_provider.dart';
import 'package:goods_carrier/features/settings/presentation/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  testWidgets('App boots without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          themeProvider.overrideWith((ref) => ThemeNotifier(ThemeMode.system)),
          localeProvider.overrideWith((ref) => LocaleNotifier(const Locale('en'))),
        ],
        child: const GoodsCarrierApp(),
      ),
    );

    // Give async providers (SharedPreferences init) time to settle.
    await tester.pumpAndSettle();

    // The app should render *something* — at minimum a Material widget.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
