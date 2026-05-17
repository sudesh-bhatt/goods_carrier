/// Navigation payload for [ShipmentPostConfirmationScreen].
class ShipmentPostConfirmationArgs {
  const ShipmentPostConfirmationArgs({
    required this.shipmentId,
    required this.fromCity,
    required this.toCity,
    required this.pickupDate,
    required this.totalPrice,
  });

  final String shipmentId;
  final String fromCity;
  final String toCity;
  final DateTime pickupDate;
  final double totalPrice;
}
