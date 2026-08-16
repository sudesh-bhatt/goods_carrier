import '../../../../core/extensions/string_ext.dart';
import 'driver_trip.dart';

extension DriverTripDisplay on DriverTrip {
  static final _unsetSchedule = DateTime(1970, 1, 1);

  String get fromDisplayLabel => fromCity;

  String get toDisplayLabel => toCity;

  /// Vehicle type label for display — prefers the API's already-localized
  /// [DriverTrip.vehicleTypeName] over [DriverTrip.vehicleCategory]'s
  /// hardcoded English label. Falls back to the enum label for local/dummy
  /// data where the API name isn't available.
  String get vehicleTypeDisplayLabel {
    final apiName = vehicleTypeName?.trim();
    return apiName != null && apiName.isNotEmpty
        ? apiName
        : vehicleCategory.label;
  }

  String get estimatedStartLabel =>
      _formatSchedule(estimatedStartDate);

  String get estimatedEndLabel => _formatSchedule(estimatedEndDate);

  String _formatSchedule(DateTime value) {
    if (value == _unsetSchedule || value.year <= 1971) return '—';
    return value.displayDateTime;
  }

  String get loadCapacityLabel {
    if (loadCapacity != null && loadCapacity! > 0 && capacityUnit != null) {
      final value = loadCapacity!;
      final formatted = value == value.truncateToDouble()
          ? value.toInt().toString()
          : value.toStringAsFixed(1);
      return capacityUnit == 'KG' ? '$formatted KG' : '$formatted Ton';
    }
    if (loadCapacityTons <= 0) return vehicleCategory.capacityDisplay;
    if (loadCapacityTons >= 1) {
      final tons = loadCapacityTons % 1 == 0
          ? loadCapacityTons.toInt().toString()
          : loadCapacityTons.toStringAsFixed(1);
      return '$tons Ton';
    }
    final kg = (loadCapacityTons * 1000).round();
    return '$kg KG';
  }

  bool get showInterestBadge =>
      isInterested || interestRequestCount > 0;
}
