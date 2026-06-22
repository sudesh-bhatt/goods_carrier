import '../enums/saved_address_label.dart';
import 'saved_address.dart';

/// Customer saved address from `/api/customer/addresses`.
class CustomerSavedAddress {
  const CustomerSavedAddress({
    required this.id,
    required this.label,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });

  final int id;
  final String label;
  final String addressLine;
  final String city;
  final String state;
  final String pincode;
  final String latitude;
  final String longitude;
  final bool isDefault;

  double get latitudeValue => double.tryParse(latitude) ?? 0;
  double get longitudeValue => double.tryParse(longitude) ?? 0;

  String get formattedAddress {
    final parts = <String>[
      if (addressLine.trim().isNotEmpty) addressLine.trim(),
      if (city.trim().isNotEmpty) city.trim(),
      if (state.trim().isNotEmpty) state.trim(),
      if (pincode.trim().isNotEmpty) pincode.trim(),
    ];
    return parts.join(', ');
  }

  SavedAddressLabel get labelEnum {
    final normalized = label.trim().toLowerCase();
    if (normalized == 'home') return SavedAddressLabel.home;
    if (normalized == 'office' || normalized == 'work') {
      return SavedAddressLabel.office;
    }
    return SavedAddressLabel.other;
  }

  SavedAddress toDisplayAddress() => SavedAddress(
        id: id.toString(),
        label: labelEnum,
        title: label.trim().isNotEmpty ? label : labelEnum.name,
        fullAddressLine: addressLine,
        city: city,
        pincode: pincode,
        latitude: latitudeValue,
        longitude: longitudeValue,
      );

  CustomerSavedAddress copyWith({
    int? id,
    String? label,
    String? addressLine,
    String? city,
    String? state,
    String? pincode,
    String? latitude,
    String? longitude,
    bool? isDefault,
  }) =>
      CustomerSavedAddress(
        id: id ?? this.id,
        label: label ?? this.label,
        addressLine: addressLine ?? this.addressLine,
        city: city ?? this.city,
        state: state ?? this.state,
        pincode: pincode ?? this.pincode,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        isDefault: isDefault ?? this.isDefault,
      );

  static List<CustomerSavedAddress> seedDefaults() => const [
        CustomerSavedAddress(
          id: 1,
          label: 'Home',
          addressLine: '123 Skyview Apartments, Sector 45',
          city: 'Gurgaon',
          state: 'Haryana',
          pincode: '122003',
          latitude: '28.4595',
          longitude: '77.0266',
          isDefault: true,
        ),
        CustomerSavedAddress(
          id: 2,
          label: 'Office',
          addressLine: 'Tech Hub Towers, Plot 14, Phase 3, Hitech City',
          city: 'Hyderabad',
          state: 'Telangana',
          pincode: '500081',
          latitude: '17.4435',
          longitude: '78.3772',
        ),
      ];
}
