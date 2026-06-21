import 'package:goods_carrier/shared/domain/enums/vehicle_type.dart';

import '../entities/driver_vehicle.dart';
import '../enums/driver_vehicle_status.dart';

/// Full vehicle payload for the Vehicle Details / edit form screens.
class DriverVehicleDetail {
  const DriverVehicleDetail({
    required this.id,
    required this.registrationNumber,
    required this.vehicleTypeId,
    required this.vehicleTypeName,
    required this.vehicleTypeSlug,
    required this.capacity,
    required this.capacityUnit,
    required this.status,
    this.driverName = '',
    this.driverCountryCode = '+91',
    this.driverPhone = '',
    this.driverSubtitle = '',
    this.profilePhotoUrl,
    this.licenseFrontUrl,
    this.licenseBackUrl,
    this.vehiclePhotoUrl,
    this.fleetCode,
  });

  final int id;
  final String registrationNumber;
  final int vehicleTypeId;
  final String vehicleTypeName;
  final String vehicleTypeSlug;
  final double capacity;
  final String capacityUnit;
  final DriverVehicleStatus status;
  final String driverName;
  final String driverCountryCode;
  final String driverPhone;
  final String driverSubtitle;
  final String? profilePhotoUrl;
  final String? licenseFrontUrl;
  final String? licenseBackUrl;
  final String? vehiclePhotoUrl;
  final String? fleetCode;

  String get capacityLabel {
    final value = capacity == capacity.truncateToDouble()
        ? capacity.toInt().toString()
        : capacity.toString();
    final unit = capacityUnit.toUpperCase() == 'TON' ? 'Tons' : capacityUnit;
    return '$value $unit';
  }

  DriverVehicle toListItem() => DriverVehicle(
        id: id,
        vehicleNumber: registrationNumber,
        vehicleTypeId: vehicleTypeId,
        vehicleTypeName: vehicleTypeName,
        vehicleTypeSlug: vehicleTypeSlug,
        capacity: capacity,
        capacityUnit: capacityUnit,
        status: status, vehicleType: VehicleType.mini,
      );
}
