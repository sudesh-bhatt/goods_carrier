import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/utils/platform_utils.dart';
import 'features/settings/presentation/providers/locale_provider.dart';
import 'features/settings/presentation/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Android: draw content behind status/nav bars.
  PlatformUtils.enableEdgeToEdge();

  // Lock to portrait for Android and iOS.
  await PlatformUtils.lockPortrait();

  // Read both persisted preferences before the first frame so there is
  // no flicker on theme or language on cold start.
  final prefs = await SharedPreferences.getInstance();
  final savedThemeMode = loadPersistedThemeMode(prefs);
  final savedLocale = loadPersistedLocale(prefs);

  runApp(
    ProviderScope(
      overrides: [
        themeProvider.overrideWith((ref) => ThemeNotifier(savedThemeMode)),
        localeProvider.overrideWith((ref) => LocaleNotifier(savedLocale)),
      ],
      child: const GoodsCarrierApp(),
    ),
  );
}
