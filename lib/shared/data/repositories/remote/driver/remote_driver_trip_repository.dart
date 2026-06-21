import '../../../api/driver/driver_trip_api_client.dart';
import '../../../../domain/entities/driver_trip.dart';
import '../../../../domain/models/driver_trip_detail.dart';
import '../../../../domain/models/trip_form_prefill.dart';
import '../../../../domain/models/trip_submit_options.dart';
import '../../../../domain/repositories/i_trip_repository.dart';

/// Remote driver trip operations aligned with Postman collection.
class RemoteDriverTripRepository implements ITripRepository {
  RemoteDriverTripRepository({required DriverTripApiClient apiClient})
      : _api = apiClient;

  final DriverTripApiClient _api;

  @override
  Future<List<DriverTrip>> getDriverTrips(String driverId) async {
    final result = await _api.listTrips(fallbackDriverId: driverId);
    return result.items;
  }

  @override
  Future<DriverTrip> getTrip(String id) => _api.getTrip(id);

  @override
  Future<DriverTripDetail> getTripDetail(String id) => _api.getTripDetail(id);

  @override
  Future<DriverTripRequest> acceptTripRequest({
    required String tripId,
    required String requestId,
  }) =>
      _api.acceptTripRequest(tripId: tripId, requestId: requestId);

  @override
  Future<DriverTripRequest> rejectTripRequest({
    required String tripId,
    required String requestId,
  }) =>
      _api.rejectTripRequest(tripId: tripId, requestId: requestId);

  @override
  Future<TripFormPrefill> getTripForEdit(String id) => _api.getTripForEdit(id);

  @override
  Future<DriverTrip> postTrip(
    DriverTrip trip, {
    required TripSubmitOptions options,
  }) =>
      _api.publishTrip(
        trip,
        options: options,
        fallbackDriverId: trip.driverId,
      );

  @override
  Future<DriverTrip> updateTrip(
    DriverTrip trip, {
    required TripSubmitOptions options,
  }) =>
      _api.updateTrip(
        trip,
        options: options,
        fallbackDriverId: trip.driverId,
      );

  @override
  Future<DriverTrip> cancelTrip(
    String tripId, {
    required String reason,
    String? otherReason,
  }) =>
      _api.cancelTrip(
        tripId,
        reason: reason,
        otherReason: otherReason,
      );
}
