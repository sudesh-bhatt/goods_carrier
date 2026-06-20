import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../domain/entities/shipment.dart';
import '../../../domain/entities/shipment_masters.dart';
import '../../../domain/models/customer_shipment_detail.dart';
import '../../../domain/models/customer_shipment_list_query.dart';
import '../../../domain/models/paginated_result.dart';
import '../../../domain/models/shipment_form_prefill.dart';
import '../../../domain/models/shipment_submit_options.dart';
import 'shipment_api_mapper.dart';

/// Customer shipment endpoints — Postman **Customer → Shipments** folder.
class CustomerShipmentApiClient {
  CustomerShipmentApiClient(this._dio);

  final Dio _dio;

  Future<PaginatedResult<Shipment>> listShipments({
    CustomerShipmentListQuery query = const CustomerShipmentListQuery(),
    String fallbackCustomerId = '',
  }) async {
    final allItems = <Shipment>[];
    var page = query.page;
    var lastPage = query.page;

    do {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.customerShipments,
        queryParameters: query.copyWith(page: page).toQueryParameters(),
      );
      final payload = ApiEnvelope.parsePaginatedData(response.data);
      allItems.addAll(
        payload.items.map(
          (row) => ShipmentApiMapper.fromJson(
            row,
            fallbackCustomerId: fallbackCustomerId,
          ),
        ),
      );
      lastPage = payload.lastPage;
      page++;
    } while (page <= lastPage);

    return PaginatedResult<Shipment>(
      items: allItems,
      currentPage: query.page,
      lastPage: lastPage,
      perPage: query.perPage,
      total: allItems.length,
    );
  }

  Future<Shipment> getShipment(
    String id, {
    String fallbackCustomerId = '',
  }) async {
    final detail = await getCustomerShipmentDetail(
      id,
      fallbackCustomerId: fallbackCustomerId,
    );
    return detail.shipment;
  }

  Future<CustomerShipmentDetail> getCustomerShipmentDetail(
    String id, {
    String fallbackCustomerId = '',
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.customerShipment(id),
    );
    return ShipmentApiMapper.parseDetail(
      ApiEnvelope.parseData(response.data),
      fallbackCustomerId: fallbackCustomerId,
    );
  }

  Future<ShipmentFormPrefill> getShipmentForEdit(
    String id, {
    String fallbackCustomerId = '',
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.customerShipmentEdit(id),
    );
    return ShipmentApiMapper.parseFormPrefill(
      ApiEnvelope.parseData(response.data),
      fallbackCustomerId: fallbackCustomerId,
    );
  }

  Future<Shipment> createShipment(
    Shipment shipment, {
    String fallbackCustomerId = '',
    ShipmentSubmitOptions? options,
  }) async {
    if (options == null) {
      throw ArgumentError('ShipmentSubmitOptions required for createShipment');
    }
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.customerShipments,
      data: ShipmentApiMapper.toRequestBody(shipment, options: options),
    );
    return ShipmentApiMapper.fromJson(
      ApiEnvelope.parseData(response.data),
      fallbackCustomerId: fallbackCustomerId.isNotEmpty
          ? fallbackCustomerId
          : shipment.customerId,
    );
  }

  Future<Shipment> updateShipment(
    Shipment shipment, {
    String fallbackCustomerId = '',
    ShipmentSubmitOptions? options,
  }) async {
    if (options == null) {
      throw ArgumentError('ShipmentSubmitOptions required for updateShipment');
    }
    final response = await _dio.put<Map<String, dynamic>>(
      ApiConstants.customerShipment(shipment.apiResourceId),
      data: ShipmentApiMapper.toRequestBody(
        shipment,
        options: options,
        forUpdate: true,
      ),
    );
    return ShipmentApiMapper.fromJson(
      ApiEnvelope.parseData(response.data),
      fallbackCustomerId: fallbackCustomerId.isNotEmpty
          ? fallbackCustomerId
          : shipment.customerId,
    );
  }

  Future<Shipment> cancelShipment(
    String id, {
    required String reason,
    String? otherReason,
    String fallbackCustomerId = '',
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.cancelShipment(id),
      data: ShipmentApiMapper.toCancelBody(
        reason: reason,
        otherReason: otherReason,
      ),
    );
    return ShipmentApiMapper.fromJson(
      ApiEnvelope.parseData(response.data),
      fallbackCustomerId: fallbackCustomerId,
    );
  }

  Future<ShipmentMasters> fetchMasters() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.customerShipmentMasters,
    );
    return ShipmentMasters.fromJson(ApiEnvelope.parseData(response.data));
  }
}

extension on CustomerShipmentListQuery {
  CustomerShipmentListQuery copyWith({int? page}) => CustomerShipmentListQuery(
        status: status,
        search: search,
        page: page ?? this.page,
        perPage: perPage,
      );
}
