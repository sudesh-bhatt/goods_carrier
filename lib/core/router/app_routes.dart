/// All named route paths as compile-time constants.
/// Use with GoRouter: `context.go(AppRoutes.phoneInput)`.
abstract final class AppRoutes {
  // ── Auth / Onboarding ──────────────────────────────────────────────────────
  static const String splash              = '/';
  static const String roleSelection       = '/role-selection';
  static const String languageSelection   = '/language-selection';
  static const String terms               = '/terms';
  static const String phoneInput          = '/phone-input';
  static const String otpVerification     = '/otp-verification';
  static const String customerProfileSetup = '/profile-setup/customer';
  static const String driverProfileSetup   = '/profile-setup/driver';

  // ── Customer ───────────────────────────────────────────────────────────────
  static const String customerHome         = '/customer/home';
  static const String postShipment         = '/customer/post-shipment';
  static const String shipmentDetail       = '/customer/shipment/:id';
  static const String tracking             = '/customer/tracking/:id';
  static const String customerNotifications= '/customer/notifications';
  static const String customerProfile      = '/customer/profile';
  static const String customerHistory      = '/customer/history';

  // ── Driver ────────────────────────────────────────────────────────────────
  static const String driverHome           = '/driver/home';
  static const String postTrip             = '/driver/post-trip';
  static const String driverTripDetail     = '/driver/trip/:id';
  static const String driverNotifications  = '/driver/notifications';
  static const String driverProfile        = '/driver/profile';
  static const String driverEarnings       = '/driver/earnings';

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Build `/customer/shipment/:id` → `/customer/shipment/TRK-0001`
  static String shipmentDetailOf(String id) => '/customer/shipment/$id';
  static String trackingOf(String id)        => '/customer/tracking/$id';
  static String driverTripDetailOf(String id)=> '/driver/trip/$id';
}
