import '../../../api/customer/customer_shipment_api_client.dart';
import '../../../api/driver/driver_dashboard_api_client.dart';
import '../../../../domain/entities/shipment.dart';
import '../../../../domain/models/customer_shipment_detail.dart';
import '../../../../domain/models/driver_dashboard_query.dart';
import '../../../../domain/models/driver_shipment_detail.dart';
import '../../../../domain/models/shipment_form_prefill.dart';
import '../../../../domain/models/shipment_submit_options.dart';
import '../../../../domain/repositories/i_shipment_repository.dart';

/// Remote customer shipment operations aligned with Postman collection.
///
/// Driver-side methods use [DriverDashboardApiClient].
class RemoteCustomerShipmentRepository implements IShipmentRepository {
  RemoteCustomerShipmentRepository({
    required CustomerShipmentApiClient apiClient,
    required DriverDashboardApiClient driverDashboardApi,
  })  : _api = apiClient,
        _driverDashboardApi = driverDashboardApi;

  final CustomerShipmentApiClient _api;
  final DriverDashboardApiClient _driverDashboardApi;

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

  // ── Driver operations ────────────────────────────────────────────────────

  @override
  Future<List<Shipment>> getPendingRequests({
    String? driverId,
    DriverDashboardQuery query = const DriverDashboardQuery(),
  }) async {
    final result = await _driverDashboardApi.fetchDashboard(query: query);
    return result.items;
  }

  @override
  Future<DriverShipmentDetail> getDriverShipmentDetail(String id) =>
      _driverDashboardApi.getShipmentDetail(id);

  @override
  Future<bool> expressInterest({
    required String shipmentId,
    required String driverId,
    required int vehicleId,
    required double offeredPrice,
    required String note,
  }) async {
    await _driverDashboardApi.expressInterest(
      shipmentId,
      vehicleId: vehicleId,
      offeredPrice: offeredPrice,
      note: note,
    );
    return true;
  }
}
