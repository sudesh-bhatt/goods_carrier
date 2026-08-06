import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../shared/domain/models/confirm_subscription_payment.dart';
import '../../../../shared/domain/models/current_subscription.dart';
import '../../../../shared/domain/models/initiate_subscription_payment.dart';
import '../../../../shared/domain/models/subscription_plan.dart';
import '../models/subscription_flow_args.dart';

class DriverSubscriptionState {
  const DriverSubscriptionState({
    this.plans = const [],
    this.currentSubscription,
    this.isLoadingPlans = false,
    this.isProcessingPayment = false,
    this.error,
    this.checkoutArgs,
    this.pendingInitiate,
    this.paymentResultArgs,
  });

  final List<SubscriptionPlan> plans;
  final CurrentSubscription? currentSubscription;
  final bool isLoadingPlans;
  final bool isProcessingPayment;
  final String? error;

  /// Survives GoRouter dropping non-serializable `extra` when Razorpay's
  /// Android CheckoutActivity backgrounds the Flutter activity (netbanking).
  final SubscriptionCheckoutArgs? checkoutArgs;
  final InitiateSubscriptionPaymentResult? pendingInitiate;
  final SubscriptionPaymentResultArgs? paymentResultArgs;

  DriverSubscriptionState copyWith({
    List<SubscriptionPlan>? plans,
    CurrentSubscription? currentSubscription,
    bool? isLoadingPlans,
    bool? isProcessingPayment,
    String? error,
    bool clearError = false,
    bool clearCurrentSubscription = false,
    SubscriptionCheckoutArgs? checkoutArgs,
    bool clearCheckoutArgs = false,
    InitiateSubscriptionPaymentResult? pendingInitiate,
    bool clearPendingInitiate = false,
    SubscriptionPaymentResultArgs? paymentResultArgs,
    bool clearPaymentResultArgs = false,
  }) =>
      DriverSubscriptionState(
        plans: plans ?? this.plans,
        currentSubscription: clearCurrentSubscription
            ? null
            : (currentSubscription ?? this.currentSubscription),
        isLoadingPlans: isLoadingPlans ?? this.isLoadingPlans,
        isProcessingPayment: isProcessingPayment ?? this.isProcessingPayment,
        error: clearError ? null : (error ?? this.error),
        checkoutArgs:
            clearCheckoutArgs ? null : (checkoutArgs ?? this.checkoutArgs),
        pendingInitiate: clearPendingInitiate
            ? null
            : (pendingInitiate ?? this.pendingInitiate),
        paymentResultArgs: clearPaymentResultArgs
            ? null
            : (paymentResultArgs ?? this.paymentResultArgs),
      );
}

