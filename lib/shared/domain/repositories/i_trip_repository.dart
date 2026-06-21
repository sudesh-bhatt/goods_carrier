import '../entities/driver_trip.dart';
import '../models/driver_trip_detail.dart';
import '../models/trip_form_prefill.dart';
import '../models/trip_submit_options.dart';

/// Contract for driver trip data operations.
abstract class ITripRepository {
  /// Returns trips for the authenticated driver.
  Future<List<DriverTrip>> getDriverTrips(String driverId);

  /// Loads a single trip (`GET .../trips/{id}`).
  Future<DriverTrip> getTrip(String id);

  /// Loads trip detail with customer requests.
  Future<DriverTripDetail> getTripDetail(String id);

  /// Accepts a customer request on a trip.
  Future<DriverTripRequest> acceptTripRequest({
    required String tripId,
    required String requestId,
  });

  /// Rejects a customer request on a trip.
  Future<DriverTripRequest> rejectTripRequest({
    required String tripId,
    required String requestId,
  });

  /// Loads a trip for the edit form (`GET .../edit`).
  Future<TripFormPrefill> getTripForEdit(String id);

  /// Publishes a new trip.
  Future<DriverTrip> postTrip(
    DriverTrip trip, {
    required TripSubmitOptions options,
  });

  /// Updates an existing trip.
  Future<DriverTrip> updateTrip(
    DriverTrip trip, {
    required TripSubmitOptions options,
  });

  /// Cancels a trip. Returns the server-updated trip on success.
  Future<DriverTrip> cancelTrip(
    String tripId, {
    required String reason,
    String? otherReason,
  });
}
