import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../config/google_maps_config.dart';

/// Resolves map camera targets — saved coords, device location, or fallback.
abstract final class MapLocationHelper {
  static const defaultPosition = LatLng(
    GoogleMapsConfig.defaultLatitude,
    GoogleMapsConfig.defaultLongitude,
  );

  static bool isValidCoordinate(double latitude, double longitude) {
    if (latitude.isNaN || longitude.isNaN) return false;
    if (latitude.abs() < 0.000001 && longitude.abs() < 0.000001) {
      return false;
    }
    if (latitude.abs() > 90 || longitude.abs() > 180) return false;
    return true;
  }

  /// Saved address coords when valid; otherwise current location; else Gurgaon default.
  static Future<LatLng> resolveInitialPosition({
    double? savedLatitude,
    double? savedLongitude,
  }) async {
    if (savedLatitude != null &&
        savedLongitude != null &&
        isValidCoordinate(savedLatitude, savedLongitude)) {
      if (kDebugMode) {
        debugPrint(
          '[MapLocation] using saved '
          '($savedLatitude, $savedLongitude)',
        );
      }
      return LatLng(savedLatitude, savedLongitude);
    }

    final current = await tryCurrentLocation();
    if (current != null) return current;

    if (kDebugMode) {
      debugPrint('[MapLocation] falling back to default center');
    }
    return defaultPosition;
  }

  /// GPS fix for the my-location button — skips stale last-known position.
  static Future<LatLng?> getFreshCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (isValidCoordinate(pos.latitude, pos.longitude)) {
        return LatLng(pos.latitude, pos.longitude);
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[MapLocation] fresh location failed: $e\n$st');
      }
    }
    return null;
  }

  static Future<LatLng?> tryCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode) {
          debugPrint('[MapLocation] location services disabled');
        }
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (kDebugMode) {
          debugPrint('[MapLocation] permission denied: $permission');
        }
        return null;
      }

      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null &&
          isValidCoordinate(lastKnown.latitude, lastKnown.longitude)) {
        if (kDebugMode) {
          debugPrint(
            '[MapLocation] using last known '
            '(${lastKnown.latitude}, ${lastKnown.longitude})',
          );
        }
        return LatLng(lastKnown.latitude, lastKnown.longitude);
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      if (isValidCoordinate(pos.latitude, pos.longitude)) {
        if (kDebugMode) {
          debugPrint(
            '[MapLocation] using current '
            '(${pos.latitude}, ${pos.longitude})',
          );
        }
        return LatLng(pos.latitude, pos.longitude);
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[MapLocation] current location failed: $e\n$st');
      }
    }
    return null;
  }
}
