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

  /// Driver publish / update trip form — Figma `1:3634`.
  String get formLabel => switch (this) {
        VehicleType.mini        => 'Mini Truck',
        VehicleType.pickupTruck => 'Pickup Truck (1T)',
        VehicleType.truck       => 'Truck (5T)',
        VehicleType.heavyDuty   => 'Heavy Duty Truck (10-20T)',
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
