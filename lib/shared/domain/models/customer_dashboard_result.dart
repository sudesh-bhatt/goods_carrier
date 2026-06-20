import '../entities/driver_trip.dart';
import '../entities/shipment_masters.dart';

/// Parsed payload from `GET /api/customer/dashboard`.
class CustomerDashboardResult {
  const CustomerDashboardResult({
    required this.trips,
    this.vehicleTypes = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 10,
    this.total = 0,
  });

  final List<DriverTrip> trips;
  final List<ShipmentMasterOption> vehicleTypes;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
}
