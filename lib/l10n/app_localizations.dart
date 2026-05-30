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
  /// **'Phone Number'**
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

  /// No description provided for @authVerifyNumberTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Number'**
  String get authVerifyNumberTitle;

  /// No description provided for @authEnterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get authEnterOtp;

  /// No description provided for @authOtpCodeSentPrefix.
  ///
  /// In en, this message translates to:
  /// **'Enter the 4-digit code sent to'**
  String get authOtpCodeSentPrefix;

  /// No description provided for @authVerifyAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Verify & Continue'**
  String get authVerifyAndContinue;

  /// No description provided for @authResendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get authResendOtp;

  /// No description provided for @authResendSms.
  ///
  /// In en, this message translates to:
  /// **'Resend SMS'**
  String get authResendSms;

  /// No description provided for @authResendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in'**
  String get authResendCodeIn;

  /// No description provided for @authResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String authResendIn(int seconds);

  /// No description provided for @authHavingTrouble.
  ///
  /// In en, this message translates to:
  /// **'Having trouble? '**
  String get authHavingTrouble;

  /// No description provided for @authNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Need Help'**
  String get authNeedHelp;

  /// No description provided for @authEncryptedVerification.
  ///
  /// In en, this message translates to:
  /// **'END-TO-END ENCRYPTED VERIFICATION'**
  String get authEncryptedVerification;

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

  /// No description provided for @profileEmailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email Address (Optional)'**
  String get profileEmailOptional;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get profilePhone;

  /// No description provided for @profilePrimaryAddress.
  ///
  /// In en, this message translates to:
  /// **'Primary Address'**
  String get profilePrimaryAddress;

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
  /// **'Create Your Profile'**
  String get profileSetupTitle;

  /// No description provided for @profileSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get started'**
  String get profileSetupSubtitle;

  /// No description provided for @profileCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get profileCreateButton;

  /// No description provided for @profilePhotoPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhotoPickerTitle;

  /// No description provided for @profilePhotoTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get profilePhotoTakePhoto;

  /// No description provided for @profilePhotoChooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get profilePhotoChooseGallery;

  /// No description provided for @profilePhotoCameraPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera access is required to take a profile photo. Please allow camera access in Settings.'**
  String get profilePhotoCameraPermissionDenied;

  /// No description provided for @profilePhotoGalleryPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Photo library access is required to choose a profile photo. Please allow photo access in Settings.'**
  String get profilePhotoGalleryPermissionDenied;

  /// No description provided for @profilePhotoLimitedTitle.
  ///
  /// In en, this message translates to:
  /// **'Limited photo access'**
  String get profilePhotoLimitedTitle;

  /// No description provided for @profilePhotoLimitedMessage.
  ///
  /// In en, this message translates to:
  /// **'You have allowed access to only selected photos. To browse your full gallery, allow full photo access in Settings.'**
  String get profilePhotoLimitedMessage;

  /// No description provided for @profilePhotoAllowFullAccess.
  ///
  /// In en, this message translates to:
  /// **'Allow full access'**
  String get profilePhotoAllowFullAccess;

  /// No description provided for @profilePhotoContinueWithLimited.
  ///
  /// In en, this message translates to:
  /// **'Continue with selected photos'**
  String get profilePhotoContinueWithLimited;

  /// No description provided for @actionOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get actionOpenSettings;

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

  /// No description provided for @shipmentPostConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get shipmentPostConfirmationTitle;

  /// No description provided for @shipmentPostSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipment Post Successfully'**
  String get shipmentPostSuccessTitle;

  /// No description provided for @shipmentPostSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Your shipment has been post successfully your shipment id is #{shipmentId}'**
  String shipmentPostSuccessBody(String shipmentId);

  /// No description provided for @shipmentPostBackToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get shipmentPostBackToHome;

  /// No description provided for @shipmentPostDateLabel.
  ///
  /// In en, this message translates to:
  /// **'DATE'**
  String get shipmentPostDateLabel;

  /// No description provided for @shipmentPostTotalPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'TOTAL PRICE'**
  String get shipmentPostTotalPriceLabel;

  /// No description provided for @shipmentEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Shipment'**
  String get shipmentEditTitle;

  /// No description provided for @shipmentUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update Shipment'**
  String get shipmentUpdate;

  /// No description provided for @shipmentFormPrecisionLogistics.
  ///
  /// In en, this message translates to:
  /// **'Precision Logistics'**
  String get shipmentFormPrecisionLogistics;

  /// No description provided for @shipmentFormHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Where is your cargo heading?'**
  String get shipmentFormHeroTitle;

  /// No description provided for @shipmentFormHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in the details below to get instant bids from verified carriers.'**
  String get shipmentFormHeroSubtitle;

  /// No description provided for @shipmentFormFromHint.
  ///
  /// In en, this message translates to:
  /// **'Enter origin city or warehouse'**
  String get shipmentFormFromHint;

  /// No description provided for @shipmentFormToHint.
  ///
  /// In en, this message translates to:
  /// **'Enter destination address'**
  String get shipmentFormToHint;

  /// No description provided for @shipmentFormVehicleRequirement.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Requirement'**
  String get shipmentFormVehicleRequirement;

  /// No description provided for @shipmentFormEstWeight.
  ///
  /// In en, this message translates to:
  /// **'Est. Weight'**
  String get shipmentFormEstWeight;

  /// No description provided for @shipmentFormEstWeightType.
  ///
  /// In en, this message translates to:
  /// **'Est. Weight Type'**
  String get shipmentFormEstWeightType;

  /// No description provided for @shipmentFormPickupDate.
  ///
  /// In en, this message translates to:
  /// **'Preferred Pickup Date'**
  String get shipmentFormPickupDate;

  /// No description provided for @shipmentFormPickupTime.
  ///
  /// In en, this message translates to:
  /// **'Preferred Pickup Time'**
  String get shipmentFormPickupTime;

  /// No description provided for @shipmentFormYourBudget.
  ///
  /// In en, this message translates to:
  /// **'Your Budget'**
  String get shipmentFormYourBudget;

  /// No description provided for @shipmentFormBudgetHint.
  ///
  /// In en, this message translates to:
  /// **'Enter target price'**
  String get shipmentFormBudgetHint;

  /// No description provided for @shipmentFormCommentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Additional Comments (Optional)'**
  String get shipmentFormCommentsLabel;

  /// No description provided for @shipmentFormCommentsHint.
  ///
  /// In en, this message translates to:
  /// **'Please provide any additional context regarding this shipment'**
  String get shipmentFormCommentsHint;

  /// No description provided for @shipmentFormTerms.
  ///
  /// In en, this message translates to:
  /// **'You have successfully agreed to our Terms & Conditions.'**
  String get shipmentFormTerms;

  /// No description provided for @shipmentFormVehicleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a vehicle requirement'**
  String get shipmentFormVehicleRequired;

  /// No description provided for @shipmentFormScheduleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select pickup date and time'**
  String get shipmentFormScheduleRequired;

  /// No description provided for @shipmentFormTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please accept the Terms & Conditions'**
  String get shipmentFormTermsRequired;

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

  /// No description provided for @customerHomeBrandTitle.
  ///
  /// In en, this message translates to:
  /// **'Good Carrier'**
  String get customerHomeBrandTitle;

  /// No description provided for @customerHomeDriverTrips.
  ///
  /// In en, this message translates to:
  /// **'Driver Trips'**
  String get customerHomeDriverTrips;

  /// No description provided for @customerHomeInterestBadge.
  ///
  /// In en, this message translates to:
  /// **'YOUR ARE IN INTEREST'**
  String get customerHomeInterestBadge;

  /// No description provided for @customerHomeEstStartDate.
  ///
  /// In en, this message translates to:
  /// **'estimated start date'**
  String get customerHomeEstStartDate;

  /// No description provided for @customerHomeEstEndDate.
  ///
  /// In en, this message translates to:
  /// **'estimated end date'**
  String get customerHomeEstEndDate;

  /// No description provided for @customerHomeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by destination or vehicle'**
  String get customerHomeSearchHint;

  /// No description provided for @customerHomeActiveShipments.
  ///
  /// In en, this message translates to:
  /// **'{count} Active shipments'**
  String customerHomeActiveShipments(int count);

  /// No description provided for @customerHomeYourShipments.
  ///
  /// In en, this message translates to:
  /// **'Your Shipments'**
  String get customerHomeYourShipments;

  /// No description provided for @customerNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get customerNavHome;

  /// No description provided for @customerNavShipments.
  ///
  /// In en, this message translates to:
  /// **'Shipment'**
  String get customerNavShipments;

  /// No description provided for @customerNavNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get customerNavNotifications;

  /// No description provided for @customerNavProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get customerNavProfile;

  /// No description provided for @actionViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get actionViewDetails;

  /// No description provided for @customerHomeFilterSoon.
  ///
  /// In en, this message translates to:
  /// **'Advanced filters are coming soon'**
  String get customerHomeFilterSoon;

  /// No description provided for @filterSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter Search'**
  String get filterSearchTitle;

  /// No description provided for @filterClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get filterClearAll;

  /// No description provided for @filterRouteDetails.
  ///
  /// In en, this message translates to:
  /// **'Route Details'**
  String get filterRouteDetails;

  /// No description provided for @filterFromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get filterFromLabel;

  /// No description provided for @filterFromHint.
  ///
  /// In en, this message translates to:
  /// **'Enter origin city'**
  String get filterFromHint;

  /// No description provided for @filterToLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get filterToLabel;

  /// No description provided for @filterToHint.
  ///
  /// In en, this message translates to:
  /// **'Enter destination'**
  String get filterToHint;

  /// No description provided for @filterPickupDate.
  ///
  /// In en, this message translates to:
  /// **'Pickup Date'**
  String get filterPickupDate;

  /// No description provided for @filterCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get filterCalendar;

  /// No description provided for @filterToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get filterToday;

  /// No description provided for @filterVehicleClass.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Class'**
  String get filterVehicleClass;

  /// No description provided for @filterLoadCapacity.
  ///
  /// In en, this message translates to:
  /// **'Load Capacity'**
  String get filterLoadCapacity;

  /// No description provided for @filterApply.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get filterApply;

  /// No description provided for @customerMyShipment.
  ///
  /// In en, this message translates to:
  /// **'My Shipment'**
  String get customerMyShipment;

  /// No description provided for @customerMyProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get customerMyProfile;

  /// No description provided for @customerRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customerRoleLabel;

  /// No description provided for @customerAccountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get customerAccountSettings;

  /// No description provided for @customerEditPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit Personal Information'**
  String get customerEditPersonalInfo;

  /// No description provided for @customerEditPersonalInfoSub.
  ///
  /// In en, this message translates to:
  /// **'Name, Email, Phone'**
  String get customerEditPersonalInfoSub;

  /// No description provided for @customerEditProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Your Profile'**
  String get customerEditProfileTitle;

  /// No description provided for @customerUpdateProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get customerUpdateProfileButton;

  /// No description provided for @customerDefaultShippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Default Shipping Address'**
  String get customerDefaultShippingAddress;

  /// No description provided for @customerAddressNotSet.
  ///
  /// In en, this message translates to:
  /// **'Add your shipping address'**
  String get customerAddressNotSet;

  /// No description provided for @customerEditAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Address'**
  String get customerEditAddressTitle;

  /// No description provided for @customerSavedAddresses.
  ///
  /// In en, this message translates to:
  /// **'Saved Addresses'**
  String get customerSavedAddresses;

  /// No description provided for @customerSavedAddressesSub.
  ///
  /// In en, this message translates to:
  /// **'Home, Office & others'**
  String get customerSavedAddressesSub;

  /// No description provided for @customerSavedLocationsSection.
  ///
  /// In en, this message translates to:
  /// **'SAVED LOCATIONS'**
  String get customerSavedLocationsSection;

  /// No description provided for @customerAddAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Address'**
  String get customerAddAddressTitle;

  /// No description provided for @customerEditAddressScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Address'**
  String get customerEditAddressScreenTitle;

  /// No description provided for @customerSelectAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'SELECT ADDRESS LABEL'**
  String get customerSelectAddressLabel;

  /// No description provided for @customerAddressLabelHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get customerAddressLabelHome;

  /// No description provided for @customerAddressLabelOffice.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get customerAddressLabelOffice;

  /// No description provided for @customerAddressLabelOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get customerAddressLabelOther;

  /// No description provided for @customerAddressFullLine.
  ///
  /// In en, this message translates to:
  /// **'Full Address Line'**
  String get customerAddressFullLine;

  /// No description provided for @customerAddressFullLineHint.
  ///
  /// In en, this message translates to:
  /// **'House No, Street Name, Area'**
  String get customerAddressFullLineHint;

  /// No description provided for @customerAddressCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get customerAddressCity;

  /// No description provided for @customerAddressCityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. San Francisco'**
  String get customerAddressCityHint;

  /// No description provided for @customerAddressPincode.
  ///
  /// In en, this message translates to:
  /// **'Pincode'**
  String get customerAddressPincode;

  /// No description provided for @customerAddressPincodeHint.
  ///
  /// In en, this message translates to:
  /// **'Zip Code'**
  String get customerAddressPincodeHint;

  /// No description provided for @customerAddressLandmark.
  ///
  /// In en, this message translates to:
  /// **'Landmark (Optional)'**
  String get customerAddressLandmark;

  /// No description provided for @customerAddressLandmarkHint.
  ///
  /// In en, this message translates to:
  /// **'Near by famous place'**
  String get customerAddressLandmarkHint;

  /// No description provided for @customerAddressLandmarkTip.
  ///
  /// In en, this message translates to:
  /// **'Providing an accurate landmark helps our delivery partners find your location 30% faster.'**
  String get customerAddressLandmarkTip;

  /// No description provided for @customerSaveAddress.
  ///
  /// In en, this message translates to:
  /// **'Save Address'**
  String get customerSaveAddress;

  /// No description provided for @customerAddressSaved.
  ///
  /// In en, this message translates to:
  /// **'Address saved'**
  String get customerAddressSaved;

  /// No description provided for @customerLocationPermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to show your current position.'**
  String get customerLocationPermissionNeeded;

  /// No description provided for @customerReportedTrips.
  ///
  /// In en, this message translates to:
  /// **'Reported Trips'**
  String get customerReportedTrips;

  /// No description provided for @customerReportedTripsSub.
  ///
  /// In en, this message translates to:
  /// **'Show reported trips'**
  String get customerReportedTripsSub;

  /// No description provided for @customerReportedByYouBadge.
  ///
  /// In en, this message translates to:
  /// **'REPORTED BY YOU'**
  String get customerReportedByYouBadge;

  /// No description provided for @customerEstimatedPrice.
  ///
  /// In en, this message translates to:
  /// **'Estimated Price'**
  String get customerEstimatedPrice;

  /// No description provided for @customerActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get customerActivity;

  /// No description provided for @customerSettingsSub.
  ///
  /// In en, this message translates to:
  /// **'Push notification, Privacy Policy'**
  String get customerSettingsSub;

  /// No description provided for @customerHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get customerHelpSupport;

  /// No description provided for @customerHelpSupportSub.
  ///
  /// In en, this message translates to:
  /// **'FAQs and more'**
  String get customerHelpSupportSub;

  /// No description provided for @supportCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Support Center'**
  String get supportCenterTitle;

  /// No description provided for @supportFaqSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get supportFaqSectionTitle;

  /// No description provided for @supportDirectChannelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Direct Channels'**
  String get supportDirectChannelsTitle;

  /// No description provided for @supportEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get supportEmailTitle;

  /// No description provided for @supportEmailDisplay.
  ///
  /// In en, this message translates to:
  /// **'yourname@gmail.com'**
  String get supportEmailDisplay;

  /// No description provided for @supportCallTitle.
  ///
  /// In en, this message translates to:
  /// **'Call Support'**
  String get supportCallTitle;

  /// No description provided for @supportPhoneDisplay.
  ///
  /// In en, this message translates to:
  /// **'+91 9898989898'**
  String get supportPhoneDisplay;

  /// No description provided for @supportEmailCopied.
  ///
  /// In en, this message translates to:
  /// **'Email address copied'**
  String get supportEmailCopied;

  /// No description provided for @supportPhoneCopied.
  ///
  /// In en, this message translates to:
  /// **'Phone number copied'**
  String get supportPhoneCopied;

  /// No description provided for @supportFaqTrackQuestion.
  ///
  /// In en, this message translates to:
  /// **'How to track my shipment?'**
  String get supportFaqTrackQuestion;

  /// No description provided for @supportFaqTrackAnswer.
  ///
  /// In en, this message translates to:
  /// **'Open the Shipments tab, select your active shipment, and tap Track to see live status updates from pickup through delivery.'**
  String get supportFaqTrackAnswer;

  /// No description provided for @supportFaqChargesQuestion.
  ///
  /// In en, this message translates to:
  /// **'What are the delivery charges?'**
  String get supportFaqChargesQuestion;

  /// No description provided for @supportFaqChargesAnswer.
  ///
  /// In en, this message translates to:
  /// **'Charges depend on distance, vehicle type, and load weight. You will see an estimated price before you confirm a booking.'**
  String get supportFaqChargesAnswer;

  /// No description provided for @supportFaqCancelQuestion.
  ///
  /// In en, this message translates to:
  /// **'How to cancel a shipment?'**
  String get supportFaqCancelQuestion;

  /// No description provided for @supportFaqCancelAnswer.
  ///
  /// In en, this message translates to:
  /// **'Go to Shipment Details while the trip is still pending and tap Cancel Shipment. Once a driver is assigned, contact support to request cancellation.'**
  String get supportFaqCancelAnswer;

  /// No description provided for @supportFaqCustomsQuestion.
  ///
  /// In en, this message translates to:
  /// **'National customs documentation requirements?'**
  String get supportFaqCustomsQuestion;

  /// No description provided for @supportFaqCustomsAnswer.
  ///
  /// In en, this message translates to:
  /// **'Cross-border shipments may need an invoice, packing list, and HS codes. Our team will guide you on any extra documents required for your route.'**
  String get supportFaqCustomsAnswer;

  /// No description provided for @shipmentEstimatedPay.
  ///
  /// In en, this message translates to:
  /// **'Estimated Pay'**
  String get shipmentEstimatedPay;

  /// No description provided for @shipmentStatusPublished.
  ///
  /// In en, this message translates to:
  /// **'published'**
  String get shipmentStatusPublished;

  /// No description provided for @shipmentViewInterest.
  ///
  /// In en, this message translates to:
  /// **'View Interest ({count})'**
  String shipmentViewInterest(int count);

  /// No description provided for @shipmentDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipment Details'**
  String get shipmentDetailsTitle;

  /// No description provided for @customerTripDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip Details'**
  String get customerTripDetailsTitle;

  /// No description provided for @customerReportTripQuestion.
  ///
  /// In en, this message translates to:
  /// **'Report a trip?'**
  String get customerReportTripQuestion;

  /// No description provided for @customerReportIssueTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get customerReportIssueTitle;

  /// No description provided for @reportTripHeadline.
  ///
  /// In en, this message translates to:
  /// **'Report this post'**
  String get reportTripHeadline;

  /// No description provided for @reportTripDescription.
  ///
  /// In en, this message translates to:
  /// **'Help us understand the issue by selecting a reason'**
  String get reportTripDescription;

  /// No description provided for @reportReasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam or misleading information'**
  String get reportReasonSpam;

  /// No description provided for @reportReasonIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect details'**
  String get reportReasonIncorrect;

  /// No description provided for @reportReasonFraud.
  ///
  /// In en, this message translates to:
  /// **'Fraud or suspicious activity'**
  String get reportReasonFraud;

  /// No description provided for @reportReasonInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get reportReasonInappropriate;

  /// No description provided for @reportReasonNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Already completed / not available'**
  String get reportReasonNotAvailable;

  /// No description provided for @reportReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reportReasonOther;

  /// No description provided for @reportTripDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue'**
  String get reportTripDetailsHint;

  /// No description provided for @reportTripSubmit.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportTripSubmit;

  /// No description provided for @reportTripStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Status'**
  String get reportTripStatusTitle;

  /// No description provided for @reportTripSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Submitted'**
  String get reportTripSuccessTitle;

  /// No description provided for @reportTripSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Thank you for helping us improve the platform. Our team will review this report shortly.'**
  String get reportTripSuccessBody;

  /// No description provided for @reportIdLabel.
  ///
  /// In en, this message translates to:
  /// **'REPORT ID'**
  String get reportIdLabel;

  /// No description provided for @reportDateLabel.
  ///
  /// In en, this message translates to:
  /// **'DATE'**
  String get reportDateLabel;

  /// No description provided for @reportReviewTimeInfo.
  ///
  /// In en, this message translates to:
  /// **'Average review time: 24 hours'**
  String get reportReviewTimeInfo;

  /// No description provided for @customerTripEstimatedStartDate.
  ///
  /// In en, this message translates to:
  /// **'Estimated start date'**
  String get customerTripEstimatedStartDate;

  /// No description provided for @customerTripEstimatedEndDate.
  ///
  /// In en, this message translates to:
  /// **'Estimated end date'**
  String get customerTripEstimatedEndDate;

  /// No description provided for @customerTripEstimatedPrice.
  ///
  /// In en, this message translates to:
  /// **'Estimated price'**
  String get customerTripEstimatedPrice;

  /// No description provided for @customerExpertDriver.
  ///
  /// In en, this message translates to:
  /// **'Expert Driver'**
  String get customerExpertDriver;

  /// No description provided for @actionRequest.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get actionRequest;

  /// No description provided for @customerShipmentPublishBadge.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get customerShipmentPublishBadge;

  /// No description provided for @customerPaymentSummary.
  ///
  /// In en, this message translates to:
  /// **'Payment summary'**
  String get customerPaymentSummary;

  /// No description provided for @customerBaseFare.
  ///
  /// In en, this message translates to:
  /// **'Base Fare'**
  String get customerBaseFare;

  /// No description provided for @customerTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get customerTotalAmount;

  /// No description provided for @customerCancelShipment.
  ///
  /// In en, this message translates to:
  /// **'Cancel Shipment'**
  String get customerCancelShipment;

  /// No description provided for @shipmentRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Shipment?'**
  String get shipmentRemoveTitle;

  /// No description provided for @shipmentRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'This will remove shipment {shipmentId}. This action cannot be undone.'**
  String shipmentRemoveBody(String shipmentId);

  /// No description provided for @cancelShipmentHeadline.
  ///
  /// In en, this message translates to:
  /// **'Precision Review Required'**
  String get cancelShipmentHeadline;

  /// No description provided for @cancelShipmentDescription.
  ///
  /// In en, this message translates to:
  /// **'Please select a reason for cancellation. This data helps our kinetic ledger optimize future logistics routes.'**
  String get cancelShipmentDescription;

  /// No description provided for @cancelShipmentReasonLegend.
  ///
  /// In en, this message translates to:
  /// **'Reason for cancellation'**
  String get cancelShipmentReasonLegend;

  /// No description provided for @cancelReasonChangeOfPlans.
  ///
  /// In en, this message translates to:
  /// **'Change of plans'**
  String get cancelReasonChangeOfPlans;

  /// No description provided for @cancelReasonBetterPrice.
  ///
  /// In en, this message translates to:
  /// **'Found a better price'**
  String get cancelReasonBetterPrice;

  /// No description provided for @cancelReasonDriverDelayed.
  ///
  /// In en, this message translates to:
  /// **'Driver delayed'**
  String get cancelReasonDriverDelayed;

  /// No description provided for @cancelReasonIncorrectDetails.
  ///
  /// In en, this message translates to:
  /// **'Incorrect details entered'**
  String get cancelReasonIncorrectDetails;

  /// No description provided for @cancelReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get cancelReasonOther;

  /// No description provided for @cancelShipmentCommentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Additional comments (optional)'**
  String get cancelShipmentCommentsLabel;

  /// No description provided for @cancelShipmentCommentsHint.
  ///
  /// In en, this message translates to:
  /// **'Please provide any additional context regarding this cancellation...'**
  String get cancelShipmentCommentsHint;

  /// No description provided for @cancelShipmentNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get cancelShipmentNoticeTitle;

  /// No description provided for @cancelShipmentNoticeBody.
  ///
  /// In en, this message translates to:
  /// **'Cancellations processed after the 2-hour window may incur a handling fee. Review the Ledger Policies for more information.'**
  String get cancelShipmentNoticeBody;

  /// No description provided for @cancelShipmentKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep Shipment'**
  String get cancelShipmentKeep;

  /// No description provided for @shipmentCancelSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipment Cancel Successfully'**
  String get shipmentCancelSuccessTitle;

  /// No description provided for @shipmentCancelSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Your shipment has been cancel successfully your shipment id is #{shipmentId}'**
  String shipmentCancelSuccessBody(String shipmentId);

  /// No description provided for @notificationNewBadge.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get notificationNewBadge;

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

  /// No description provided for @customerEmptyShipmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Active Shipments'**
  String get customerEmptyShipmentsTitle;

  /// No description provided for @customerEmptyShipmentsDescription.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t posted any requirements yet. Start by adding your first shipment to experience precision tracking.'**
  String get customerEmptyShipmentsDescription;

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

  /// No description provided for @customerHomeNoMatchingShipments.
  ///
  /// In en, this message translates to:
  /// **'No shipments match your filters'**
  String get customerHomeNoMatchingShipments;

  /// No description provided for @customerHomeNoMatchingShipmentsHint.
  ///
  /// In en, this message translates to:
  /// **'Try a different vehicle type or clear filters to see all trips'**
  String get customerHomeNoMatchingShipmentsHint;

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

  /// No description provided for @customerSettingsNotificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get customerSettingsNotificationsSection;

  /// No description provided for @customerSettingsPushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get customerSettingsPushNotifications;

  /// No description provided for @customerSettingsPushNotificationsSub.
  ///
  /// In en, this message translates to:
  /// **'Real-time shipment updates'**
  String get customerSettingsPushNotificationsSub;

  /// No description provided for @customerSettingsLanguageSection.
  ///
  /// In en, this message translates to:
  /// **'Language setting'**
  String get customerSettingsLanguageSection;

  /// No description provided for @customerSettingsChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get customerSettingsChooseLanguage;

  /// No description provided for @customerSettingsLegalSection.
  ///
  /// In en, this message translates to:
  /// **'Legal & About'**
  String get customerSettingsLegalSection;

  /// No description provided for @customerSettingsAboutApp.
  ///
  /// In en, this message translates to:
  /// **'About Good Carrier'**
  String get customerSettingsAboutApp;

  /// No description provided for @customerSettingsVersionFooter.
  ///
  /// In en, this message translates to:
  /// **'GOOD CARRIER V4.2.0-STABLE'**
  String get customerSettingsVersionFooter;

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
