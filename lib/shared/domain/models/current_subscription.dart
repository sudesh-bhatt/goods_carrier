class CurrentSubscription {
  const CurrentSubscription({
    required this.id,
    required this.planId,
    required this.planName,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.isExpired = false,
  });

  final int id;
  final int planId;
  final String planName;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final bool isExpired;
}
