import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../shared/domain/models/confirm_subscription_payment.dart';
import '../../../../shared/domain/models/current_subscription.dart';
import '../../../../shared/domain/models/initiate_subscription_payment.dart';
import '../../../../shared/domain/models/subscription_plan.dart';

class DriverSubscriptionState {
  const DriverSubscriptionState({
    this.plans = const [],
    this.currentSubscription,
    this.isLoadingPlans = false,
    this.isProcessingPayment = false,
    this.error,
  });

  final List<SubscriptionPlan> plans;
  final CurrentSubscription? currentSubscription;
  final bool isLoadingPlans;
  final bool isProcessingPayment;
  final String? error;

  DriverSubscriptionState copyWith({
    List<SubscriptionPlan>? plans,
    CurrentSubscription? currentSubscription,
    bool? isLoadingPlans,
    bool? isProcessingPayment,
    String? error,
    bool clearError = false,
    bool clearCurrentSubscription = false,
  }) =>
      DriverSubscriptionState(
        plans: plans ?? this.plans,
        currentSubscription: clearCurrentSubscription
            ? null
            : (currentSubscription ?? this.currentSubscription),
        isLoadingPlans: isLoadingPlans ?? this.isLoadingPlans,
        isProcessingPayment:
            isProcessingPayment ?? this.isProcessingPayment,
        error: clearError ? null : (error ?? this.error),
      );
}

class DriverSubscriptionNotifier extends StateNotifier<DriverSubscriptionState> {
  DriverSubscriptionNotifier(this._ref)
      : super(const DriverSubscriptionState());

  final Ref _ref;

  Future<void> loadPlans() async {
    state = state.copyWith(isLoadingPlans: true, clearError: true);
    if (!EnvConfig.useRemoteApi) {
      state = const DriverSubscriptionState(plans: _dummyPlans);
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
      state = DriverSubscriptionState(
        plans: _sortedPlans(plans),
        currentSubscription: current,
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
  }) async {
    state = state.copyWith(isProcessingPayment: true, clearError: true);
    try {
      final result = await _ref
          .read(driverSubscriptionApiClientProvider)
          .initiatePayment(
            InitiateSubscriptionPaymentRequest(
              planId: planId,
              paymentMethod: paymentMethod,
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
  }) async {
    state = state.copyWith(isProcessingPayment: true, clearError: true);
    try {
      final result = await _ref
          .read(driverSubscriptionApiClientProvider)
          .confirmPayment(
            ConfirmSubscriptionPaymentRequest(
              transactionId: transactionId,
              gatewayTransactionId: gatewayTransactionId,
              paymentStatus: success ? 'success' : 'failed',
            ),
          );
      if (result.success) {
        await loadPlans();
      } else {
        state = state.copyWith(isProcessingPayment: false);
      }
      return result;
    } catch (e) {
      state = state.copyWith(
        isProcessingPayment: false,
        error: ApiExceptionMapper.userMessage(e),
      );
      rethrow;
    }
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
