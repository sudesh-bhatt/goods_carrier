import '../enums/vehicle_type.dart';

class ShipmentMasterOption {
  const ShipmentMasterOption({
    required this.id,
    required this.name,
    this.slug,
    this.capacityRange,
    this.iconUrl,
    this.imageUrl,
  });

  final int id;
  final String name;
  final String? slug;
  final String? capacityRange;
  final String? iconUrl;
  final String? imageUrl;

  factory ShipmentMasterOption.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    return ShipmentMasterOption(
      id: rawId is int ? rawId : int.parse(rawId.toString()),
      name: json['name'] as String? ??
          json['label'] as String? ??
          json['title'] as String? ??
          '',
      slug: json['slug'] as String? ??
          json['code'] as String? ??
          json['value'] as String?,
      capacityRange: _optionalString(json, const [
        'capacity_range',
        'capacity',
        'capacity_label',
      ]),
      iconUrl: _optionalString(json, const [
        'icon_url',
        'icon',
      ]),
      imageUrl: _optionalString(json, const [
        'image_url',
        'image',
      ]),
    );
  }

  static String? _optionalString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  /// Whether this type appears on customer home vehicle chips.
  /// All API vehicle types are shown — no client-side type exclusions.
  bool get showsOnCustomerHomeChips => true;
}

List<ShipmentMasterOption> homeDashboardVehicleTypes(
  Iterable<ShipmentMasterOption> types,
) =>
    types.toList(growable: false);

/// Previous hardcoded filter pills — used when masters API fails / is empty.
const fallbackFilterVehicleTypes = <ShipmentMasterOption>[
  ShipmentMasterOption(id: 1, name: 'Mini', slug: 'mini'),
  ShipmentMasterOption(id: 2, name: 'Pickup', slug: 'pickup'),
  ShipmentMasterOption(id: 3, name: 'Truck', slug: 'truck'),
];

List<ShipmentMasterOption> resolveFilterVehicleTypes(
  Iterable<ShipmentMasterOption>? types,
) {
  final list = types?.toList(growable: false) ?? const [];
  return list.isNotEmpty ? list : fallbackFilterVehicleTypes;
}

/// Fills missing [ShipmentMasterOption.iconUrl] / media from [masters] by id/slug.
List<ShipmentMasterOption> enrichVehicleTypeMedia(
  List<ShipmentMasterOption> types,
  Iterable<ShipmentMasterOption> masters,
) {
  if (types.isEmpty || masters.isEmpty) return types;
  return types.map((type) {
    final hasIcon = type.iconUrl != null && type.iconUrl!.trim().isNotEmpty;
    final hasImage = type.imageUrl != null && type.imageUrl!.trim().isNotEmpty;
    final hasCapacity =
        type.capacityRange != null && type.capacityRange!.trim().isNotEmpty;
    if (hasIcon && hasImage && hasCapacity) return type;

    ShipmentMasterOption? match;
    for (final master in masters) {
      if (master.id == type.id) {
        match = master;
        break;
      }
      final typeSlug = (type.slug ?? '').toLowerCase();
      final masterSlug = (master.slug ?? '').toLowerCase();
      if (typeSlug.isNotEmpty && typeSlug == masterSlug) {
        match = master;
        break;
      }
    }
    if (match == null) return type;

    return ShipmentMasterOption(
      id: type.id,
      name: type.name,
      slug: type.slug ?? match.slug,
      capacityRange: hasCapacity ? type.capacityRange : match.capacityRange,
      iconUrl: hasIcon ? type.iconUrl : match.iconUrl,
      imageUrl: hasImage ? type.imageUrl : match.imageUrl,
    );
  }).toList(growable: false);
}

/// Maps a home-chip master option to [VehicleType] for filter-sheet sync.
VehicleType? vehicleTypeFromMasterOption(ShipmentMasterOption option) {
  final key = (option.slug ?? option.name).trim();
  if (key.isEmpty) return null;
  final normalized =
      key.toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
  for (final type in VehicleType.values) {
    if (type.apiValue == normalized || type.name == normalized) {
      return type;
    }
  }
  if (normalized.contains('pickup')) return VehicleType.pickupTruck;
  if (normalized.contains('mini')) return VehicleType.mini;
  if (normalized.contains('heavy')) return VehicleType.heavyDuty;
  if (normalized.contains('truck')) return VehicleType.truck;
  return null;
}

int? homeDashboardVehicleTypeIdFor(
  Iterable<ShipmentMasterOption> types,
  VehicleType type,
) {
  for (final item in types) {
    if (vehicleTypeFromMasterOption(item) == type) return item.id;
  }
  return null;
}

