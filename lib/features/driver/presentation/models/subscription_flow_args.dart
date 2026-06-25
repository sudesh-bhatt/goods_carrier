import '../../../../shared/domain/models/subscription_plan.dart';

/// Checkout context passed from plan list → payment method screen.
class SubscriptionCheckoutArgs {
  const SubscriptionCheckoutArgs({required this.plan});

  final SubscriptionPlan plan;
}

/// Receipt data passed to the payment result screen.
class SubscriptionPaymentResultArgs {
  const SubscriptionPaymentResultArgs({
    required this.isSuccess,
    required this.planName,
    required this.amount,
    this.transactionId,
    this.gatewayTransactionId,
    this.paidAt,
    this.expiresAt,
    this.failureMessage,
  });

  final bool isSuccess;
  final String planName;
  final double amount;
  final String? transactionId;
  final String? gatewayTransactionId;
  final DateTime? paidAt;
  final DateTime? expiresAt;
  final String? failureMessage;
}
