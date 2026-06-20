import '../../../domain/entities/shipment.dart';
import '../../../domain/enums/shipment_status.dart';
import '../../../domain/enums/vehicle_type.dart';
import '../../../domain/models/customer_shipment_detail.dart';
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
    return CustomerShipmentDetail(
      shipment: shipment,
      paymentSummary: _parsePaymentSummary(json, shipment.estimatedPrice),
      interestedDrivers: _parseInterestedDriverDetails(json, shipment),
    );
  }

  static ShipmentFormPrefill parseFormPrefill(
    Map<String, dynamic> json, {
    String fallbackCustomerId = '',
  }) {
    final nested = json['shipment'];
    final source = nested is Map<String, dynamic> ? nested : json;

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
      apiId: shipmentCode != null && rawNumericId != null
          ? _stringId(rawNumericId)
          : null,
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
      interestCount: _readInt(source['interest_count']) ?? 0,
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

  static ShipmentLocation _parsePickupLocation(Map<String, dynamic> source) =>
      _parseEndpointLocation(
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
        weightKg: _weightToKg(
          _parseDouble(nested['estimated_weight'] ?? nested['weight_kg']),
          nested['weight_unit'] as String?,
        ),
        isFragile: nested['is_fragile'] as bool? ?? false,
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
    final rawList = source['interested_drivers'] ??
        source['driver_requests'] ??
        source['shipment_requests'];
    if (rawList is! List || rawList.isEmpty) return const [];

    final defaultCapacity = shipment.loadCapacityLabel.toUpperCase();
    final defaultVehicle = shipment.vehicleType.label;

    return rawList.whereType<Map<String, dynamic>>().map((item) {
      final nestedDriver = item['driver'];
      final driverMap =
          nestedDriver is Map<String, dynamic> ? nestedDriver : item;

      final name = _firstString(driverMap, [
        'name',
        'driver_name',
        'full_name',
      ]);
      final vehicleName = _firstString(item, [
        'vehicle_type',
        'vehicle_name',
        'vehicle',
      ]);
      final vehicleNumber = _firstString(item, [
        'vehicle_number',
        'vehicle_no',
        'registration_number',
      ]);
      final capacity = _firstString(item, [
        'capacity',
        'load_capacity',
        'estimated_weight',
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
      );
    }).where((d) => d.driverId.isNotEmpty).toList(growable: false);
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
