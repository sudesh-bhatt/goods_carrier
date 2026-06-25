import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../domain/models/confirm_subscription_payment.dart';
import '../../../domain/models/current_subscription.dart';
import '../../../domain/models/initiate_subscription_payment.dart';
import '../../../domain/models/subscription_plan.dart';
import 'driver_subscription_api_mapper.dart';

class DriverSubscriptionApiClient {
  DriverSubscriptionApiClient(this._dio);

  final Dio _dio;

  Future<List<SubscriptionPlan>> listPlans() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.driverSubscriptionPlans,
    );
    final rows = ApiEnvelope.parseDataListFlexible(response.data);
    return rows
        .map(DriverSubscriptionApiMapper.planFromJson)
        .where((plan) => plan.isActive)
        .toList(growable: false);
  }

  Future<InitiateSubscriptionPaymentResult> initiatePayment(
    InitiateSubscriptionPaymentRequest request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.driverSubscriptionsInitiate,
      data: request.toJson(),
    );
    return DriverSubscriptionApiMapper.initiateFromJson(
      ApiEnvelope.parseData(response.data),
    );
  }

  Future<ConfirmSubscriptionPaymentResult> confirmPayment(
    ConfirmSubscriptionPaymentRequest request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.driverSubscriptionsConfirm,
      data: request.toJson(),
    );
    final raw = response.data;
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('Unexpected confirm payment response');
    }
    final data = raw['data'];
    if (data is Map<String, dynamic>) {
      return DriverSubscriptionApiMapper.confirmFromJson(data);
    }
    return DriverSubscriptionApiMapper.confirmFromJson(raw);
  }

  Future<CurrentSubscription?> getCurrentSubscription() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.driverSubscriptionsCurrent,
    );
    final data = ApiEnvelope.parseData(response.data);
    if (data.isEmpty) return null;
    return DriverSubscriptionApiMapper.currentFromJson(data);
  }
}
