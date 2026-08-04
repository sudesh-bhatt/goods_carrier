class InitiateSubscriptionPaymentRequest {
  const InitiateSubscriptionPaymentRequest({
    required this.planId,
    required this.paymentMethod,
  });

  final int planId;
  final String paymentMethod;

  Map<String, dynamic> toJson() => {
        'plan_id': planId,
        'payment_method': paymentMethod,
      };
}

class InitiateSubscriptionPaymentResult {
  const InitiateSubscriptionPaymentResult({
    required this.transactionId,
    required this.status,
    this.paymentUrl,
    this.upiIntent,
    this.razorpayOrderId,
    this.razorpayKey,
    this.amountPaise,
    this.currency = 'INR',
  });

  final String transactionId;
  final String status;
  final String? paymentUrl;
  final String? upiIntent;
  final String? razorpayOrderId;
  final String? razorpayKey;
  final int? amountPaise;
  final String currency;

  /// True when the backend created a real Razorpay order. The publishable key
  /// is checked separately because it can fall back to `EnvConfig`.
  bool get hasRazorpayOrder =>
      (razorpayOrderId?.isNotEmpty ?? false) && (amountPaise ?? 0) > 0;
}
