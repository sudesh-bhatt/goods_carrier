enum DriverVehicleStatus {
  active,
  inMaintenance,
  inTransit;

  static DriverVehicleStatus fromApi(String? raw) {
    final slug = raw?.trim().toLowerCase().replaceAll(' ', '_') ?? '';
    return switch (slug) {
      'in_maintenance' || 'maintenance' => DriverVehicleStatus.inMaintenance,
      'in_transit' || 'transit' => DriverVehicleStatus.inTransit,
      _ => DriverVehicleStatus.active,
    };
  }

  String get apiValue => switch (this) {
        DriverVehicleStatus.active => 'active',
        DriverVehicleStatus.inMaintenance => 'in_maintenance',
        DriverVehicleStatus.inTransit => 'in_transit',
      };
}
