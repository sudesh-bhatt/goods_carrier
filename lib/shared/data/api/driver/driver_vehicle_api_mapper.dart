import '../../../domain/entities/driver_vehicle.dart';
import '../../../domain/enums/driver_vehicle_status.dart';
import '../../../domain/enums/vehicle_type.dart';
import '../../../domain/models/driver_vehicle_detail.dart';
import '../../../domain/models/driver_vehicle_list_result.dart';
import '../../../domain/models/driver_vehicle_masters.dart';

abstract final class DriverVehicleApiMapper {
  static DriverVehicleListResult listResultFromJson(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      return const DriverVehicleListResult(vehicles: []);
    }

    final summary = _parseSummary(raw);
    final vehicles = _parseVehicleList(raw);
    return DriverVehicleListResult(vehicles: vehicles, summary: summary);
  }

  static DriverVehicleMasters mastersFromJson(Map<String, dynamic> data) {
    final typesRaw = data['vehicle_types'] ?? data['types'] ?? data['vehicle_type'];
    final unitsRaw = data['capacity_units'] ?? data['units'];

    final types = <DriverVehicleTypeOption>[];
    if (typesRaw is List) {
      for (final item in typesRaw) {
        if (item is Map<String, dynamic>) {
          final id = _readInt(item['id']);
          final name = _firstString(item, ['name', 'label', 'title']);
          if (id != null && id > 0 && name.isNotEmpty) {
            types.add(
              DriverVehicleTypeOption(
                id: id,
                name: name,
                slug: _firstString(item, ['slug', 'code']),
                capacityRange: _firstString(item, [
                  'capacity_range',
                  'capacity',
                  'capacity_label',
                ]),
                iconUrl: _firstString(item, ['icon_url', 'icon']),
                imageUrl: _firstString(item, ['image_url', 'image']),
              ),
            );
          }
        }
      }
    }

    final units = <String>[];
    if (unitsRaw is List) {
      for (final item in unitsRaw) {
        if (item is String && item.trim().isNotEmpty) {
          units.add(item.trim().toUpperCase());
        } else if (item is Map<String, dynamic>) {
          final value = _firstString(item, ['code', 'value', 'name']);
          if (value.isNotEmpty) units.add(value.toUpperCase());
        }
      }
    }

    return DriverVehicleMasters(
      vehicleTypes: types,
      capacityUnits: units.isEmpty ? const ['TON'] : units,
    );
  }

  static DriverVehicleDetail detailFromJson(Map<String, dynamic> json) {
    final type = _parseVehicleType(json);
    final capacityFields = _parseCapacityFields(json);
    return DriverVehicleDetail(
      id: _readInt(json['id']) ?? 0,
      registrationNumber: _firstString(json, [
        'registration_number',
        'vehicle_number',
        'vehicle_no',
      ]),
      vehicleTypeId: type.id ?? 0,
      vehicleTypeName: type.name,
      vehicleTypeSlug: type.slug,
      capacity: capacityFields.value ?? 0,
      capacityUnit: capacityFields.unit,
      status: DriverVehicleStatus.fromApi(
        _firstString(json, ['status', 'vehicle_status']),
      ),
      driverName: _firstString(json, ['driver_name', 'name']),
      driverCountryCode: _firstString(json, ['driver_country_code']).isEmpty
          ? '+91'
          : _firstString(json, ['driver_country_code']),
      driverPhone: _firstString(json, ['driver_phone', 'phone']),
      driverSubtitle: _firstString(json, [
        'driver_subtitle',
        'driver_role',
        'designation',
      ]),
      profilePhotoUrl: _documentUrl(json, [
        'profile_photo',
        'profile_photo_url',
        'driver_photo',
      ]),
      licenseFrontUrl: _documentUrl(json, [
        'license_front',
        'license_front_url',
        'driving_license_front',
      ]),
      licenseBackUrl: _documentUrl(json, [
        'license_back',
        'license_back_url',
        'driving_license_back',
      ]),
      vehiclePhotoUrl: _documentUrl(json, [
        'vehicle_photo',
        'vehicle_photo_url',
        'photo',
        'image',
      ]),
      fleetCode: _firstString(json, ['fleet_code', 'code', 'vehicle_code']),
      capacityLabelOverride: _firstString(json, [
        'capacity_label',
        'capacity_display',
      ]),
    );
  }

  static DriverVehicle fromJson(Map<String, dynamic> json) {
    final type = _parseVehicleType(json);
    final capacityFields = _parseCapacityFields(json);
    return DriverVehicle(
      id: _readInt(json['id']) ?? 0,
      vehicleNumber: _firstString(json, [
        'registration_number',
        'vehicle_number',
        'vehicle_no',
      ]),
      vehicleType: VehicleType.fromApi(type.slug.isEmpty ? type.name : type.slug),
      vehicleTypeId: type.id,
      vehicleTypeName: type.name,
      vehicleTypeSlug: type.slug,
      capacity: capacityFields.value,
      capacityUnit: capacityFields.unit,
      status: DriverVehicleStatus.fromApi(
        _firstString(json, ['status', 'vehicle_status']),
      ),
    );
  }

  static DriverVehicleFleetSummary _parseSummary(Map<String, dynamic> raw) {
    final summary = raw['summary'] ?? raw['fleet_summary'] ?? raw['overview'];
    if (summary is Map<String, dynamic>) {
      return DriverVehicleFleetSummary(
        totalActive: _readInt(summary['total_active']) ?? 0,
        inTransit: _readInt(summary['in_transit']) ?? 0,
      );
    }

    return DriverVehicleFleetSummary(
      totalActive: _readInt(raw['total_active']) ?? 0,
      inTransit: _readInt(raw['in_transit']) ?? 0,
    );
  }

  static List<DriverVehicle> _parseVehicleList(Map<String, dynamic> raw) {
    final nested = raw['vehicles'] ?? raw['items'] ?? raw['data'];
    if (nested is List) {
      return nested
          .whereType<Map<String, dynamic>>()
          .map(fromJson)
          .where((v) => v.id > 0)
          .toList(growable: false);
    }
    if (raw.containsKey('id')) {
      final one = fromJson(raw);
      return one.id > 0 ? [one] : const [];
    }
    return const [];
  }

  static _TypeParts _parseVehicleType(Map<String, dynamic> json) {
    final nestedType = json['vehicle_type'];
    if (nestedType is Map<String, dynamic>) {
      return _TypeParts(
        id: _readInt(nestedType['id']),
        name: _firstString(nestedType, ['name', 'label', 'title']),
        slug: _firstString(nestedType, ['slug', 'code']),
      );
    }

    final typeId = _readInt(json['vehicle_type_id']);
    var typeName = _firstString(json, ['vehicle_type_name', 'type_name']);
    var typeSlug = nestedType is String
        ? nestedType
        : _firstString(json, ['vehicle_type_slug', 'type_slug']);

    if (typeName.isEmpty && typeSlug.isNotEmpty) {
      typeName = typeSlug;
    }

    return _TypeParts(id: typeId, name: typeName, slug: typeSlug);
  }

  /// Reads a document URL from the root payload or nested `documents` object.
  static String _documentUrl(Map<String, dynamic> json, List<String> keys) {
    final direct = _firstString(json, keys);
    if (direct.isNotEmpty) return direct;

    final docs = json['documents'];
    if (docs is Map<String, dynamic>) {
      return _firstString(docs, keys);
    }
    return '';
  }

  static int? _readInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString());
  }

  /// Supports numeric capacity, separate `capacity_unit`, and combined strings
  /// like `"500 KG"` returned by the list API.
  static ({double? value, String unit}) _parseCapacityFields(
    Map<String, dynamic> json,
  ) {
    final unitField = _normalizeCapacityUnit(
      _firstString(json, ['capacity_unit', 'unit']),
    );
    final raw = json['capacity'];

    if (raw is num) {
      return (value: raw.toDouble(), unit: unitField);
    }

    if (raw is String && raw.trim().isNotEmpty) {
      final trimmed = raw.trim();
      final pure = double.tryParse(trimmed);
      if (pure != null) {
        return (value: pure, unit: unitField);
      }

      final match = RegExp(
        r'^([\d.]+)\s*(.+)?$',
        caseSensitive: false,
      ).firstMatch(trimmed);
      if (match != null) {
        final value = double.tryParse(match.group(1)!);
        final embeddedUnit = match.group(2)?.trim() ?? '';
        final unit = embeddedUnit.isEmpty
            ? unitField
            : _normalizeCapacityUnit(embeddedUnit);
        return (value: value, unit: unit);
      }
    }

    return (value: null, unit: unitField);
  }

  static String _normalizeCapacityUnit(String raw) {
    final unit = raw.trim().toUpperCase();
    if (unit.isEmpty) return 'TON';
    if (unit.startsWith('KG')) return 'KG';
    if (unit.startsWith('TON')) return 'TON';
    return unit;
  }

  static String _firstString(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return '';
  }
}

class _TypeParts {
  const _TypeParts({this.id, this.name = '', this.slug = ''});

  final int? id;
  final String name;
  final String slug;
}
