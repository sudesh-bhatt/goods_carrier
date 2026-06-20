import '../../../api/customer/customer_shipment_api_client.dart';
import '../../../../domain/entities/shipment.dart';
import '../../../../domain/models/customer_shipment_detail.dart';
import '../../../../domain/models/shipment_form_prefill.dart';
import '../../../../domain/models/shipment_submit_options.dart';
import '../../../../domain/repositories/i_shipment_repository.dart';
import '../../local_shipment_repository.dart';

/// Remote customer shipment operations aligned with Postman collection.
///
/// Driver-side methods delegate to [LocalShipmentRepository] until Phase 3.
class RemoteCustomerShipmentRepository implements IShipmentRepository {
  RemoteCustomerShipmentRepository({
    required CustomerShipmentApiClient apiClient,
    required LocalShipmentRepository driverFallback,
  })  : _api = apiClient,
        _driverFallback = driverFallback;

  final CustomerShipmentApiClient _api;
  final LocalShipmentRepository _driverFallback;

  // ── Customer operations ──────────────────────────────────────────────────

  @override
  Future<List<Shipment>> getCustomerShipments(String customerId) async {
    final result = await _api.listShipments(
      fallbackCustomerId: customerId,
    );
    return result.items;
  }

  @override
  Future<Shipment> getShipment(String id) => _api.getShipment(id);

  @override
  Future<CustomerShipmentDetail> getCustomerShipmentDetail(String id) =>
      _api.getCustomerShipmentDetail(id);

  @override
  Future<ShipmentFormPrefill> getShipmentForEdit(String id) =>
      _api.getShipmentForEdit(id);

  @override
  Future<Shipment> createShipment(
    Shipment shipment, {
    ShipmentSubmitOptions? options,
  }) =>
      _api.createShipment(
        shipment,
        fallbackCustomerId: shipment.customerId,
        options: options,
      );

  @override
  Future<Shipment> updateShipment(
    Shipment shipment, {
    ShipmentSubmitOptions? options,
  }) =>
      _api.updateShipment(
        shipment,
        fallbackCustomerId: shipment.customerId,
        options: options,
      );

  @override
  Future<Shipment> cancelShipment(
    String shipmentId, {
    required String reason,
    String? otherReason,
  }) =>
      _api.cancelShipment(
        shipmentId,
        reason: reason,
        otherReason: otherReason,
      );

  @override
  Future<void> assignDriver(String shipmentId, String driverId) {
    throw UnsupportedError(
      'assignDriver is not in the Postman collection yet. '
      'Confirm endpoint with backend before wiring.',
    );
  }

  // ── Driver operations (Phase 3) ──────────────────────────────────────────

  @override
  Future<List<Shipment>> getPendingRequests({String? driverId}) =>
      _driverFallback.getPendingRequests(driverId: driverId);

  @override
  Future<void> expressInterest({
    required String shipmentId,
    required String driverId,
    double? quotedPrice,
  }) =>
      _driverFallback.expressInterest(
        shipmentId: shipmentId,
        driverId: driverId,
        quotedPrice: quotedPrice,
      );
}
