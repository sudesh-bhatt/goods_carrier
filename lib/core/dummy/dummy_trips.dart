import '../../shared/domain/entities/driver_trip.dart';
import '../../shared/domain/enums/trip_status.dart';
import '../../shared/domain/enums/vehicle_type.dart';

class DummyTrips {
  DummyTrips._();

  static final List<DriverTrip> myTrips = [
    DriverTrip(
      id: 'VB-9928',
      driverId: 'USR-0002',
      driverName: 'Vikram Singh Rajput',
      fromCity: 'Mumbai, MH',
      toCity: 'Delhi',
      estimatedStartDate: DateTime(2026, 4, 15, 9, 0),
      estimatedEndDate:   DateTime(2026, 4, 18, 18, 0),
      vehicleCategory: VehicleType.pickupTruck,
      vehicleNumber: 'MH 02 CC 4156',
      loadCapacityTons: 1,
      estimatedPrice: 2100,
      status: TripStatus.active,
    ),
    DriverTrip(
      id: 'VB-8814',
      driverId: 'USR-0002',
      driverName: 'Vikram Singh Rajput',
      fromCity: 'Pune, MH',
      toCity: 'Ahmedabad, GJ',
      estimatedStartDate: DateTime(2026, 4, 20, 10, 0),
      estimatedEndDate:   DateTime(2026, 4, 22, 20, 0),
      vehicleCategory: VehicleType.heavyDuty,
      vehicleNumber: 'MH 02 CC 4156',
      loadCapacityTons: 15,
      estimatedPrice: 8500,
      status: TripStatus.confirmed,
    ),
    DriverTrip(
      id: 'VB-7701',
      driverId: 'USR-0002',
      driverName: 'Vikram Singh Rajput',
      fromCity: 'Mumbai, MH',
      toCity: 'Bengaluru, KA',
      estimatedStartDate: DateTime(2026, 3, 28, 7, 0),
      estimatedEndDate:   DateTime(2026, 3, 30, 16, 0),
      vehicleCategory: VehicleType.truck,
      vehicleNumber: 'MH 02 CC 4156',
      loadCapacityTons: 5,
      estimatedPrice: 5500,
      status: TripStatus.completed,
    ),
  ];
}
