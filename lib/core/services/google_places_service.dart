import 'package:dio/dio.dart';

import '../config/google_places_config.dart';
/// Gooogle Api Key Android SDK== AIzaSyCcOuYM8_Wo-3bz61kAft6TFOvRdKsa84I
/// Gooogle Api Key IOS SDK== AIzaSyCPeryXfeNsD9G_gYfYHOHbka2CaF1PbnY
/// A single Places Autocomplete prediction.
class PlacePrediction {
  const PlacePrediction({
    required this.placeId,
    required this.description,
  });

  final String placeId;
  final String description;
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

    final response = await _dio.get<Map<String, dynamic>>(
      '/place/autocomplete/json',
      queryParameters: {
        'input': input.trim(),
        'key': GooglePlacesConfig.apiKey,
        'sessiontoken': sessionToken,
        'components': 'country:in',
        'types': 'address',
      },
    );

    final status = response.data?['status'] as String? ?? '';
    if (status != 'OK' && status != 'ZERO_RESULTS') {
      throw GooglePlacesException(status);
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

  /// Resolves [placeId] to a formatted street address.
  Future<String> fetchFormattedAddress({
    required String placeId,
    required String sessionToken,
  }) async {
    if (!isAvailable) return '';

    final response = await _dio.get<Map<String, dynamic>>(
      '/place/details/json',
      queryParameters: {
        'place_id': placeId,
        'key': GooglePlacesConfig.apiKey,
        'sessiontoken': sessionToken,
        'fields': 'formatted_address',
      },
    );

    final status = response.data?['status'] as String? ?? '';
    if (status != 'OK') {
      throw GooglePlacesException(status);
    }

    final result = response.data?['result'] as Map<String, dynamic>?;
    return result?['formatted_address'] as String? ?? '';
  }
}

class GooglePlacesException implements Exception {
  GooglePlacesException(this.status);
  final String status;

  @override
  String toString() => 'GooglePlacesException($status)';
}
