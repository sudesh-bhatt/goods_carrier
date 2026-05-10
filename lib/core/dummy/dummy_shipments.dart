import '../../shared/domain/entities/shipment.dart';
import '../../shared/domain/enums/shipment_status.dart';
import '../../shared/domain/enums/vehicle_type.dart';

class DummyShipments {
  DummyShipments._();

  static final List<Shipment> all = [
    Shipment(
      id: 'TRK-8829',
      customerId: 'USR-0001',
      pickup: const ShipmentLocation(
        city: 'Mumbai, MH', fullAddress: 'Bandra East, Mumbai',
        lat: 19.0596, lng: 72.8295,
      ),
      drop: const ShipmentLocation(
        city: 'Delhi', fullAddress: 'Karol Bagh, New Delhi',
        lat: 28.6519, lng: 77.1909,
      ),
      pickupDateTime: DateTime(2026, 4, 15, 9, 0),
      dropDateTime:   DateTime(2026, 4, 18, 16, 0),
      goods: const GoodsDetail(type: 'Electronics', weightKg: 500, isFragile: true),
      vehicleType: VehicleType.pickupTruck,
      status: ShipmentStatus.pending,
      estimatedPrice: 2100,
      interestedDriverIds: ['USR-0002', 'USR-0003'],
    ),
    Shipment(
      id: 'TRK-6645',
      customerId: 'USR-0001',
      pickup: const ShipmentLocation(
        city: 'Pune, MH', fullAddress: 'Hinjewadi, Pune',
        lat: 18.5912, lng: 73.7389,
      ),
      drop: const ShipmentLocation(
        city: 'Ahmedabad, GJ', fullAddress: 'Maninagar, Ahmedabad',
        lat: 23.0009, lng: 72.6069,
      ),
      pickupDateTime: DateTime(2026, 4, 20, 10, 0),
      dropDateTime:   DateTime(2026, 4, 22, 14, 0),
      goods: const GoodsDetail(type: 'FMCG', weightKg: 2000, isFragile: false),
      vehicleType: VehicleType.truck,
      status: ShipmentStatus.assigned,
      estimatedPrice: 4500,
      assignedDriverId: 'USR-0002',
    ),
    Shipment(
      id: 'TRK-5512',
      customerId: 'USR-0001',
      pickup: const ShipmentLocation(
        city: 'Chennai, TN', fullAddress: 'T. Nagar, Chennai',
        lat: 13.0418, lng: 80.2341,
      ),
      drop: const ShipmentLocation(
        city: 'Bengaluru, KA', fullAddress: 'Whitefield, Bengaluru',
        lat: 12.9698, lng: 77.7499,
      ),
      pickupDateTime: DateTime(2026, 4, 10, 8, 0),
      dropDateTime:   DateTime(2026, 4, 10, 20, 0),
      goods: const GoodsDetail(type: 'Textiles', weightKg: 800, isFragile: false),
      vehicleType: VehicleType.pickupTruck,
      status: ShipmentStatus.delivered,
      estimatedPrice: 1800,
    ),
    Shipment(
      id: 'TRK-4401',
      customerId: 'USR-0001',
      pickup: const ShipmentLocation(
        city: 'Hyderabad, TS', fullAddress: 'HITEC City, Hyderabad',
        lat: 17.4435, lng: 78.3772,
      ),
      drop: const ShipmentLocation(
        city: 'Vizag, AP', fullAddress: 'Gajuwaka, Visakhapatnam',
        lat: 17.6868, lng: 83.2185,
      ),
      pickupDateTime: DateTime(2026, 4, 5, 7, 30),
      dropDateTime:   DateTime(2026, 4, 6, 12, 0),
      goods: const GoodsDetail(type: 'Auto Parts', weightKg: 1200, isFragile: false),
      vehicleType: VehicleType.truck,
      status: ShipmentStatus.cancelled,
      estimatedPrice: 3200,
    ),
  ];

  static List<Shipment> get pending   => all.where((s) => s.isPending).toList();
  static List<Shipment> get active    => all.where((s) => s.isActive).toList();
  static List<Shipment> get completed => all.where((s) => s.isCompleted).toList();
  static List<Shipment> get cancelled => all.where((s) => s.isCancelled).toList();
}
