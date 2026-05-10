import '../../../core/dummy/dummy_trips.dart';
import '../../domain/entities/driver_trip.dart';
import '../../domain/enums/trip_status.dart';
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
  Future<DriverTrip> postTrip(DriverTrip trip) async {
    await _delay();
    _trips.insert(0, trip);
    return trip;
  }

  @override
  Future<void> cancelTrip(String tripId) async {
    await _delay();
    final idx = _trips.indexWhere((t) => t.id == tripId);
    if (idx != -1) {
      _trips[idx] = _trips[idx].copyWith(status: TripStatus.cancelled);
    }
  }
}
