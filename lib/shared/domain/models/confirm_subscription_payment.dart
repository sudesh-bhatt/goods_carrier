class ConfirmSubscriptionPaymentRequest {
  const ConfirmSubscriptionPaymentRequest({
    required this.transactionId,
    required this.gatewayTransactionId,
    required this.paymentStatus,
  });

  final String transactionId;
  final String gatewayTransactionId;
  final String paymentStatus;

  Map<String, dynamic> toJson() => {
        'transaction_id': transactionId,
        'gateway_transaction_id': gatewayTransactionId,
        'payment_status': paymentStatus,
      };
}

class ConfirmSubscriptionPaymentResult {
  const ConfirmSubscriptionPaymentResult({
    required this.success,
    this.message,
    this.subscriptionId,
  });

  final bool success;
  final String? message;
  final String? subscriptionId;
}
