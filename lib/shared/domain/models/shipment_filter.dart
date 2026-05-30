import 'package:flutter/foundation.dart';

import '../entities/shipment.dart';
import '../enums/vehicle_type.dart';

/// Load capacity bands — Figma filter sheet segmented control.
enum LoadCapacityBand {
  upTo500kg,
  from500kgTo2t,
  over2t;

  String get label => switch (this) {
        LoadCapacityBand.upTo500kg => '0-500kg',
        LoadCapacityBand.from500kgTo2t => '500kg-2t',
        LoadCapacityBand.over2t => '2t+',
      };

  String get summaryLabel => switch (this) {
        LoadCapacityBand.upTo500kg => '0-500kg',
        LoadCapacityBand.from500kgTo2t => '500kg - 2t',
        LoadCapacityBand.over2t => '2t+',
      };
}

/// Search / filter criteria — reusable across customer & driver flows.
@immutable
class ShipmentFilter {
  const ShipmentFilter({
    this.fromCity,
    this.toCity,
    this.pickupDate,
    this.vehicleClass,
    this.capacityBand = LoadCapacityBand.from500kgTo2t,
    this.capacityRangeStart = 0.15,
    this.capacityRangeEnd = 0.82,
    this.restrictCapacity = false,
  });

  final String? fromCity;
  final String? toCity;
  final DateTime? pickupDate;
  final VehicleType? vehicleClass;
  final LoadCapacityBand capacityBand;
  final double capacityRangeStart;
  final double capacityRangeEnd;

  /// When true, [capacityBand] is applied (set from the filter sheet only).
  final bool restrictCapacity;

  bool get hasActiveFilters =>
      (fromCity?.trim().isNotEmpty ?? false) ||
      (toCity?.trim().isNotEmpty ?? false) ||
      pickupDate != null ||
      vehicleClass != null ||
      restrictCapacity;

  ShipmentFilter copyWith({
    String? fromCity,
    String? toCity,
    DateTime? pickupDate,
    VehicleType? vehicleClass,
    LoadCapacityBand? capacityBand,
    double? capacityRangeStart,
    double? capacityRangeEnd,
    bool? restrictCapacity,
    bool clearFromCity = false,
    bool clearToCity = false,
    bool clearPickupDate = false,
    bool clearVehicleClass = false,
  }) {
    return ShipmentFilter(
      fromCity: clearFromCity ? null : (fromCity ?? this.fromCity),
      toCity: clearToCity ? null : (toCity ?? this.toCity),
      pickupDate:
          clearPickupDate ? null : (pickupDate ?? this.pickupDate),
      vehicleClass: clearVehicleClass
          ? null
          : (vehicleClass ?? this.vehicleClass),
      capacityBand: capacityBand ?? this.capacityBand,
      capacityRangeStart: capacityRangeStart ?? this.capacityRangeStart,
      capacityRangeEnd: capacityRangeEnd ?? this.capacityRangeEnd,
      restrictCapacity: restrictCapacity ?? this.restrictCapacity,
    );
  }

  ShipmentFilter cleared() => const ShipmentFilter();

  bool matches(Shipment shipment) {
    if (fromCity != null &&
        fromCity!.trim().isNotEmpty &&
        !shipment.pickup.city
            .toLowerCase()
            .contains(fromCity!.trim().toLowerCase())) {
      return false;
    }
    if (toCity != null &&
        toCity!.trim().isNotEmpty &&
        !shipment.drop.city
            .toLowerCase()
            .contains(toCity!.trim().toLowerCase())) {
      return false;
    }
    if (pickupDate != null) {
      final d = shipment.pickupDateTime;
      if (d.year != pickupDate!.year ||
          d.month != pickupDate!.month ||
          d.day != pickupDate!.day) {
        return false;
      }
    }
    if (vehicleClass != null && shipment.vehicleType != vehicleClass) {
      return false;
    }
    if (restrictCapacity && !_matchesCapacity(shipment.goods.weightKg)) {
      return false;
    }
    return true;
  }

  bool _matchesCapacity(double weightKg) {
    return switch (capacityBand) {
      LoadCapacityBand.upTo500kg => weightKg <= 500,
      LoadCapacityBand.from500kgTo2t => weightKg > 500 && weightKg <= 2000,
      LoadCapacityBand.over2t => weightKg > 2000,
    };
  }
}
