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
  String get authPhoneLabel => 'Phone Number';

  @override
  String get authPhoneHint => '+91 XXXXX XXXXX';

  @override
  String get authSendOtp => 'Send OTP';

  @override
  String get authVerifyOtp => 'Verify OTP';

  @override
  String get authVerifyNumberTitle => 'Verify Number';

  @override
  String get authEnterOtp => 'Enter OTP';

  @override
  String get authOtpCodeSentPrefix => 'Enter the 4-digit code sent to';

  @override
  String get authVerifyAndContinue => 'Verify & Continue';

  @override
  String get authResendOtp => 'Resend OTP';

  @override
  String get authResendSms => 'Resend SMS';

  @override
  String get authResendCodeIn => 'Resend code in';

  @override
  String authResendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get authHavingTrouble => 'Having trouble? ';

  @override
  String get authNeedHelp => 'Need Help';

  @override
  String get authEncryptedVerification => 'END-TO-END ENCRYPTED VERIFICATION';

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
  String get profileEmailOptional => 'Email Address (Optional)';

  @override
  String get profilePhone => 'Phone Number';

  @override
  String get profilePrimaryAddress => 'Primary Address';

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
  String get profileSetupTitle => 'Create Your Profile';

  @override
  String get profileSetupSubtitle => 'Let\'s get started';

  @override
  String get profileCreateButton => 'Create Profile';

  @override
  String get driverProfileCompleteTitle => 'Complete Profile';

  @override
  String get driverProfilePersonalDetails => 'Personal Details';

  @override
  String get driverProfileBusinessDetails => 'Business Details';

  @override
  String get driverProfileCompleteButton => 'Complete Profile';

  @override
  String get profileCity => 'City';

  @override
  String get profilePostalCode => 'Postal Code';

  @override
  String get profileFullAddress => 'Full Address';

  @override
  String get profileGstName => 'GST Name';

  @override
  String get profileGstNumberOptional => 'GST Number (Optional)';

  @override
  String get profileBusinessPhone => 'Phone Number';

  @override
  String get profilePhotoPickerTitle => 'Profile photo';

  @override
  String get profilePhotoTakePhoto => 'Take photo';

  @override
  String get profilePhotoChooseGallery => 'Choose from gallery';

  @override
  String get profilePhotoCameraPermissionDenied =>
      'Camera access is required to take a profile photo. Please allow camera access in Settings.';

  @override
  String get profilePhotoGalleryPermissionDenied =>
      'Photo library access is required to choose a profile photo. Please allow photo access in Settings.';

  @override
  String get profilePhotoLimitedTitle => 'Limited photo access';

  @override
  String get profilePhotoLimitedMessage =>
      'You have allowed access to only selected photos. To browse your full gallery, allow full photo access in Settings.';

  @override
  String get profilePhotoAllowFullAccess => 'Allow full access';

  @override
  String get profilePhotoContinueWithLimited => 'Continue with selected photos';

  @override
  String get actionOpenSettings => 'Open Settings';

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
  String get shipmentPostConfirmationTitle => 'Confirmation';

  @override
  String get shipmentPostSuccessTitle => 'Shipment Post Successfully';

  @override
  String shipmentPostSuccessBody(String shipmentId) {
    return 'Your shipment has been post successfully your shipment id is #$shipmentId';
  }

  @override
  String get shipmentPostBackToHome => 'Back to Home';

  @override
  String get shipmentPostDateLabel => 'DATE';

  @override
  String get shipmentPostTotalPriceLabel => 'TOTAL PRICE';

  @override
  String get shipmentEditTitle => 'Edit Shipment';

  @override
  String get shipmentUpdate => 'Update Shipment';

  @override
  String get shipmentFormPrecisionLogistics => 'Precision Logistics';

  @override
  String get shipmentFormHeroTitle => 'Where is your cargo heading?';

  @override
  String get shipmentFormHeroSubtitle =>
      'Fill in the details below to get instant bids from verified carriers.';

  @override
  String get shipmentFormFromHint => 'Enter origin city or warehouse';

  @override
  String get shipmentFormToHint => 'Enter destination address';

  @override
  String get shipmentFormVehicleRequirement => 'Vehicle Requirement';

  @override
  String get shipmentFormEstWeight => 'Est. Weight';

  @override
  String get shipmentFormEstWeightType => 'Est. Weight Type';

  @override
  String get shipmentFormPickupDate => 'Preferred Pickup Date';

  @override
  String get shipmentFormPickupTime => 'Preferred Pickup Time';

  @override
  String get shipmentFormYourBudget => 'Your Budget';

  @override
  String get shipmentFormBudgetHint => 'Enter target price';

  @override
  String get shipmentFormCommentsLabel => 'Additional Comments (Optional)';

  @override
  String get shipmentFormCommentsHint =>
      'Please provide any additional context regarding this shipment';

  @override
  String get shipmentFormTerms =>
      'You have successfully agreed to our Terms & Conditions.';

  @override
  String get shipmentFormVehicleRequired =>
      'Please select a vehicle requirement';

  @override
  String get shipmentFormScheduleRequired =>
      'Please select pickup date and time';

  @override
  String get shipmentFormTermsRequired =>
      'Please accept the Terms & Conditions';

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
  String get customerHomeBrandTitle => 'Good Carrier';

  @override
  String get customerHomeDriverTrips => 'Driver Trips';

  @override
  String get customerHomeInterestBadge => 'YOUR ARE IN INTEREST';

  @override
  String get customerHomeEstStartDate => 'estimated start date';

  @override
  String get customerHomeEstEndDate => 'estimated end date';

  @override
  String get customerHomeSearchHint => 'Search by destination or vehicle';

  @override
  String customerHomeActiveShipments(int count) {
    return '$count Active shipments';
  }

  @override
  String get customerHomeYourShipments => 'Your Shipments';

  @override
  String get customerNavHome => 'Home';

  @override
  String get customerNavShipments => 'Shipment';

  @override
  String get customerNavNotifications => 'Notifications';

  @override
  String get customerNavProfile => 'Profile';

  @override
  String get driverNavMyTrip => 'My Trip';

  @override
  String get driverMyTripTitle => 'My Trip';

  @override
  String get driverMyTripsTitle => 'My Trips';

  @override
  String get driverTripDetailsTitle => 'Trip Details';

  @override
  String get driverCancelTrip => 'Cancel Trip';

  @override
  String driverViewRequestCount(int count) {
    return 'View Request ($count)';
  }

  @override
  String get driverTripPickupLabel => 'PICKUP';

  @override
  String get driverTripDropLabel => 'DROP';

  @override
  String get driverTripCapacityLabel => 'CAPACITY';

  @override
  String get driverTripBadgePublished => 'PUBLISHED';

  @override
  String get driverTripBadgePublish => 'PUBLISH';

  @override
  String get driverTripBadgeExpired => 'EXPIRED';

  @override
  String get driverTripBadgeDraft => 'DRAFT';

  @override
  String get driverExpertDriverLabel => 'Expert Driver';

  @override
  String get driverDeleteTripTitle => 'Delete trip?';

  @override
  String get driverDeleteTripBody =>
      'This will remove the trip from your list. You can publish a new trip anytime.';

  @override
  String get cancelTripReasonRouteChanged => 'Route no longer viable';

  @override
  String get cancelTripReasonVehicleUnavailable => 'Vehicle not available';

  @override
  String get cancelTripReasonBetterLoad => 'Found a better load';

  @override
  String get cancelTripReasonIncorrectDetails => 'Incorrect details entered';

  @override
  String get cancelTripReasonOther => 'Other';

  @override
  String get cancelTripKeep => 'Keep Trip';

  @override
  String get tripCancelSuccessTitle => 'Your Trip Cancel Successfully';

  @override
  String tripCancelSuccessBody(String tripId) {
    return 'Your trip has been cancel successfully your trip id is $tripId';
  }

  @override
  String get driverHomeShipmentId => 'Shipment ID';

  @override
  String get driverShipmentDetailsTitle => 'Shipment Details';

  @override
  String get driverAddRequest => 'Add Request';

  @override
  String get driverRequestSent => 'Request Sent';

  @override
  String get driverConfirmRequestTitle => 'Confirm Request';

  @override
  String get driverConfirmRequestBody =>
      'Are you sure you want to show interest in this shipment? The customer will be notified.';

  @override
  String get driverConfirmYesContinue => 'Yes, Continue';

  @override
  String get driverGoodsDetails => 'Goods Details';

  @override
  String get driverGoodsType => 'Type';

  @override
  String get driverGoodsWeight => 'Weight';

  @override
  String get driverFragileHandlingRequired => 'Fragile Handling Required';

  @override
  String get driverPickupLocation => 'Pickup Location';

  @override
  String get driverDropLocation => 'Drop Location';

  @override
  String get driverVehicleRequirement => 'Vehicle Requirement';

  @override
  String get driverMatchesYourVehicle => 'Matches Your Vehicle';

  @override
  String get driverReportShipmentQuestion => 'Report a shipment?';

  @override
  String get driverConfirmationTitle => 'Confirmation';

  @override
  String get driverInterestSentTitle => 'Request Sent Successfully';

  @override
  String get driverInterestSentBody =>
      'Your request has been sent to the customer. You will be notified once they respond.';

  @override
  String get driverSummaryDate => 'Date';

  @override
  String get driverSummaryTotalPrice => 'Total Price';

  @override
  String get actionViewDetails => 'View Details';

  @override
  String get customerHomeFilterSoon => 'Advanced filters are coming soon';

  @override
  String get filterSearchTitle => 'Filter Search';

  @override
  String get filterClearAll => 'Clear All';

  @override
  String get filterRouteDetails => 'Route Details';

  @override
  String get filterFromLabel => 'From';

  @override
  String get filterFromHint => 'Enter origin city';

  @override
  String get filterToLabel => 'To';

  @override
  String get filterToHint => 'Enter destination';

  @override
  String get filterPickupDate => 'Pickup Date';

  @override
  String get filterCalendar => 'Calendar';

  @override
  String get filterToday => 'TODAY';

  @override
  String get filterVehicleClass => 'Vehicle Class';

  @override
  String get filterLoadCapacity => 'Load Capacity';

  @override
  String get filterApply => 'Apply Filters';

  @override
  String get customerMyShipment => 'My Shipment';

  @override
  String get customerMyProfile => 'My Profile';

  @override
  String get customerRoleLabel => 'Customer';

  @override
  String get customerAccountSettings => 'Account Settings';

  @override
  String get customerEditPersonalInfo => 'Edit Personal Information';

  @override
  String get customerEditPersonalInfoSub => 'Name, Email, Phone';

  @override
  String get customerEditProfileTitle => 'Edit Your Profile';

  @override
  String get customerUpdateProfileButton => 'Update Profile';

  @override
  String get customerDefaultShippingAddress => 'Default Shipping Address';

  @override
  String get customerAddressNotSet => 'Add your shipping address';

  @override
  String get customerEditAddressTitle => 'Edit Address';

  @override
  String get customerSavedAddresses => 'Saved Addresses';

  @override
  String get customerSavedAddressesSub => 'Home, Office & others';

  @override
  String get customerSavedLocationsSection => 'SAVED LOCATIONS';

  @override
  String get customerAddAddressTitle => 'Add Address';

  @override
  String get customerEditAddressScreenTitle => 'Edit Address';

  @override
  String get customerSelectAddressLabel => 'SELECT ADDRESS LABEL';

  @override
  String get customerAddressLabelHome => 'Home';

  @override
  String get customerAddressLabelOffice => 'Office';

  @override
  String get customerAddressLabelOther => 'Other';

  @override
  String get customerAddressFullLine => 'Full Address Line';

  @override
  String get customerAddressFullLineHint => 'House No, Street Name, Area';

  @override
  String get customerAddressCity => 'City';

  @override
  String get customerAddressCityHint => 'e.g. San Francisco';

  @override
  String get customerAddressPincode => 'Pincode';

  @override
  String get customerAddressPincodeHint => 'Zip Code';

  @override
  String get customerAddressLandmark => 'Landmark (Optional)';

  @override
  String get customerAddressLandmarkHint => 'Near by famous place';

  @override
  String get customerAddressLandmarkTip =>
      'Providing an accurate landmark helps our delivery partners find your location 30% faster.';

  @override
  String get customerSaveAddress => 'Save Address';

  @override
  String get customerAddressSaved => 'Address saved';

  @override
  String get customerLocationPermissionNeeded =>
      'Location permission is required to show your current position.';

  @override
  String get customerReportedTrips => 'Reported Trips';

  @override
  String get customerReportedTripsSub => 'Show reported trips';

  @override
  String get customerReportedByYouBadge => 'REPORTED BY YOU';

  @override
  String get customerEstimatedPrice => 'Estimated Price';

  @override
  String get customerActivity => 'Activity';

  @override
  String get customerSettingsSub => 'Push notification, Privacy Policy';

  @override
  String get customerHelpSupport => 'Help & Support';

  @override
  String get customerHelpSupportSub => 'FAQs and more';

  @override
  String get supportCenterTitle => 'Support Center';

  @override
  String get supportFaqSectionTitle => 'Frequently Asked Questions';

  @override
  String get supportDirectChannelsTitle => 'Direct Channels';

  @override
  String get supportEmailTitle => 'Email Support';

  @override
  String get supportEmailDisplay => 'yourname@gmail.com';

  @override
  String get supportCallTitle => 'Call Support';

  @override
  String get supportPhoneDisplay => '+91 9898989898';

  @override
  String get supportEmailCopied => 'Email address copied';

  @override
  String get supportPhoneCopied => 'Phone number copied';

  @override
  String get supportFaqTrackQuestion => 'How to track my shipment?';

  @override
  String get supportFaqTrackAnswer =>
      'Open the Shipments tab, select your active shipment, and tap Track to see live status updates from pickup through delivery.';

  @override
  String get supportFaqChargesQuestion => 'What are the delivery charges?';

  @override
  String get supportFaqChargesAnswer =>
      'Charges depend on distance, vehicle type, and load weight. You will see an estimated price before you confirm a booking.';

  @override
  String get supportFaqCancelQuestion => 'How to cancel a shipment?';

  @override
  String get supportFaqCancelAnswer =>
      'Go to Shipment Details while the trip is still pending and tap Cancel Shipment. Once a driver is assigned, contact support to request cancellation.';

  @override
  String get supportFaqCustomsQuestion =>
      'National customs documentation requirements?';

  @override
  String get supportFaqCustomsAnswer =>
      'Cross-border shipments may need an invoice, packing list, and HS codes. Our team will guide you on any extra documents required for your route.';

  @override
  String get shipmentEstimatedPay => 'Estimated Pay';

  @override
  String get shipmentStatusPublished => 'published';

  @override
  String shipmentViewInterest(int count) {
    return 'View Interest ($count)';
  }

  @override
  String get shipmentDetailsTitle => 'Shipment Details';

  @override
  String get customerTripDetailsTitle => 'Trip Details';

  @override
  String get customerReportTripQuestion => 'Report a trip?';

  @override
  String get customerReportIssueTitle => 'Report Issue';

  @override
  String get reportTripHeadline => 'Report this post';

  @override
  String get reportTripDescription =>
      'Help us understand the issue by selecting a reason';

  @override
  String get reportReasonSpam => 'Spam or misleading information';

  @override
  String get reportReasonIncorrect => 'Incorrect details';

  @override
  String get reportReasonFraud => 'Fraud or suspicious activity';

  @override
  String get reportReasonInappropriate => 'Inappropriate content';

  @override
  String get reportReasonNotAvailable => 'Already completed / not available';

  @override
  String get reportReasonOther => 'Other';

  @override
  String get reportTripDetailsHint => 'Describe the issue';

  @override
  String get reportTripSubmit => 'Report';

  @override
  String get reportTripStatusTitle => 'Report Status';

  @override
  String get reportTripSuccessTitle => 'Report Submitted';

  @override
  String get reportTripSuccessBody =>
      'Thank you for helping us improve the platform. Our team will review this report shortly.';

  @override
  String get reportIdLabel => 'REPORT ID';

  @override
  String get reportDateLabel => 'DATE';

  @override
  String get reportReviewTimeInfo => 'Average review time: 24 hours';

  @override
  String get customerTripEstimatedStartDate => 'Estimated start date';

  @override
  String get customerTripEstimatedEndDate => 'Estimated end date';

  @override
  String get customerTripEstimatedPrice => 'Estimated price';

  @override
  String get customerExpertDriver => 'Expert Driver';

  @override
  String get actionRequest => 'Request';

  @override
  String get customerShipmentPublishBadge => 'Publish';

  @override
  String get customerPaymentSummary => 'Payment summary';

  @override
  String get customerBaseFare => 'Base Fare';

  @override
  String get customerTotalAmount => 'Total Amount';

  @override
  String get customerCancelShipment => 'Cancel Shipment';

  @override
  String get shipmentRemoveTitle => 'Remove Shipment?';

  @override
  String shipmentRemoveBody(String shipmentId) {
    return 'This will remove shipment $shipmentId. This action cannot be undone.';
  }

  @override
  String get cancelShipmentHeadline => 'Precision Review Required';

  @override
  String get cancelShipmentDescription =>
      'Please select a reason for cancellation. This data helps our kinetic ledger optimize future logistics routes.';

  @override
  String get cancelShipmentReasonLegend => 'Reason for cancellation';

  @override
  String get cancelReasonChangeOfPlans => 'Change of plans';

  @override
  String get cancelReasonBetterPrice => 'Found a better price';

  @override
  String get cancelReasonDriverDelayed => 'Driver delayed';

  @override
  String get cancelReasonIncorrectDetails => 'Incorrect details entered';

  @override
  String get cancelReasonOther => 'Other';

  @override
  String get cancelShipmentCommentsLabel => 'Additional comments (optional)';

  @override
  String get cancelShipmentCommentsHint =>
      'Please provide any additional context regarding this cancellation...';

  @override
  String get cancelShipmentNoticeTitle => 'Notice';

  @override
  String get cancelShipmentNoticeBody =>
      'Cancellations processed after the 2-hour window may incur a handling fee. Review the Ledger Policies for more information.';

  @override
  String get cancelShipmentKeep => 'Keep Shipment';

  @override
  String get shipmentCancelSuccessTitle => 'Shipment Cancel Successfully';

  @override
  String shipmentCancelSuccessBody(String shipmentId) {
    return 'Your shipment has been cancel successfully your shipment id is #$shipmentId';
  }

  @override
  String get notificationNewBadge => 'NEW';

  @override
  String get tripPostNew => 'Post Trip';

  @override
  String get driverAddTripTitle => 'Add Trip';

  @override
  String get driverUpdateTripTitle => 'Update Trip';

  @override
  String get driverPublishTrip => 'Publish Trip';

  @override
  String get driverUpdateTrip => 'Update Trip';

  @override
  String get driverTripFormContext => 'Trip Details';

  @override
  String get driverTripFormHero => 'Set your route & load';

  @override
  String get driverTripFormRouteInfo => 'Route Information';

  @override
  String get driverTripFormFromLocation => 'From Location';

  @override
  String get driverTripFormToLocation => 'To Location';

  @override
  String get driverTripFormFromHint => 'Enter departure city';

  @override
  String get driverTripFormToHint => 'Enter destination city';

  @override
  String get driverTripFormSchedule => 'Schedule';

  @override
  String get driverTripFormEstStartDate => 'Est. Start Date';

  @override
  String get driverTripFormEstStartTime => 'Est. Start Time';

  @override
  String get driverTripFormEstEndDate => 'Est. End Date';

  @override
  String get driverTripFormEstEndTime => 'Est. End Time';

  @override
  String get driverTripFormVehicleCapacity => 'Vehicle & Capacity';

  @override
  String get driverTripFormVehicleCategory => 'Vehicle Category';

  @override
  String get driverTripFormLoadCapacity => 'Load Capacity';

  @override
  String get driverTripFormEstPrice => 'Est. Price';

  @override
  String get driverTripFormDriverInfo => 'Driver Info';

  @override
  String get driverTripFormDriverName => 'Driver Name';

  @override
  String get driverTripFormDriverPhone => 'Driver Phone';

  @override
  String get driverTripFormDriverNameHint => 'E.g Vikram singh R';

  @override
  String get driverTripFormVehicleRequired =>
      'Please select a vehicle category';

  @override
  String get driverTripFormScheduleRequired =>
      'Please select start and end schedule';

  @override
  String get driverTripFormEndBeforeStart =>
      'End schedule must be after start schedule';

  @override
  String get driverTripFormCapacityRequired => 'Enter a valid load capacity';

  @override
  String get driverTripFormPriceRequired => 'Enter a valid estimated price';

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
  String get customerEmptyShipmentsTitle => 'No Active Shipments';

  @override
  String get customerEmptyShipmentsDescription =>
      'You haven\'t posted any requirements yet. Start by adding your first shipment to experience precision tracking.';

  @override
  String get emptyTrips => 'No trips yet';

  @override
  String get emptyTripsSubtitle =>
      'Post your available route to receive shipment requests';

  @override
  String get driverEmptyTripsTitle => 'No Active Trip';

  @override
  String get driverEmptyTripsDescription =>
      'You haven\'t posted any requirements yet. Start by adding your first Trip to experience precision tracking.';

  @override
  String get emptyNotifications => 'No notifications';

  @override
  String get emptyHistory => 'No history found';

  @override
  String get customerHomeNoMatchingShipments =>
      'No shipments match your filters';

  @override
  String get customerHomeNoMatchingShipmentsHint =>
      'Try a different vehicle type or clear filters to see all trips';

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
  String get customerSettingsNotificationsSection => 'Notifications';

  @override
  String get customerSettingsPushNotifications => 'Push Notifications';

  @override
  String get customerSettingsPushNotificationsSub =>
      'Real-time shipment updates';

  @override
  String get customerSettingsLanguageSection => 'Language setting';

  @override
  String get customerSettingsChooseLanguage => 'Choose Language';

  @override
  String get customerSettingsLegalSection => 'Legal & About';

  @override
  String get customerSettingsAboutApp => 'About Good Carrier';

  @override
  String get customerSettingsVersionFooter => 'GOOD CARRIER V4.2.0-STABLE';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }
}
