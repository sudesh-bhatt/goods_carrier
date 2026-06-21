import '../../../domain/entities/driver_trip.dart';
import '../../../domain/enums/trip_status.dart';
import '../../../domain/enums/vehicle_type.dart';
import '../../../domain/models/driver_trip_detail.dart';
import '../../../domain/models/trip_form_prefill.dart';
import '../../../domain/models/trip_submit_options.dart';

/// Maps [DriverTrip] entities to/from Goods Carrier driver trip APIs.
///
/// Response parsing aligns with `GET /api/customer/dashboard` trip rows and
/// `GET /api/driver/trips` list/detail responses.
abstract final class TripApiMapper {
  // ── Request ──────────────────────────────────────────────────────────────

  static Map<String, dynamic> toRequestBody(
    DriverTrip trip, {
    required TripSubmitOptions options,
  }) {
    final start = trip.estimatedStartDate;
    final end = trip.estimatedEndDate;

    return {
      'from_city': trip.fromCity,
      if (options.fromAddress != null && options.fromAddress!.isNotEmpty)
        'from_address': options.fromAddress,
      'to_city': trip.toCity,
      if (options.toAddress != null && options.toAddress!.isNotEmpty)
        'to_address': options.toAddress,
      'estimated_start_date': _formatDate(start),
      'estimated_start_time': _formatTime(start),
      'estimated_end_date': _formatDate(end),
      'estimated_end_time': _formatTime(end),
      'vehicle_type_id': options.vehicleTypeId,
      'vehicle_number': trip.vehicleNumber,
      'capacity': options.capacity,
      'capacity_unit': options.capacityUnit,
      'budget': trip.estimatedPrice,
      if (trip.driverName.isNotEmpty) 'driver_name': trip.driverName,
      if (options.driverPhone != null && options.driverPhone!.isNotEmpty)
        'driver_phone': options.driverPhone,
    };
  }

  static Map<String, dynamic> toCancelBody({
    required String reason,
    String? otherReason,
  }) =>
      {
        'reason': reason,
        'other_reason': otherReason,
      };

  /// Fallback when vehicle masters are not loaded yet.
  static int defaultVehicleTypeId(VehicleType type) => switch (type) {
        VehicleType.mini => 1,
        VehicleType.pickupTruck => 2,
        VehicleType.truck => 3,
        VehicleType.heavyDuty => 4,
      };

  // ── Response ─────────────────────────────────────────────────────────────

  static DriverTrip fromJson(
    Map<String, dynamic> json, {
    String fallbackDriverId = '',
  }) =>
      parseFormPrefill(json, fallbackDriverId: fallbackDriverId).trip;

  static DriverTripDetail parseDetail(
    Map<String, dynamic> json, {
    String fallbackDriverId = '',
  }) {
    final trip = fromJson(json, fallbackDriverId: fallbackDriverId);
    final requests = parseTripRequests(json);
    return DriverTripDetail(trip: trip, requests: requests);
  }

  static List<DriverTripRequest> parseTripRequests(Map<String, dynamic> source) {
    final rawList = source['requests'] ??
        source['trip_requests'] ??
        source['customer_requests'] ??
        source['interested_customers'];
    if (rawList is! List || rawList.isEmpty) return const [];

    return rawList.whereType<Map<String, dynamic>>().map(_parseTripRequest).where(
          (request) => request.id.isNotEmpty,
        ).toList(growable: false);
  }

  static DriverTripRequest parseRequestItem(Map<String, dynamic> item) =>
      _parseTripRequest(item);

  static DriverTripRequest _parseTripRequest(Map<String, dynamic> item) {
    final nestedCustomer = item['customer'];
    final customerMap =
        nestedCustomer is Map<String, dynamic> ? nestedCustomer : item;

    final customerId = _stringId(
      item['customer_id'] ??
          customerMap['id'] ??
          customerMap['customer_id'],
    );
    final name = _firstString(customerMap, [
      'name',
      'customer_name',
      'full_name',
    ]);
    final phone = _firstString(customerMap, [
      'phone',
      'mobile',
      'contact_number',
    ]);

    return DriverTripRequest(
      id: _stringId(item['id'] ?? item['request_id']),
      customerId: customerId,
      customerName: name.isNotEmpty ? name : 'Customer',
      phone: phone.isEmpty ? null : phone,
      status: item['status'] as String?,
      quotedPrice: _parseDouble(
        item['quoted_price'] ?? item['price'] ?? item['budget'],
      ),
    );
  }

