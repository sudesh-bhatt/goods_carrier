import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/env_config.dart';
import '../../shared/data/api/auth/auth_api_client.dart';
import '../../shared/data/api/customer/customer_address_api_client.dart';
import '../../shared/data/api/customer/customer_dashboard_api_client.dart';
import '../../shared/data/api/customer/customer_shipment_api_client.dart';
import '../../shared/data/api/driver/driver_dashboard_api_client.dart';
import '../../shared/data/api/driver/driver_trip_api_client.dart';
import '../../shared/data/api/driver/driver_vehicle_api_client.dart';
import '../../shared/data/api/customer/customer_settings_api_client.dart';
import '../../shared/data/api/customer/customer_support_api_client.dart';
import '../../shared/data/api/driver/driver_payment_api_client.dart';
import '../../shared/data/api/driver/driver_subscription_api_client.dart';
import '../../shared/data/api/app/app_config_api_client.dart';
import '../../shared/data/api/notifications/notifications_api_client.dart';
import '../../shared/data/api/reports/reports_api_client.dart';
import '../../shared/data/repositories/local_customer_address_repository.dart';
import '../../shared/data/repositories/local_notifications_repository.dart';
import '../../shared/data/repositories/local_reports_repository.dart';
import '../../shared/data/api/driver/driver_address_api_client.dart';
import '../../shared/data/api/onboarding/onboarding_api_client.dart';
import '../../shared/data/repositories/local_auth_repository.dart';
import '../../shared/data/repositories/local_onboarding_repository.dart';
import '../../shared/data/repositories/local_trip_repository.dart';
import '../../shared/data/repositories/remote/auth/remote_auth_repository.dart';
import '../../shared/data/repositories/remote/customer/remote_customer_address_repository.dart';
import '../../shared/data/repositories/remote/customer/remote_customer_shipment_repository.dart';
import '../../shared/data/repositories/remote/remote_notifications_repository.dart';
import '../../shared/data/repositories/remote/remote_reports_repository.dart';
import '../../shared/data/repositories/local_driver_address_repository.dart';
import '../../shared/data/repositories/remote/driver/remote_driver_trip_repository.dart';
import '../../shared/data/repositories/remote/onboarding/remote_onboarding_repository.dart';
import '../../shared/data/local/auth_preferences_store.dart';
import '../../shared/domain/repositories/i_auth_repository.dart';
import '../../shared/domain/repositories/i_customer_address_repository.dart';
import '../../shared/domain/repositories/i_driver_address_repository.dart';
import '../../shared/data/repositories/remote/driver/remote_driver_address_repository.dart';
import '../../shared/domain/repositories/i_notifications_repository.dart';
import '../../shared/domain/repositories/i_onboarding_repository.dart';
import '../../shared/domain/repositories/i_reports_repository.dart';
import '../../shared/domain/repositories/i_customer_trip_repository.dart';
import '../../shared/domain/repositories/i_shipment_repository.dart';
import '../../shared/domain/repositories/i_trip_repository.dart';
import '../network/dio_client.dart';
import 'shared_preferences_provider.dart';
import '../../shared/data/api/customer/customer_trip_api_client.dart';
import '../../shared/data/repositories/local_customer_trip_repository.dart';
import '../../shared/data/repositories/local_shipment_repository.dart';
import '../../shared/data/repositories/remote/customer/remote_customer_trip_repository.dart';

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

final customerAddressApiClientProvider =
    Provider<CustomerAddressApiClient>((ref) {
  return CustomerAddressApiClient(ref.read(dioProvider));
});

final customerAddressRepositoryProvider =
    Provider<ICustomerAddressRepository>((ref) {
  if (EnvConfig.useRemoteApi) {
    return RemoteCustomerAddressRepository(
      apiClient: ref.read(customerAddressApiClientProvider),
    );
  }
  return LocalCustomerAddressRepository();
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

final driverAddressApiClientProvider = Provider<DriverAddressApiClient>((ref) {
  return DriverAddressApiClient(ref.read(dioProvider));
});

final driverAddressRepositoryProvider = Provider<IDriverAddressRepository>((ref) {
  if (EnvConfig.useRemoteApi) {
    return RemoteDriverAddressRepository(
      apiClient: ref.read(driverAddressApiClientProvider),
    );
  }
  return LocalDriverAddressRepository();
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

final notificationsApiClientProvider = Provider<NotificationsApiClient>((ref) {
  return NotificationsApiClient(ref.read(dioProvider));
});

final notificationsRepositoryProvider = Provider<INotificationsRepository>((ref) {
  if (EnvConfig.useRemoteApi) {
    return RemoteNotificationsRepository(
      apiClient: ref.read(notificationsApiClientProvider),
    );
  }
  return LocalNotificationsRepository();
});

final customerNotificationsRepositoryProvider =
    Provider<INotificationsRepository>((ref) {
  if (EnvConfig.useRemoteApi) {
    return RemoteNotificationsRepository(
      apiClient: ref.read(notificationsApiClientProvider),
    );
  }
  return LocalNotificationsRepository(forDriver: false);
});

final driverNotificationsRepositoryProvider =
    Provider<INotificationsRepository>((ref) {
  if (EnvConfig.useRemoteApi) {
    return RemoteNotificationsRepository(
      apiClient: ref.read(notificationsApiClientProvider),
    );
  }
  return LocalNotificationsRepository(forDriver: true);
});

final reportsApiClientProvider = Provider<ReportsApiClient>((ref) {
  return ReportsApiClient(ref.read(dioProvider));
});

final reportsRepositoryProvider = Provider<IReportsRepository>((ref) {
  if (EnvConfig.useRemoteApi) {
    return RemoteReportsRepository(
      apiClient: ref.read(reportsApiClientProvider),
    );
  }
  return LocalReportsRepository();
});

final customerSettingsApiClientProvider =
    Provider<CustomerSettingsApiClient>((ref) {
  return CustomerSettingsApiClient(ref.read(dioProvider));
});

final customerSupportApiClientProvider =
    Provider<CustomerSupportApiClient>((ref) {
  return CustomerSupportApiClient(ref.read(dioProvider));
});

final driverPaymentApiClientProvider = Provider<DriverPaymentApiClient>((ref) {
  return DriverPaymentApiClient(ref.read(dioProvider));
});

final driverSubscriptionApiClientProvider =
    Provider<DriverSubscriptionApiClient>((ref) {
  return DriverSubscriptionApiClient(ref.read(dioProvider));
});

final customerTripApiClientProvider = Provider<CustomerTripApiClient>((ref) {
  return CustomerTripApiClient(ref.read(dioProvider));
});

final customerTripRepositoryProvider = Provider<ICustomerTripRepository>((ref) {
  if (EnvConfig.useRemoteApi) {
    return RemoteCustomerTripRepository(
      apiClient: ref.read(customerTripApiClientProvider),
    );
  }
  return LocalCustomerTripRepository();
});

final appConfigApiClientProvider = Provider<AppConfigApiClient>((ref) {
  return AppConfigApiClient(ref.read(dioProvider));
});
