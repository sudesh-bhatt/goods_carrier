import '../../../../l10n/app_localizations.dart';
import '../../../../shared/domain/enums/shipment_status.dart';

/// Single source of truth for customer shipment status pill copy.
///
/// Prefers API [allottedStatus] (e.g. "Driver Assigned") when present.
String customerShipmentStatusBadgeLabel(
  AppLocalizations l10n,
  ShipmentStatus status, {
  String? allottedStatus,
}) {
  final allotted = allottedStatus?.trim();
  if (allotted != null && allotted.isNotEmpty) {
    return allotted.toUpperCase();
  }
  return switch (status) {
    ShipmentStatus.cancelled => 'EXPIRED',
    _ => l10n.shipmentStatusPublished.toUpperCase(),
  };
}