  static TripFormPrefill parseFormPrefill(
    Map<String, dynamic> json, {
    String fallbackDriverId = '',
  }) {
    final nested = json['trip'];
    final source = nested is Map<String, dynamic> ? nested : json;

    final tripCode = _firstString(source, [
      'trip_id',
      'trip_code',
      'code',
    ]);
    final rawNumericId = source['id'];

    final vehicleTypeId = _readInt(source['vehicle_type_id']) ??
        (source['vehicle_type'] is Map<String, dynamic>
            ? _readInt((source['vehicle_type'] as Map)['id'])
            : null);

    final capacity = _parseCapacity(source);
    final capacityUnit = _normalizeCapacityUnit(
      source['capacity_unit'] as String? ??
          source['weight_unit'] as String?,
    );

    final trip = DriverTrip(
      id: tripCode.isNotEmpty ? tripCode : _stringId(rawNumericId),
      apiId: tripCode.isNotEmpty && rawNumericId != null
          ? _stringId(rawNumericId)
          : null,
      driverId: _stringId(
        source['driver_id'] ??
            source['user_id'] ??
            (source['driver'] is Map<String, dynamic>
                ? (source['driver'] as Map)['id']
                : null) ??
            fallbackDriverId,
      ),
      driverName: _firstString(source, [
        'driver_name',
        'driver',
      ]),
      fromCity: _firstString(source, [
        'from_city',
        'from_address',
        'pickup_city',
        'pickup_address',
      ]),
      toCity: _firstString(source, [
        'to_city',
        'to_address',
        'drop_city',
        'drop_address',
      ]),
      estimatedStartDate: _parseStartDate(source),
      estimatedEndDate: _parseEndDate(source),
      vehicleCategory: _parseVehicleType(source),
      vehicleNumber: _firstString(source, [
        'vehicle_number',
        'vehicle_no',
        'registration_number',
      ]),
      loadCapacityTons: capacity,
      estimatedPrice: _parseDouble(
        source['estimated_price'] ??
            source['price'] ??
            source['budget'] ??
            source['total_amount'],
      ),
      status: TripStatus.fromApi(source['status'] as String?),
      interestRequestCount: _readInt(
            source['interest_count'] ??
                source['interest_request_count'] ??
                source['requests_count'],
          ) ??
          0,
      isInterested: source['is_interested'] as bool? ?? false,
    );

    return TripFormPrefill(
      trip: trip,
      options: TripSubmitOptions(
        vehicleTypeId: vehicleTypeId ?? defaultVehicleTypeId(trip.vehicleCategory),
        capacity: capacity > 0 ? capacity : trip.loadCapacityTons,
        capacityUnit: capacityUnit,
        fromAddress: _firstString(source, ['from_address', 'pickup_address']),
        toAddress: _firstString(source, ['to_address', 'drop_address']),
      ),
    );
  }

  static final _unsetSchedule = DateTime(1970, 1, 1);

  static String _formatDate(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  static String _formatTime(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';

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

  static double _parseCapacity(Map<String, dynamic> json) {
    final rawCapacity = json['capacity'] ??
        json['load_capacity'] ??
        json['load_capacity_tons'] ??
        json['capacity_tons'];

    if (rawCapacity is num) {
      final unit = _normalizeCapacityUnit(
        json['capacity_unit'] as String? ?? json['weight_unit'] as String?,
      );
      if (unit == 'KG' && rawCapacity > 20) return rawCapacity / 1000;
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

  static String _normalizeCapacityUnit(String? raw) {
    if (raw == null || raw.isEmpty) return 'TON';
    return raw.toLowerCase() == 'kg' ? 'KG' : 'TON';
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
