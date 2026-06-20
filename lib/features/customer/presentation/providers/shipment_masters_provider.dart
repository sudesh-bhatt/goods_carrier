import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../shared/domain/entities/shipment_masters.dart';

final shipmentMastersProvider = FutureProvider<ShipmentMasters>((ref) async {
  if (!EnvConfig.useRemoteApi) {
    return const ShipmentMasters(goodsTypes: [], vehicleTypes: []);
  }
  return ref.read(customerShipmentApiClientProvider).fetchMasters();
});