class DriverSubscriptionNotifier
    extends StateNotifier<DriverSubscriptionState> {
  DriverSubscriptionNotifier(this._ref)
      : super(const DriverSubscriptionState());

  final Ref _ref;

  Future<void> loadPlans() async {
    state = state.copyWith(isLoadingPlans: true, clearError: true);
    if (!EnvConfig.useRemoteApi) {
      state = state.copyWith(
        plans: _dummyPlans,
        isLoadingPlans: false,
        clearError: true,
        clearCurrentSubscription: true,
      );
      return;
    }

    try {
      final client = _ref.read(driverSubscriptionApiClientProvider);
      final plans = await client.listPlans();
      CurrentSubscription? current;
      try {
        current = await client.getCurrentSubscription();
      } catch (_) {
        current = null;
      }
      state = state.copyWith(
        plans: _sortedPlans(plans),
        currentSubscription: current,
        isLoadingPlans: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingPlans: false,
        error: ApiExceptionMapper.userMessage(e),
      );
    }
  }

  Future<InitiateSubscriptionPaymentResult> initiatePayment({
    required int planId,
    required String paymentMethod,
    bool forceNew = false,
  }) async {
    state = state.copyWith(isProcessingPayment: true, clearError: true);
    try {
      final result =
          await _ref.read(driverSubscriptionApiClientProvider).initiatePayment(
                InitiateSubscriptionPaymentRequest(
                  planId: planId,
                  paymentMethod: paymentMethod,
                  forceNew: forceNew,
                ),
              );
      state = state.copyWith(isProcessingPayment: false);
      return result;
    } catch (e) {
      state = state.copyWith(
        isProcessingPayment: false,
        error: ApiExceptionMapper.userMessage(e),
      );
      rethrow;
    }
  }

  Future<ConfirmSubscriptionPaymentResult> confirmPayment({
    required String transactionId,
    required String gatewayTransactionId,
    required bool success,
    String? razorpayOrderId,
    String? razorpayPaymentId,
    String? razorpaySignature,
  }) async {
    state = state.copyWith(isProcessingPayment: true, clearError: true);
    try {
      final result =
          await _ref.read(driverSubscriptionApiClientProvider).confirmPayment(
                ConfirmSubscriptionPaymentRequest(
                  transactionId: transactionId,
                  gatewayTransactionId: gatewayTransactionId,
                  paymentStatus: success ? 'success' : 'failed',
                  razorpayOrderId: razorpayOrderId,
                  razorpayPaymentId: razorpayPaymentId,
                  razorpaySignature: razorpaySignature,
                ),
              );
      if (result.success) {
        await loadPlans();
      }
      // Always clear — loadPlans() does not touch isProcessingPayment, so a
      // successful confirm previously left the plans screen spinner stuck.
      state = state.copyWith(isProcessingPayment: false);
      return result;
    } catch (e) {
      state = state.copyWith(
        isProcessingPayment: false,
        error: ApiExceptionMapper.userMessage(e),
      );
      rethrow;
    }
  }

  void beginCheckout(SubscriptionCheckoutArgs args) {
    state = state.copyWith(
      checkoutArgs: args,
      clearPendingInitiate: true,
      clearPaymentResultArgs: true,
      clearError: true,
    );
  }

  void setPendingInitiate(InitiateSubscriptionPaymentResult initiate) {
    state = state.copyWith(pendingInitiate: initiate);
  }

  void beginPaymentResult(SubscriptionPaymentResultArgs args) {
    state = state.copyWith(
      paymentResultArgs: args,
      clearPendingInitiate: true,
    );
  }

  void clearCheckoutFlow() {
    state = state.copyWith(
      clearCheckoutArgs: true,
      clearPendingInitiate: true,
      clearPaymentResultArgs: true,
    );
  }

  List<SubscriptionPlan> _sortedPlans(List<SubscriptionPlan> plans) {
    final sorted = [...plans]..sort((a, b) => a.price.compareTo(b.price));
    if (sorted.any((plan) => plan.isRecommended)) return sorted;
    if (sorted.length >= 2) {
      final middle = sorted.length ~/ 2;
      return sorted
          .asMap()
          .entries
          .map(
            (entry) => entry.key == middle
                ? SubscriptionPlan(
                    id: entry.value.id,
                    name: entry.value.name,
                    tagline: entry.value.tagline,
                    description: entry.value.description,
                    price: entry.value.price,
                    currency: entry.value.currency,
                    durationDays: entry.value.durationDays,
                    isActive: entry.value.isActive,
                    isRecommended: true,
                    features: entry.value.features,
                  )
                : entry.value,
          )
          .toList(growable: false);
    }
    return sorted;
  }
}

final driverSubscriptionProvider =
    StateNotifierProvider<DriverSubscriptionNotifier, DriverSubscriptionState>(
  (ref) => DriverSubscriptionNotifier(ref),
);

const _dummyPlans = [
  SubscriptionPlan(
    id: 1,
    name: 'Basic Plan',
    tagline: 'Ideal for solo transporters',
    price: 99,
    currency: 'INR',
    durationDays: 30,
    features: [
      'Basic route matching',
      '5 active bids',
      'Standard support',
    ],
  ),
  SubscriptionPlan(
    id: 2,
    name: 'Professional Plan',
    tagline: 'Best for scaling fleets',
    price: 199,
    currency: 'INR',
    durationDays: 30,
    isRecommended: true,
    features: [
      'Priority route access',
      'Unlimited bids',
      'Real-time analytics',
      'Priority support',
    ],
  ),
  SubscriptionPlan(
    id: 3,
    name: 'Enterprise Plan',
    tagline: 'For large logistics operations',
    price: 399,
    currency: 'INR',
    durationDays: 30,
    features: [
      'Dedicated account manager',
      'API access',
      'Custom reporting',
      '24/7 Premium support',
    ],
  ),
];
