import '../entities/shipment_masters.dart';

class DriverVehicleTypeOption {
  const DriverVehicleTypeOption({
    required this.id,
    required this.name,
    this.slug = '',
    this.capacityRange = '',
    this.iconUrl = '',
    this.imageUrl = '',
  });

  final int id;
  final String name;
  final String slug;
  final String capacityRange;
  final String iconUrl;
  final String imageUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverVehicleTypeOption && other.id == id;

  @override
  int get hashCode => id.hashCode;

  ShipmentMasterOption toMasterOption() => ShipmentMasterOption(
        id: id,
        name: name,
        slug: slug.isEmpty ? null : slug,
        capacityRange: capacityRange.isEmpty ? null : capacityRange,
        iconUrl: iconUrl.isEmpty ? null : iconUrl,
        imageUrl: imageUrl.isEmpty ? null : imageUrl,
      );
}

class DriverVehicleMasters {
  const DriverVehicleMasters({
    this.vehicleTypes = const [],
    this.capacityUnits = const ['TON'],
  });

  final List<DriverVehicleTypeOption> vehicleTypes;
  final List<String> capacityUnits;

  List<ShipmentMasterOption> get asMasterOptions =>
      vehicleTypes.map((t) => t.toMasterOption()).toList(growable: false);

  /// Offline / API-failure backup — mirrors the previous hardcoded filter set.
  static const fallback = DriverVehicleMasters(
    vehicleTypes: [
      DriverVehicleTypeOption(id: 1, name: 'Mini', slug: 'mini'),
      DriverVehicleTypeOption(id: 2, name: 'Pickup', slug: 'pickup'),
      DriverVehicleTypeOption(id: 3, name: 'Truck', slug: 'truck'),
    ],
    capacityUnits: ['KG', 'TON'],
  );
}
