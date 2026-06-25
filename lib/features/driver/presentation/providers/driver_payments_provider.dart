import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../shared/domain/models/driver_payment_record.dart';

class DriverPaymentsState {
  const DriverPaymentsState({
    this.payments = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = false,
  });

  final List<DriverPaymentRecord> payments;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasMore;

  DriverPaymentsState copyWith({
    List<DriverPaymentRecord>? payments,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasMore,
    bool clearError = false,
  }) =>
      DriverPaymentsState(
        payments: payments ?? this.payments,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        error: clearError ? null : (error ?? this.error),
        hasMore: hasMore ?? this.hasMore,
      );
}

class DriverPaymentsNotifier extends StateNotifier<DriverPaymentsState> {
  DriverPaymentsNotifier(this._ref) : super(const DriverPaymentsState()) {
    load();
  }

  final Ref _ref;
  static const _perPage = 20;
  var _page = 1;

  Future<void> load({bool refresh = false}) async {
    if (refresh) _page = 1;
    state = state.copyWith(isLoading: true, clearError: true);

    if (!EnvConfig.useRemoteApi) {
      state = DriverPaymentsState(payments: _dummyPayments);
      return;
    }

    try {
      final payments = await _ref
          .read(driverPaymentApiClientProvider)
          .listPayments(page: _page, perPage: _perPage);
      state = DriverPaymentsState(
        payments: payments,
        hasMore: payments.length >= _perPage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiExceptionMapper.userMessage(e),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || !EnvConfig.useRemoteApi) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final nextPage = _page + 1;
      final payments = await _ref
          .read(driverPaymentApiClientProvider)
          .listPayments(page: nextPage, perPage: _perPage);
      _page = nextPage;
      state = DriverPaymentsState(
        payments: [...state.payments, ...payments],
        hasMore: payments.length >= _perPage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: ApiExceptionMapper.userMessage(e),
      );
    }
  }

  Future<String> resolveInvoiceUrl(DriverPaymentRecord payment) async {
    if (payment.invoiceUrl != null && payment.invoiceUrl!.isNotEmpty) {
      return payment.invoiceUrl!;
    }
    return _ref
        .read(driverPaymentApiClientProvider)
        .getPaymentInvoiceUrl(payment.id);
  }
}

final driverPaymentsProvider =
    StateNotifierProvider<DriverPaymentsNotifier, DriverPaymentsState>(
  (ref) => DriverPaymentsNotifier(ref),
);

final _dummyPayments = [
  DriverPaymentRecord(
    id: 1,
    transactionId: 'TXN-98234',
    planName: 'Professional Plan',
    amount: 199,
    currency: 'INR',
    paymentMethod: 'upi',
    status: 'success',
    paidAt: DateTime(2026, 4, 15),
  ),
  DriverPaymentRecord(
    id: 2,
    transactionId: 'TXN-98234',
    planName: 'Basic Plan',
    amount: 99,
    currency: 'INR',
    paymentMethod: 'card',
    status: 'success',
    paidAt: DateTime(2026, 3, 14),
  ),
  DriverPaymentRecord(
    id: 3,
    transactionId: 'TXN-98234',
    planName: 'Professional Plan',
    amount: 199,
    currency: 'INR',
    paymentMethod: 'upi',
    status: 'success',
    paidAt: DateTime(2026, 3, 14),
  ),
  DriverPaymentRecord(
    id: 4,
    transactionId: 'TXN-98234',
    planName: 'Enterprise Plan',
    amount: 399,
    currency: 'INR',
    paymentMethod: 'netbanking',
    status: 'success',
    paidAt: DateTime(2026, 3, 14),
  ),
  DriverPaymentRecord(
    id: 5,
    transactionId: 'TXN-98234',
    planName: 'Professional Plan',
    amount: 199,
    currency: 'INR',
    paymentMethod: 'wallet',
    status: 'success',
    paidAt: DateTime(2026, 3, 14),
  ),
];
