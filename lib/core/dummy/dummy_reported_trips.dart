import '../../shared/domain/entities/reported_trip.dart';
import '../../shared/domain/enums/vehicle_type.dart';

/// Sample reported trips — Figma `1:6391`.
abstract final class DummyReportedTrips {
  static final List<ReportedTrip> list = [
    ReportedTrip(
      id: 'RT-1001',
      fromCity: 'Bandra East',
      toCity: 'Andheri West',
      estimatedStartDate: DateTime(2026, 4, 15, 9),
      estimatedEndDate: DateTime(2026, 4, 17, 19),
      vehicleType: VehicleType.pickupTruck,
      loadCapacityTons: 1,
      estimatedPrice: 2100,
    ),
    ReportedTrip(
      id: 'RT-1002',
      fromCity: 'Mumbai',
      toCity: 'New Delhi',
      estimatedStartDate: DateTime(2026, 4, 15, 9),
      estimatedEndDate: DateTime(2026, 4, 17, 19),
      vehicleType: VehicleType.pickupTruck,
      loadCapacityTons: 1,
      estimatedPrice: 2100,
    ),
  ];
}
