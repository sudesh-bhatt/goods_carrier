import '../enums/vehicle_type.dart';

/// Customer-reported driver trip — Figma reported trips list (`1:6391`).
class ReportedTrip {
  const ReportedTrip({
    required this.id,
    required this.fromCity,
    required this.toCity,
    required this.estimatedStartDate,
    this.estimatedEndDate,
    required this.vehicleType,
    required this.loadCapacityTons,
    this.loadCapacity,
    this.capacityUnit,
    required this.estimatedPrice,
  });

  final String id;
  final String fromCity;
  final String toCity;
  final DateTime estimatedStartDate;
  final DateTime? estimatedEndDate;
  final VehicleType vehicleType;
  final double loadCapacityTons;
  /// Raw capacity value as returned by the API (e.g. 100 for `"100 KG"`).
  final double? loadCapacity;
  /// `KG` or `TON` — original unit from API.
  final String? capacityUnit;
  final double estimatedPrice;

  String get capacityDisplay {
    final raw = loadCapacity ?? loadCapacityTons;
    final unit = capacityUnit?.toUpperCase();
    if (unit == 'KG') {
      if (raw == raw.roundToDouble()) {
        return '${raw.toInt()} KG';
      }
      return '$raw KG';
    }
    if (loadCapacityTons == loadCapacityTons.roundToDouble()) {
      return '${loadCapacityTons.toInt()} Ton';
    }
    return '$loadCapacityTons Ton';
  }
}
