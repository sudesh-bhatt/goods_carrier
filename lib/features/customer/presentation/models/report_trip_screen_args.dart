import '../../../../shared/domain/entities/shipment.dart';

/// Navigation payload for [ReportTripScreen].
class ReportTripScreenArgs {
  const ReportTripScreenArgs({required this.shipment});

  final Shipment shipment;
}
