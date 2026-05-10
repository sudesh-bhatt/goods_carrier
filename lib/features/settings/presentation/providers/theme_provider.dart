import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Key ───────────────────────────────────────────────────────────────────

const _kThemeModeKey = 'theme_mode';

// ─── Codec helpers ─────────────────────────────────────────────────────────

int _themeModeToInt(ThemeMode mode) => switch (mode) {
      ThemeMode.light => 0,
      ThemeMode.dark => 1,
      ThemeMode.system => 2,
    };

ThemeMode _intToThemeMode(int? raw) => switch (raw) {
      0 => ThemeMode.light,
      1 => ThemeMode.dark,
      _ => ThemeMode.system, // null / unknown → follow system
    };

// ─── StateNotifier ─────────────────────────────────────────────────────────

/// Manages [ThemeMode] and persists the choice via [SharedPreferences].
///
/// Usage:
/// ```dart
/// final mode   = ref.watch(themeProvider);
/// final toggle = ref.read(themeProvider.notifier);
///
/// toggle.setMode(ThemeMode.dark);
/// toggle.cycle(); // system → light → dark → system
/// ```
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier(super.initial);

  /// Persist [mode] and update state immediately.
  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemeModeKey, _themeModeToInt(mode));
  }

  /// Cycle through system → light → dark → system.
  Future<void> cycle() => setMode(switch (state) {
        ThemeMode.system => ThemeMode.light,
        ThemeMode.light => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.system,
      });

  bool get isLight => state == ThemeMode.light;
  bool get isDark => state == ThemeMode.dark;
  bool get isSystem => state == ThemeMode.system;
}

// ─── Provider ──────────────────────────────────────────────────────────────

/// Seeded in [main.dart] via [ProviderScope.overrides] with the value
/// read from SharedPreferences before [runApp].
///
/// ```dart
/// // main.dart
/// final prefs = await SharedPreferences.getInstance();
/// final savedMode = loadPersistedThemeMode(prefs);
///
/// runApp(
///   ProviderScope(
///     overrides: [
///       themeProvider.overrideWith((ref) => ThemeNotifier(savedMode)),
///     ],
///     child: const GoodsCarrierApp(),
///   ),
/// );
/// ```
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(ThemeMode.system),
);

// ─── Bootstrap helper ──────────────────────────────────────────────────────

/// Call in [main] with the already-resolved [SharedPreferences] instance.
/// Avoids a second async call inside the provider.
ThemeMode loadPersistedThemeMode(SharedPreferences prefs) =>
    _intToThemeMode(prefs.getInt(_kThemeModeKey));
