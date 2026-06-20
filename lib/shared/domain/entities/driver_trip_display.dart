import '../../../../core/extensions/string_ext.dart';
import 'driver_trip.dart';

extension DriverTripDisplay on DriverTrip {
  static final _unsetSchedule = DateTime(1970, 1, 1);

  String get fromDisplayLabel => fromCity;

  String get toDisplayLabel => toCity;

  String get estimatedStartLabel =>
      _formatSchedule(estimatedStartDate);

  String get estimatedEndLabel => _formatSchedule(estimatedEndDate);

  String _formatSchedule(DateTime value) {
    if (value == _unsetSchedule || value.year <= 1971) return '—';
    return value.displayDateTime;
  }

  String get loadCapacityLabel {
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
