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
}
