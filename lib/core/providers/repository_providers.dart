import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/env_config.dart';
import '../../shared/data/api/auth/auth_api_client.dart';
import '../../shared/data/api/customer/customer_dashboard_api_client.dart';
import '../../shared/data/api/customer/customer_shipment_api_client.dart';
import '../../shared/data/api/driver/driver_dashboard_api_client.dart';
import '../../shared/data/api/driver/driver_trip_api_client.dart';
import '../../shared/data/api/driver/driver_vehicle_api_client.dart';
import '../../shared/data/api/onboarding/onboarding_api_client.dart';
import '../../shared/data/repositories/local_auth_repository.dart';
import '../../shared/data/repositories/local_onboarding_repository.dart';
import '../../shared/data/repositories/local_trip_repository.dart';
import '../../shared/data/repositories/remote/auth/remote_auth_repository.dart';
import '../../shared/data/repositories/remote/customer/remote_customer_shipment_repository.dart';
import '../../shared/data/repositories/remote/driver/remote_driver_trip_repository.dart';
import '../../shared/data/repositories/remote/onboarding/remote_onboarding_repository.dart';
import '../../shared/data/local/auth_preferences_store.dart';
import '../../shared/domain/repositories/i_auth_repository.dart';
import '../../shared/domain/repositories/i_onboarding_repository.dart';
import '../../shared/domain/repositories/i_shipment_repository.dart';
import '../../shared/domain/repositories/i_trip_repository.dart';
import '../network/dio_client.dart';
import 'shared_preferences_provider.dart';
import '../../shared/data/repositories/local_shipment_repository.dart';

final authApiClientProvider = Provider<AuthApiClient>((ref) {
  return AuthApiClient(ref.read(dioProvider));
});

final onboardingApiClientProvider = Provider<OnboardingApiClient>((ref) {
  return OnboardingApiClient(ref.read(dioProvider));
});

final customerShipmentApiClientProvider =
    Provider<CustomerShipmentApiClient>((ref) {
  return CustomerShipmentApiClient(ref.read(dioProvider));
});

final customerDashboardApiClientProvider =
    Provider<CustomerDashboardApiClient>((ref) {
  return CustomerDashboardApiClient(ref.read(dioProvider));
});

final driverTripApiClientProvider = Provider<DriverTripApiClient>((ref) {
  return DriverTripApiClient(ref.read(dioProvider));
});

final driverDashboardApiClientProvider =
    Provider<DriverDashboardApiClient>((ref) {
  return DriverDashboardApiClient(ref.read(dioProvider));
});

final driverVehicleApiClientProvider = Provider<DriverVehicleApiClient>((ref) {
  return DriverVehicleApiClient(ref.read(dioProvider));
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
  final local = LocalShipmentRepository(ref.read(sharedPreferencesProvider));
  if (EnvConfig.useRemoteApi) {
    return RemoteCustomerShipmentRepository(
      apiClient: ref.read(customerShipmentApiClientProvider),
      driverDashboardApi: ref.read(driverDashboardApiClientProvider),
    );
  }
  return local;
});

final tripRepositoryProvider = Provider<ITripRepository>((ref) {
  if (EnvConfig.useRemoteApi) {
    return RemoteDriverTripRepository(
      apiClient: ref.read(driverTripApiClientProvider),
    );
  }
  return LocalTripRepository();
});
