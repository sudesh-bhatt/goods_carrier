import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/env_config.dart';
import '../../shared/data/api/auth/auth_api_client.dart';
import '../../shared/data/api/onboarding/onboarding_api_client.dart';
import '../../shared/data/repositories/local_auth_repository.dart';
import '../../shared/data/repositories/local_onboarding_repository.dart';
import '../../shared/data/repositories/remote/auth/remote_auth_repository.dart';
import '../../shared/data/repositories/remote/onboarding/remote_onboarding_repository.dart';
import '../../shared/data/local/auth_preferences_store.dart';
import '../../shared/domain/repositories/i_auth_repository.dart';
import '../../shared/domain/repositories/i_onboarding_repository.dart';
import '../../shared/domain/repositories/i_shipment_repository.dart';
import '../../shared/domain/repositories/i_trip_repository.dart';
import '../network/dio_client.dart';
import 'shared_preferences_provider.dart';
import '../../shared/data/repositories/local_shipment_repository.dart';
import '../../shared/data/repositories/local_trip_repository.dart';

final authApiClientProvider = Provider<AuthApiClient>((ref) {
  return AuthApiClient(ref.read(dioProvider));
});

final onboardingApiClientProvider = Provider<OnboardingApiClient>((ref) {
  return OnboardingApiClient(ref.read(dioProvider));
});

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final storage = ref.read(secureStorageProvider);
  final prefsStore = AuthPreferencesStore(ref.read(sharedPreferencesProvider));
  if (EnvConfig.useRemoteApi) {
    return RemoteAuthRepository(
      apiClient: ref.read(authApiClientProvider),
      storage: storage,
      prefsStore: prefsStore,
    );
  }
  return LocalAuthRepository(storage, prefsStore: prefsStore);
});

final onboardingRepositoryProvider = Provider<IOnboardingRepository>((ref) {
  if (EnvConfig.useRemoteApi) {
    return RemoteOnboardingRepository(ref.read(onboardingApiClientProvider));
  }
  return LocalOnboardingRepository();
});

final shipmentRepositoryProvider = Provider<IShipmentRepository>((ref) {
  return LocalShipmentRepository(ref.read(sharedPreferencesProvider));
});

final tripRepositoryProvider = Provider<ITripRepository>((ref) {
  return LocalTripRepository();
});
