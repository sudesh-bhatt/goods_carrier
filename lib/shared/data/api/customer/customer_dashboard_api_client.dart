import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../../core/network/app_exception.dart';
import '../../../domain/entities/shipment_masters.dart';
import '../../../domain/models/customer_dashboard_query.dart';
import '../../../domain/models/customer_dashboard_result.dart';
import 'customer_dashboard_api_mapper.dart';

/// Customer dashboard — available driver trips (`GET /api/customer/dashboard`).
class CustomerDashboardApiClient {
  CustomerDashboardApiClient(this._dio);

  final Dio _dio;

  Future<CustomerDashboardResult> fetchDashboard({
    CustomerDashboardQuery query = const CustomerDashboardQuery(),
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.customerDashboard,
      queryParameters: query.toQueryParameters(),
    );
    return _parseDashboardResponse(response.data);
  }

  CustomerDashboardResult _parseDashboardResponse(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw const UnknownException('Unexpected dashboard response');
    }

    final data = raw['data'];
    final payload = ApiEnvelope.parsePaginatedData(raw);

    final vehicleTypes = _parseVehicleTypes(data);
    final trips = payload.items
        .map(CustomerDashboardApiMapper.fromJson)
        .toList(growable: false);

    return CustomerDashboardResult(
      trips: trips,
      vehicleTypes: vehicleTypes,
      currentPage: payload.currentPage,
      lastPage: payload.lastPage,
      perPage: payload.perPage,
      total: payload.total,
    );
  }

  List<ShipmentMasterOption> _parseVehicleTypes(dynamic data) {
    if (data is! Map<String, dynamic>) return const [];
    final rawList = data['vehicle_types'];
    if (rawList is! List) return const [];
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(ShipmentMasterOption.fromJson)
        .toList(growable: false);
  }
}
