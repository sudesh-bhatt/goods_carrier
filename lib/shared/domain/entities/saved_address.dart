import '../enums/saved_address_label.dart';

/// Customer saved address with map coordinates.
class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.label,
    required this.title,
    required this.fullAddressLine,
    required this.city,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    this.landmark,
  });

  final String id;
  final SavedAddressLabel label;
  final String title;
  final String fullAddressLine;
  final String city;
  final String pincode;
  final double latitude;
  final double longitude;
  final String? landmark;

  /// Display line — Figma: street + pincode (e.g. "…Gurgaon, 122003.").
  String get formattedAddress {
    final line = fullAddressLine.trim();
    final zip = pincode.trim();
    if (line.isEmpty) return zip;
    if (zip.isEmpty) return line.endsWith('.') ? line : '$line.';
    if (line.endsWith(zip) || line.endsWith('$zip.')) {
      return line.endsWith('.') ? line : '$line.';
    }
    return '$line, $zip.';
  }

  SavedAddress copyWith({
    String? id,
    SavedAddressLabel? label,
    String? title,
    String? fullAddressLine,
    String? city,
    String? pincode,
    double? latitude,
    double? longitude,
    String? landmark,
    bool clearLandmark = false,
  }) {
    return SavedAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      title: title ?? this.title,
      fullAddressLine: fullAddressLine ?? this.fullAddressLine,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      landmark: clearLandmark ? null : (landmark ?? this.landmark),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label.storageKey,
        'title': title,
        'full_address_line': fullAddressLine,
        'city': city,
        'pincode': pincode,
        'latitude': latitude,
        'longitude': longitude,
        if (landmark != null && landmark!.isNotEmpty) 'landmark': landmark,
      };

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    return SavedAddress(
      id: json['id'] as String,
      label: SavedAddressLabel.fromKey(json['label'] as String?),
      title: json['title'] as String? ?? '',
      fullAddressLine: json['full_address_line'] as String? ?? '',
      city: json['city'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      landmark: json['landmark'] as String?,
    );
  }

  static List<SavedAddress> seedDefaults() => [
        SavedAddress(
          id: 'addr_home',
          label: SavedAddressLabel.home,
          title: 'Home',
          fullAddressLine:
              '123 Skyview Apartments, Sector 45, Gurgaon',
          city: 'Gurgaon',
          pincode: '122003',
          latitude: 28.4595,
          longitude: 77.0266,
        ),
        SavedAddress(
          id: 'addr_office',
          label: SavedAddressLabel.office,
          title: 'Office',
          fullAddressLine:
              'Tech Hub Towers, Plot 14, Phase 3, Hitech City',
          city: 'Hyderabad',
          pincode: '500081',
          latitude: 17.4435,
          longitude: 78.3772,
        ),
        SavedAddress(
          id: 'addr_warehouse',
          label: SavedAddressLabel.other,
          title: 'Warehouse',
          fullAddressLine:
              'Precision Logistics Park, Gate 4, NH-8, Bhiwandi',
          city: 'Bhiwandi',
          pincode: '421302',
          latitude: 19.2813,
          longitude: 73.0483,
        ),
      ];
}
