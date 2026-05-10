import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Platform-level helpers — status bar, haptics, safe area, keyboard.
/// All methods are static; no instances needed.
class PlatformUtils {
  PlatformUtils._();

  // ─── Status bar ────────────────────────────────────────────────────────────

  /// Forces the Android system status-bar icons to dark (for light screens).
  static void setStatusBarDark() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Android
        statusBarBrightness: Brightness.light,    // iOS (inverted logic)
      ),
    );
  }

  /// Forces the status-bar icons to light (for dark / orange screens).
  static void setStatusBarLight() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  /// Applies the correct status-bar style for [brightness].
  /// Call this from AppBar or screen initState when the status-bar colour
  /// must match the current theme.
  static void applyStatusBarForBrightness(Brightness brightness) {
    if (brightness == Brightness.light) {
      setStatusBarDark();
    } else {
      setStatusBarLight();
    }
  }

  // ─── Edge-to-edge (Android) ────────────────────────────────────────────────

  /// Enables edge-to-edge rendering on Android: content draws behind the
  /// system bars. Call once in [main] before [runApp].
  static void enableEdgeToEdge() {
    if (Platform.isAndroid) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
    }
  }

  // ─── Orientation lock ──────────────────────────────────────────────────────

  /// Lock the app to portrait mode (call once in main).
  static Future<void> lockPortrait() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // ─── Haptics ───────────────────────────────────────────────────────────────

  /// Light tap — button presses, list-item taps.
  static Future<void> lightImpact() =>
      HapticFeedback.lightImpact();

  /// Medium impact — confirm actions, swipe-to-delete.
  static Future<void> mediumImpact() =>
      HapticFeedback.mediumImpact();

  /// Heavy impact — destructive actions, errors.
  static Future<void> heavyImpact() =>
      HapticFeedback.heavyImpact();

  /// Selection click — toggles, pickers, segment taps.
  static Future<void> selectionClick() =>
      HapticFeedback.selectionClick();

  // ─── Safe area helpers ─────────────────────────────────────────────────────

  /// Top padding: status bar height. Use instead of hardcoding 24 / 44.
  static double statusBarHeight(BuildContext context) =>
      MediaQuery.of(context).padding.top;

  /// Bottom padding: home-indicator height (iPhone) / gesture bar (Android).
  static double bottomInset(BuildContext context) =>
      MediaQuery.of(context).padding.bottom;

  /// True when the software keyboard is fully or partially visible.
  static bool isKeyboardVisible(BuildContext context) =>
      MediaQuery.of(context).viewInsets.bottom > 0;

  /// Height the keyboard currently occupies (0 when hidden).
  static double keyboardHeight(BuildContext context) =>
      MediaQuery.of(context).viewInsets.bottom;

  // ─── Platform checks ───────────────────────────────────────────────────────

  static bool get isAndroid => Platform.isAndroid;
  static bool get isIOS => Platform.isIOS;

  // ─── Keyboard dismiss ──────────────────────────────────────────────────────

  /// Hides the software keyboard without moving focus elsewhere.
  static void dismissKeyboard(BuildContext context) {
    final current = FocusScope.of(context);
    if (!current.hasPrimaryFocus) current.unfocus();
  }
}
