import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/config/env_config.dart';
import 'core/config/runtime_api_base_url.dart';
import 'core/providers/shared_preferences_provider.dart';
import 'core/utils/platform_utils.dart';
import 'features/settings/presentation/providers/locale_provider.dart';
import 'features/settings/presentation/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load();
  GoogleFonts.config.allowRuntimeFetching = false;

  // Android: draw content behind status/nav bars.
  PlatformUtils.enableEdgeToEdge();

  // Lock to portrait for Android and iOS.
  await PlatformUtils.lockPortrait();

  // Read both persisted preferences before the first frame so there is
  // no flicker on theme or language on cold start.
  final prefs = await SharedPreferences.getInstance();
  RuntimeApiBaseUrl.initFromPrefs(prefs);
  final savedThemeMode = loadPersistedThemeMode(prefs);
  final savedLocale = loadPersistedLocale(prefs);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        themeProvider.overrideWith((ref) => ThemeNotifier(savedThemeMode)),
        localeProvider.overrideWith((ref) => LocaleNotifier(savedLocale)),
      ],
      child: const GoodsCarrierApp(),
    ),
  );
}
