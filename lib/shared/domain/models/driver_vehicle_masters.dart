class DriverVehicleTypeOption {
  const DriverVehicleTypeOption({
    required this.id,
    required this.name,
    this.slug = '',
  });

  final int id;
  final String name;
  final String slug;
}

class DriverVehicleMasters {
  const DriverVehicleMasters({
    this.vehicleTypes = const [],
    this.capacityUnits = const ['TON'],
  });

  final List<DriverVehicleTypeOption> vehicleTypes;
  final List<String> capacityUnits;
}
