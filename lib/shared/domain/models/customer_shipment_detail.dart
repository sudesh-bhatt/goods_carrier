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
    this.countryCode = '+91',
    this.avatarUrl,
    this.offeredPrice,
    this.note,
  });

  final String driverId;
  final String name;
  final String? subtitle;
  final String vehicleName;
  final String vehicleNumber;
  final String capacityLabel;
  final String? phone;
  final String countryCode;
  final String? avatarUrl;
  final double? offeredPrice;
  final String? note;
}

/// Result of `POST /api/customer/shipments/{id}/assign`.
class ShipmentAssignmentResult {
  const ShipmentAssignmentResult({
    required this.shipmentId,
    required this.driverId,
    required this.driver,
    this.status = 'accepted',
    this.offeredPrice,
  });

  final String shipmentId;
  final String driverId;
  final ShipmentInterestedDriver driver;
  final String status;
  final double? offeredPrice;
}

/// Detail payload from `GET /api/customer/shipments/{id}`.
class CustomerShipmentDetail {
  const CustomerShipmentDetail({
    required this.shipment,
    required this.paymentSummary,
    this.interestedDrivers = const [],
    this.assignedDriver,
  });

  final Shipment shipment;
  final ShipmentPaymentSummary paymentSummary;
  final List<ShipmentInterestedDriver> interestedDrivers;
  final ShipmentInterestedDriver? assignedDriver;

  CustomerShipmentDetail copyWith({
    Shipment? shipment,
    ShipmentPaymentSummary? paymentSummary,
    List<ShipmentInterestedDriver>? interestedDrivers,
    ShipmentInterestedDriver? assignedDriver,
    bool clearAssignedDriver = false,
  }) =>
      CustomerShipmentDetail(
        shipment: shipment ?? this.shipment,
        paymentSummary: paymentSummary ?? this.paymentSummary,
        interestedDrivers: interestedDrivers ?? this.interestedDrivers,
        assignedDriver: clearAssignedDriver
            ? null
            : (assignedDriver ?? this.assignedDriver),
      );
}
