class DriverPaymentRecord {
  const DriverPaymentRecord({
    required this.id,
    required this.tripId,
    required this.amount,
    required this.paidAt,
    required this.isPaid,
    this.invoiceUrl,
  });

  final int id;
  final String tripId;
  final double amount;
  final DateTime paidAt;
  final bool isPaid;
  final String? invoiceUrl;

  String get displayId => 'INV-$id';
}
