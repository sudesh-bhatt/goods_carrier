import '../config/env_config.dart';

/// All Goods Carrier API surface constants.
///
/// Paths are relative to [EnvConfig.apiBaseUrl].
abstract final class ApiConstants {
  // ── Base ───────────────────────────────────────────────────────────────────
  static String get baseUrl => EnvConfig.apiBaseUrl;

  // ── Timeouts ───────────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout    = Duration(seconds: 30);

  // ── Auth ───────────────────────────────────────────────────────────────────
  static const String sendOtp    = '/api/auth/send-otp';
  static const String verifyOtp  = '/api/auth/verify-otp';
  static const String resendOtp  = '/api/auth/resend-otp';
  static const String authMe     = '/api/auth/me';
  static const String authLogout = '/api/auth/logout';

  // ── Onboarding ───────────────────────────────────────────────────────────
  static const String onboardingRole           = '/api/onboarding/role';
  static const String onboardingLanguage       = '/api/onboarding/language';
  static const String onboardingAcceptAgreement = '/api/onboarding/accept-agreement';
  static const String onboardingStatus         = '/api/onboarding/status';

  // ── Customer ─────────────────────────────────────────────────────────────
  static const String customerProfile       = '/api/customer/profile';
  static const String customerProfileAvatar = '/api/customer/profile/avatar';
  static const String customerShipments = '/api/customer/shipments';
  static const String customerDashboard = '/api/customer/dashboard';
  static const String customerShipmentMasters = '/api/customer/shipment-masters';
  static String customerShipment(String id) => '/api/customer/shipments/$id';
  static String customerShipmentEdit(String id) =>
      '/api/customer/shipments/$id/edit';
  static String cancelShipment(String id) => '/api/customer/shipments/$id/cancel';

  // ── Driver ───────────────────────────────────────────────────────────────
  static const String driverProfile       = '/api/driver/profile';
  static const String driverProfileAvatar = '/api/driver/profile/avatar';
  static const String driverTrips         = '/api/driver/trips';
  static const String driverDashboard     = '/api/driver/dashboard';
  static String driverTrip(String id) => '/api/driver/trips/$id';
  static String driverTripEdit(String id) => '/api/driver/trips/$id/edit';
  static String driverTripRequests(String tripId) =>
      '/api/driver/trips/$tripId/requests';
  static String acceptDriverTripRequest(String tripId, String requestId) =>
      '/api/driver/trips/$tripId/requests/$requestId/accept';
  static String rejectDriverTripRequest(String tripId, String requestId) =>
      '/api/driver/trips/$tripId/requests/$requestId/reject';
  static String cancelTrip(String id) => '/api/driver/trips/$id/cancel';
  static String driverShipment(String id) => '/api/driver/shipments/$id';
  static String driverShipmentRequest(String id) =>
      '/api/driver/shipments/$id/requests';
  static const String driverVehicles = '/api/driver/vehicles';
  static const String driverVehicleMasters = '/api/driver/vehicle-masters';
  static String driverVehicle(int id) => '/api/driver/vehicles/$id';

  // ── Notifications ──────────────────────────────────────────────────────────
  static const String notifications = '/api/notifications';

  // ── Secure-storage keys ────────────────────────────────────────────────────
  static const String kAuthToken        = 'auth_token';
  static const String kOtpReferenceId   = 'otp_reference_id';

  /// Legacy keys — cleared on session reset.
  static const String kAccessToken  = 'access_token';
  static const String kRefreshToken = 'refresh_token';

  /// Paths that must not send Authorization header.
  static const publicPaths = [
    sendOtp,
    verifyOtp,
    resendOtp,
  ];
}
