/// All Goods Carrier API surface constants.
///
/// Replace [baseUrl] with your staging / production URL before going live.
/// All endpoint paths are relative to [baseUrl].
abstract final class ApiConstants {
  // ── Base ───────────────────────────────────────────────────────────────────
  static const String baseUrl = 'https://api.goodscarrier.in/v1';

  // ── Timeouts ───────────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout    = Duration(seconds: 30);

  // ── Auth ───────────────────────────────────────────────────────────────────
  static const String sendOtp      = '/auth/otp/send';
  static const String verifyOtp    = '/auth/otp/verify';
  static const String refreshToken = '/auth/token/refresh';

  // ── Customer ───────────────────────────────────────────────────────────────
  static const String customerProfile   = '/customer/profile';
  static const String customerShipments = '/customer/shipments';
  static String cancelShipment(String id)   => '/customer/shipments/$id/cancel';
  static String assignDriver(String id)     => '/customer/shipments/$id/assign';

  // ── Driver ─────────────────────────────────────────────────────────────────
  static const String driverProfile      = '/driver/profile';
  static const String driverTrips        = '/driver/trips';
  static const String driverRequests     = '/driver/requests';
  static String expressInterest(String id) => '/driver/requests/$id/interest';
  static String cancelTrip(String id)      => '/driver/trips/$id/cancel';

  // ── Notifications ──────────────────────────────────────────────────────────
  static const String notifications = '/notifications';

  // ── Secure-storage keys ────────────────────────────────────────────────────
  static const String kAccessToken  = 'access_token';
  static const String kRefreshToken = 'refresh_token';
}
