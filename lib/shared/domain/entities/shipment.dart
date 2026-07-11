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

  /// City when present; otherwise the flat address from list/detail APIs.
  String get displayLabel =>
      city.isNotEmpty ? city : fullAddress;
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
    this.apiId,
    this.assignedDriverId,
    this.interestedDriverIds = const [],
    this.interestCount = 0,
    this.allottedStatus,
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

  /// Numeric backend id when [id] is a display code such as `TRK-8829`.
  final String? apiId;

  /// Id to use in `/api/customer/shipments/{id}` paths.
  String get apiResourceId => apiId ?? id;

  final String? assignedDriverId;
  final List<String> interestedDriverIds;

  /// From list/detail API `request_count` / `interest_count` when driver IDs
  /// are not included.
  final int interestCount;

  /// Human-readable allotment label from API (`allotted_status`), e.g.
  /// "Driver Assigned". Prefer this over [status] for list/detail badges.
  final String? allottedStatus;

  bool get isActive    => status == ShipmentStatus.assigned || status == ShipmentStatus.inTransit;
  bool get isPending   => status == ShipmentStatus.pending || status == ShipmentStatus.interestReceived;
  bool get isCompleted => status == ShipmentStatus.delivered;
  bool get isCancelled => status == ShipmentStatus.cancelled;

  int get resolvedInterestCount =>
      interestedDriverIds.isNotEmpty ? interestedDriverIds.length : interestCount;

  String get loadCapacityLabel => goods.weightKg > 0
      ? goods.weightLabel
      : vehicleType.capacityDisplay;

  Shipment copyWith({
    ShipmentStatus? status,
    String? assignedDriverId,
    List<String>? interestedDriverIds,
    int? interestCount,
    String? allottedStatus,
    double? estimatedPrice,
  }) => Shipment(
    id: id, customerId: customerId, pickup: pickup, drop: drop,
    pickupDateTime: pickupDateTime, dropDateTime: dropDateTime,
    goods: goods, vehicleType: vehicleType,
    apiId: apiId,
    status: status ?? this.status,
    estimatedPrice: estimatedPrice ?? this.estimatedPrice,
    assignedDriverId: assignedDriverId ?? this.assignedDriverId,
    interestedDriverIds: interestedDriverIds ?? this.interestedDriverIds,
    interestCount: interestCount ?? this.interestCount,
    allottedStatus: allottedStatus ?? this.allottedStatus,
  );

  // ── JSON ────────────────────────────────────────────────────────────────

  factory Shipment.fromJson(Map<String, dynamic> j) => Shipment(
        id:                  _stringId(j['shipment_id'] ?? j['id']),
        apiId:               j['shipment_id'] != null
            ? _nullableStringId(j['id'])
            : null,
        customerId:          _stringId(j['customer_id']),
        pickup:              ShipmentLocationJson.fromJson(
                               j['pickup'] as Map<String, dynamic>? ??
                                   _flatPickupJson(j)),
        drop:                ShipmentLocationJson.fromJson(
                               j['drop'] as Map<String, dynamic>? ??
                                   _flatDropJson(j)),
        pickupDateTime:      DateTime.parse(
                               (j['pickup_datetime'] as String?) ??
                                   DateTime.now().toIso8601String()),
        dropDateTime:        DateTime.parse(
                               (j['drop_datetime'] as String?) ??
                                   DateTime.now().toIso8601String()),
        goods:               j['goods'] is Map<String, dynamic>
            ? GoodsDetailJson.fromJson(j['goods'] as Map<String, dynamic>)
            : GoodsDetail(
                type: j['goods_type'] as String? ?? '',
                weightKg: (j['weight_kg'] as num?)?.toDouble() ?? 0,
                isFragile: j['is_fragile'] as bool? ?? false,
                specialInstructions: j['special_instructions'] as String?,
              ),
        vehicleType:         VehicleType.fromApi(j['vehicle_type'] as String?),
        status:              ShipmentStatus.fromApi(j['status'] as String?),
        estimatedPrice:      (j['estimated_price'] as num?)?.toDouble() ?? 0,
        assignedDriverId:    _nullableStringId(j['assigned_driver_id']),
        interestedDriverIds: (j['interested_driver_ids'] as List<dynamic>?)
                                 ?.map((e) => e.toString())
                                 .toList() ??
                             const [],
        interestCount: (j['request_count'] as num?)?.toInt() ??
            (j['interest_count'] as num?)?.toInt() ??
            0,
        allottedStatus: (j['allotted_status'] as String?)?.trim().isNotEmpty ==
                true
            ? (j['allotted_status'] as String).trim()
            : null,
      );

  static String _stringId(dynamic raw) {
    if (raw == null) return '';
    if (raw is int) return raw.toString();
    return raw as String;
  }

  static String? _nullableStringId(dynamic raw) {
    if (raw == null) return null;
    return _stringId(raw);
  }

  static Map<String, dynamic> _flatPickupJson(Map<String, dynamic> j) => {
        'city': j['pickup_city'] ?? '',
        'full_address': j['pickup_address'] ?? '',
        'lat': j['pickup_latitude'] ?? j['pickup_lat'] ?? 0,
        'lng': j['pickup_longitude'] ?? j['pickup_lng'] ?? 0,
      };

  static Map<String, dynamic> _flatDropJson(Map<String, dynamic> j) => {
        'city': j['drop_city'] ?? '',
        'full_address': j['drop_address'] ?? '',
        'lat': j['drop_latitude'] ?? j['drop_lat'] ?? 0,
        'lng': j['drop_longitude'] ?? j['drop_lng'] ?? 0,
      };

  Map<String, dynamic> toJson() => {
        'id':                    id,
        if (apiId != null) 'api_id': apiId,
        'customer_id':           customerId,
        'pickup':                pickup.toJson(),
        'drop':                  drop.toJson(),
        'pickup_datetime':       pickupDateTime.toIso8601String(),
        'drop_datetime':         dropDateTime.toIso8601String(),
        'goods':                 goods.toJson(),
        'vehicle_type':          vehicleType.apiValue,
        'status':                status.apiValue,
        'estimated_price':       estimatedPrice,
        'assigned_driver_id':    assignedDriverId,
        'interested_driver_ids': interestedDriverIds,
        'interest_count':        interestCount,
        if (allottedStatus != null) 'allotted_status': allottedStatus,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Shipment && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
