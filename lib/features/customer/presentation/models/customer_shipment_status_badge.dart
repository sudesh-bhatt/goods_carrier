import '../../../../l10n/app_localizations.dart';
import '../../../../shared/domain/enums/shipment_status.dart';

/// Single source of truth for customer shipment status pill copy.
String customerShipmentStatusBadgeLabel(
  AppLocalizations l10n,
  ShipmentStatus status,
) =>
    switch (status) {
      ShipmentStatus.cancelled => 'EXPIRED',
      _ => l10n.shipmentStatusPublished.toUpperCase(),
    };
