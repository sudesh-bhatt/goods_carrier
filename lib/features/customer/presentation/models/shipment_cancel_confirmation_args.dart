/// Navigation payload for [ShipmentCancelSuccessScreen].
class ShipmentCancelConfirmationArgs {
  const ShipmentCancelConfirmationArgs({
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
