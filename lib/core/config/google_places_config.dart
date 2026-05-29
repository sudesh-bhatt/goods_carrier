import 'env_config.dart';

/// Google Places API (REST autocomplete from Dart).
abstract final class GooglePlacesConfig {
  static String get apiKey => EnvConfig.googleApiKey;

  static bool get isConfigured => apiKey.isNotEmpty;

  /// ISO 3166-1 alpha-2 — autocomplete is restricted to this country only.
  static const String autocompleteCountryCode = 'in';
}
