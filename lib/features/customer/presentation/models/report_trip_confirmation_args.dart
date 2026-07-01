/// Navigation payload for [ReportTripSuccessScreen].
class ReportTripConfirmationArgs {
  const ReportTripConfirmationArgs({
    required this.reportId,
    required this.submittedAt,
    required this.tripId,
    required this.fromCity,
    required this.toCity,
    this.isDriver = false,
  });

  final String reportId;
  final DateTime submittedAt;
  final String tripId;
  final String fromCity;
  final String toCity;
  final bool isDriver;
}
