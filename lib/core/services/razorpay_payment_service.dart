import 'package:razorpay_flutter/razorpay_flutter.dart';

typedef RazorpaySuccessHandler = void Function(PaymentSuccessResponse response);
typedef RazorpayFailureHandler = void Function(PaymentFailureResponse response);
typedef RazorpayExternalWalletHandler = void Function(
  ExternalWalletResponse response,
);

/// Thin wrapper around [Razorpay] for subscription checkout.
class RazorpayPaymentService {
  /// Methods Razorpay accepts in `prefill.method`. Anything else is dropped so
  /// checkout opens on its default screen instead of erroring.
  static const _prefillableMethods = {
    'card',
    'netbanking',
    'wallet',
    'upi',
    'emi',
  };

  Razorpay? _razorpay;

  void init({
    required RazorpaySuccessHandler onSuccess,
    required RazorpayFailureHandler onError,
    RazorpayExternalWalletHandler? onExternalWallet,
  }) {
    dispose();
    final razorpay = Razorpay()
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, onError);
    if (onExternalWallet != null) {
      razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
    }
    _razorpay = razorpay;
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
    String? preferredMethod,
  }) {
    final razorpay = _razorpay;
    if (razorpay == null) {
      throw StateError('RazorpayPaymentService.init must be called first');
    }

    // Razorpay's top-level `method` option is for direct invocation and needs
    // companion params (`vpa`, `bank`, `wallet`), so the driver's choice is
    // passed as a prefill preference instead.
    final prefill = <String, dynamic>{
      if (contact != null && contact.isNotEmpty) 'contact': contact,
      if (email != null && email.isNotEmpty) 'email': email,
      if (preferredMethod != null &&
          _prefillableMethods.contains(preferredMethod))
        'method': preferredMethod,
    };

    final options = <String, dynamic>{
      'key': key,
      'amount': amountPaise,
      'currency': currency,
      'name': name,
      'order_id': orderId,
      'description': description,
      if (prefill.isNotEmpty) 'prefill': prefill,
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
