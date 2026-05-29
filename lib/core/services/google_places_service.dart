import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/google_places_config.dart';

/// A single Places Autocomplete prediction.
class PlacePrediction {
  const PlacePrediction({
    required this.placeId,
    required this.description,
  });

  final String placeId;
  final String description;
}

/// Parsed address fields + coordinates from Place Details.
class PlaceAddressDetails {
  const PlaceAddressDetails({
    required this.fullAddressLine,
    required this.city,
    required this.pincode,
    required this.latitude,
    required this.longitude,
  });

  final String fullAddressLine;
  final String city;
  final String pincode;
  final double latitude;
  final double longitude;
}

/// Thin client for Google Places Autocomplete + Place Details (legacy REST).
///
/// Docs: https://developers.google.com/maps/documentation/places/web-service/autocomplete
class GooglePlacesService {
  GooglePlacesService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://maps.googleapis.com/maps/api',
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            );

  final Dio _dio;

  bool get isAvailable => GooglePlacesConfig.isConfigured;

  /// Returns address predictions restricted to India.
  Future<List<PlacePrediction>> fetchPredictions({
    required String input,
    required String sessionToken,
  }) async {
    if (!isAvailable || input.trim().length < 3) return [];

    _logRequest(
      endpoint: 'place/autocomplete/json',
      input: input.trim(),
      sessionToken: sessionToken,
    );

    const country = GooglePlacesConfig.autocompleteCountryCode;

    final response = await _dio.get<Map<String, dynamic>>(
      '/place/autocomplete/json',
      queryParameters: {
        'input': input.trim(),
        'key': GooglePlacesConfig.apiKey,
        'sessiontoken': sessionToken,
        // Hard limit: only places in this country (not a soft bias).
        'components': 'country:$country',
        // Prefer results inside the country (works with [components]).
        'region': country,
        'types': 'geocode',
      },
    );

    final status = response.data?['status'] as String? ?? '';
    final errorMessage = response.data?['error_message'] as String?;

    _logResponse(
      endpoint: 'place/autocomplete/json',
      status: status,
      errorMessage: errorMessage,
      resultCount: (response.data?['predictions'] as List?)?.length,
    );

    if (status != 'OK' && status != 'ZERO_RESULTS') {
      throw GooglePlacesException(
        status: status,
        errorMessage: errorMessage,
      );
    }

    final predictions = response.data?['predictions'] as List<dynamic>? ?? [];
    return predictions
        .map((p) {
          final map = p as Map<String, dynamic>;
          return PlacePrediction(
            placeId: map['place_id'] as String,
            description: map['description'] as String,
          );
        })
        .toList();
  }

  /// Country is enforced server-side via `components=country:xx` on the request.

  /// Resolves [placeId] to a formatted street address.
  Future<String> fetchFormattedAddress({
    required String placeId,
    required String sessionToken,
  }) async {
    if (!isAvailable) return '';
    final details = await fetchPlaceAddressDetails(
      placeId: placeId,
      sessionToken: sessionToken,
    );
    return details.fullAddressLine;
  }

  /// Full address breakdown + lat/lng for map pin placement.
  Future<PlaceAddressDetails> fetchPlaceAddressDetails({
    required String placeId,
    required String sessionToken,
  }) async {
    if (!isAvailable) {
      throw GooglePlacesException(status: 'NOT_CONFIGURED');
    }

    _logRequest(
      endpoint: 'place/details/json',
      placeId: placeId,
      sessionToken: sessionToken,
    );

    final response = await _dio.get<Map<String, dynamic>>(
      '/place/details/json',
      queryParameters: {
        'place_id': placeId,
        'key': GooglePlacesConfig.apiKey,
        'sessiontoken': sessionToken,
        'fields': 'formatted_address,address_components,geometry',
      },
    );

    final status = response.data?['status'] as String? ?? '';
    final errorMessage = response.data?['error_message'] as String?;

    _logResponse(
      endpoint: 'place/details/json',
      status: status,
      errorMessage: errorMessage,
    );

    if (status != 'OK') {
      throw GooglePlacesException(
        status: status,
        errorMessage: errorMessage,
      );
    }

    final result = response.data?['result'] as Map<String, dynamic>? ?? {};
    return _parsePlaceAddressDetails(result);
  }

  static PlaceAddressDetails _parsePlaceAddressDetails(
    Map<String, dynamic> result,
  ) {
    final formatted = result['formatted_address'] as String? ?? '';
    final components =
        (result['address_components'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();

    String? component(String type) {
      for (final entry in components) {
        final types = (entry['types'] as List<dynamic>? ?? []).cast<String>();
        if (types.contains(type)) {
          return entry['long_name'] as String?;
        }
      }
      return null;
    }

    final city = component('locality') ??
        component('administrative_area_level_2') ??
        component('sublocality_level_1') ??
        component('sublocality') ??
        '';

    final pincode = component('postal_code') ?? '';

    final streetParts = [
      component('premise'),
      component('subpremise'),
      component('street_number'),
      component('route'),
      component('sublocality_level_2'),
      component('sublocality_level_1'),
      component('neighborhood'),
    ].whereType<String>().where((part) => part.trim().isNotEmpty);

    var fullAddressLine = streetParts.join(', ');
    if (fullAddressLine.isEmpty) {
      fullAddressLine = _stripCountryAndPincode(formatted, city, pincode);
    }

    final geometry = result['geometry'] as Map<String, dynamic>? ?? {};
    final location = geometry['location'] as Map<String, dynamic>? ?? {};
    final latitude = (location['lat'] as num?)?.toDouble() ?? 0;
    final longitude = (location['lng'] as num?)?.toDouble() ?? 0;

    return PlaceAddressDetails(
      fullAddressLine: fullAddressLine.isNotEmpty ? fullAddressLine : formatted,
      city: city,
      pincode: pincode,
      latitude: latitude,
      longitude: longitude,
    );
  }

  static String _stripCountryAndPincode(
    String formatted,
    String city,
    String pincode,
  ) {
    var line = formatted;
    if (pincode.isNotEmpty) {
      line = line.replaceAll(RegExp('\\b$pincode\\b'), '').trim();
    }
    if (city.isNotEmpty) {
      line = line.replaceAll('$city,', '').replaceAll(city, '').trim();
    }
    line = line.replaceAll(', India', '').replaceAll('India', '').trim();
    while (line.endsWith(',')) {
      line = line.substring(0, line.length - 1).trim();
    }
    return line.isNotEmpty ? line : formatted;
  }

  static void _logRequest({
    required String endpoint,
    String? input,
    String? placeId,
    String? sessionToken,
  }) {
    if (!kDebugMode) return;

    debugPrint('[GooglePlaces] → GET $endpoint');
    debugPrint('[GooglePlaces]   key: ${_maskKey(GooglePlacesConfig.apiKey)}');
    debugPrint('[GooglePlaces]   configured: ${GooglePlacesConfig.isConfigured}');
    if (input != null) debugPrint('[GooglePlaces]   input: "$input"');
    if (placeId != null) debugPrint('[GooglePlaces]   placeId: $placeId');
    if (sessionToken != null) {
      debugPrint('[GooglePlaces]   sessionToken: ${_maskKey(sessionToken)}');
    }
  }

  static void _logResponse({
    required String endpoint,
    required String status,
    String? errorMessage,
    int? resultCount,
  }) {
    if (!kDebugMode) return;

    debugPrint('[GooglePlaces] ← $endpoint status=$status');
    if (errorMessage != null) {
      debugPrint('[GooglePlaces]   error_message: $errorMessage');
    }
    if (resultCount != null) {
      debugPrint('[GooglePlaces]   predictions: $resultCount');
    }
    if (status == 'REQUEST_DENIED') {
      debugPrint('[GooglePlaces] REQUEST_DENIED checklist:');
      debugPrint('[GooglePlaces]   1. Enable "Places API" in Google Cloud Console');
      debugPrint('[GooglePlaces]   2. Enable billing on the GCP project');
      debugPrint('[GooglePlaces]   3. Key restrictions must allow Places REST '
          '(Android/iOS-only keys often block server/HTTP calls)');
      debugPrint('[GooglePlaces]   4. Verify GOOGLE_API_KEY in .env matches Console key');
    }
  }

  static String _maskKey(String value) {
    if (value.isEmpty) return '(empty)';
    if (value.length <= 8) return '***';
    return '${value.substring(0, 8)}…';
  }
}

class GooglePlacesException implements Exception {
  GooglePlacesException({
    required this.status,
    this.errorMessage,
  });

  final String status;
  final String? errorMessage;

  /// User-facing hint; full detail stays in [errorMessage] / logs.
  String get displayMessage {
    if (status == 'REQUEST_DENIED') {
      return 'Address search unavailable. Check Places API key setup.';
    }
    if (status == 'OVER_QUERY_LIMIT') {
      return 'Address search limit reached. Try again later.';
    }
    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return errorMessage!;
    }
    return status;
  }

  @override
  String toString() =>
      'GooglePlacesException(status: $status, errorMessage: $errorMessage)';
}
