import '../../../domain/entities/driver_trip.dart';
import '../driver/trip_api_mapper.dart';

/// Maps `GET /api/customer/dashboard` rows to [DriverTrip].
abstract final class CustomerDashboardApiMapper {
  static DriverTrip fromJson(Map<String, dynamic> json) =>
      TripApiMapper.fromJson(json);
}
