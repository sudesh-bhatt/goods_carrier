import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/data/repositories/local_auth_repository.dart';
import '../../shared/data/repositories/local_shipment_repository.dart';
import '../../shared/data/repositories/local_trip_repository.dart';
import '../../shared/data/repositories/remote_auth_repository.dart';
import '../../shared/data/repositories/remote_shipment_repository.dart';
import '../../shared/data/repositories/remote_trip_repository.dart';
import '../../shared/domain/repositories/i_auth_repository.dart';
import '../../shared/domain/repositories/i_shipment_repository.dart';
import '../../shared/domain/repositories/i_trip_repository.dart';
import '../network/dio_client.dart';

// ─── Shipment Repository ─────────────────────────────────────────────────────

/// Toggle the active shipment repository:
///   - [LocalShipmentRepository]  — dummy data, no network required (dev mode)
///   - [RemoteShipmentRepository] — live REST API via Dio
///
/// **To go live:** comment out the `Local` line and uncomment `Remote`.
final shipmentRepositoryProvider = Provider<IShipmentRepository>((ref) {
  return LocalShipmentRepository();
  // return RemoteShipmentRepository(ref.read(dioProvider));
});

// ─── Trip Repository ──────────────────────────────────────────────────────────

/// Toggle the active trip repository.
final tripRepositoryProvider = Provider<ITripRepository>((ref) {
  return LocalTripRepository();
  // return RemoteTripRepository(ref.read(dioProvider));
});

// ─── Auth Repository ──────────────────────────────────────────────────────────

/// Toggle the active auth repository.
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final storage = ref.read(secureStorageProvider);
  return LocalAuthRepository(storage);
  // return RemoteAuthRepository(
  //   dio:     ref.read(dioProvider),
  //   storage: storage,
  // );
});
