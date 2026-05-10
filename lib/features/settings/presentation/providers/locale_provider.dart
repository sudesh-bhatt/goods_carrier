import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Constants ─────────────────────────────────────────────────────────────

const _kLocaleKey = 'app_locale';

/// All locales the app supports. Order matches the language picker UI.
const supportedAppLocales = [
  Locale('en'),
  Locale('hi'),
  Locale('gu'),
];

// ─── StateNotifier ─────────────────────────────────────────────────────────

/// Manages the current [Locale] and persists the choice via [SharedPreferences].
///
/// Usage:
/// ```dart
/// final locale   = ref.watch(localeProvider);
/// final switcher = ref.read(localeProvider.notifier);
///
/// switcher.setLocale(const Locale('hi'));
/// ```
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(super.initial);

  /// Persist [locale] and update state immediately.
  /// Only accepts a locale that exists in [supportedAppLocales].
  Future<void> setLocale(Locale locale) async {
    assert(
      supportedAppLocales.contains(locale),
      'Locale $locale is not in supportedAppLocales',
    );
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, locale.languageCode);
  }

  bool get isEnglish => state.languageCode == 'en';
  bool get isHindi => state.languageCode == 'hi';
  bool get isGujarati => state.languageCode == 'gu';
}

// ─── Provider ──────────────────────────────────────────────────────────────

/// Seeded in [main.dart] via [ProviderScope.overrides] with the value
/// read from SharedPreferences before [runApp].
///
/// ```dart
/// // main.dart
/// final prefs = await SharedPreferences.getInstance();
/// final savedLocale = loadPersistedLocale(prefs);
///
/// runApp(
///   ProviderScope(
///     overrides: [
///       localeProvider.overrideWith((ref) => LocaleNotifier(savedLocale)),
///     ],
///     child: const GoodsCarrierApp(),
///   ),
/// );
/// ```
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(const Locale('en')),
);

// ─── Bootstrap helper ──────────────────────────────────────────────────────

/// Reads the persisted language code from SharedPreferences.
/// Falls back to English if nothing is saved or the code is unrecognised.
Locale loadPersistedLocale(SharedPreferences prefs) {
  final code = prefs.getString(_kLocaleKey);
  return supportedAppLocales.firstWhere(
    (l) => l.languageCode == code,
    orElse: () => const Locale('en'),
  );
}
