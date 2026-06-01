/// Navigation payload for [TripCancelSuccessScreen].
class TripCancelConfirmationArgs {
  const TripCancelConfirmationArgs({
    required this.tripId,
    required this.fromCity,
    required this.toCity,
    required this.startDate,
    required this.totalPrice,
  });

  final String tripId;
  final String fromCity;
  final String toCity;
  final DateTime startDate;
  final double totalPrice;
}
