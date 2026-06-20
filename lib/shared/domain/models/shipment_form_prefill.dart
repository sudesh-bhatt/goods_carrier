import '../entities/shipment.dart';
import 'shipment_submit_options.dart';

/// Shipment + API-only fields returned by create/edit/detail endpoints.
class ShipmentFormPrefill {
  const ShipmentFormPrefill({
    required this.shipment,
    required this.options,
  });

  final Shipment shipment;
  final ShipmentSubmitOptions options;
}
