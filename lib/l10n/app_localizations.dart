import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
    Locale('hi')
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Goods Carrier'**
  String get appName;

  /// App tagline on splash/onboarding
  ///
  /// In en, this message translates to:
  /// **'Logistics made simple'**
  String get appTagline;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get actionSubmit;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get actionSelect;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get actionYes;

  /// No description provided for @actionNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get actionNo;

  /// No description provided for @actionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get actionNext;

  /// No description provided for @actionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actionSkip;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// No description provided for @actionSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get actionSearch;

  /// No description provided for @actionFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get actionFilter;

  /// No description provided for @actionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actionShare;

  /// No description provided for @actionCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get actionCopy;

  /// Generic loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get labelLoading;

  /// No description provided for @labelError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get labelError;

  /// No description provided for @labelNoData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get labelNoData;

  /// No description provided for @labelOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get labelOptional;

  /// No description provided for @labelRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get labelRequired;

  /// No description provided for @labelToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get labelToday;

  /// No description provided for @labelYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get labelYesterday;

  /// No description provided for @labelAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get labelAll;

  /// No description provided for @labelNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get labelNew;

  /// Generic required field message
  ///
  /// In en, this message translates to:
  /// **'{fieldName} is required'**
  String validationFieldRequired(String fieldName);

  /// No description provided for @validationPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get validationPhoneRequired;

  /// No description provided for @validationPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit mobile number'**
  String get validationPhoneInvalid;

  /// No description provided for @validationGstRequired.
  ///
  /// In en, this message translates to:
  /// **'GST number is required'**
  String get validationGstRequired;

  /// No description provided for @validationGstInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid GST number (e.g. 27AABCS1429B1ZB)'**
  String get validationGstInvalid;

  /// No description provided for @validationVehicleRequired.
  ///
  /// In en, this message translates to:
  /// **'Vehicle number is required'**
  String get validationVehicleRequired;

  /// No description provided for @validationVehicleInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid vehicle number (e.g. MH02CC4156)'**
  String get validationVehicleInvalid;

  /// No description provided for @validationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get validationEmailInvalid;

  /// No description provided for @validationOtpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter the 4-digit OTP'**
  String get validationOtpInvalid;

  /// No description provided for @validationOtpDigitsOnly.
  ///
  /// In en, this message translates to:
  /// **'OTP must be 4 digits'**
  String get validationOtpDigitsOnly;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusInterestReceived.
  ///
  /// In en, this message translates to:
  /// **'Interest Received'**
  String get statusInterestReceived;

  /// No description provided for @statusAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get statusAssigned;

  /// No description provided for @statusInTransit.
  ///
  /// In en, this message translates to:
  /// **'In Transit'**
  String get statusInTransit;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @tripStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get tripStatusActive;

  /// No description provided for @tripStatusPendingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Pending Confirmation'**
  String get tripStatusPendingConfirmation;

  /// No description provided for @tripStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get tripStatusConfirmed;

  /// No description provided for @tripStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get tripStatusCompleted;

  /// No description provided for @tripStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get tripStatusCancelled;

  /// No description provided for @vehicleMini.
  ///
  /// In en, this message translates to:
  /// **'Mini'**
  String get vehicleMini;

  /// No description provided for @vehicleMiniCapacity.
  ///
  /// In en, this message translates to:
  /// **'Up to 500 KG'**
  String get vehicleMiniCapacity;

  /// No description provided for @vehiclePickupTruck.
  ///
  /// In en, this message translates to:
  /// **'Pickup Truck'**
  String get vehiclePickupTruck;

  /// No description provided for @vehiclePickupTruckCapacity.
  ///
  /// In en, this message translates to:
  /// **'Up to 1.5 Ton'**
  String get vehiclePickupTruckCapacity;

  /// No description provided for @vehicleTruck.
  ///
  /// In en, this message translates to:
  /// **'Truck'**
  String get vehicleTruck;

  /// No description provided for @vehicleTruckCapacity.
  ///
  /// In en, this message translates to:
  /// **'Up to 5 Ton'**
  String get vehicleTruckCapacity;

  /// No description provided for @vehicleHeavyDuty.
  ///
  /// In en, this message translates to:
  /// **'Heavy Duty'**
  String get vehicleHeavyDuty;

  /// No description provided for @vehicleHeavyDutyCapacity.
  ///
  /// In en, this message translates to:
  /// **'Up to 20 Ton'**
  String get vehicleHeavyDutyCapacity;

  /// No description provided for @authWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Goods Carrier'**
  String get authWelcome;

  /// No description provided for @authLoginBrandLine.
  ///
  /// In en, this message translates to:
  /// **'YOUR LOGISTICS PARTNER'**
  String get authLoginBrandLine;

  /// No description provided for @authLoginHeadline.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the Marketplace'**
  String get authLoginHeadline;

  /// No description provided for @authCountryCodeInd.
  ///
  /// In en, this message translates to:
  /// **'IND  +91'**
  String get authCountryCodeInd;

  /// No description provided for @authPhoneDigitsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'000-000-0000'**
  String get authPhoneDigitsPlaceholder;

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your trusted logistics partner'**
  String get authSubtitle;

  /// No description provided for @authPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get authPhoneLabel;

  /// No description provided for @authPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+91 XXXXX XXXXX'**
  String get authPhoneHint;

  /// No description provided for @authSendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get authSendOtp;

  /// No description provided for @authVerifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get authVerifyOtp;

  /// No description provided for @authResendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get authResendOtp;

  /// No description provided for @authResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String authResendIn(int seconds);

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to receive a secure login code.'**
  String get authLoginSubtitle;

  /// No description provided for @authPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get authPrivacyPolicy;

  /// No description provided for @authHelpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get authHelpCenter;

  /// No description provided for @authFeatureVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verified Carriers'**
  String get authFeatureVerifiedTitle;

  /// No description provided for @authFeatureVerifiedDesc.
  ///
  /// In en, this message translates to:
  /// **'Join 50,000+ trusted logistics professionals.'**
  String get authFeatureVerifiedDesc;

  /// No description provided for @authFeatureSecureTitle.
  ///
  /// In en, this message translates to:
  /// **'Secure Payments'**
  String get authFeatureSecureTitle;

  /// No description provided for @authFeatureSecureDesc.
  ///
  /// In en, this message translates to:
  /// **'Encrypted transactions and reliable escrow.'**
  String get authFeatureSecureDesc;

  /// No description provided for @authIAmCustomer.
  ///
  /// In en, this message translates to:
  /// **'I\'m a Customer'**
  String get authIAmCustomer;

  /// No description provided for @authIAmDriver.
  ///
  /// In en, this message translates to:
  /// **'I\'m a Driver'**
  String get authIAmDriver;

  /// No description provided for @authTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our '**
  String get authTermsPrefix;

  /// No description provided for @authTermsLink.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get authTermsLink;

  /// No description provided for @authOtpSentTo.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to {phone}'**
  String authOtpSentTo(String phone);

  /// No description provided for @roleCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get roleCustomer;

  /// No description provided for @roleDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get roleDriver;

  /// Heading on the language selection screen
  ///
  /// In en, this message translates to:
  /// **'Select Your Language'**
  String get langSelectionTitle;

  /// Subtitle on the language selection screen
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language to continue'**
  String get langSelectionSubtitle;

  /// No description provided for @langEnglishName.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglishName;

  /// No description provided for @langEnglishSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Primary language'**
  String get langEnglishSubtitle;

  /// No description provided for @langHindiName.
  ///
  /// In en, this message translates to:
  /// **'Hindi (हिन्दी)'**
  String get langHindiName;

  /// No description provided for @langHindiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Standard Hindi'**
  String get langHindiSubtitle;

  /// No description provided for @langGujaratiName.
  ///
  /// In en, this message translates to:
  /// **'Gujarati (ગુજરાતી)'**
  String get langGujaratiName;

  /// No description provided for @langGujaratiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Regional Gujarati'**
  String get langGujaratiSubtitle;

  /// Heading on the role selection screen
  ///
  /// In en, this message translates to:
  /// **'Choose Your Role'**
  String get roleSelectionTitle;

  /// Subtitle on the role selection screen
  ///
  /// In en, this message translates to:
  /// **'Select how you\'d like to use the Goods Carrier platform to manage your logistics.'**
  String get roleSelectionSubtitle;

  /// Card title for the customer role
  ///
  /// In en, this message translates to:
  /// **'Customer / Send Goods'**
  String get roleCustomerTitle;

  /// Card description for the customer role
  ///
  /// In en, this message translates to:
  /// **'Find transport easily. Ship anything from small parcels to full containers globally.'**
  String get roleCustomerDescription;

  /// Card title for the driver role
  ///
  /// In en, this message translates to:
  /// **'Driver / Transporter'**
  String get roleDriverTitle;

  /// Card description for the driver role
  ///
  /// In en, this message translates to:
  /// **'List trips and earn. Connect with businesses needing reliable transport solutions.'**
  String get roleDriverDescription;

  /// Progress label on the splash screen
  ///
  /// In en, this message translates to:
  /// **'SYSTEM INITIALIZING'**
  String get splashInitializing;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get profileName;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get profileEmail;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get profilePhone;

  /// No description provided for @profileCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get profileCompanyName;

  /// No description provided for @profileGstNumber.
  ///
  /// In en, this message translates to:
  /// **'GST Number'**
  String get profileGstNumber;

  /// No description provided for @profileGstNumberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 27AABCS1429B1ZB'**
  String get profileGstNumberHint;

  /// No description provided for @profileBusinessEmail.
  ///
  /// In en, this message translates to:
  /// **'Business Email'**
  String get profileBusinessEmail;

  /// No description provided for @profileVehicleNumber.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Number'**
  String get profileVehicleNumber;

  /// No description provided for @profileVehicleNumberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. MH 02 CC 4156'**
  String get profileVehicleNumberHint;

  /// No description provided for @profileVehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get profileVehicleType;

  /// No description provided for @profileLoadCapacity.
  ///
  /// In en, this message translates to:
  /// **'Load Capacity (Tons)'**
  String get profileLoadCapacity;

  /// No description provided for @profileSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get profileSetupTitle;

  /// No description provided for @profileSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get you started'**
  String get profileSetupSubtitle;

  /// No description provided for @shipmentPickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup Location'**
  String get shipmentPickup;

  /// No description provided for @shipmentPickupCity.
  ///
  /// In en, this message translates to:
  /// **'Pickup City'**
  String get shipmentPickupCity;

  /// No description provided for @shipmentDrop.
  ///
  /// In en, this message translates to:
  /// **'Drop Location'**
  String get shipmentDrop;

  /// No description provided for @shipmentDropCity.
  ///
  /// In en, this message translates to:
  /// **'Drop City'**
  String get shipmentDropCity;

  /// No description provided for @shipmentGoods.
  ///
  /// In en, this message translates to:
  /// **'Goods Details'**
  String get shipmentGoods;

  /// No description provided for @shipmentGoodsType.
  ///
  /// In en, this message translates to:
  /// **'Goods Type'**
  String get shipmentGoodsType;

  /// No description provided for @shipmentWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get shipmentWeight;

  /// No description provided for @shipmentDate.
  ///
  /// In en, this message translates to:
  /// **'Shipment Date'**
  String get shipmentDate;

  /// No description provided for @shipmentPrice.
  ///
  /// In en, this message translates to:
  /// **'Estimated Price'**
  String get shipmentPrice;

  /// No description provided for @shipmentPostNew.
  ///
  /// In en, this message translates to:
  /// **'Post Shipment'**
  String get shipmentPostNew;

  /// No description provided for @shipmentFragile.
  ///
  /// In en, this message translates to:
  /// **'Fragile Goods'**
  String get shipmentFragile;

  /// No description provided for @shipmentFragileWarning.
  ///
  /// In en, this message translates to:
  /// **'Handle with care — fragile goods'**
  String get shipmentFragileWarning;

  /// No description provided for @shipmentSpecialInstructions.
  ///
  /// In en, this message translates to:
  /// **'Special Instructions'**
  String get shipmentSpecialInstructions;

  /// No description provided for @shipmentSpecialInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'Any special handling requirements...'**
  String get shipmentSpecialInstructionsHint;

  /// No description provided for @shipmentInterestedDrivers.
  ///
  /// In en, this message translates to:
  /// **'Interested Drivers'**
  String get shipmentInterestedDrivers;

  /// No description provided for @shipmentSelectDriver.
  ///
  /// In en, this message translates to:
  /// **'Select Driver'**
  String get shipmentSelectDriver;

  /// No description provided for @shipmentNoDriversYet.
  ///
  /// In en, this message translates to:
  /// **'No drivers have shown interest yet'**
  String get shipmentNoDriversYet;

  /// No description provided for @shipmentId.
  ///
  /// In en, this message translates to:
  /// **'Shipment ID'**
  String get shipmentId;

  /// No description provided for @shipmentActiveCount.
  ///
  /// In en, this message translates to:
  /// **'{count} active shipment(s)'**
  String shipmentActiveCount(int count);

  /// No description provided for @tripPostNew.
  ///
  /// In en, this message translates to:
  /// **'Post Trip'**
  String get tripPostNew;

  /// No description provided for @tripFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get tripFrom;

  /// No description provided for @tripTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get tripTo;

  /// No description provided for @tripDate.
  ///
  /// In en, this message translates to:
  /// **'Trip Date'**
  String get tripDate;

  /// No description provided for @tripCapacity.
  ///
  /// In en, this message translates to:
  /// **'Load Capacity'**
  String get tripCapacity;

  /// No description provided for @tripVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get tripVehicle;

  /// No description provided for @tripId.
  ///
  /// In en, this message translates to:
  /// **'Trip ID'**
  String get tripId;

  /// No description provided for @tripExpressInterest.
  ///
  /// In en, this message translates to:
  /// **'Express Interest'**
  String get tripExpressInterest;

  /// No description provided for @tripInterestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Interest submitted'**
  String get tripInterestSubmitted;

  /// No description provided for @tripPrice.
  ///
  /// In en, this message translates to:
  /// **'Your Quote (₹)'**
  String get tripPrice;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notificationMarkAllRead;

  /// No description provided for @notificationNoNew.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get notificationNoNew;

  /// No description provided for @emptyShipments.
  ///
  /// In en, this message translates to:
  /// **'No shipments yet'**
  String get emptyShipments;

  /// No description provided for @emptyShipmentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Post your first shipment to get started'**
  String get emptyShipmentsSubtitle;

  /// No description provided for @emptyTrips.
  ///
  /// In en, this message translates to:
  /// **'No trips yet'**
  String get emptyTrips;

  /// No description provided for @emptyTripsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Post your available route to receive shipment requests'**
  String get emptyTripsSubtitle;

  /// No description provided for @emptyNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get emptyNotifications;

  /// No description provided for @emptyHistory.
  ///
  /// In en, this message translates to:
  /// **'No history found'**
  String get emptyHistory;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get errorNetwork;

  /// No description provided for @errorNetworkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and retry'**
  String get errorNetworkSubtitle;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please retry.'**
  String get errorTimeout;

  /// No description provided for @errorUnauthorised.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please login again.'**
  String get errorUnauthorised;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settingsThemeSystem;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageHindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get settingsLanguageHindi;

  /// No description provided for @settingsLanguageGujarati.
  ///
  /// In en, this message translates to:
  /// **'ગુજરાતી'**
  String get settingsLanguageGujarati;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get settingsLogoutConfirm;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(String version);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'gu', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
