// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Goods Carrier';

  @override
  String get appTagline => 'Logistics made simple';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionSubmit => 'Submit';

  @override
  String get actionBack => 'Back';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionDone => 'Done';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionSelect => 'Select';

  @override
  String get actionClose => 'Close';

  @override
  String get actionYes => 'Yes';

  @override
  String get actionNo => 'No';

  @override
  String get actionNext => 'Next';

  @override
  String get actionSkip => 'Skip';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionRemove => 'Remove';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionFilter => 'Filter';

  @override
  String get actionShare => 'Share';

  @override
  String get actionCopy => 'Copy';

  @override
  String get labelLoading => 'Loading...';

  @override
  String get labelError => 'Something went wrong';

  @override
  String get labelNoData => 'No data available';

  @override
  String get labelOptional => 'Optional';

  @override
  String get labelRequired => 'Required';

  @override
  String get labelToday => 'Today';

  @override
  String get labelYesterday => 'Yesterday';

  @override
  String get labelAll => 'All';

  @override
  String get labelNew => 'New';

  @override
  String validationFieldRequired(String fieldName) {
    return '$fieldName is required';
  }

  @override
  String get validationPhoneRequired => 'Phone number is required';

  @override
  String get validationPhoneInvalid => 'Enter a valid 10-digit mobile number';

  @override
  String get validationGstRequired => 'GST number is required';

  @override
  String get validationGstInvalid =>
      'Enter a valid GST number (e.g. 27AABCS1429B1ZB)';

  @override
  String get validationVehicleRequired => 'Vehicle number is required';

  @override
  String get validationVehicleInvalid =>
      'Enter a valid vehicle number (e.g. MH02CC4156)';

  @override
  String get validationEmailRequired => 'Email is required';

  @override
  String get validationEmailInvalid => 'Enter a valid email address';

  @override
  String get validationOtpInvalid => 'Enter the 4-digit OTP';

  @override
  String get validationOtpDigitsOnly => 'OTP must be 4 digits';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusInterestReceived => 'Interest Received';

  @override
  String get statusAssigned => 'Assigned';

  @override
  String get statusInTransit => 'In Transit';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get tripStatusActive => 'Active';

  @override
  String get tripStatusPendingConfirmation => 'Pending Confirmation';

  @override
  String get tripStatusConfirmed => 'Confirmed';

  @override
  String get tripStatusCompleted => 'Completed';

  @override
  String get tripStatusCancelled => 'Cancelled';

  @override
  String get vehicleMini => 'Mini';

  @override
  String get vehicleMiniCapacity => 'Up to 500 KG';

  @override
  String get vehiclePickupTruck => 'Pickup Truck';

  @override
  String get vehiclePickupTruckCapacity => 'Up to 1.5 Ton';

  @override
  String get vehicleTruck => 'Truck';

  @override
  String get vehicleTruckCapacity => 'Up to 5 Ton';

  @override
  String get vehicleHeavyDuty => 'Heavy Duty';

  @override
  String get vehicleHeavyDutyCapacity => 'Up to 20 Ton';

  @override
  String get authWelcome => 'Welcome to Goods Carrier';

  @override
  String get authLoginBrandLine => 'YOUR LOGISTICS PARTNER';

  @override
  String get authLoginHeadline => 'Welcome to the Marketplace';

  @override
  String get authCountryCodeInd => 'IND  +91';

  @override
  String get authPhoneDigitsPlaceholder => '000-000-0000';

  @override
  String get authSubtitle => 'Your trusted logistics partner';

  @override
  String get authPhoneLabel => 'Mobile Number';

  @override
  String get authPhoneHint => '+91 XXXXX XXXXX';

  @override
  String get authSendOtp => 'Send OTP';

  @override
  String get authVerifyOtp => 'Verify OTP';

  @override
  String get authResendOtp => 'Resend OTP';

  @override
  String authResendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get authLoginSubtitle =>
      'Enter your phone number to receive a secure login code.';

  @override
  String get authPrivacyPolicy => 'Privacy Policy';

  @override
  String get authHelpCenter => 'Help Center';

  @override
  String get authFeatureVerifiedTitle => 'Verified Carriers';

  @override
  String get authFeatureVerifiedDesc =>
      'Join 50,000+ trusted logistics professionals.';

  @override
  String get authFeatureSecureTitle => 'Secure Payments';

  @override
  String get authFeatureSecureDesc =>
      'Encrypted transactions and reliable escrow.';

  @override
  String get authIAmCustomer => 'I\'m a Customer';

  @override
  String get authIAmDriver => 'I\'m a Driver';

  @override
  String get authTermsPrefix => 'By continuing, you agree to our ';

  @override
  String get authTermsLink => 'Terms & Conditions';

  @override
  String authOtpSentTo(String phone) {
    return 'OTP sent to $phone';
  }

  @override
  String get roleCustomer => 'Customer';

  @override
  String get roleDriver => 'Driver';

  @override
  String get langSelectionTitle => 'Select Your Language';

  @override
  String get langSelectionSubtitle =>
      'Choose your preferred language to continue';

  @override
  String get langEnglishName => 'English';

  @override
  String get langEnglishSubtitle => 'Primary language';

  @override
  String get langHindiName => 'Hindi (हिन्दी)';

  @override
  String get langHindiSubtitle => 'Standard Hindi';

  @override
  String get langGujaratiName => 'Gujarati (ગુજરાતી)';

  @override
  String get langGujaratiSubtitle => 'Regional Gujarati';

  @override
  String get roleSelectionTitle => 'Choose Your Role';

  @override
  String get roleSelectionSubtitle =>
      'Select how you\'d like to use the Goods Carrier platform to manage your logistics.';

  @override
  String get roleCustomerTitle => 'Customer / Send Goods';

  @override
  String get roleCustomerDescription =>
      'Find transport easily. Ship anything from small parcels to full containers globally.';

  @override
  String get roleDriverTitle => 'Driver / Transporter';

  @override
  String get roleDriverDescription =>
      'List trips and earn. Connect with businesses needing reliable transport solutions.';

  @override
  String get splashInitializing => 'SYSTEM INITIALIZING';

  @override
  String get profileName => 'Full Name';

  @override
  String get profileEmail => 'Email Address';

  @override
  String get profilePhone => 'Phone Number';

  @override
  String get profileCompanyName => 'Company Name';

  @override
  String get profileGstNumber => 'GST Number';

  @override
  String get profileGstNumberHint => 'e.g. 27AABCS1429B1ZB';

  @override
  String get profileBusinessEmail => 'Business Email';

  @override
  String get profileVehicleNumber => 'Vehicle Number';

  @override
  String get profileVehicleNumberHint => 'e.g. MH 02 CC 4156';

  @override
  String get profileVehicleType => 'Vehicle Type';

  @override
  String get profileLoadCapacity => 'Load Capacity (Tons)';

  @override
  String get profileSetupTitle => 'Complete Your Profile';

  @override
  String get profileSetupSubtitle => 'Let\'s get you started';

  @override
  String get shipmentPickup => 'Pickup Location';

  @override
  String get shipmentPickupCity => 'Pickup City';

  @override
  String get shipmentDrop => 'Drop Location';

  @override
  String get shipmentDropCity => 'Drop City';

  @override
  String get shipmentGoods => 'Goods Details';

  @override
  String get shipmentGoodsType => 'Goods Type';

  @override
  String get shipmentWeight => 'Weight';

  @override
  String get shipmentDate => 'Shipment Date';

  @override
  String get shipmentPrice => 'Estimated Price';

  @override
  String get shipmentPostNew => 'Post Shipment';

  @override
  String get shipmentFragile => 'Fragile Goods';

  @override
  String get shipmentFragileWarning => 'Handle with care — fragile goods';

  @override
  String get shipmentSpecialInstructions => 'Special Instructions';

  @override
  String get shipmentSpecialInstructionsHint =>
      'Any special handling requirements...';

  @override
  String get shipmentInterestedDrivers => 'Interested Drivers';

  @override
  String get shipmentSelectDriver => 'Select Driver';

  @override
  String get shipmentNoDriversYet => 'No drivers have shown interest yet';

  @override
  String get shipmentId => 'Shipment ID';

  @override
  String shipmentActiveCount(int count) {
    return '$count active shipment(s)';
  }

  @override
  String get tripPostNew => 'Post Trip';

  @override
  String get tripFrom => 'From';

  @override
  String get tripTo => 'To';

  @override
  String get tripDate => 'Trip Date';

  @override
  String get tripCapacity => 'Load Capacity';

  @override
  String get tripVehicle => 'Vehicle';

  @override
  String get tripId => 'Trip ID';

  @override
  String get tripExpressInterest => 'Express Interest';

  @override
  String get tripInterestSubmitted => 'Interest submitted';

  @override
  String get tripPrice => 'Your Quote (₹)';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationMarkAllRead => 'Mark all as read';

  @override
  String get notificationNoNew => 'You\'re all caught up!';

  @override
  String get emptyShipments => 'No shipments yet';

  @override
  String get emptyShipmentsSubtitle =>
      'Post your first shipment to get started';

  @override
  String get emptyTrips => 'No trips yet';

  @override
  String get emptyTripsSubtitle =>
      'Post your available route to receive shipment requests';

  @override
  String get emptyNotifications => 'No notifications';

  @override
  String get emptyHistory => 'No history found';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork => 'No internet connection';

  @override
  String get errorNetworkSubtitle => 'Check your connection and retry';

  @override
  String get errorTimeout => 'Request timed out. Please retry.';

  @override
  String get errorUnauthorised => 'Session expired. Please login again.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System Default';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageHindi => 'हिन्दी';

  @override
  String get settingsLanguageGujarati => 'ગુજરાતી';

  @override
  String get settingsLogout => 'Logout';

  @override
  String get settingsLogoutConfirm => 'Are you sure you want to logout?';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }
}
