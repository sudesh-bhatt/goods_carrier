import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../shared/domain/entities/driver_trip.dart';
import '../../../../shared/domain/models/customer_trip_request_result.dart';
import '../../../../shared/domain/repositories/i_customer_trip_repository.dart';
import 'customer_dashboard_provider.dart';

class CustomerTripActionsNotifier extends StateNotifier<String?> {
  CustomerTripActionsNotifier(this._ref, this._repo) : super(null);

  final Ref _ref;
  final ICustomerTripRepository _repo;

  Future<CustomerTripRequestResult> submitRequest({
    required DriverTrip trip,
    required int shipmentId,
    required String note,
  }) async {
    state = null;
    try {
      final result = await _repo.submitTripRequest(
        tripId: trip.apiResourceId,
        shipmentId: shipmentId,
        note: note,
      );
      _ref.read(customerDashboardProvider.notifier).markInterested(trip.id);
      return result;
    } catch (e) {
      state = ApiExceptionMapper.userMessage(e);
      rethrow;
    }
  }

  Future<String> submitReport({
    required DriverTrip trip,
    required String reason,
    String? description,
  }) async {
    state = null;
    try {
      final reportId = await _repo.reportTrip(
        tripId: trip.apiResourceId,
        reason: reason,
        description: description,
      );
      return reportId;
    } catch (e) {
      state = ApiExceptionMapper.userMessage(e);
      rethrow;
    }
  }
}

final customerTripActionsProvider =
    StateNotifierProvider<CustomerTripActionsNotifier, String?>(
  (ref) => CustomerTripActionsNotifier(
    ref,
    ref.read(customerTripRepositoryProvider),
  ),
);
