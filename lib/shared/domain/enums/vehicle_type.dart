enum VehicleType {
  mini,
  pickupTruck,
  truck,
  heavyDuty;

  String get label => switch (this) {
        VehicleType.mini        => 'Mini',
        VehicleType.pickupTruck => 'Pickup Truck',
        VehicleType.truck       => 'Truck',
        VehicleType.heavyDuty   => 'Heavy Duty (10–20T)',
      };

  String get capacityLabel => switch (this) {
        VehicleType.mini        => 'Cap: 500 KG',
        VehicleType.pickupTruck => 'Cap: 1 Ton',
        VehicleType.truck       => 'Cap: 5 Ton',
        VehicleType.heavyDuty   => 'Cap: 10–20 Ton',
      };

  /// Short capacity for trip detail — Figma `1:2117`.
  String get capacityDisplay => switch (this) {
        VehicleType.mini        => '500 KG',
        VehicleType.pickupTruck => '1 Ton',
        VehicleType.truck       => '5 Ton',
        VehicleType.heavyDuty   => '10–20 Ton',
      };
}
