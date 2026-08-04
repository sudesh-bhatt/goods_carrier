class ConfirmSubscriptionPaymentRequest {
  const ConfirmSubscriptionPaymentRequest({
    required this.transactionId,
    required this.gatewayTransactionId,
    required this.paymentStatus,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.razorpaySignature,
  });

  final String transactionId;
  final String gatewayTransactionId;
  final String paymentStatus;

  /// Razorpay checkout handshake. The backend must treat `payment_status` as
  /// an untrusted hint and only grant the subscription after verifying
  /// `razorpay_signature` against `order_id|payment_id` with the Key Secret.
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? razorpaySignature;

  Map<String, dynamic> toJson() => {
        'transaction_id': transactionId,
        'gateway_transaction_id': gatewayTransactionId,
        'payment_status': paymentStatus,
        if (razorpayOrderId != null && razorpayOrderId!.isNotEmpty)
          'razorpay_order_id': razorpayOrderId,
        if (razorpayPaymentId != null && razorpayPaymentId!.isNotEmpty)
          'razorpay_payment_id': razorpayPaymentId,
        if (razorpaySignature != null && razorpaySignature!.isNotEmpty)
          'razorpay_signature': razorpaySignature,
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
