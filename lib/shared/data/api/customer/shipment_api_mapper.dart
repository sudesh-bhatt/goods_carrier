import '../../../domain/entities/shipment.dart';
import '../../../domain/enums/shipment_status.dart';
import '../../../domain/enums/vehicle_type.dart';
import '../../../domain/models/customer_shipment_detail.dart';
import '../../../domain/models/driver_shipment_detail.dart';
import '../../../domain/models/shipment_form_prefill.dart';
import '../../../domain/models/shipment_submit_options.dart';

/// Maps [Shipment] entities to/from Goods Carrier customer shipment APIs.
///
/// Request/response field names match Postman **Customer → Shipments** +
/// validation errors from `POST /api/customer/shipments`.
abstract final class ShipmentApiMapper {
  // ── Request ──────────────────────────────────────────────────────────────

  static Map<String, dynamic> toRequestBody(
    Shipment shipment, {
    required ShipmentSubmitOptions options,
    bool forUpdate = false,
  }) {
    final pickup = shipment.pickupDateTime;
    final pickupDate =
        '${pickup.year.toString().padLeft(4, '0')}-'
        '${pickup.month.toString().padLeft(2, '0')}-'
        '${pickup.day.toString().padLeft(2, '0')}';
    final pickupTime = forUpdate
        ? '${pickup.hour.toString().padLeft(2, '0')}:'
            '${pickup.minute.toString().padLeft(2, '0')}'
        : '${pickup.hour.toString().padLeft(2, '0')}:'
            '${pickup.minute.toString().padLeft(2, '0')}:00';

    final body = <String, dynamic>{
      'from_address': shipment.pickup.fullAddress,
      if (shipment.pickup.city.isNotEmpty) 'from_city': shipment.pickup.city,
      if (!forUpdate && shipment.pickup.lat != 0)
        'from_latitude': shipment.pickup.lat,
      if (!forUpdate && shipment.pickup.lng != 0)
        'from_longitude': shipment.pickup.lng,
      'to_address': shipment.drop.fullAddress,
      if (shipment.drop.city.isNotEmpty) 'to_city': shipment.drop.city,
      if (!forUpdate && shipment.drop.lat != 0) 'to_latitude': shipment.drop.lat,
      if (!forUpdate && shipment.drop.lng != 0) 'to_longitude': shipment.drop.lng,
      'pickup_date': pickupDate,
      'pickup_time': pickupTime,
      'goods_type_id': options.goodsTypeId,
      'vehicle_type_id': options.vehicleTypeId,
      'estimated_weight': options.estimatedWeight,
      'weight_unit': _requestWeightUnit(options.weightUnit),
      'budget': shipment.estimatedPrice,
      'terms_accepted': options.termsAccepted,
    };

    final comments = shipment.goods.specialInstructions?.trim();
    if (comments != null && comments.isNotEmpty) {
      body['additional_comments'] = comments;
    } else if (!forUpdate && shipment.goods.isFragile) {
      body['is_fragile'] = true;
    }

    return body;
  }

  static String _requestWeightUnit(String unit) {
    final normalized = unit.trim().toLowerCase();
    if (normalized == 'ton') return 'TON';
    return 'KG';
  }

  static Map<String, dynamic> toCancelBody({
    required String reason,
    String? otherReason,
  }) {
    return {
      'reason': reason,
      'other_reason': otherReason,
    };
  }

  // ── Response ─────────────────────────────────────────────────────────────

  static Shipment fromJson(
    Map<String, dynamic> json, {
    String fallbackCustomerId = '',
  }) =>
      parseFormPrefill(json, fallbackCustomerId: fallbackCustomerId).shipment;

  static CustomerShipmentDetail parseDetail(
    Map<String, dynamic> json, {
    String fallbackCustomerId = '',
  }) {
    final shipment = fromJson(json, fallbackCustomerId: fallbackCustomerId);
    final interested = _parseInterestedDriverDetails(json, shipment);
    return CustomerShipmentDetail(
      shipment: shipment,
      paymentSummary: _parsePaymentSummary(json, shipment.estimatedPrice),
      interestedDrivers: interested,
      assignedDriver: _resolveAssignedDriver(json, shipment, interested),
    );
  }

