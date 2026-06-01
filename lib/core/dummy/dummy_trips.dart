import '../../shared/domain/entities/driver_trip.dart';
import '../../shared/domain/enums/trip_status.dart';
import '../../shared/domain/enums/vehicle_type.dart';

class DummyTrips {
  DummyTrips._();

  static final List<DriverTrip> myTrips = [
    DriverTrip(
      id: 'VB-9928',
      driverId: 'USR-0002',
      driverName: 'Vikram Singh',
      fromCity: 'Mumbai',
      toCity: 'New Delhi',
      estimatedStartDate: DateTime(2026, 4, 15, 9, 0),
      estimatedEndDate: DateTime(2026, 4, 17, 19, 0),
      vehicleCategory: VehicleType.pickupTruck,
      vehicleNumber: 'MH 02 CC 4156',
      loadCapacityTons: 1,
      estimatedPrice: 2100,
      status: TripStatus.active,
      interestRequestCount: 4,
    ),
    DriverTrip(
      id: 'VB-8814',
      driverId: 'USR-0002',
      driverName: 'Vikram Singh',
      fromCity: 'Mumbai',
      toCity: 'New Delhi',
      estimatedStartDate: DateTime(2026, 4, 15, 9, 0),
      estimatedEndDate: DateTime(2026, 4, 17, 19, 0),
      vehicleCategory: VehicleType.pickupTruck,
      vehicleNumber: 'MH 02 CC 4156',
      loadCapacityTons: 1,
      estimatedPrice: 2100,
      status: TripStatus.completed,
      interestRequestCount: 3,
    ),
    DriverTrip(
      id: 'VB-7701',
      driverId: 'USR-0002',
      driverName: 'Vikram Singh',
      fromCity: 'Mumbai',
      toCity: 'New Delhi',
      estimatedStartDate: DateTime(2026, 4, 15, 9, 0),
      estimatedEndDate: DateTime(2026, 4, 17, 19, 0),
      vehicleCategory: VehicleType.pickupTruck,
      vehicleNumber: 'MH 02 CC 4156',
      loadCapacityTons: 1,
      estimatedPrice: 2100,
      status: TripStatus.pendingConfirmation,
      interestRequestCount: 11,
    ),
  ];

  static const interestedCustomers = [
    'Ravindra Soni',
    'Bina Patel',
    'Poonam Patil',
    'Rudra Swami',
  ];
}
