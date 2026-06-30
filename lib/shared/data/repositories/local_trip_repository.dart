import '../../../core/dummy/dummy_trips.dart';
import '../../domain/entities/driver_trip.dart';
import '../../domain/enums/trip_status.dart';
import '../../domain/models/driver_trip_detail.dart';
import '../../domain/models/trip_form_prefill.dart';
import '../../domain/models/trip_submit_options.dart';
import '../../domain/repositories/i_trip_repository.dart';

/// In-memory implementation backed by [DummyTrips].
class LocalTripRepository implements ITripRepository {
  final List<DriverTrip> _trips = List.of(DummyTrips.myTrips);

  static Future<void> _delay() =>
      Future.delayed(const Duration(milliseconds: 400));

  @override
  Future<List<DriverTrip>> getDriverTrips(String driverId) async {
    await _delay();
    return List.unmodifiable(_trips);
  }

  @override
  Future<DriverTrip> getTrip(String id) async {
    await _delay();
    final trip = _trips.where((t) => t.id == id || t.apiId == id).firstOrNull;
    if (trip == null) throw StateError('Trip not found: $id');
    return trip;
  }

  @override
  Future<DriverTripDetail> getTripDetail(String id) async {
    final trip = await getTrip(id);
    final requests = DummyTrips.interestedCustomers
        .asMap()
        .entries
        .map(
          (entry) => DriverTripRequest(
            id: '${entry.key + 1}',
            customerId: 'CUS-${entry.key + 1}',
            customerName: entry.value,
            phone: '+91987654321${entry.key}',
            status: 'pending',
          ),
        )
        .toList(growable: false);
    return DriverTripDetail(trip: trip, requests: requests);
  }

  @override
  Future<DriverTripRequest> acceptTripRequest({
    required String tripId,
    required String requestId,
  }) async {
    await _delay();
    return DriverTripRequest(
      id: requestId,
      customerId: 'CUS-1',
      customerName: 'Customer',
      status: 'accepted',
    );
  }

  @override
  Future<DriverTripRequest> rejectTripRequest({
    required String tripId,
    required String requestId,
  }) async {
    await _delay();
    return DriverTripRequest(
      id: requestId,
      customerId: 'CUS-1',
      customerName: 'Customer',
      status: 'rejected',
    );
  }

  @override
  Future<TripFormPrefill> getTripForEdit(String id) async {
    final trip = await getTrip(id);
    return TripFormPrefill(
      trip: trip,
      options: TripSubmitOptions(
        vehicleId: 1,
        loadCapacity: trip.loadCapacityTons,
        capacityUnit: 'TON',
        fromLocation: trip.fromCity,
        toLocation: trip.toCity,
        driverCountryCode: '+91',
        driverPhone: '9876543210',
      ),
    );
  }

  @override
  Future<DriverTrip> postTrip(
    DriverTrip trip, {
    required TripSubmitOptions options,
  }) async {
    await _delay();
    _trips.insert(0, trip);
    return trip;
  }

  @override
  Future<DriverTrip> updateTrip(
    DriverTrip trip, {
    required TripSubmitOptions options,
  }) async {
    await _delay();
    final idx = _trips.indexWhere(
      (t) => t.id == trip.id || t.apiId == trip.apiId,
    );
    if (idx == -1) throw StateError('Trip not found');
    _trips[idx] = trip;
    return trip;
  }

  @override
  Future<DriverTrip> cancelTrip(
    String tripId, {
    required String reason,
    String? otherReason,
  }) async {
    await _delay();
    final idx = _trips.indexWhere(
      (t) => t.id == tripId || t.apiId == tripId || t.apiResourceId == tripId,
    );
    if (idx == -1) throw StateError('Trip not found: $tripId');
    _trips[idx] = _trips[idx].copyWith(status: TripStatus.cancelled);
    return _trips[idx];
  }
}
