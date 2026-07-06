/// Navigation payload for [CustomerTripRequestSuccessScreen].
class CustomerTripRequestSuccessArgs {
  const CustomerTripRequestSuccessArgs({
    required this.fromCity,
    required this.toCity,
    required this.pickupDateTime,
    required this.estimatedPrice,
  });

  final String fromCity;
  final String toCity;
  final DateTime pickupDateTime;
  final double estimatedPrice;
}
