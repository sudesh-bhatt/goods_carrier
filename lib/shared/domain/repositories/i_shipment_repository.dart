import '../entities/shipment.dart';
import '../models/customer_shipment_detail.dart';
import '../models/driver_dashboard_query.dart';
import '../models/driver_shipment_detail.dart';
import '../models/shipment_form_prefill.dart';
import '../models/shipment_submit_options.dart';

/// Contract for all shipment data operations.
///
/// Two implementations exist:
///   - [LocalShipmentRepository] — dummy data (Sessions 1–6)
///   - [RemoteShipmentRepository] — Dio / REST (Session 7+)
///
/// Switch implementation in [shipmentRepositoryProvider].
abstract class IShipmentRepository {
  // ── Customer operations ──────────────────────────────────────────────────

  /// Returns all shipments belonging to [customerId].
  Future<List<Shipment>> getCustomerShipments(String customerId);

  /// Loads a single shipment (`GET .../shipments/{id}`).
  Future<Shipment> getShipment(String id);

  /// Loads shipment detail including payment summary and interested drivers.
  Future<CustomerShipmentDetail> getCustomerShipmentDetail(String id);

  /// Loads a shipment for the edit form (`GET .../edit`).
  Future<ShipmentFormPrefill> getShipmentForEdit(String id);

  /// Posts a new shipment request. Returns the server-echoed entity with
  /// the server-assigned ID (may differ from the optimistic local ID).
  Future<Shipment> createShipment(
    Shipment shipment, {
    ShipmentSubmitOptions? options,
  });

  /// Updates an existing shipment (edit flow).
  Future<Shipment> updateShipment(
    Shipment shipment, {
    ShipmentSubmitOptions? options,
  });

  /// Cancels a pending shipment. Throws [AppException] if the shipment is
  /// not in a cancellable state (i.e., already assigned or in transit).
  Future<Shipment> cancelShipment(
    String shipmentId, {
    required String reason,
    String? otherReason,
  });

  /// Locks in [driverId] as the selected driver for [shipmentId].
  Future<void> assignDriver(String shipmentId, String driverId);

  // ── Driver operations ────────────────────────────────────────────────────

  /// Returns all pending shipment requests visible to this driver.
  /// Filtered server-side by vehicle type and location radius.
  Future<List<Shipment>> getPendingRequests({
    String? driverId,
    DriverDashboardQuery query = const DriverDashboardQuery(),
  });

  /// Loads driver shipment detail (`GET /api/driver/shipments/{id}`).
  Future<DriverShipmentDetail> getDriverShipmentDetail(String id);

  /// Submits the driver's interest in a shipment.
  /// Returns `true` when the API succeeds.
  Future<bool> expressInterest({
    required String shipmentId,
    required String driverId,
    required int vehicleId,
    required double offeredPrice,
    required String note,
  });
}
