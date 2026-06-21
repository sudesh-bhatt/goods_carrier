import '../entities/shipment.dart';

/// Detail payload from `GET /api/driver/shipments/{id}`.
class DriverShipmentDetail {
  const DriverShipmentDetail({
    required this.shipment,
    this.alreadyRequested = false,
    this.driverRequestStatus,
    this.matchesDriverVehicle,
    this.vehicleCapacityLabel,
    this.pickupScheduleLabel,
  });

  final Shipment shipment;
  final bool alreadyRequested;
  final String? driverRequestStatus;
  final bool? matchesDriverVehicle;
  final String? vehicleCapacityLabel;
  final String? pickupScheduleLabel;
}
