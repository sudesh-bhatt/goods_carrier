import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/razorpay_payment_service.dart';
import '../../../../shared/domain/models/initiate_subscription_payment.dart';
import '../../../../shared/domain/models/subscription_plan.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../models/subscription_flow_args.dart';
import 'driver_subscription_provider.dart';

/// Owns Razorpay across plans-screen rebuilds.
///
/// Android CheckoutActivity backgrounds Flutter; GoRouter often disposes and
/// recreates [DriverSubscriptionPlansScreen]. If Razorpay lived on that State,
/// `dispose()` cleared listeners before `open()`'s MethodChannel reply arrived,
/// so success/failure never navigated to the result screen.
class DriverSubscriptionCheckoutCoordinator {
  DriverSubscriptionCheckoutCoordinator(this._ref) {
    _razorpay.init(
      onSuccess: _onRazorpaySuccess,
      onError: _onRazorpayError,
      onExternalWallet: (_) {},
    );
  }

  final Ref _ref;
  final _razorpay = RazorpayPaymentService();

  /// Backend still expects a payment_method string; instrument is chosen in
  /// Razorpay Standard Checkout.
  static const _gatewayPaymentMethod = 'upi';

  bool _opening = false;

  /// One automatic fresh-order retry after Checkout rejects a reused order.
  bool _retriedForceNew = false;

  void dispose() => _razorpay.dispose();

  Future<void> subscribe(
    SubscriptionPlan plan, {
    bool forceNew = true,
  }) async {
    if (_opening) return;
    _opening = true;

    final checkout = SubscriptionCheckoutArgs(plan: plan);
    final sub = _ref.read(driverSubscriptionProvider.notifier);
    sub.beginCheckout(checkout);

    try {
      // Default force_new: backend was reusing paid/attempted orders after a
      // prior Checkout success where confirm never ran, which makes Razorpay
      // show "Uh! oh! Something went wrong". Safe once backend honours the flag.
      final initiate = await sub.initiatePayment(
        planId: plan.id,
        paymentMethod: _gatewayPaymentMethod,
        forceNew: forceNew,
      );
      sub.setPendingInitiate(initiate);

      final key = initiate.razorpayKey ?? EnvConfig.razorpayKey;
      if (!initiate.hasRazorpayOrder || key.isEmpty) {
        throw StateError(
          'Razorpay order/key missing from initiate payment response',
        );
      }

      if (initiate.reused) {
        debugPrint(
          '[SubscriptionCheckout] opening reused order '
          '${initiate.razorpayOrderId} (txn ${initiate.transactionId})',
        );
      }

      final user = _ref.read(authProvider).user;
      _razorpay.openCheckout(
        key: key,
        orderId: initiate.razorpayOrderId!,
        amountPaise: initiate.amountPaise!,
        currency: initiate.currency,
        name: 'Goods Carrier',
        description: plan.name,
        contact: user?.displayPhone ?? user?.phone,
        email: user?.email,
        transactionId: initiate.transactionId,
      );
    } catch (e) {
      sub.clearCheckoutFlow();
      rethrow;
    } finally {
      _opening = false;
    }
  }

  Future<void> _onRazorpaySuccess(PaymentSuccessResponse response) async {
    _retriedForceNew = false;
    final state = _ref.read(driverSubscriptionProvider);
    final initiate = state.pendingInitiate;
    final plan = state.checkoutArgs?.plan;
    if (initiate == null || plan == null) {
      debugPrint(
        '[SubscriptionCheckout] success ignored — missing pending initiate/plan',
      );
      return;
    }

    try {
      final gatewayId =
          response.paymentId ?? response.orderId ?? initiate.transactionId;
      final confirm = await _ref
          .read(driverSubscriptionProvider.notifier)
          .confirmPayment(
            transactionId: initiate.transactionId,
            gatewayTransactionId: gatewayId,
            success: true,
            razorpayOrderId: response.orderId ?? initiate.razorpayOrderId,
            razorpayPaymentId: response.paymentId,
            razorpaySignature: response.signature,
          );

      _goToResult(
        success: confirm.success,
        initiate: initiate,
        plan: plan,
        gatewayTransactionId: gatewayId,
        failureMessage: confirm.message,
      );
    } catch (e) {
      _goToResult(
        success: false,
        initiate: initiate,
        plan: plan,
        failureMessage: ApiExceptionMapper.userMessage(e),
      );
    }
  }

