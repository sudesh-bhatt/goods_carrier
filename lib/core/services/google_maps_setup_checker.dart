import 'package:flutter/foundation.dart';

import '../config/google_maps_config.dart';

/// Debug-only console hints for native Maps SDK setup.
///
/// Maps SDK for iOS/Android cannot be verified over REST — enabling
/// Maps Static API is unrelated. We only check that `.env` has a key.
abstract final class GoogleMapsSetupChecker {
  static var _logged = false;

  /// Logs setup hints once per app session in debug builds.
  static void logSetupHintsIfNeeded() {
    if (!kDebugMode || _logged) return;
    _logged = true;

    if (!GoogleMapsConfig.isConfigured) {
      debugPrint(
        '[GoogleMapsSetup] GOOGLE_API_KEY missing in .env — '
        'run: dart run tool/sync_env.dart',
      );
      return;
    }

    debugPrint(
      '[GoogleMapsSetup] env key present. Native tiles need Maps SDK for iOS '
      '(bundle/package: com.goodscarrier.app) in Google Cloud Console.',
    );
  }
}
