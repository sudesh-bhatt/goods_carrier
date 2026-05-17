import 'package:dio/dio.dart';

import '../../../core/network/api_constants.dart';
import '../../domain/entities/shipment.dart';
import '../../domain/repositories/i_shipment_repository.dart';

/// REST implementation of [IShipmentRepository].
///
/// All responses are expected in the shape:
/// ```json
/// { "data": { ... } }        // single resource
/// { "data": [ ... ] }        // collection
/// ```
///
/// Activate by updating [shipmentRepositoryProvider] in
/// `repository_providers.dart`.
class RemoteShipmentRepository implements IShipmentRepository {
  RemoteShipmentRepository(this._dio);
  final Dio _dio;

  // ── Customer operations ──────────────────────────────────────────────────

  @override
  Future<List<Shipment>> getCustomerShipments(String customerId) async {
    final response = await _dio.get(
      ApiConstants.customerShipments,
      queryParameters: {'customer_id': customerId},
    );
    return _parseList(response.data['data']);
  }

  @override
  Future<Shipment> createShipment(Shipment shipment) async {
    final response = await _dio.post(
      ApiConstants.customerShipments,
      data: shipment.toJson(),
    );
    return Shipment.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<Shipment> updateShipment(Shipment shipment) async {
    final response = await _dio.put(
      '${ApiConstants.customerShipments}/${shipment.id}',
      data: shipment.toJson(),
    );
    return Shipment.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> cancelShipment(String shipmentId) =>
      _dio.patch(ApiConstants.cancelShipment(shipmentId));

  @override
  Future<void> assignDriver(String shipmentId, String driverId) =>
      _dio.patch(
        ApiConstants.assignDriver(shipmentId),
        data: {'driver_id': driverId},
      );

  // ── Driver operations ────────────────────────────────────────────────────

  @override
  Future<List<Shipment>> getPendingRequests({String? driverId}) async {
    final response = await _dio.get(
      ApiConstants.driverRequests,
      queryParameters:  (driverId != null)? {'driver_id': driverId}: null,
    );
    return _parseList(response.data['data']);
  }

  @override
  Future<void> expressInterest({
    required String shipmentId,
    required String driverId,
    double? quotedPrice,
  }) =>
      _dio.post(
        ApiConstants.expressInterest(shipmentId),
        data: {
          'driver_id':    driverId,
          if (quotedPrice != null) 'quoted_price': quotedPrice,
        },
      );

  // ── Helpers ──────────────────────────────────────────────────────────────

  List<Shipment> _parseList(dynamic data) => (data as List<dynamic>)
      .map((e) => Shipment.fromJson(e as Map<String, dynamic>))
      .toList();
}
