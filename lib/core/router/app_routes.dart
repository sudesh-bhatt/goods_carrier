/// All named route paths as compile-time constants.
/// Use with GoRouter: `context.go(AppRoutes.loginScreen)`.
abstract final class AppRoutes {
  // ── Auth / Onboarding ──────────────────────────────────────────────────────
  static const String splash              = '/';
  static const String roleSelection       = '/role-selection';
  static const String languageSelection   = '/language-selection';
  static const String terms               = '/terms';
  /// Login (phone) — matches Figma "Login Screen".
  static const String loginScreen         = '/login';
  static const String otpVerification     = '/otp-verification';
  static const String customerProfileSetup = '/profile-setup/customer';
  static const String driverProfileSetup   = '/profile-setup/driver';

  // ── Customer ───────────────────────────────────────────────────────────────
  static const String customerHome         = '/customer/home';
  static const String postShipment         = '/customer/post-shipment';
  static const String shipmentPostConfirmation =
      '/customer/post-shipment/confirmation';
  static const String editShipment         = '/customer/shipment/:id/edit';
  static const String shipmentDetail       = '/customer/shipment/:id';
  static const String cancelShipment       = '/customer/shipment/:id/cancel';
  static const String shipmentCancelSuccess =
      '/customer/shipment/cancel-success';
  static const String customerTripDetail   = '/customer/trip/:id';
  static const String reportTrip           = '/customer/trip/:id/report';
  static const String reportTripSuccess    = '/customer/report-trip/success';
  static const String tracking             = '/customer/tracking/:id';
  static const String customerNotifications= '/customer/notifications';
  static const String customerProfile      = '/customer/profile';
  static const String customerEditProfile  = '/customer/profile/edit';
  static const String customerSettings = '/customer/profile/settings';
  static const String customerSupportCenter = '/customer/profile/support';
  static const String customerReportedTrips = '/customer/profile/reported-trips';
  static const String driverReportedShipments =
      '/driver/profile/reported-shipments';
  static const String customerSavedAddresses = '/customer/profile/addresses';
  static const String customerAddAddress   = '/customer/profile/addresses/add';
  static const String customerEditAddress  = '/customer/profile/addresses/:id/edit';
  static const String customerHistory      = '/customer/history';

  // ── Driver ────────────────────────────────────────────────────────────────
  static const String driverHome           = '/driver/home';
  static const String driverMyTrips        = '/driver/my-trips';
  static const String postTrip             = '/driver/post-trip';
  static const String editTrip             = '/driver/trip/:id/edit';
  static const String driverTripDetail     = '/driver/trip/:id';
  static const String cancelTrip           = '/driver/trip/:id/cancel';
  static const String tripCancelSuccess    = '/driver/trip/cancel-success';
  static const String driverShipmentDetail = '/driver/shipment/:id';
  static const String driverAddShipmentRequest = '/driver/shipment/:id/add-request';
  static const String driverInterestSuccess = '/driver/shipment/interest-success';
  static const String driverNotifications  = '/driver/notifications';
  static const String driverProfile        = '/driver/profile';
  static const String driverEditProfile    = '/driver/profile/edit';
  static const String driverEarnings       = '/driver/earnings';
  static const String driverVehicles       = '/driver/profile/vehicles';
  static const String driverVehicleDetail  = '/driver/profile/vehicles/:id';
  static const String driverAddVehicle     = '/driver/profile/vehicles/add';
  static const String driverEditVehicle    = '/driver/profile/vehicles/:id/edit';
  static const String driverSavedAddresses = '/driver/profile/addresses';
  static const String driverAddAddress     = '/driver/profile/addresses/add';
  static const String driverEditAddress    = '/driver/profile/addresses/:id/edit';

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Build `/customer/shipment/:id` → `/customer/shipment/TRK-0001`
  static String shipmentDetailOf(String id) => '/customer/shipment/$id';
  static String cancelShipmentOf(String id) => '/customer/shipment/$id/cancel';
  static String tripDetailOf(String id) => '/customer/trip/$id';
  static String reportTripOf(String id) => '/customer/trip/$id/report';
  static String editShipmentOf(String id) => '/customer/shipment/$id/edit';
  static String trackingOf(String id)        => '/customer/tracking/$id';
  static String driverTripDetailOf(String id)=> '/driver/trip/$id';
  static String cancelTripOf(String id) => '/driver/trip/$id/cancel';
  static String editTripOf(String id) => '/driver/trip/$id/edit';
  static String driverShipmentDetailOf(String id) => '/driver/shipment/$id';
  static String driverAddShipmentRequestOf(String id) =>
      '/driver/shipment/$id/add-request';
  static String customerEditAddressOf(dynamic id) =>
      '/customer/profile/addresses/$id/edit';
  static String driverVehicleDetailOf(int id) => '/driver/profile/vehicles/$id';
  static String driverEditVehicleOf(int id) =>
      '/driver/profile/vehicles/$id/edit';
  static String driverEditAddressOf(int id) =>
      '/driver/profile/addresses/$id/edit';
}
