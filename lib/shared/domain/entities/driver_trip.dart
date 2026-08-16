import '../enums/trip_status.dart';
import '../enums/vehicle_type.dart';

class DriverTrip {
  const DriverTrip({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.fromCity,
    required this.toCity,
    required this.estimatedStartDate,
    required this.estimatedEndDate,
    required this.vehicleCategory,
    required this.vehicleNumber,
    required this.loadCapacityTons,
    required this.estimatedPrice,
    required this.status,
    this.apiId,
    this.vehicleTypeName,
    this.loadCapacity,
    this.capacityUnit,
    this.driverPhone,
    this.driverAvatarUrl,
    this.interestRequestCount = 0,
    this.isInterested = false,
  });

  final String id;              // VB-XXXX or numeric string
  final String? apiId;
  final String driverId;
  final String driverName;
  final String fromCity;
  final String toCity;
  final DateTime estimatedStartDate;
  final DateTime estimatedEndDate;
  final VehicleType vehicleCategory;
  /// Vehicle type name as returned by the API, already localized per
  /// `Accept-Language` (e.g. "ટ્રક" for gu). Prefer this for display over
  /// [vehicleCategory]'s hardcoded English label — see [vehicleTypeDisplayLabel].
  final String? vehicleTypeName;
  final String vehicleNumber;   // MH 02 CC 4156
  final double loadCapacityTons;
  /// Raw capacity value as returned by the API (e.g. 200 for `"200 KG"`).
  final double? loadCapacity;
  /// `KG` or `TON` — original unit from API / form submit.
  final String? capacityUnit;
  final String? driverPhone;
  final String? driverAvatarUrl;
  final double estimatedPrice;
  final TripStatus status;
  /// Customer interest count shown on "View Request (n)" CTA.
  final int interestRequestCount;
  /// Whether the logged-in customer already expressed interest.
  final bool isInterested;

  /// Numeric backend id when [id] is a display code such as `VB-9928`.
  String get apiResourceId => apiId ?? id;

  bool get isActive => status == TripStatus.active;

  DriverTrip copyWith({
    String? id,
    String? apiId,
    String? driverName,
    String? fromCity,
    String? toCity,
    DateTime? estimatedStartDate,
    DateTime? estimatedEndDate,
    VehicleType? vehicleCategory,
    String? vehicleTypeName,
    String? vehicleNumber,
    double? loadCapacityTons,
    double? loadCapacity,
    String? capacityUnit,
    String? driverPhone,
    String? driverAvatarUrl,
    double? estimatedPrice,
    TripStatus? status,
    int? interestRequestCount,
    bool? isInterested,
      }) =>
      DriverTrip(
        id: id ?? this.id,
        apiId: apiId ?? this.apiId,
        driverId: driverId,
        driverName: driverName ?? this.driverName,
        fromCity: fromCity ?? this.fromCity,
        toCity: toCity ?? this.toCity,
        estimatedStartDate: estimatedStartDate ?? this.estimatedStartDate,
        estimatedEndDate: estimatedEndDate ?? this.estimatedEndDate,
        vehicleCategory: vehicleCategory ?? this.vehicleCategory,
        vehicleTypeName: vehicleTypeName ?? this.vehicleTypeName,
        vehicleNumber: vehicleNumber ?? this.vehicleNumber,
        loadCapacityTons: loadCapacityTons ?? this.loadCapacityTons,
        loadCapacity: loadCapacity ?? this.loadCapacity,
        capacityUnit: capacityUnit ?? this.capacityUnit,
        driverPhone: driverPhone ?? this.driverPhone,
        driverAvatarUrl: driverAvatarUrl ?? this.driverAvatarUrl,
        estimatedPrice: estimatedPrice ?? this.estimatedPrice,
        status: status ?? this.status,
        interestRequestCount:
            interestRequestCount ?? this.interestRequestCount,
        isInterested: isInterested ?? this.isInterested,
      );

  // ── JSON ────────────────────────────────────────────────────────────────

  factory DriverTrip.fromJson(Map<String, dynamic> j) => DriverTrip(
        id:                 j['id']              as String,
        driverId:           j['driver_id']       as String,
        driverName:         j['driver_name']     as String,
        fromCity:           j['from_city']       as String,
        toCity:             j['to_city']         as String,
        estimatedStartDate: DateTime.parse(j['start_date'] as String),
        estimatedEndDate:   DateTime.parse(j['end_date']   as String),
        vehicleCategory:    VehicleType.values.byName(j['vehicle_category'] as String),
        vehicleNumber:      j['vehicle_number']   as String,
        loadCapacityTons:   (j['load_capacity_tons'] as num).toDouble(),
        estimatedPrice:     (j['estimated_price']    as num).toDouble(),
        status:             TripStatus.values.byName(j['status']  as String),
        interestRequestCount:
            (j['request_count'] as num?)?.toInt() ??
            (j['interest_request_count'] as num?)?.toInt() ??
            0,
        isInterested: j['is_interested'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id':                 id,
        'driver_id':          driverId,
        'driver_name':        driverName,
        'from_city':          fromCity,
        'to_city':            toCity,
        'start_date':         estimatedStartDate.toIso8601String(),
        'end_date':           estimatedEndDate.toIso8601String(),
        'vehicle_category':   vehicleCategory.name,
        'vehicle_number':     vehicleNumber,
        'load_capacity_tons': loadCapacityTons,
        'estimated_price':    estimatedPrice,
        'status':             status.name,
        'interest_request_count': interestRequestCount,
        'is_interested': isInterested,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DriverTrip && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
