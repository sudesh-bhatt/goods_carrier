class CurrentSubscription {
  const CurrentSubscription({
    required this.id,
    required this.planId,
    required this.planName,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.isExpired = false,
    this.price,
    this.currency = 'INR',
    this.tripLimit,
    this.tripsUsed,
    this.tripsRemaining,
  });

  final int id;
  final int planId;
  final String planName;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final bool isExpired;
  final double? price;
  final String currency;
  final int? tripLimit;
  final int? tripsUsed;
  final int? tripsRemaining;

  /// True when the driver should see Active-plan UX (cannot rebuy same plan).
  bool get isCurrentlyActive {
    if (isExpired) return false;
    final normalized = status.trim().toLowerCase();
    if (normalized != 'active') return false;
    return endDate.isAfter(DateTime.now());
  }

  String get priceLabel {
    final value = price;
    if (value == null) return '';
    final whole = value.truncateToDouble() == value;
    return '₹${value.toStringAsFixed(whole ? 0 : 2)}';
  }
}
