/// Extra fields required by `POST/PUT /api/driver/trips`.
class TripSubmitOptions {
  const TripSubmitOptions({
    required this.vehicleId,
    required this.loadCapacity,
    required this.capacityUnit,
    required this.fromLocation,
    required this.toLocation,
    required this.driverCountryCode,
    required this.driverPhone,
  });

  final int vehicleId;
  final double loadCapacity;

  /// API values: `TON` or `KG`.
  final String capacityUnit;
  final String fromLocation;
  final String toLocation;

  /// E.g. `+91`.
  final String driverCountryCode;

  /// Local digits only (no country prefix).
  final String driverPhone;

  static String apiCapacityUnit(String uiUnit) {
    return uiUnit.toLowerCase() == 'ton' ? 'TON' : 'KG';
  }
}
