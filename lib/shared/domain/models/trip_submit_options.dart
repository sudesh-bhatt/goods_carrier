/// Extra fields required by `POST/PUT /api/driver/trips` (Postman contract).
class TripSubmitOptions {
  const TripSubmitOptions({
    required this.vehicleTypeId,
    required this.capacity,
    required this.capacityUnit,
    this.driverPhone,
    this.fromAddress,
    this.toAddress,
  });

  final int vehicleTypeId;
  final double capacity;

  /// API values: `TON` or `KG`.
  final String capacityUnit;
  final String? driverPhone;
  final String? fromAddress;
  final String? toAddress;

  static String apiCapacityUnit(String uiUnit) {
    return uiUnit.toLowerCase() == 'ton' ? 'TON' : 'KG';
  }
}
