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

  /// Razorpay publishable key — used when initiate API does not return `razorpay_key`.
  static String get razorpayKey {
    const fromDefine = String.fromEnvironment('RAZORPAY_KEY');
    if (fromDefine.isNotEmpty) return fromDefine;

    final fromFile = dotenv.env['RAZORPAY_KEY']?.trim();
    if (fromFile != null && fromFile.isNotEmpty) return fromFile;

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
}
