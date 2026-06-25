class DriverPaymentRecord {
  const DriverPaymentRecord({
    required this.id,
    required this.transactionId,
    required this.planName,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    required this.paidAt,
    this.invoiceUrl,
  });

  final int id;
  final String transactionId;
  final String planName;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String status;
  final DateTime paidAt;
  final String? invoiceUrl;

  String get displayTransactionId =>
      transactionId.isNotEmpty ? transactionId : 'TXN-$id';

  String get displayStatus => status.trim().toUpperCase();

  bool get isSuccess {
    final normalized = status.toLowerCase();
    return normalized == 'success' ||
        normalized == 'paid' ||
        normalized == 'completed';
  }

  String get amountLabel {
    final value = amount.truncateToDouble() == amount
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    return '₹$value';
  }
}
