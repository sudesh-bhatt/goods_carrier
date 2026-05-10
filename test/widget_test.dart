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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Provide a clean SharedPreferences mock for each test so
    // ThemeProvider and LocaleProvider initialise without touching disk.
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App boots without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: GoodsCarrierApp(),
      ),
    );

    // Give async providers (SharedPreferences init) time to settle.
    await tester.pumpAndSettle();

    // The app should render *something* — at minimum a Material widget.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
