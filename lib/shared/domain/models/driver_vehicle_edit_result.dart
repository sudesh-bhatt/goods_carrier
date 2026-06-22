import 'driver_vehicle_detail.dart';

/// Result returned when popping [DriverAddVehicleScreen] in edit mode.
class DriverVehicleEditResult {
  const DriverVehicleEditResult._({
    required this.updated,
    this.detail,
  });

  final bool updated;
  final DriverVehicleDetail? detail;

  factory DriverVehicleEditResult.updated(DriverVehicleDetail detail) {
    return DriverVehicleEditResult._(updated: true, detail: detail);
  }

  static const DriverVehicleEditResult cancelled =
      DriverVehicleEditResult._(updated: false);
}
