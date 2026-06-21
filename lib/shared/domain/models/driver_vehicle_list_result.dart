import '../entities/driver_vehicle.dart';

class DriverVehicleFleetSummary {
  const DriverVehicleFleetSummary({
    this.totalActive = 0,
    this.inTransit = 0,
  });

  final int totalActive;
  final int inTransit;
}

class DriverVehicleListResult {
  const DriverVehicleListResult({
    required this.vehicles,
    this.summary = const DriverVehicleFleetSummary(),
  });

  final List<DriverVehicle> vehicles;
  final DriverVehicleFleetSummary summary;
}
