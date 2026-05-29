import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Central access to secrets from the root `.env` file.
///
/// Setup: `cp .env.example .env` → set [googleApiKey] → `dart run tool/sync_env.dart`
abstract final class EnvConfig {
  static var _loaded = false;

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

  /// Google Maps + Places (single key for native SDKs and Places REST).
  static String get googleApiKey {
    const fromDefine = String.fromEnvironment('GOOGLE_API_KEY');
    if (fromDefine.isNotEmpty) return fromDefine;

    final fromFile = dotenv.env['GOOGLE_API_KEY']?.trim();
    if (fromFile != null && fromFile.isNotEmpty) return fromFile;

    return '';
  }
}
