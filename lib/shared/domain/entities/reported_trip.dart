import '../enums/vehicle_type.dart';

/// Customer-reported driver trip — Figma reported trips list (`1:6391`).
class ReportedTrip {
  const ReportedTrip({
    required this.id,
    required this.fromCity,
    required this.toCity,
    required this.estimatedStartDate,
    required this.estimatedEndDate,
    required this.vehicleType,
    required this.loadCapacityTons,
    required this.estimatedPrice,
  });

  final String id;
  final String fromCity;
  final String toCity;
  final DateTime estimatedStartDate;
  final DateTime estimatedEndDate;
  final VehicleType vehicleType;
  final double loadCapacityTons;
  final double estimatedPrice;

  String get capacityDisplay {
    if (loadCapacityTons == loadCapacityTons.roundToDouble()) {
      return '${loadCapacityTons.toInt()} Ton';
    }
    return '$loadCapacityTons Ton';
  }
}
