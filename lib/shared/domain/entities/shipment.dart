import '../enums/shipment_status.dart';
import '../enums/vehicle_type.dart';

// ─── JSON helpers ─────────────────────────────────────────────────────────────

extension ShipmentLocationJson on ShipmentLocation {
  Map<String, dynamic> toJson() => {
        'city':         city,
        'full_address': fullAddress,
        'lat':          lat,
        'lng':          lng,
      };

  static ShipmentLocation fromJson(Map<String, dynamic> j) => ShipmentLocation(
        city:        j['city']         as String,
        fullAddress: j['full_address'] as String,
        lat:         (j['lat']  as num?)?.toDouble() ?? 0.0,
        lng:         (j['lng']  as num?)?.toDouble() ?? 0.0,
      );
}

extension GoodsDetailJson on GoodsDetail {
  Map<String, dynamic> toJson() => {
        'type':                 type,
        'weight_kg':            weightKg,
        'is_fragile':           isFragile,
        'special_instructions': specialInstructions,
      };

  static GoodsDetail fromJson(Map<String, dynamic> j) => GoodsDetail(
        type:                j['type']      as String,
        weightKg:            (j['weight_kg'] as num).toDouble(),
        isFragile:           j['is_fragile'] as bool,
        specialInstructions: j['special_instructions'] as String?,
      );
}

class ShipmentLocation {
  const ShipmentLocation({
    required this.city,
    required this.fullAddress,
    this.lat = 0.0,
    this.lng = 0.0,
  });

  final String city;
  final String fullAddress;
  final double lat;
  final double lng;
}

class GoodsDetail {
  const GoodsDetail({
    required this.type,
    required this.weightKg,
    required this.isFragile,
    this.specialInstructions,
  });

  final String type;
  final double weightKg;
  final bool isFragile;
  final String? specialInstructions;

  String get weightLabel => weightKg >= 1000
      ? '${(weightKg / 1000).toStringAsFixed(1)} Ton'
      : '${weightKg.toStringAsFixed(0)} KG';
}

class Shipment {
  const Shipment({
    required this.id,
    required this.customerId,
    required this.pickup,
    required this.drop,
    required this.pickupDateTime,
    required this.dropDateTime,
    required this.goods,
    required this.vehicleType,
    required this.status,
    required this.estimatedPrice,
    this.assignedDriverId,
    this.interestedDriverIds = const [],
  });

  final String id;                        // TRK-XXXX
  final String customerId;
  final ShipmentLocation pickup;
  final ShipmentLocation drop;
  final DateTime pickupDateTime;
  final DateTime dropDateTime;
  final GoodsDetail goods;
  final VehicleType vehicleType;
  final ShipmentStatus status;
  final double estimatedPrice;
  final String? assignedDriverId;
  final List<String> interestedDriverIds;

  bool get isActive    => status == ShipmentStatus.assigned || status == ShipmentStatus.inTransit;
  bool get isPending   => status == ShipmentStatus.pending || status == ShipmentStatus.interestReceived;
  bool get isCompleted => status == ShipmentStatus.delivered;
  bool get isCancelled => status == ShipmentStatus.cancelled;

  Shipment copyWith({
    ShipmentStatus? status,
    String? assignedDriverId,
    List<String>? interestedDriverIds,
    double? estimatedPrice,
  }) => Shipment(
    id: id, customerId: customerId, pickup: pickup, drop: drop,
    pickupDateTime: pickupDateTime, dropDateTime: dropDateTime,
    goods: goods, vehicleType: vehicleType,
    status: status ?? this.status,
    estimatedPrice: estimatedPrice ?? this.estimatedPrice,
    assignedDriverId: assignedDriverId ?? this.assignedDriverId,
    interestedDriverIds: interestedDriverIds ?? this.interestedDriverIds,
  );

  // ── JSON ────────────────────────────────────────────────────────────────

  factory Shipment.fromJson(Map<String, dynamic> j) => Shipment(
        id:                  j['id']           as String,
        customerId:          j['customer_id']  as String,
        pickup:              ShipmentLocationJson.fromJson(
                               j['pickup'] as Map<String, dynamic>),
        drop:                ShipmentLocationJson.fromJson(
                               j['drop'] as Map<String, dynamic>),
        pickupDateTime:      DateTime.parse(j['pickup_datetime'] as String),
        dropDateTime:        DateTime.parse(j['drop_datetime']   as String),
        goods:               GoodsDetailJson.fromJson(
                               j['goods'] as Map<String, dynamic>),
        vehicleType:         VehicleType.values.byName(j['vehicle_type'] as String),
        status:              ShipmentStatus.values.byName(j['status']    as String),
        estimatedPrice:      (j['estimated_price'] as num).toDouble(),
        assignedDriverId:    j['assigned_driver_id'] as String?,
        interestedDriverIds: (j['interested_driver_ids'] as List<dynamic>?)
                                 ?.cast<String>() ??
                             const [],
      );

  Map<String, dynamic> toJson() => {
        'id':                    id,
        'customer_id':           customerId,
        'pickup':                pickup.toJson(),
        'drop':                  drop.toJson(),
        'pickup_datetime':       pickupDateTime.toIso8601String(),
        'drop_datetime':         dropDateTime.toIso8601String(),
        'goods':                 goods.toJson(),
        'vehicle_type':          vehicleType.name,
        'status':                status.name,
        'estimated_price':       estimatedPrice,
        'assigned_driver_id':    assignedDriverId,
        'interested_driver_ids': interestedDriverIds,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Shipment && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
