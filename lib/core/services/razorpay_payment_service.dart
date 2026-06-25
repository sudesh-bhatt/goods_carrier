import 'package:razorpay_flutter/razorpay_flutter.dart';

typedef RazorpaySuccessHandler = void Function(PaymentSuccessResponse response);
typedef RazorpayFailureHandler = void Function(PaymentFailureResponse response);

/// Thin wrapper around [Razorpay] for subscription checkout.
class RazorpayPaymentService {
  Razorpay? _razorpay;

  void init({
    required RazorpaySuccessHandler onSuccess,
    required RazorpayFailureHandler onError,
  }) {
    dispose();
    _razorpay = Razorpay()
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, onError);
  }

  void openCheckout({
    required String key,
    required String orderId,
    required int amountPaise,
    required String currency,
    required String name,
    required String description,
    String? contact,
    String? email,
    String? transactionId,
    required String method,
  }) {
    final razorpay = _razorpay;
    if (razorpay == null) {
      throw StateError('RazorpayPaymentService.init must be called first');
    }

    final options = <String, dynamic>{
      'key': key,
      'amount': amountPaise,
      'currency': currency,
      'name': name,
      'order_id': orderId,
      'description': description,
      'method': method,
      if (contact != null && contact.isNotEmpty)
        'prefill': {
          'contact': contact,
          if (email != null && email.isNotEmpty) 'email': email,
        },
      if (transactionId != null && transactionId.isNotEmpty)
        'notes': {'transaction_id': transactionId},
    };

    razorpay.open(options);
  }

  void dispose() {
    _razorpay?.clear();
    _razorpay = null;
  }
}