VehicleType? homeDashboardVehicleClassForId(
  Iterable<ShipmentMasterOption> types,
  int? id,
) {
  if (id == null) return null;
  for (final item in types) {
    if (item.id == id) return vehicleTypeFromMasterOption(item);
  }
  return null;
}

class WeightUnitOption {
  const WeightUnitOption({required this.value, required this.label});

  final String value;
  final String label;

  factory WeightUnitOption.fromJson(Map<String, dynamic> json) {
    final rawValue =
        json['value'] as String? ?? json['code'] as String? ?? 'KG';
    final label =
        json['label'] as String? ?? json['name'] as String? ?? rawValue;
    return WeightUnitOption(
      value: _apiWeightUnitValue(rawValue),
      label: label,
    );
  }

  factory WeightUnitOption.fromString(String raw) {
    return WeightUnitOption(
      value: _apiWeightUnitValue(raw),
      label: raw.toLowerCase() == 'ton' ? 'Ton' : 'KG',
    );
  }

  static String _apiWeightUnitValue(String raw) {
    return raw.toLowerCase() == 'ton' ? 'TON' : 'KG';
  }
}

/// Dropdown data from `GET /api/customer/shipment-masters`.
class ShipmentMasters {
  const ShipmentMasters({
    required this.goodsTypes,
    required this.vehicleTypes,
    this.weightUnits = const [
      WeightUnitOption(value: 'KG', label: 'KG'),
      WeightUnitOption(value: 'TON', label: 'Ton'),
    ],
  });

  final List<ShipmentMasterOption> goodsTypes;
  final List<ShipmentMasterOption> vehicleTypes;
  final List<WeightUnitOption> weightUnits;

  List<String> get goodsTypeNames =>
      goodsTypes.map((g) => g.name).where((n) => n.isNotEmpty).toList();

  List<ShipmentMasterOption> get vehicleOptions => vehicleTypes;

  int? goodsTypeIdForName(String name) {
    final normalized = name.trim().toLowerCase();
    for (final item in goodsTypes) {
      if (item.name.toLowerCase() == normalized) return item.id;
    }
    return null;
  }

  int? vehicleTypeIdFor(VehicleType type) {
    final slug = type.apiValue;
    for (final item in vehicleTypes) {
      if (item.slug?.toLowerCase() == slug) return item.id;
      if (item.name.toLowerCase().contains(type.label.toLowerCase())) {
        return item.id;
      }
    }
    return null;
  }

  int? vehicleTypeIdForMasterName(String name) {
    final normalized = name.trim().toLowerCase();
    for (final item in vehicleTypes) {
      if (item.name.toLowerCase() == normalized) return item.id;
    }
    return null;
  }

  String uiWeightUnitForApi(String apiUnit) {
    final normalized = apiUnit.toLowerCase();
    for (final unit in weightUnits) {
      if (unit.value.toLowerCase() == normalized) return unit.label;
    }
    return normalized == 'ton' ? 'TON' : 'KG';
  }

  String apiWeightUnitForUi(String uiUnit) {
    final normalized = uiUnit.toLowerCase();
    for (final unit in weightUnits) {
      if (unit.label.toLowerCase() == normalized ||
          unit.value.toLowerCase() == normalized) {
        return unit.value;
      }
    }
    return normalized == 'ton' ? 'TON' : 'KG';
  }

  factory ShipmentMasters.fromJson(Map<String, dynamic> json) {
    final nested = json['masters'];
    final source = nested is Map<String, dynamic> ? nested : json;

    return ShipmentMasters(
      goodsTypes: _parseOptions(
        source['goods_types'] ?? source['goods_type'] ?? source['goodsTypes'],
      ),
      vehicleTypes: _parseOptions(
        source['vehicle_types'] ??
            source['vehicle_type'] ??
            source['vehicleTypes'],
      ),
      weightUnits: _parseWeightUnits(source['weight_units']),
    );
  }

  static List<ShipmentMasterOption> _parseOptions(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ShipmentMasterOption.fromJson)
        .toList();
  }

  static List<WeightUnitOption> _parseWeightUnits(dynamic raw) {
    if (raw is List && raw.isNotEmpty) {
      if (raw.first is Map<String, dynamic>) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map(WeightUnitOption.fromJson)
            .toList();
      }
      return raw
          .map((e) => WeightUnitOption.fromString(e.toString()))
          .toList();
    }
    return const [
      WeightUnitOption(value: 'KG', label: 'KG'),
      WeightUnitOption(value: 'TON', label: 'Ton'),
    ];
  }
}
