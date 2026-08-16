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
      'from_location': options.fromLocation,
      'to_location': options.toLocation,
      'estimated_start_date': _formatDate(start),
      'estimated_start_time': _formatTime(start),
      'estimated_end_date': _formatDate(end),
      'estimated_end_time': _formatTime(end),
      'vehicle_id': options.vehicleId,
      'vehicle_number': trip.vehicleNumber,
      'load_capacity': options.loadCapacity,
      'capacity_unit': options.capacityUnit,
      'estimated_price': trip.estimatedPrice,
      if (trip.driverName.isNotEmpty) 'driver_name': trip.driverName,
      'driver_country_code': options.driverCountryCode,
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
    final resolvedName = name.isNotEmpty
        ? name
        : _firstString(item, ['name', 'customer_name', 'full_name']);

    var phone = _firstString(customerMap, [
      'phone',
      'mobile',
      'contact_number',
    ]);
    if (phone.isEmpty) {
      phone = _firstString(item, ['phone', 'mobile', 'contact_number']);
    }

    final countryCode = _firstString(customerMap, [
      'country_code',
      'dial_code',
    ]);
    final resolvedCountryCode = countryCode.isNotEmpty
        ? countryCode
        : _firstString(item, ['country_code', 'dial_code']);

    final avatarUrl = _firstString(customerMap, [
      'avatar',
      'profile_image_url',
      'photo',
    ]);
    final resolvedAvatar = avatarUrl.isNotEmpty
        ? avatarUrl
        : _firstString(item, ['avatar', 'profile_image_url', 'photo']);

    final note = _firstString(item, ['note', 'message', 'additional_note']);

    return DriverTripRequest(
      id: _stringId(item['id'] ?? item['request_id']),
      customerId: customerId,
      customerName: resolvedName.isNotEmpty ? resolvedName : 'Customer',
      phone: phone.isEmpty ? null : phone,
      countryCode:
          resolvedCountryCode.isNotEmpty ? resolvedCountryCode : '+91',
      avatarUrl: resolvedAvatar.isEmpty ? null : resolvedAvatar,
      status: item['status'] as String?,
      quotedPrice: _parseDouble(
        item['quoted_price'] ??
            item['offered_price'] ??
            item['price'] ??
            item['budget'],
      ),
      note: note.isEmpty ? null : note,
    );
  }

  static TripFormPrefill parseFormPrefill(
    Map<String, dynamic> json, {
    String fallbackDriverId = '',
  }) {
    final nested = json['trip'];
    final source = _resolveTripSource(json);
    final root = nested is Map ? json : source;

    final tripCode = _firstString(source, [
      'trip_id',
      'trip_code',
      'code',
    ]);
    final rawNumericId = source['id'];

    final cap = _parseCapacityFields(source);

    final trip = DriverTrip(
      id: tripCode.isNotEmpty ? tripCode : _stringId(rawNumericId),
      apiId: rawNumericId != null ? _stringId(rawNumericId) : null,
      driverId: _stringId(
        source['driver_id'] ??
            source['user_id'] ??
            (source['driver'] is Map<String, dynamic>
                ? (source['driver'] as Map)['id']
                : null) ??
            fallbackDriverId,
      ),
      driverName: _parseDriverName(source, root),
      driverPhone: _parseDriverPhone(source, root),
      driverAvatarUrl: _parseDriverAvatar(source, root),
      fromCity: _firstString(source, [
        'from_city',
        'from_location',
        'from_address',
        'pickup_city',
        'pickup_address',
      ]),
      toCity: _firstString(source, [
        'to_city',
        'to_location',
        'to_address',
        'drop_city',
        'drop_address',
      ]),
      estimatedStartDate: _parseStartDate(source),
      estimatedEndDate: _parseEndDate(source),
      vehicleCategory: _parseVehicleType(source),
      vehicleTypeName: _parseVehicleTypeName(source),
      vehicleNumber: _parseVehicleNumber(source),
      loadCapacity: cap.raw > 0 ? cap.raw : null,
      capacityUnit: cap.raw > 0 ? cap.unit : null,
      loadCapacityTons: cap.tons,
      estimatedPrice: _parseDouble(
        source['estimated_price'] ??
            source['price'] ??
            source['budget'] ??
            source['total_amount'],
      ),
      status: TripStatus.fromApi(source['status'] as String?),
      interestRequestCount: _readInt(
            source['request_count'] ??
                source['interest_count'] ??
                source['interest_request_count'] ??
                source['requests_count'],
          ) ??
          (source['requests'] is List
              ? (source['requests'] as List).length
              : 0),
      isInterested: source['is_interested'] as bool? ?? false,
    );

    final vehicleId = _readInt(source['vehicle_id']) ??
        (source['vehicle'] is Map<String, dynamic>
            ? _readInt((source['vehicle'] as Map)['id'])
            : null);

    return TripFormPrefill(
      trip: trip,
      options: TripSubmitOptions(
        vehicleId: vehicleId ?? 0,
        loadCapacity: cap.raw > 0 ? cap.raw : cap.tons,
        capacityUnit: cap.unit,
        fromLocation: _firstString(source, [
          'from_location',
          'from_address',
          'from_city',
          'pickup_address',
        ]),
        toLocation: _firstString(source, [
          'to_location',
          'to_address',
          'to_city',
          'drop_address',
        ]),
        driverCountryCode: _firstString(source, ['driver_country_code']).isEmpty
            ? '+91'
            : _firstString(source, ['driver_country_code']),
        driverPhone: _parseDriverPhone(source, root).isNotEmpty
            ? _parseDriverPhone(source, root)
            : _firstString(source, ['driver_phone']),
      ),
    );
  }

  static final _unsetSchedule = DateTime(1970, 1, 1);

  /// Publish/update responses may only return `trip_id` + `status`.
  static DriverTrip mergeWithFallback({
    required DriverTrip parsed,
    required DriverTrip submitted,
  }) {
    return submitted.copyWith(
      id: parsed.id.isNotEmpty ? parsed.id : submitted.id,
      apiId: parsed.apiId ?? submitted.apiId,
      fromCity: parsed.fromCity.isNotEmpty ? parsed.fromCity : submitted.fromCity,
      toCity: parsed.toCity.isNotEmpty ? parsed.toCity : submitted.toCity,
      estimatedStartDate: _hasSchedule(parsed.estimatedStartDate)
          ? parsed.estimatedStartDate
          : submitted.estimatedStartDate,
      estimatedEndDate: _hasSchedule(parsed.estimatedEndDate)
          ? parsed.estimatedEndDate
          : submitted.estimatedEndDate,
      vehicleNumber: parsed.vehicleNumber.isNotEmpty
          ? parsed.vehicleNumber
          : submitted.vehicleNumber,
      vehicleTypeName: parsed.vehicleTypeName ?? submitted.vehicleTypeName,
      loadCapacityTons: parsed.loadCapacityTons > 0
          ? parsed.loadCapacityTons
          : submitted.loadCapacityTons,
      loadCapacity: parsed.loadCapacity ?? submitted.loadCapacity,
      capacityUnit: parsed.capacityUnit ?? submitted.capacityUnit,
      driverPhone: parsed.driverPhone ?? submitted.driverPhone,
      driverAvatarUrl: parsed.driverAvatarUrl ?? submitted.driverAvatarUrl,
      estimatedPrice: parsed.estimatedPrice > 0
          ? parsed.estimatedPrice
          : submitted.estimatedPrice,
      driverName: parsed.driverName.isNotEmpty
          ? parsed.driverName
          : submitted.driverName,
      status: parsed.status,
      interestRequestCount: parsed.interestRequestCount,
    );
  }

  static bool _hasSchedule(DateTime value) =>
      value.isAfter(_unsetSchedule.add(const Duration(days: 1)));

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

  /// Raw vehicle type name straight from the API, already localized per
  /// `Accept-Language` (e.g. "ટ્રક" for gu, "ट्रक" for hi). Kept separate from
  /// [_parseVehicleType] because that only recognizes English slugs/keywords
  /// and silently defaults when the API returns a translated name instead.
  static String? _parseVehicleTypeName(Map<String, dynamic> json) {
    final nested = json['vehicle_type'];
    if (nested is Map<String, dynamic>) {
      final name = nested['name'] as String?;
      if (name != null && name.trim().isNotEmpty) return name.trim();
    } else if (nested is String && nested.trim().isNotEmpty) {
      return nested.trim();
    }

    final vehicle = json['vehicle'];
    if (vehicle is Map<String, dynamic>) {
      final vehicleType = vehicle['vehicle_type'];
      if (vehicleType is String && vehicleType.trim().isNotEmpty) {
        return vehicleType.trim();
      }
      if (vehicleType is Map<String, dynamic>) {
        final name = vehicleType['name'] as String?;
        if (name != null && name.trim().isNotEmpty) return name.trim();
      }
    }
    return null;
  }

  /// Supports numeric capacity, separate `capacity_unit`, and combined strings
  /// like `"200 KG"` returned by trip detail/list APIs.
  static ({double raw, String unit, double tons}) _parseCapacityFields(
    Map<String, dynamic> json,
  ) {
    final unitField = _normalizeCapacityUnit(
      json['capacity_unit'] as String? ?? json['weight_unit'] as String?,
    );
    final raw = json['load_capacity'] ??
        json['capacity'] ??
        json['load_capacity_tons'] ??
        json['capacity_tons'];

    if (raw is num) {
      final value = raw.toDouble();
      final unit = unitField;
      final tons = unit == 'KG' ? value / 1000 : value;
      return (raw: value, unit: unit, tons: tons);
    }

    if (raw is String && raw.trim().isNotEmpty) {
      final trimmed = raw.trim();
      final pure = double.tryParse(trimmed);
      if (pure != null) {
        final unit = unitField;
        final tons = unit == 'KG' ? pure / 1000 : pure;
        return (raw: pure, unit: unit, tons: tons);
      }

      final match = RegExp(
        r'^([\d.]+)\s*(.+)?$',
        caseSensitive: false,
      ).firstMatch(trimmed);
      if (match != null) {
        final value = double.tryParse(match.group(1)!) ?? 0;
        final embeddedUnit = match.group(2)?.trim() ?? '';
        final unit = embeddedUnit.isEmpty
            ? unitField
            : _normalizeCapacityUnit(embeddedUnit);
        final tons = unit == 'KG' ? value / 1000 : value;
        return (raw: value, unit: unit, tons: tons);
      }
    }

    return (raw: 0, unit: 'TON', tons: 0);
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

  static Map<String, dynamic> _resolveTripSource(Map<String, dynamic> json) {
    final nested = json['trip'];
    if (nested is! Map) return json;

    final tripMap = Map<String, dynamic>.from(nested);
    final merged = Map<String, dynamic>.from(tripMap);
    for (final entry in json.entries) {
      if (entry.key == 'trip') continue;
      if (!_hasPayloadValue(merged[entry.key])) {
        merged[entry.key] = entry.value;
      }
    }
    return merged;
  }

  static bool _hasPayloadValue(dynamic value) {
    if (value == null) return false;
    if (value is String) return value.isNotEmpty;
    if (value is List) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    return true;
  }

  static String _parseDriverName(
    Map<String, dynamic> source,
    Map<String, dynamic> root,
  ) {
    for (final map in [source, root]) {
      final name = _firstString(map, ['driver_name', 'driver', 'user']);
      if (name.isNotEmpty) return name;
    }
    return '';
  }

  static String _parseDriverPhone(
    Map<String, dynamic> source,
    Map<String, dynamic> root,
  ) {
    for (final map in [source, root]) {
      final direct = _firstString(map, ['driver_phone', 'phone']);
      if (direct.isNotEmpty) return direct;
      for (final key in ['driver', 'user']) {
        final nested = map[key];
        if (nested is Map) {
          final phone = _firstString(
            Map<String, dynamic>.from(nested),
            ['phone', 'mobile', 'driver_phone', 'contact_number'],
          );
          if (phone.isNotEmpty) return phone;
        }
      }
    }
    return '';
  }

  static String _parseDriverAvatar(
    Map<String, dynamic> source,
    Map<String, dynamic> root,
  ) {
    for (final map in [source, root]) {
      final direct = _firstString(map, [
        'driver_avatar',
        'avatar',
        'profile_image_url',
      ]);
      if (direct.isNotEmpty) return direct;
      for (final key in ['driver', 'user']) {
        final nested = map[key];
        if (nested is Map) {
          final avatar = _firstString(
            Map<String, dynamic>.from(nested),
            ['avatar', 'photo', 'image', 'profile_image_url'],
          );
          if (avatar.isNotEmpty) return avatar;
        }
      }
    }
    return '';
  }

  static String _parseVehicleNumber(Map<String, dynamic> source) {
    final direct = _firstString(source, [
      'vehicle_number',
      'vehicle_no',
      'registration_number',
    ]);
    if (direct.isNotEmpty) return direct;

    final vehicle = source['vehicle'];
    if (vehicle is Map) {
      return _firstString(
        Map<String, dynamic>.from(vehicle),
        [
          'vehicle_number',
          'registration_number',
          'number',
          'plate_number',
        ],
      );
    }
    return '';
  }

  static String _firstString(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.isNotEmpty) return value;
      if (value is Map) {
        final map = Map<String, dynamic>.from(value);
        for (final nestedKey in [
          'name',
          'full_name',
          'driver_name',
          'label',
        ]) {
          final nested = map[nestedKey];
          if (nested is String && nested.isNotEmpty) return nested;
        }
      }
    }
    return '';
  }
}
