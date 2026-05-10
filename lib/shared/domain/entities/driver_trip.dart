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
  });

  final String id;              // VB-XXXX
  final String driverId;
  final String driverName;
  final String fromCity;
  final String toCity;
  final DateTime estimatedStartDate;
  final DateTime estimatedEndDate;
  final VehicleType vehicleCategory;
  final String vehicleNumber;   // MH 02 CC 4156
  final double loadCapacityTons;
  final double estimatedPrice;
  final TripStatus status;

  bool get isActive => status == TripStatus.active;

  DriverTrip copyWith({TripStatus? status, double? estimatedPrice}) => DriverTrip(
    id: id, driverId: driverId, driverName: driverName,
    fromCity: fromCity, toCity: toCity,
    estimatedStartDate: estimatedStartDate, estimatedEndDate: estimatedEndDate,
    vehicleCategory: vehicleCategory, vehicleNumber: vehicleNumber,
    loadCapacityTons: loadCapacityTons,
    estimatedPrice: estimatedPrice ?? this.estimatedPrice,
    status: status ?? this.status,
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
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DriverTrip && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
