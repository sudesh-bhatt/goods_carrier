import '../enums/driver_vehicle_status.dart';
import '../enums/vehicle_type.dart';

/// Driver-owned vehicle from `GET /api/driver/vehicles`.
class DriverVehicle {
  const DriverVehicle({
    required this.id,
    required this.vehicleNumber,
    required this.vehicleType,
    this.vehicleTypeId,
    this.vehicleTypeName,
    this.vehicleTypeSlug,
    this.capacity,
    this.capacityUnit = 'TON',
    this.status = DriverVehicleStatus.active,
  });

  final int id;
  final String vehicleNumber;
  final VehicleType vehicleType;
  final int? vehicleTypeId;
  final String? vehicleTypeName;
  final String? vehicleTypeSlug;
  final double? capacity;
  final String capacityUnit;
  final DriverVehicleStatus status;

  String get displayLabel {
    if (vehicleNumber.isEmpty) return displayTypeName;
    return '$vehicleNumber · $displayTypeName';
  }

  String get displayTypeName =>
      vehicleTypeName?.trim().isNotEmpty == true
          ? vehicleTypeName!.trim()
          : vehicleType.label;

  String get capacityLabel {
    if (capacity == null) return vehicleType.capacityDisplay;
    final value = capacity == capacity!.truncateToDouble()
        ? capacity!.toInt().toString()
        : capacity.toString();
    final unit = capacityUnit.toUpperCase() == 'TON' ? 'Tons' : capacityUnit;
    return '$value $unit';
  }
}
