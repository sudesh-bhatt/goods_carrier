import '../entities/shipment.dart';

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

  /// Posts a new shipment request. Returns the server-echoed entity with
  /// the server-assigned ID (may differ from the optimistic local ID).
  Future<Shipment> createShipment(Shipment shipment);

  /// Updates an existing shipment (edit flow).
  Future<Shipment> updateShipment(Shipment shipment);

  /// Cancels a pending shipment. Throws [AppException] if the shipment is
  /// not in a cancellable state (i.e., already assigned or in transit).
  Future<void> cancelShipment(String shipmentId);

  /// Locks in [driverId] as the selected driver for [shipmentId].
  Future<void> assignDriver(String shipmentId, String driverId);

  // ── Driver operations ────────────────────────────────────────────────────

  /// Returns all pending shipment requests visible to this driver.
  /// Filtered server-side by vehicle type and location radius.
  Future<List<Shipment>> getPendingRequests({String? driverId});

  /// Submits the driver's interest in a shipment with an optional
  /// custom [quotedPrice]. Idempotent — re-submitting is a no-op.
  Future<void> expressInterest({
    required String shipmentId,
    required String driverId,
    double? quotedPrice,
  });
}