  void _onRazorpayError(PaymentFailureResponse response) {
    final state = _ref.read(driverSubscriptionProvider);
    final initiate = state.pendingInitiate;
    final plan = state.checkoutArgs?.plan;
    if (initiate == null || plan == null) {
      debugPrint(
        '[SubscriptionCheckout] error ignored — missing pending initiate/plan',
      );
      return;
    }

    final cancelled = response.code == Razorpay.PAYMENT_CANCELLED;
    final shouldForceNew = !cancelled &&
        !_retriedForceNew &&
        (initiate.reused || response.code == Razorpay.INVALID_OPTIONS);

    if (shouldForceNew) {
      _retriedForceNew = true;
      debugPrint(
        '[SubscriptionCheckout] Checkout failed on '
        '${initiate.reused ? "reused" : "fresh"} order '
        '${initiate.razorpayOrderId} (code=${response.code}). '
        'Retrying initiate with force_new=true.',
      );
      // ignore: unawaited_futures
      _retryWithFreshOrder(plan);
      return;
    }

    _retriedForceNew = false;
    _goToResult(
      success: false,
      initiate: initiate,
      plan: plan,
      failureMessage: response.message,
    );
  }

  Future<void> _retryWithFreshOrder(SubscriptionPlan plan) async {
    try {
      await subscribe(plan, forceNew: true);
    } catch (e) {
      final state = _ref.read(driverSubscriptionProvider);
      final initiate = state.pendingInitiate;
      if (initiate == null) {
        debugPrint(
          '[SubscriptionCheckout] force_new retry failed: $e',
        );
        return;
      }
      _goToResult(
        success: false,
        initiate: initiate,
        plan: plan,
        failureMessage: ApiExceptionMapper.userMessage(e),
      );
    }
  }

  void _goToResult({
    required bool success,
    required InitiateSubscriptionPaymentResult initiate,
    required SubscriptionPlan plan,
    String? gatewayTransactionId,
    String? failureMessage,
  }) {
    final paidAt = DateTime.now();
    final serverEndDate =
        _ref.read(driverSubscriptionProvider).currentSubscription?.endDate;
    final expiresAt = serverEndDate != null && serverEndDate.isAfter(paidAt)
        ? serverEndDate
        : paidAt.add(Duration(days: plan.durationDays));

    final resultArgs = SubscriptionPaymentResultArgs(
      isSuccess: success,
      planName: plan.name,
      amount: plan.price,
      transactionId: initiate.transactionId,
      gatewayTransactionId: gatewayTransactionId,
      paidAt: paidAt,
      expiresAt: success ? expiresAt : null,
      failureMessage: failureMessage,
    );

    _ref
        .read(driverSubscriptionProvider.notifier)
        .beginPaymentResult(resultArgs);

    final router = _ref.read(appRouterProvider);
    final location = router.routerDelegate.currentConfiguration.uri.path;
    if (location == AppRoutes.driverSubscriptionPaymentResult) return;

    router.push(
      AppRoutes.driverSubscriptionPaymentResult,
      extra: resultArgs,
    );
  }
}

final driverSubscriptionCheckoutProvider =
    Provider<DriverSubscriptionCheckoutCoordinator>((ref) {
  final coordinator = DriverSubscriptionCheckoutCoordinator(ref);
  ref.onDispose(coordinator.dispose);
  // Survive brief unmount while CheckoutActivity is open / GoRouter rebuilds.
  ref.keepAlive();
  return coordinator;
});
