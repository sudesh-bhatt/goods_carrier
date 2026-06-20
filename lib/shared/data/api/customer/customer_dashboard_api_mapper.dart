import '../../../domain/entities/driver_trip.dart';
import '../../../domain/enums/trip_status.dart';
import '../../../domain/enums/vehicle_type.dart';

/// Maps `GET /api/customer/dashboard` rows to [DriverTrip].
abstract final class CustomerDashboardApiMapper {
  static DriverTrip fromJson(Map<String, dynamic> json) {
    final tripCode = _firstString(json, [
      'trip_id',
      'trip_code',
      'code',
    ]);
    final rawId = json['id'];
    final id = tripCode.isNotEmpty
        ? tripCode
        : _stringId(rawId);

    final fromCity = _firstString(json, [
      'from_city',
      'from_address',
      'pickup_city',
      'pickup_address',
    ]);
    final toCity = _firstString(json, [
      'to_city',
      'to_address',
      'drop_city',
      'drop_address',
    ]);

    return DriverTrip(
      id: id,
      driverId: _stringId(
        json['driver_id'] ??
            json['user_id'] ??
            (json['driver'] is Map<String, dynamic>
                ? (json['driver'] as Map)['id']
                : null),
      ),
      driverName: _firstString(json, [
        'driver_name',
        'driver',
      ]),
      fromCity: fromCity,
      toCity: toCity,
      estimatedStartDate: _parseStartDate(json),
      estimatedEndDate: _parseEndDate(json),
      vehicleCategory: _parseVehicleType(json),
      vehicleNumber: _firstString(json, [
        'vehicle_number',
        'vehicle_no',
        'registration_number',
      ]),
      loadCapacityTons: _parseCapacityTons(json),
      estimatedPrice: _parseDouble(
        json['estimated_price'] ??
            json['price'] ??
            json['budget'] ??
            json['total_amount'],
      ),
      status: TripStatus.fromApi(json['status'] as String?),
      interestRequestCount: _readInt(
            json['interest_count'] ??
                json['interest_request_count'] ??
                json['requests_count'],
          ) ??
          0,
      isInterested: json['is_interested'] as bool? ?? false,
    );
  }

  static final _unsetSchedule = DateTime(1970, 1, 1);

  static DateTime _parseStartDate(Map<String, dynamic> json) {
    final fromParts = _parseDateTimeParts(
      json,
      dateKeys: [
        'estimated_start_date',
        'start_date',
        'pickup_date',
      ],
      timeKeys: [
        'estimated_start_time',
        'start_time',
        'pickup_time',
      ],
    );
    if (fromParts != null) return fromParts;

    final combined = json['start_datetime'] ??
        json['pickup_datetime'] ??
        json['pickup_at'];
    if (combined is String && combined.isNotEmpty) {
      return DateTime.parse(combined);
    }

    return _unsetSchedule;
  }

  static DateTime _parseEndDate(Map<String, dynamic> json) {
    final fromParts = _parseDateTimeParts(
      json,
      dateKeys: [
        'estimated_end_date',
        'end_date',
        'drop_date',
      ],
      timeKeys: [
        'estimated_end_time',
        'end_time',
        'drop_time',
      ],
    );
    if (fromParts != null) return fromParts;

    final combined = json['end_datetime'] ??
        json['drop_datetime'] ??
        json['drop_at'];
    if (combined is String && combined.isNotEmpty) {
      return DateTime.parse(combined);
    }

    final start = _parseStartDate(json);
    if (start != _unsetSchedule) {
      return start.add(const Duration(days: 2));
    }
    return _unsetSchedule;
  }

  static DateTime? _parseDateTimeParts(
    Map<String, dynamic> json, {
    required List<String> dateKeys,
    required List<String> timeKeys,
  }) {
    final date = _firstString(json, dateKeys);
    if (date.isEmpty) return null;

    final time = _firstString(json, timeKeys);
    if (time.isNotEmpty) {
      final normalizedTime = time.length <= 5 ? '$time:00' : time;
      return DateTime.parse('${date}T$normalizedTime');
    }
    return DateTime.parse(date);
  }

  static VehicleType _parseVehicleType(Map<String, dynamic> json) {
    final nested = json['vehicle_type'];
    if (nested is Map<String, dynamic>) {
      return VehicleType.fromApi(
        nested['slug'] as String? ??
            nested['code'] as String? ??
            nested['name'] as String?,
      );
    }
    return VehicleType.fromApi(
      json['vehicle_type'] as String? ??
          json['vehicle_category'] as String?,
    );
  }

  static double _parseCapacityTons(Map<String, dynamic> json) {
    final rawCapacity = json['capacity'] ??
        json['load_capacity'] ??
        json['load_capacity_tons'] ??
        json['capacity_tons'];

    if (rawCapacity is num) {
      // Values <= 20 are treated as tons; larger values as kg.
      return rawCapacity > 20 ? rawCapacity / 1000 : rawCapacity.toDouble();
    }

    if (rawCapacity is String) {
      final match = RegExp(r'([\d.]+)').firstMatch(rawCapacity);
      if (match != null) {
        final value = double.tryParse(match.group(1)!) ?? 0;
        if (value <= 0) return 0;
        if (rawCapacity.toLowerCase().contains('kg')) return value / 1000;
        if (rawCapacity.toLowerCase().contains('ton')) return value;
        return value > 20 ? value / 1000 : value;
      }
    }

    return 0;
  }

  static double _parseDouble(dynamic raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw) ?? 0;
    return 0;
  }

  static int? _readInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString());
  }

  static String _stringId(dynamic raw) {
    if (raw == null) return '';
    if (raw is int) return raw.toString();
    return raw.toString();
  }

  static String _firstString(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.isNotEmpty) return value;
      if (value is Map<String, dynamic>) {
        final nested = value['name'] as String? ?? value['label'] as String?;
        if (nested != null && nested.isNotEmpty) return nested;
      }
    }
    return '';
  }
}
