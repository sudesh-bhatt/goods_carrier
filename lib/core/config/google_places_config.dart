/// Google Places API configuration.
///
/// Pass the key at build/run time:
/// ```bash
/// flutter run --dart-define=GOOGLE_PLACES_API_KEY=your_key_here
/// ```
///
/// Enable **Places API** and **Places API (New)** or legacy Places in Google Cloud,
/// and restrict the key (Android/iOS app + API restrictions).
abstract final class GooglePlacesConfig {
  static const String apiKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
    defaultValue: '',
  );

  static bool get isConfigured => apiKey.isNotEmpty;
}
