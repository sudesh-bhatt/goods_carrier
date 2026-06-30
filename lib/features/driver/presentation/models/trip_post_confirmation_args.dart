/// Navigation payload for [TripPostConfirmationScreen].
class TripPostConfirmationArgs {
  const TripPostConfirmationArgs({
    required this.tripId,
    required this.fromCity,
    required this.toCity,
    required this.startDate,
    required this.totalPrice,
    this.isUpdate = false,
  });

  final String tripId;
  final String fromCity;
  final String toCity;
  final DateTime startDate;
  final double totalPrice;
  final bool isUpdate;
}
