class InitiateSubscriptionPaymentRequest {
  const InitiateSubscriptionPaymentRequest({
    required this.planId,
    required this.paymentMethod,
    this.forceNew = false,
  });

  final int planId;
  final String paymentMethod;

  /// When true, backend must create a fresh Razorpay order even if a pending
  /// transaction exists. Used after Checkout rejects a reused/paid order.
  final bool forceNew;

  Map<String, dynamic> toJson() => {
        'plan_id': planId,
        'payment_method': paymentMethod,
        if (forceNew) 'force_new': true,
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
    this.reused = false,
  });

  final String transactionId;
  final String status;
  final String? paymentUrl;
  final String? upiIntent;
  final String? razorpayOrderId;
  final String? razorpayKey;
  final int? amountPaise;
  final String currency;

  /// True when backend returned an existing pending order instead of creating
  /// a new one. Reused paid/attempted orders make Razorpay show "Uh oh".
  final bool reused;

  /// True when the backend created a real Razorpay order. The publishable key
  /// is checked separately because it can fall back to `EnvConfig`.
  bool get hasRazorpayOrder =>
      (razorpayOrderId?.isNotEmpty ?? false) && (amountPaise ?? 0) > 0;
}
