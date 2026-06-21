/// @deprecated Use [RemoteCustomerShipmentRepository] instead.
/// Kept for reference during Phase 3 driver shipment wiring.
library;

import 'package:dio/dio.dart';

import '../../../core/network/api_constants.dart';
import '../../../core/network/api_envelope.dart';
import '../../domain/entities/shipment.dart';
import '../../domain/models/customer_shipment_detail.dart';
import '../../domain/models/driver_shipment_detail.dart';
import '../../domain/models/shipment_form_prefill.dart';
import '../../domain/models/shipment_submit_options.dart';
import '../../domain/repositories/i_shipment_repository.dart';

/// Legacy REST implementation — superseded by
/// `remote/customer/remote_customer_shipment_repository.dart`.
@Deprecated('Use RemoteCustomerShipmentRepository')
class RemoteShipmentRepository implements IShipmentRepository {
  RemoteShipmentRepository(this._dio);
  final Dio _dio;

  @override
  Future<List<Shipment>> getCustomerShipments(String customerId) async {
    final response = await _dio.get(
      ApiConstants.customerShipments,
      queryParameters: {'customer_id': customerId},
    );
    return _parseList(response.data['data']);
  }

  @override
  Future<Shipment> getShipment(String id) async {
    final response = await _dio.get(ApiConstants.customerShipment(id));
    return Shipment.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<CustomerShipmentDetail> getCustomerShipmentDetail(String id) async {
    final shipment = await getShipment(id);
    return CustomerShipmentDetail(
      shipment: shipment,
      paymentSummary: ShipmentPaymentSummary(
        baseFare: shipment.estimatedPrice,
        totalAmount: shipment.estimatedPrice,
      ),
    );
  }

  @override
  Future<ShipmentFormPrefill> getShipmentForEdit(String id) async {
    final response = await _dio.get(
      ApiConstants.customerShipmentEdit(id),
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return ShipmentFormPrefill(
      shipment: Shipment.fromJson(data),
      options: const ShipmentSubmitOptions(
        goodsTypeId: 1,
        vehicleTypeId: 1,
        estimatedWeight: 0,
        weightUnit: 'kg',
        termsAccepted: true,
      ),
    );
  }

  @override
  Future<Shipment> createShipment(
    Shipment shipment, {
    ShipmentSubmitOptions? options,
  }) async {
    final response = await _dio.post(
      ApiConstants.customerShipments,
      data: shipment.toJson(),
    );
    return Shipment.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<Shipment> updateShipment(
    Shipment shipment, {
    ShipmentSubmitOptions? options,
  }) async {
    final response = await _dio.put(
      ApiConstants.customerShipment(shipment.id),
      data: shipment.toJson(),
    );
    return Shipment.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<Shipment> cancelShipment(
    String shipmentId, {
    required String reason,
    String? otherReason,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.cancelShipment(shipmentId),
      data: {
        'reason': reason,
        'other_reason': otherReason,
      },
    );
    return Shipment.fromJson(ApiEnvelope.parseData(response.data));
  }

  @override
  Future<void> assignDriver(String shipmentId, String driverId) {
    throw UnsupportedError('assignDriver endpoint not in Postman collection');
  }

  @override
  Future<List<Shipment>> getPendingRequests({String? driverId}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.driverDashboard,
    );
    final items = ApiEnvelope.parsePaginatedData(response.data).items;
    return items.map(Shipment.fromJson).toList();
  }

  @override
  Future<DriverShipmentDetail> getDriverShipmentDetail(String id) {
    throw UnsupportedError('Use DriverDashboardApiClient.getShipmentDetail');
  }

  @override
  Future<bool> expressInterest({
    required String shipmentId,
    required String driverId,
    required int vehicleId,
    required double offeredPrice,
    required String note,
  }) async {
    await _dio.post(
      ApiConstants.driverShipmentRequest(shipmentId),
      data: {
        'vehicle_id': vehicleId,
        'offered_price': offeredPrice,
        'note': note,
      },
    );
    return true;
  }

  List<Shipment> _parseList(dynamic data) => (data as List<dynamic>)
      .map((e) => Shipment.fromJson(e as Map<String, dynamic>))
      .toList();
}
