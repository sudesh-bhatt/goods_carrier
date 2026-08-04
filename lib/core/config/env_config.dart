import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Central access to secrets from the root `.env` file.
///
/// Setup: `cp .env.example .env` → set values → `dart run tool/sync_env.dart`
abstract final class EnvConfig {
  static var _loaded = false;

  static const _defaultApiBaseUrl = 'https://goodscarrier.ajonetech.com';

  /// Loads `.env` from assets. Call once in [main] before [runApp].
  static Future<void> load() async {
    if (_loaded) return;
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'EnvConfig: missing .env asset — copy .env.example to .env. $e',
        );
      }
    }
    _loaded = true;
  }

  /// Goods Carrier REST API base URL (no trailing slash).
  static String get apiBaseUrl {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    if (fromDefine.isNotEmpty) return fromDefine.replaceAll(RegExp(r'/+$'), '');

    final fromFile = dotenv.env['API_BASE_URL']?.trim();
    if (fromFile != null && fromFile.isNotEmpty) {
      return fromFile.replaceAll(RegExp(r'/+$'), '');
    }

    return _defaultApiBaseUrl;
  }

  /// When `false`, local dummy repositories are used (dev without backend).
  static bool get useRemoteApi {
    const fromDefine = String.fromEnvironment('USE_REMOTE_API');
    if (fromDefine.isNotEmpty) {
      return fromDefine.toLowerCase() == 'true';
    }

    final fromFile = dotenv.env['USE_REMOTE_API']?.trim().toLowerCase();
    if (fromFile != null && fromFile.isNotEmpty) {
      return fromFile == 'true';
    }

    return true;
  }

  /// Razorpay environment — `live` for production, `test` for sandbox.
  ///
  /// Must match the mode the backend creates orders in; a live key cannot pay
  /// a test order. Anything other than `live` resolves to `test`.
  static String get razorpayMode {
    const fromDefine = String.fromEnvironment('RAZORPAY_MODE');
    final raw = fromDefine.isNotEmpty
        ? fromDefine
        : (dotenv.env['RAZORPAY_MODE']?.trim() ?? '');
    return raw.toLowerCase() == 'live' ? 'live' : 'test';
  }

  static bool get isRazorpayLive => razorpayMode == 'live';

  /// Razorpay publishable key for the active [razorpayMode].
  ///
  /// Only a fallback — `razorpay_key` from the initiate response wins, since
  /// the order lives on whichever Razorpay account the backend used. Never
  /// holds the Key Secret; `.env` ships inside the app bundle.
  static String get razorpayKey {
    if (isRazorpayLive) {
      const fromDefine = String.fromEnvironment('RAZORPAY_KEY_LIVE');
      if (fromDefine.isNotEmpty) return fromDefine;

      final fromFile = dotenv.env['RAZORPAY_KEY_LIVE']?.trim();
      if (fromFile != null && fromFile.isNotEmpty) return fromFile;
    } else {
      const fromDefine = String.fromEnvironment('RAZORPAY_KEY_TEST');
      if (fromDefine.isNotEmpty) return fromDefine;

      final fromFile = dotenv.env['RAZORPAY_KEY_TEST']?.trim();
      if (fromFile != null && fromFile.isNotEmpty) return fromFile;
    }

    const legacyDefine = String.fromEnvironment('RAZORPAY_KEY');
    if (legacyDefine.isNotEmpty) return legacyDefine;

    final legacyFile = dotenv.env['RAZORPAY_KEY']?.trim();
    if (legacyFile != null && legacyFile.isNotEmpty) return legacyFile;

    return '';
  }

  /// Google Maps + Places (single key for native SDKs and Places REST).
  static String get googleApiKey {
    const fromDefine = String.fromEnvironment('GOOGLE_API_KEY');
    if (fromDefine.isNotEmpty) return fromDefine;

    final fromFile = dotenv.env['GOOGLE_API_KEY']?.trim();
    if (fromFile != null && fromFile.isNotEmpty) return fromFile;

    return '';
  }

  /// Full iOS App Store URL used by update prompts.
  static String get iosAppStoreUrl {
    const fromDefine = String.fromEnvironment('IOS_APP_STORE_URL');
    if (fromDefine.isNotEmpty) return fromDefine;

    final fromFile = dotenv.env['IOS_APP_STORE_URL']?.trim();
    if (fromFile != null && fromFile.isNotEmpty) return fromFile;

    return '';
  }
}
