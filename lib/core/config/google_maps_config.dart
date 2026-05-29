import 'env_config.dart';

/// Google Maps SDK (native map tiles).
abstract final class GoogleMapsConfig {
  static String get apiKey => EnvConfig.googleApiKey;

  static bool get isConfigured => apiKey.isNotEmpty;

  /// Default map center (Gurgaon) when location is unavailable.
  static const defaultLatitude = 28.4595;
  static const defaultLongitude = 77.0266;
}
