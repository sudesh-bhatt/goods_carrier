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
  static String cancelShipment(String id) => '/api/customer/shipments/$id/cancel';
  static String assignDriver(String id) => '/api/customer/shipments/$id/assign';

  // ── Driver ───────────────────────────────────────────────────────────────
  static const String driverProfile = '/api/driver/profile';
  static const String driverTrips   = '/api/driver/trips';
  static const String driverRequests = '/api/driver/requests';
  static String expressInterest(String id) => '/api/driver/requests/$id/interest';
  static String cancelTrip(String id) => '/api/driver/trips/$id/cancel';

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
