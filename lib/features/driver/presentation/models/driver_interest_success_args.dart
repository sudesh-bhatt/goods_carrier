/// Navigation payload for [DriverInterestSuccessScreen].
class DriverInterestSuccessArgs {
  const DriverInterestSuccessArgs({
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
