import '../entities/driver_trip.dart';

/// Contract for driver trip data operations.
abstract class ITripRepository {
  /// Returns all trips posted by [driverId].
  Future<List<DriverTrip>> getDriverTrips(String driverId);

  /// Posts a new available trip. Returns the persisted entity with the
  /// server-assigned VB-XXXX ID.
  Future<DriverTrip> postTrip(DriverTrip trip);

  /// Cancels an active trip. Throws [AppException] if the trip is not
  /// in a cancellable state.
  Future<void> cancelTrip(String tripId);
}
