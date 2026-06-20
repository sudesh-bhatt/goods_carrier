/// Extra fields required by `POST/PUT /api/customer/shipments` (Postman contract).
class ShipmentSubmitOptions {
  const ShipmentSubmitOptions({
    required this.goodsTypeId,
    required this.vehicleTypeId,
    required this.estimatedWeight,
    required this.weightUnit,
    required this.termsAccepted,
  });

  final int goodsTypeId;
  final int vehicleTypeId;

  /// Raw weight value as entered (not converted to kg).
  final double estimatedWeight;

  /// API values: `KG` or `Ton`.
  final String weightUnit;
  final bool termsAccepted;

  /// Maps UI unit label to API `weight_unit` (uppercase).
  static String apiWeightUnit(String uiUnit) {
    return uiUnit.toLowerCase() == 'ton' ? 'TON' : 'KG';
  }
}