  /// Parses `POST /api/customer/shipments/{id}/assign` response `data`.
  static ShipmentAssignmentResult parseAssignment(Map<String, dynamic> json) {
    final driver = _parseAssignmentDriver(json);
    final driverId = driver.driverId.isNotEmpty
        ? driver.driverId
        : _stringId(json['driver_id']);
    return ShipmentAssignmentResult(
      shipmentId: _stringId(json['shipment_id'] ?? json['id']),
      driverId: driverId,
      driver: driver,
      status: _firstString(json, ['status']).isNotEmpty
          ? _firstString(json, ['status'])
          : 'accepted',
      offeredPrice: driver.offeredPrice,
    );
  }

  static DriverShipmentDetail parseDriverDetail(
    Map<String, dynamic> json, {
    String fallbackCustomerId = '',
  }) {
    final shipment = fromJson(json, fallbackCustomerId: fallbackCustomerId);

    final vehicleReq = json['vehicle_requirement'];
    String? vehicleCapacityLabel;
    bool? matchesDriverVehicle;
    if (vehicleReq is Map<String, dynamic>) {
      vehicleCapacityLabel = vehicleReq['capacity'] as String?;
      matchesDriverVehicle = vehicleReq['matches_driver_vehicle'] as bool?;
    }

    final driverRequest = json['driver_request'];
    var alreadyRequested = false;
    String? driverRequestStatus;
    if (driverRequest is Map<String, dynamic>) {
      alreadyRequested = driverRequest['already_requested'] as bool? ?? false;
      driverRequestStatus = driverRequest['status'] as String?;
    }

    final pickupLocation = json['pickup_location'];
    String? pickupScheduleLabel;
    if (pickupLocation is Map<String, dynamic>) {
      pickupScheduleLabel = pickupLocation['time_label'] as String?;
    }

    return DriverShipmentDetail(
      shipment: shipment,
      alreadyRequested: alreadyRequested,
      driverRequestStatus: driverRequestStatus,
      matchesDriverVehicle: matchesDriverVehicle,
      vehicleCapacityLabel: vehicleCapacityLabel,
      pickupScheduleLabel: pickupScheduleLabel,
    );
  }

  static ShipmentFormPrefill parseFormPrefill(
    Map<String, dynamic> json, {
    String fallbackCustomerId = '',
  }) {
    final source = _resolveShipmentSource(json);

    final goodsTypeId = _readInt(source['goods_type_id']) ??
        (source['goods_type'] is Map<String, dynamic>
            ? _readInt((source['goods_type'] as Map)['id'])
            : null);
    final vehicleTypeId = _readInt(source['vehicle_type_id']) ??
        (source['vehicle_type'] is Map<String, dynamic>
            ? _readInt((source['vehicle_type'] as Map)['id'])
            : null);
    final estimatedWeight = _parseDouble(
      source['estimated_weight'] ?? source['goods']?['weight_kg'],
    );
    final weightUnit = _normalizeWeightUnit(
      source['weight_unit'] as String? ??
          source['goods']?['weight_unit'] as String?,
    );

    final shipmentCode = source['shipment_id'] as String?;
    final rawNumericId = source['id'];

    final shipment = Shipment(
      id: _stringId(
        shipmentCode ??
            source['tracking_id'] ??
            source['trip_id'] ??
            rawNumericId,
      ),
      apiId: rawNumericId != null ? _stringId(rawNumericId) : null,
      customerId: _stringId(
        source['customer_id'] ?? source['user_id'] ?? fallbackCustomerId,
      ),
      pickup: _parsePickupLocation(source),
      drop: _parseDropLocation(source),
      pickupDateTime: _parsePickupDateTime(source),
      dropDateTime: _parseDateTime(
        source['drop_datetime'] ??
            source['drop_date_time'] ??
            source['drop_at'],
        fallback: _parsePickupDateTime(source).add(const Duration(days: 2)),
      ),
      goods: _parseGoods(source),
      vehicleType: _parseVehicleType(source),
      status: ShipmentStatus.fromApi(source['status'] as String?),
      estimatedPrice: _parsePrice(source),
      assignedDriverId: _parseAssignedDriverId(source),
      interestedDriverIds: _parseInterestedDriverIds(source),
      interestCount: _readInt(
            source['request_count'] ??
                source['interest_count'] ??
                source['interest_request_count'],
          ) ??
          (source['requests'] is List
              ? (source['requests'] as List).length
              : 0),
      allottedStatus: _parseAllottedStatus(source),
    );

    return ShipmentFormPrefill(
      shipment: shipment,
      options: ShipmentSubmitOptions(
        goodsTypeId: goodsTypeId ?? 0,
        vehicleTypeId: vehicleTypeId ?? 0,
        estimatedWeight: estimatedWeight > 0
            ? estimatedWeight
            : shipment.goods.weightKg,
        weightUnit: weightUnit,
        termsAccepted: source['terms_accepted'] as bool? ?? true,
      ),
    );
  }

