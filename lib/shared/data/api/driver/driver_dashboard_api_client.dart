import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../domain/entities/shipment.dart';
import '../../../domain/models/driver_dashboard_query.dart';
import '../../../domain/models/driver_shipment_detail.dart';
import '../../../domain/models/paginated_result.dart';
import '../customer/shipment_api_mapper.dart';

/// Driver dashboard — active customer shipments (`GET /api/driver/dashboard`).
class DriverDashboardApiClient {
  DriverDashboardApiClient(this._dio);

  final Dio _dio;

  Future<PaginatedResult<Shipment>> fetchDashboard({
    DriverDashboardQuery query = const DriverDashboardQuery(),
    String fallbackCustomerId = '',
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.driverDashboard,
      queryParameters: query.toQueryParameters(),
    );
    final payload = ApiEnvelope.parsePaginatedData(response.data);
    final items = payload.items
        .map(
          (row) => ShipmentApiMapper.fromJson(
            row,
            fallbackCustomerId: fallbackCustomerId,
          ),
        )
        .toList(growable: false);

    return PaginatedResult<Shipment>(
      items: items,
      currentPage: payload.currentPage,
      lastPage: payload.lastPage,
      perPage: payload.perPage,
      total: payload.total,
    );
  }

  Future<void> expressInterest(
    String shipmentId, {
    required int vehicleId,
    required double offeredPrice,
    required String note,
  }) async {
    await _dio.post<void>(
      ApiConstants.driverShipmentRequest(shipmentId),
      data: {
        'vehicle_id': vehicleId,
        'offered_price': offeredPrice,
        'note': note,
      },
    );
  }

  Future<DriverShipmentDetail> getShipmentDetail(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.driverShipment(id),
    );
    return ShipmentApiMapper.parseDriverDetail(
      ApiEnvelope.parseData(response.data),
    );
  }
}
