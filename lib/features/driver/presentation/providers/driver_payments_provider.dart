import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../shared/domain/models/driver_payment_record.dart';

class DriverPaymentsState {
  const DriverPaymentsState({
    this.payments = const [],
    this.isLoading = false,
    this.error,
  });

  final List<DriverPaymentRecord> payments;
  final bool isLoading;
  final String? error;

  DriverPaymentsState copyWith({
    List<DriverPaymentRecord>? payments,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      DriverPaymentsState(
        payments: payments ?? this.payments,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

class DriverPaymentsNotifier extends StateNotifier<DriverPaymentsState> {
  DriverPaymentsNotifier(this._ref) : super(const DriverPaymentsState()) {
    load();
  }

  final Ref _ref;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    if (!EnvConfig.useRemoteApi) {
      state = const DriverPaymentsState();
      return;
    }

    try {
      final payments =
          await _ref.read(driverPaymentApiClientProvider).listPayments();
      state = DriverPaymentsState(payments: payments);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiExceptionMapper.userMessage(e),
      );
    }
  }
}

final driverPaymentsProvider =
    StateNotifierProvider<DriverPaymentsNotifier, DriverPaymentsState>(
  (ref) => DriverPaymentsNotifier(ref),
);