  static ShipmentLocation _parsePickupLocation(Map<String, dynamic> source) {
    final pickupLocation = source['pickup_location'];
    if (pickupLocation is Map<String, dynamic>) {
      final address = pickupLocation['address'] as String? ??
          pickupLocation['full_address'] as String? ??
          '';
      final city = _firstString(source, ['from_city', 'pickup_city']);
      return ShipmentLocation(
        city: city.isNotEmpty ? city : address,
        fullAddress: address.isNotEmpty
            ? address
            : _firstString(source, ['from_address', 'pickup_address']),
      );
    }

    return _parseEndpointLocation(
      source,
      addressKeys: ['from_address', 'pickup_address'],
      cityKeys: ['from_city', 'pickup_city'],
      latKeys: ['from_latitude', 'from_lat', 'pickup_latitude', 'pickup_lat'],
      lngKeys: [
        'from_longitude',
        'from_lng',
        'pickup_longitude',
        'pickup_lng',
      ],
      nestedKey: 'pickup',
    );
  }

  static ShipmentLocation _parseDropLocation(Map<String, dynamic> source) =>
      _parseEndpointLocation(
        source,
        addressKeys: ['to_address', 'drop_address'],
        cityKeys: ['to_city', 'drop_city'],
        latKeys: ['to_latitude', 'to_lat', 'drop_latitude', 'drop_lat'],
        lngKeys: ['to_longitude', 'to_lng', 'drop_longitude', 'drop_lng'],
        nestedKey: 'drop',
      );

  static ShipmentLocation _parseEndpointLocation(
    Map<String, dynamic> source, {
    required List<String> addressKeys,
    required List<String> cityKeys,
    required List<String> latKeys,
    required List<String> lngKeys,
    required String nestedKey,
  }) {
    final nested = source[nestedKey];
    if (nested is Map<String, dynamic>) {
      return ShipmentLocation(
        city: nested['city'] as String? ?? '',
        fullAddress: nested['full_address'] as String? ??
            nested['address'] as String? ??
            nested['address_text'] as String? ??
            '',
        lat: _parseDouble(nested['lat'] ?? nested['latitude']),
        lng: _parseDouble(nested['lng'] ?? nested['longitude']),
      );
    }

    final city = _firstString(source, cityKeys);
    final fullAddress = _firstString(source, addressKeys);

    return ShipmentLocation(
      city: city.isNotEmpty ? city : fullAddress,
      fullAddress: fullAddress.isNotEmpty ? fullAddress : city,
      lat: _parseDouble(_firstRaw(source, latKeys)),
      lng: _parseDouble(_firstRaw(source, lngKeys)),
    );
  }

