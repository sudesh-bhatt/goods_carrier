/// Google Maps SDK configuration.
///
/// Uses the same dart-define as Places when a dedicated maps key is not set:
/// ```bash
/// flutter run --dart-define=GOOGLE_PLACES_API_KEY=your_key_here
/// ```
///
/// Enable **Maps SDK for Android** and **Maps SDK for iOS** in Google Cloud.
abstract final class GoogleMapsConfig {
  static const String _mapsKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  static const String _placesKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
    defaultValue: '',
  );

  static String get apiKey =>
      _mapsKey.isNotEmpty ? _mapsKey : _placesKey;

  static bool get isConfigured => apiKey.isNotEmpty;

  /// Default map center (Gurgaon) when location is unavailable.
  static const defaultLatitude = 28.4595;
  static const defaultLongitude = 77.0266;
}
