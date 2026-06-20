import '../entities/shipment.dart';

class ShipmentPaymentSummary {
  const ShipmentPaymentSummary({
    required this.baseFare,
    required this.totalAmount,
  });

  final double baseFare;
  final double totalAmount;
}

class ShipmentInterestedDriver {
  const ShipmentInterestedDriver({
    required this.driverId,
    required this.name,
    this.subtitle,
    this.vehicleName = '',
    this.vehicleNumber = '',
    this.capacityLabel = '',
    this.phone,
  });

  final String driverId;
  final String name;
  final String? subtitle;
  final String vehicleName;
  final String vehicleNumber;
  final String capacityLabel;
  final String? phone;
}

/// Detail payload from `GET /api/customer/shipments/{id}`.
class CustomerShipmentDetail {
  const CustomerShipmentDetail({
    required this.shipment,
    required this.paymentSummary,
    this.interestedDrivers = const [],
  });

  final Shipment shipment;
  final ShipmentPaymentSummary paymentSummary;
  final List<ShipmentInterestedDriver> interestedDrivers;
}