  static DateTime _parsePickupDateTime(Map<String, dynamic> source) {
    final combined = source['pickup_datetime'] ??
        source['pickup_date_time'] ??
        source['pickup_at'];
    if (combined is String && combined.isNotEmpty) {
      return DateTime.parse(combined);
    }

    final date = source['pickup_date'] as String?;
    final time = source['pickup_time'] as String?;
    if (date != null && date.isNotEmpty) {
      if (time != null && time.isNotEmpty) {
        final normalizedTime = time.length <= 5 ? '$time:00' : time;
        return DateTime.parse('${date}T$normalizedTime');
      }
      return DateTime.parse(date);
    }

    return DateTime.now();
  }

  static VehicleType _parseVehicleType(Map<String, dynamic> source) {
    final vehicleReq = source['vehicle_requirement'];
    if (vehicleReq is Map<String, dynamic>) {
      return VehicleType.fromApi(vehicleReq['vehicle_type'] as String?);
    }

    final nested = source['vehicle_type'];
    if (nested is Map<String, dynamic>) {
      return VehicleType.fromApi(
        nested['slug'] as String? ??
            nested['code'] as String? ??
            nested['name'] as String?,
      );
    }

    final id = source['vehicle_type_id'];
    if (id != null && nested == null) {
      // ID-only responses fall back until masters map is applied in UI.
      return VehicleType.mini;
    }

    return VehicleType.fromApi(
      source['vehicle_type'] as String? ??
          source['vehicle_category'] as String?,
    );
  }

  static GoodsDetail _parseGoods(Map<String, dynamic> source) {
    final nested = source['goods'];
    if (nested is Map<String, dynamic>) {
      return GoodsDetail(
        type: _goodsTypeLabel(nested),
        weightKg: _parseCapacityKg(nested['weight'] as String?) ??
            _weightToKg(
              _parseDouble(nested['estimated_weight'] ?? nested['weight_kg']),
              nested['weight_unit'] as String?,
            ),
        isFragile: nested['is_fragile'] as bool? ??
            nested['fragile_handling_required'] as bool? ??
            false,
        specialInstructions: nested['additional_comments'] as String? ??
            nested['comments'] as String? ??
            nested['special_instructions'] as String?,
      );
    }

    final nestedGoodsType = source['goods_type'];
    final typeLabel = nestedGoodsType is Map<String, dynamic>
        ? nestedGoodsType['name'] as String? ?? ''
        : source['goods_type'] as String? ?? source['type'] as String? ?? '';

    final capacityKg = _parseCapacityKg(source['capacity'] as String?);
    final estimatedWeightRaw = source['estimated_weight'];
    final estimatedWeight = estimatedWeightRaw is String
        ? (_parseCapacityKg(estimatedWeightRaw) ?? 0)
        : _parseDouble(
            estimatedWeightRaw ?? source['weight_kg'] ?? source['weight'],
          );

    return GoodsDetail(
      type: typeLabel,
      weightKg: capacityKg ??
          (estimatedWeightRaw is String
              ? estimatedWeight
              : _weightToKg(
                  estimatedWeight,
                  source['weight_unit'] as String?,
                )),
      isFragile: source['is_fragile'] as bool? ?? false,
      specialInstructions: source['additional_comments'] as String? ??
          source['comments'] as String? ??
          source['special_instructions'] as String?,
    );
  }

  static String _goodsTypeLabel(Map<String, dynamic> json) {
    final nested = json['goods_type'];
    if (nested is Map<String, dynamic>) {
      return nested['name'] as String? ?? '';
    }
    return json['type'] as String? ?? json['goods_type'] as String? ?? '';
  }

  static double _weightToKg(double value, String? unit) {
    if (unit != null && unit.toLowerCase() == 'ton') return value * 1000;
    return value;
  }

  static double? _parseCapacityKg(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final match = RegExp(r'([\d.]+)').firstMatch(raw);
    if (match == null) return null;
    final value = double.tryParse(match.group(1)!) ?? 0;
    if (value <= 0) return null;
    if (raw.toLowerCase().contains('ton')) return value * 1000;
    return value;
  }

