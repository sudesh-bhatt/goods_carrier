import 'package:razorpay_flutter/razorpay_flutter.dart';

typedef RazorpaySuccessHandler = void Function(PaymentSuccessResponse response);
typedef RazorpayFailureHandler = void Function(PaymentFailureResponse response);
typedef RazorpayExternalWalletHandler = void Function(
  ExternalWalletResponse response,
);

/// Thin wrapper around [Razorpay] for subscription checkout.
class RazorpayPaymentService {
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
  }) {
    final razorpay = _razorpay;
    if (razorpay == null) {
      throw StateError('RazorpayPaymentService.init must be called first');
    }

    // Do NOT put `method` in prefill. Razorpay docs only allow `prefill.method`
    // = `card` (and only when both contact + email are set). Values like
    // `netbanking` / `upi` / `wallet` make CheckoutActivity show
    // "Uh! oh! Something went wrong" immediately.
    final normalizedContact = _normalizeContact(contact);
    final normalizedEmail = _normalizeEmail(email);
    final prefill = <String, dynamic>{
      if (normalizedContact != null) 'contact': normalizedContact,
      if (normalizedEmail != null) 'email': normalizedEmail,
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

    assert(() {
      // ignore: avoid_print
      print('[Razorpay] open options: '
          'key=${key.substring(0, key.length.clamp(0, 12))}… '
          'order_id=$orderId amount=$amountPaise currency=$currency '
          'prefill=$prefill');
      return true;
    }());

    razorpay.open(options);
  }

  static String? _normalizeEmail(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty || !trimmed.contains('@')) return null;
    return trimmed;
  }

  /// Razorpay expects E.164 (`+91…`). Bare Indian numbers without a country
  /// code are treated as `+1…` and can break checkout.
  static String? _normalizeContact(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('+')) return trimmed;

    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    if (digits.length == 10) return '+91$digits';
    if (digits.startsWith('91') && digits.length == 12) return '+$digits';
    return '+$digits';
  }

  void dispose() {
    _razorpay?.clear();
    _razorpay = null;
  }
}
