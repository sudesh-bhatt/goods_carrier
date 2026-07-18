import 'package:flutter/foundation.dart';

import '../entities/shipment.dart';
import '../enums/vehicle_type.dart';

/// Load capacity bands — Figma filter sheet segmented control.
enum LoadCapacityBand {
  upTo500kg,
  from500kgTo2t,
  over2t;

  static const double maxKg = 2500;

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

  /// Preset range (kg) for the dual-thumb slider.
  (double min, double max) get kgRange => switch (this) {
        LoadCapacityBand.upTo500kg => (0, 500),
        LoadCapacityBand.from500kgTo2t => (500, 2000),
        LoadCapacityBand.over2t => (2000, maxKg),
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
    this.vehicleTypeId,
    this.capacityBand = LoadCapacityBand.from500kgTo2t,
    this.capacityRangeStart = 500,
    this.capacityRangeEnd = 2000,
    this.restrictCapacity = false,
  });

  final String? fromCity;
  final String? toCity;
  final DateTime? pickupDate;
  final VehicleType? vehicleClass;

  /// Preferred API filter id from vehicle masters / dashboard types.
  final int? vehicleTypeId;
  final LoadCapacityBand capacityBand;

  /// Selected load range in kg (0–[LoadCapacityBand.maxKg]).
  final double capacityRangeStart;
  final double capacityRangeEnd;

  /// When true, [capacityBand] is applied (set from the filter sheet only).
  final bool restrictCapacity;

  bool get hasActiveFilters =>
      (fromCity?.trim().isNotEmpty ?? false) ||
      (toCity?.trim().isNotEmpty ?? false) ||
      pickupDate != null ||
      vehicleClass != null ||
      vehicleTypeId != null ||
      restrictCapacity;

  /// Human-readable capacity label from the current slider range.
  String get capacityRangeLabel =>
      formatCapacityKgRange(capacityRangeStart, capacityRangeEnd);

  /// `capacity_min` / `capacity_max` for dashboard APIs (kg).
  ({int? min, int? max}) get apiCapacityKg {
    if (!restrictCapacity) return (min: null, max: null);
    return (
      min: capacityRangeStart.round(),
      max: capacityRangeEnd.round(),
    );
  }

  static String formatCapacityKgRange(double minKg, double maxKg) {
    String fmt(double kg) {
      if (kg >= 1000) {
        final tons = kg / 1000;
        return tons == tons.roundToDouble()
            ? '${tons.round()}t'
            : '${tons.toStringAsFixed(1)}t';
      }
      return '${kg.round()}kg';
    }

    return '${fmt(minKg)} - ${fmt(maxKg)}';
  }

  ShipmentFilter copyWith({
    String? fromCity,
    String? toCity,
    DateTime? pickupDate,
    VehicleType? vehicleClass,
    int? vehicleTypeId,
    LoadCapacityBand? capacityBand,
    double? capacityRangeStart,
    double? capacityRangeEnd,
    bool? restrictCapacity,
    bool clearFromCity = false,
    bool clearToCity = false,
    bool clearPickupDate = false,
    bool clearVehicleClass = false,
    bool clearVehicleTypeId = false,
  }) {
    return ShipmentFilter(
      fromCity: clearFromCity ? null : (fromCity ?? this.fromCity),
      toCity: clearToCity ? null : (toCity ?? this.toCity),
      pickupDate:
          clearPickupDate ? null : (pickupDate ?? this.pickupDate),
      vehicleClass: clearVehicleClass
          ? null
          : (vehicleClass ?? this.vehicleClass),
      vehicleTypeId: clearVehicleTypeId
          ? null
          : (vehicleTypeId ?? this.vehicleTypeId),
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
    if (restrictCapacity) {
      final weightKg = shipment.goods.weightKg;
      if (weightKg < capacityRangeStart || weightKg > capacityRangeEnd) {
        return false;
      }
    }
    return true;
  }
}
