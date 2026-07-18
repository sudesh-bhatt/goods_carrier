import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env_config.dart';
import '../../shared/domain/models/driver_vehicle_masters.dart';
import 'repository_providers.dart';

/// Driver vehicle type masters (`GET /api/driver/vehicle-masters`).
///
/// Used by driver home filters and vehicles screens only.
/// Customer home uses `vehicle_types` from `GET /api/customer/dashboard`.
/// Falls back to Mini/Pickup/Truck when the API fails or returns empty.
final vehicleMastersProvider = FutureProvider<DriverVehicleMasters>((ref) async {
  if (!EnvConfig.useRemoteApi) {
    return DriverVehicleMasters.fallback;
  }
  try {
    final masters =
        await ref.read(driverVehicleApiClientProvider).fetchMasters();
    if (masters.vehicleTypes.isEmpty) {
      return DriverVehicleMasters.fallback;
    }
    return masters;
  } catch (_) {
    return DriverVehicleMasters.fallback;
  }
});
