import '../../../domain/entities/driver_saved_address.dart';

abstract final class DriverAddressApiMapper {
  static DriverSavedAddress fromJson(Map<String, dynamic> json) =>
      DriverSavedAddress(
        id: _readInt(json['id']) ?? 0,
        label: _firstString(json, ['label']),
        addressLine: _firstString(json, ['address_line', 'full_address_line']),
        city: _firstString(json, ['city']),
        state: _firstString(json, ['state']),
        pincode: _firstString(json, ['pincode', 'postal_code', 'zip']),
        latitude: _coordString(json['latitude']),
        longitude: _coordString(json['longitude']),
        isDefault: json['is_default'] as bool? ?? false,
      );

  static Map<String, dynamic> toRequestBody({
    required String label,
    required String addressLine,
    required String city,
    required String state,
    required String pincode,
    required double latitude,
    required double longitude,
    bool isDefault = false,
  }) =>
      {
        'label': label,
        'address_line': addressLine,
        'city': city,
        'state': state,
        'pincode': pincode,
        'latitude': latitude.toStringAsFixed(6),
        'longitude': longitude.toStringAsFixed(6),
        'is_default': isDefault,
      };

  static String _coordString(dynamic raw) {
    if (raw == null) return '0';
    if (raw is num) return raw.toString();
    return raw.toString();
  }

  static int? _readInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString());
  }

  static String _firstString(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return '';
  }
}