  static String _normalizeWeightUnit(String? raw) {
    if (raw == null || raw.isEmpty) return 'KG';
    return raw.toLowerCase() == 'ton' ? 'TON' : 'KG';
  }

  static int? _readInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString());
  }

  static List<String> _parseInterestedDriverIds(Map<String, dynamic> source) {
    final rawIds = source['interested_driver_ids'];
    if (rawIds is List) {
      return rawIds.map((e) => e.toString()).toList();
    }

    final interestedDrivers = source['interested_drivers'];
    if (interestedDrivers is List) {
      return interestedDrivers
          .map((item) {
            if (item is Map<String, dynamic>) {
              return _stringId(item['driver_id'] ?? item['id']);
            }
            return item.toString();
          })
          .where((id) => id.isNotEmpty)
          .toList();
    }

    for (final key in [
      'driver_requests',
      'requests',
      'interests',
      'shipment_requests',
    ]) {
      final list = source[key];
      if (list is! List) continue;
      return list
          .map((item) {
            if (item is Map<String, dynamic>) {
              return _stringId(item['driver_id'] ?? item['id']);
            }
            return item.toString();
          })
          .where((id) => id.isNotEmpty)
          .toList();
    }

    return const [];
  }

  static List<ShipmentInterestedDriver> _parseInterestedDriverDetails(
    Map<String, dynamic> source,
    Shipment shipment,
  ) {
    final rawList = source['requests'] ??
        source['interested_drivers'] ??
        source['driver_requests'] ??
        source['shipment_requests'];
    if (rawList is! List || rawList.isEmpty) return const [];

    final defaultCapacity = shipment.loadCapacityLabel.toUpperCase();
    final defaultVehicle = shipment.vehicleType.label;

    return rawList.whereType<Map<String, dynamic>>().map((item) {
      final nestedDriver = item['driver'];
      final driverMap =
          nestedDriver is Map<String, dynamic> ? nestedDriver : item;

      final nestedVehicle = item['vehicle'];
      final vehicleMap =
          nestedVehicle is Map<String, dynamic> ? nestedVehicle : null;

      final name = _firstString(driverMap, [
        'name',
        'driver_name',
        'full_name',
      ]);

      var vehicleName = vehicleMap != null
          ? _firstString(vehicleMap, [
              'vehicle_type',
              'vehicle_name',
              'name',
              'type',
            ])
          : '';
      if (vehicleName.isEmpty) {
        final rawVehicleType = item['vehicle_type'];
        if (rawVehicleType is String && rawVehicleType.isNotEmpty) {
          vehicleName = rawVehicleType;
        } else if (rawVehicleType is Map<String, dynamic>) {
          vehicleName = _firstString(rawVehicleType, ['name', 'type', 'slug']);
        }
      }

      var vehicleNumber = vehicleMap != null
          ? _firstString(vehicleMap, [
              'registration_number',
              'vehicle_number',
              'vehicle_no',
            ])
          : '';
      if (vehicleNumber.isEmpty) {
        vehicleNumber = _firstString(item, [
          'vehicle_number',
          'vehicle_no',
          'registration_number',
        ]);
      }

      var capacity = vehicleMap != null
          ? _firstString(vehicleMap, ['capacity', 'load_capacity'])
          : '';
      if (capacity.isEmpty) {
        capacity = _firstString(item, [
          'capacity',
          'load_capacity',
        ]);
      }

      final countryCode = _firstString(driverMap, [
        'country_code',
        'dial_code',
      ]);

      final offeredPrice = _parseDouble(item['offered_price']);
      final note = _firstString(item, [
        'note',
        'message',
        'additional_note',
        'request_note',
      ]);

      return ShipmentInterestedDriver(
        driverId: _stringId(
          item['driver_id'] ??
              driverMap['id'] ??
              driverMap['driver_id'] ??
              item['id'],
        ),
        name: name.isNotEmpty ? name : 'Driver',
        subtitle: _firstString(driverMap, ['title', 'subtitle', 'role']),
        vehicleName:
            vehicleName.isNotEmpty ? vehicleName : defaultVehicle,
        vehicleNumber: vehicleNumber,
        capacityLabel: capacity.isNotEmpty ? capacity : defaultCapacity,
        phone: _firstString(driverMap, [
          'phone',
          'mobile',
          'business_phone',
        ]),
        countryCode: countryCode.isNotEmpty ? countryCode : '+91',
        avatarUrl: _firstString(driverMap, [
          'avatar',
          'profile_image_url',
          'photo',
        ]),
        offeredPrice: offeredPrice > 0 ? offeredPrice : null,
        note: note.isNotEmpty ? note : null,
      );
    }).where((d) => d.driverId.isNotEmpty).toList(growable: false);
  }

  static ShipmentInterestedDriver? _resolveAssignedDriver(
    Map<String, dynamic> source,
    Shipment shipment,
    List<ShipmentInterestedDriver> interested,
  ) {
    final assignedId = shipment.assignedDriverId;
    if (assignedId != null && assignedId.isNotEmpty) {
      final fromList = interested
          .where((d) => d.driverId == assignedId)
          .firstOrNull;
      if (fromList != null) return fromList;
    }

    final accepted = interested.where((d) {
      return assignedId != null && d.driverId == assignedId;
    }).firstOrNull;
    if (accepted != null) return accepted;

    final nested = source['assigned_driver'] ?? source['driver'];
    if (nested is Map<String, dynamic>) {
      return _parseAssignmentDriver({
        'driver': nested,
        'driver_id': nested['id'] ?? nested['driver_id'],
        'vehicle': source['vehicle'] ?? nested['vehicle'],
        'offered_price': source['offered_price'] ?? nested['offered_price'],
        'note': source['note'] ?? nested['note'],
      }, fallbackVehicle: shipment.vehicleType.label);
    }

    // Accepted request in the requests list.
    final rawList = source['requests'] ??
        source['interested_drivers'] ??
        source['driver_requests'];
    if (rawList is List) {
      for (final item in rawList.whereType<Map<String, dynamic>>()) {
        final status = item['status']?.toString().toLowerCase() ?? '';
        if (status == 'accepted' || status == 'assigned') {
          final parsed = _parseInterestedDriverDetails(
            {'requests': [item]},
            shipment,
          );
          if (parsed.isNotEmpty) return parsed.first;
        }
      }
    }

    return null;
  }

  static ShipmentInterestedDriver _parseAssignmentDriver(
    Map<String, dynamic> json, {
    String fallbackVehicle = '',
  }) {
    final nestedDriver = json['driver'];
    final driverMap =
        nestedDriver is Map<String, dynamic> ? nestedDriver : json;

    final nestedVehicle = json['vehicle'];
    final vehicleMap =
        nestedVehicle is Map<String, dynamic> ? nestedVehicle : null;

    final name = _firstString(driverMap, [
      'name',
      'driver_name',
      'full_name',
    ]);

    var vehicleName = vehicleMap != null
        ? _firstString(vehicleMap, [
            'vehicle_type',
            'vehicle_name',
            'name',
            'type',
          ])
        : '';
    if (vehicleName.isEmpty) {
      vehicleName = fallbackVehicle;
    }

    var vehicleNumber = vehicleMap != null
        ? _firstString(vehicleMap, [
            'registration_number',
            'vehicle_number',
            'vehicle_no',
          ])
        : '';
    if (vehicleNumber.isEmpty) {
      vehicleNumber = _firstString(json, [
        'vehicle_number',
        'registration_number',
      ]);
    }

    var capacity = vehicleMap != null
        ? _firstString(vehicleMap, ['capacity', 'load_capacity'])
        : '';
    if (capacity.isEmpty) {
      capacity = _firstString(json, ['capacity', 'load_capacity']);
    }

    final countryCode = _firstString(driverMap, [
      'country_code',
      'dial_code',
    ]);
    final offeredPrice = _parseDouble(json['offered_price']);
    final note = _firstString(json, [
      'note',
      'message',
      'additional_note',
    ]);

    return ShipmentInterestedDriver(
      driverId: _stringId(
        json['driver_id'] ??
            driverMap['id'] ??
            driverMap['driver_id'],
      ),
      name: name.isNotEmpty ? name : 'Driver',
      subtitle: _firstString(driverMap, ['title', 'subtitle', 'role']),
      vehicleName: vehicleName,
      vehicleNumber: vehicleNumber,
      capacityLabel: capacity,
      phone: _firstString(driverMap, [
        'phone',
        'mobile',
        'business_phone',
      ]),
      countryCode: countryCode.isNotEmpty ? countryCode : '+91',
      avatarUrl: _firstString(driverMap, [
        'avatar',
        'profile_image_url',
        'photo',
      ]),
      offeredPrice: offeredPrice > 0 ? offeredPrice : null,
      note: note.isNotEmpty ? note : null,
    );
  }

  static ShipmentPaymentSummary _parsePaymentSummary(
    Map<String, dynamic> source,
    double fallbackAmount,
  ) {
    final payment = source['payment_summary'];
    if (payment is Map<String, dynamic>) {
      final baseFare = _parseDouble(payment['base_fare']);
      final totalAmount = _parseDouble(payment['total_amount']);
      return ShipmentPaymentSummary(
        baseFare: baseFare > 0 ? baseFare : fallbackAmount,
        totalAmount: totalAmount > 0 ? totalAmount : fallbackAmount,
      );
    }
    return ShipmentPaymentSummary(
      baseFare: fallbackAmount,
      totalAmount: fallbackAmount,
    );
  }

  static String? _parseAssignedDriverId(Map<String, dynamic> source) {
    final direct = source['assigned_driver_id'] ?? source['driver_id'];
    if (direct != null) return _stringId(direct);

    final driver = source['assigned_driver'] ?? source['driver'];
    if (driver is Map<String, dynamic>) {
      final id = driver['id'] ?? driver['driver_id'];
      if (id != null) return _stringId(id);
    }
    return null;
  }

  static String? _parseAllottedStatus(Map<String, dynamic> source) {
    final raw = source['allotted_status'] ?? source['allotment_status'];
    if (raw == null) return null;
    final value = raw.toString().trim();
    if (value.isEmpty || value.toLowerCase() == 'null') return null;
    return value;
  }

  static double _parsePrice(Map<String, dynamic> source) {
    final payment = source['payment_summary'];
    if (payment is Map<String, dynamic>) {
      final total = _parseDouble(
        payment['total_amount'] ?? payment['base_fare'],
      );
      if (total > 0) return total;
    }

    return _parseDouble(
      source['budget'] ??
          source['estimated_price'] ??
          source['offered_price'] ??
          source['total_amount'] ??
          0,
    );
  }

  static DateTime _parseDateTime(dynamic raw, {DateTime? fallback}) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.parse(raw);
    }
    return fallback ?? DateTime.now();
  }

  static double _parseDouble(dynamic raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw) ?? 0;
    return 0;
  }

  static String _stringId(dynamic raw) {
    if (raw == null) return '';
    if (raw is int) return raw.toString();
    return raw.toString();
  }

  static Map<String, dynamic> _resolveShipmentSource(Map<String, dynamic> json) {
    final nested = json['shipment'];
    if (nested is! Map) return json;

    final shipmentMap = Map<String, dynamic>.from(nested);
    final merged = Map<String, dynamic>.from(shipmentMap);
    for (final entry in json.entries) {
      if (entry.key == 'shipment') continue;
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

  static String _firstString(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return '';
  }

  static dynamic _firstRaw(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      if (source.containsKey(key)) return source[key];
    }
    return null;
  }
}
