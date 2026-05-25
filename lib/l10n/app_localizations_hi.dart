// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'गुड्स कैरियर';

  @override
  String get appTagline => 'लॉजिस्टिक्स को आसान बनाएं';

  @override
  String get actionSave => 'सहेजें';

  @override
  String get actionCancel => 'रद्द करें';

  @override
  String get actionConfirm => 'पुष्टि करें';

  @override
  String get actionContinue => 'जारी रखें';

  @override
  String get actionSubmit => 'जमा करें';

  @override
  String get actionBack => 'वापस';

  @override
  String get actionRetry => 'पुनः प्रयास';

  @override
  String get actionDone => 'हो गया';

  @override
  String get actionEdit => 'संपादित करें';

  @override
  String get actionDelete => 'हटाएं';

  @override
  String get actionSelect => 'चुनें';

  @override
  String get actionClose => 'बंद करें';

  @override
  String get actionYes => 'हाँ';

  @override
  String get actionNo => 'नहीं';

  @override
  String get actionNext => 'अगला';

  @override
  String get actionSkip => 'छोड़ें';

  @override
  String get actionAdd => 'जोड़ें';

  @override
  String get actionRemove => 'हटाएं';

  @override
  String get actionSearch => 'खोजें';

  @override
  String get actionFilter => 'फ़िल्टर';

  @override
  String get actionShare => 'साझा करें';

  @override
  String get actionCopy => 'कॉपी करें';

  @override
  String get labelLoading => 'लोड हो रहा है...';

  @override
  String get labelError => 'कुछ गलत हुआ';

  @override
  String get labelNoData => 'कोई डेटा उपलब्ध नहीं';

  @override
  String get labelOptional => 'वैकल्पिक';

  @override
  String get labelRequired => 'आवश्यक';

  @override
  String get labelToday => 'आज';

  @override
  String get labelYesterday => 'कल';

  @override
  String get labelAll => 'सभी';

  @override
  String get labelNew => 'नया';

  @override
  String validationFieldRequired(String fieldName) {
    return '$fieldName आवश्यक है';
  }

  @override
  String get validationPhoneRequired => 'फ़ोन नंबर आवश्यक है';

  @override
  String get validationPhoneInvalid => 'एक वैध 10-अंकीय मोबाइल नंबर दर्ज करें';

  @override
  String get validationGstRequired => 'GST नंबर आवश्यक है';

  @override
  String get validationGstInvalid =>
      'एक वैध GST नंबर दर्ज करें (जैसे 27AABCS1429B1ZB)';

  @override
  String get validationVehicleRequired => 'वाहन नंबर आवश्यक है';

  @override
  String get validationVehicleInvalid =>
      'एक वैध वाहन नंबर दर्ज करें (जैसे MH02CC4156)';

  @override
  String get validationEmailRequired => 'ईमेल आवश्यक है';

  @override
  String get validationEmailInvalid => 'एक वैध ईमेल पता दर्ज करें';

  @override
  String get validationOtpInvalid => '6-अंकीय OTP दर्ज करें';

  @override
  String get validationOtpDigitsOnly => 'OTP में केवल 6 अंक होने चाहिए';

  @override
  String get statusPending => 'प्रतीक्षारत';

  @override
  String get statusInterestReceived => 'रुचि प्राप्त हुई';

  @override
  String get statusAssigned => 'असाइन किया गया';

  @override
  String get statusInTransit => 'पारगमन में';

  @override
  String get statusDelivered => 'डिलीवर किया गया';

  @override
  String get statusCancelled => 'रद्द किया गया';

  @override
  String get tripStatusActive => 'सक्रिय';

  @override
  String get tripStatusPendingConfirmation => 'पुष्टि की प्रतीक्षा';

  @override
  String get tripStatusConfirmed => 'पुष्टि की गई';

  @override
  String get tripStatusCompleted => 'पूर्ण';

  @override
  String get tripStatusCancelled => 'रद्द किया गया';

  @override
  String get vehicleMini => 'मिनी';

  @override
  String get vehicleMiniCapacity => '500 KG तक';

  @override
  String get vehiclePickupTruck => 'पिकअप ट्रक';

  @override
  String get vehiclePickupTruckCapacity => '1.5 टन तक';

  @override
  String get vehicleTruck => 'ट्रक';

  @override
  String get vehicleTruckCapacity => '5 टन तक';

  @override
  String get vehicleHeavyDuty => 'हैवी ड्यूटी';

  @override
  String get vehicleHeavyDutyCapacity => '20 टन तक';

  @override
  String get authWelcome => 'गुड्स कैरियर में आपका स्वागत है';

  @override
  String get authLoginBrandLine => 'आपका विश्वसनीय लॉजिस्टिक्स साथी';

  @override
  String get authLoginHeadline => 'मार्केटप्लेस में आपका स्वागत है';

  @override
  String get authCountryCodeInd => 'IND  +91';

  @override
  String get authPhoneDigitsPlaceholder => '000-000-0000';

  @override
  String get authSubtitle => 'आपका विश्वसनीय लॉजिस्टिक्स पार्टनर';

  @override
  String get authPhoneLabel => 'फ़ोन नंबर';

  @override
  String get authPhoneHint => '+91 XXXXX XXXXX';

  @override
  String get authSendOtp => 'OTP भेजें';

  @override
  String get authVerifyOtp => 'OTP सत्यापित करें';

  @override
  String get authVerifyNumberTitle => 'नंबर सत्यापित करें';

  @override
  String get authEnterOtp => 'OTP दर्ज करें';

  @override
  String get authOtpCodeSentPrefix => 'भेजा गया 4-अंकीय कोड दर्ज करें';

  @override
  String get authVerifyAndContinue => 'सत्यापित करें और जारी रखें';

  @override
  String get authResendOtp => 'OTP पुनः भेजें';

  @override
  String get authResendSms => 'SMS पुनः भेजें';

  @override
  String get authResendCodeIn => 'कोड पुनः भेजें';

  @override
  String authResendIn(int seconds) {
    return '$seconds सेकंड में पुनः भेजें';
  }

  @override
  String get authHavingTrouble => 'समस्या हो रही है? ';

  @override
  String get authNeedHelp => 'सहायता चाहिए';

  @override
  String get authEncryptedVerification => 'एंड-टू-एंड एन्क्रिप्टेड सत्यापन';

  @override
  String get authLoginSubtitle =>
      'सुरक्षित लॉगिन कोड पाने के लिए अपना फ़ोन नंबर दर्ज करें।';

  @override
  String get authPrivacyPolicy => 'गोपनीयता नीति';

  @override
  String get authHelpCenter => 'सहायता केंद्र';

  @override
  String get authFeatureVerifiedTitle => 'सत्यापित कैरियर';

  @override
  String get authFeatureVerifiedDesc =>
      '50,000+ विश्वसनीय लॉजिस्टिक्स पेशेवरों से जुड़ें।';

  @override
  String get authFeatureSecureTitle => 'सुरक्षित भुगतान';

  @override
  String get authFeatureSecureDesc =>
      'एन्क्रिप्टेड लेनदेन और विश्वसनीय एस्क्रो।';

  @override
  String get authIAmCustomer => 'मैं ग्राहक हूँ';

  @override
  String get authIAmDriver => 'मैं ड्राइवर हूँ';

  @override
  String get authTermsPrefix => 'जारी रखकर, आप हमारी ';

  @override
  String get authTermsLink => 'नियम एवं शर्तें';

  @override
  String authOtpSentTo(String phone) {
    return '$phone पर OTP भेजा गया';
  }

  @override
  String get roleCustomer => 'ग्राहक';

  @override
  String get roleDriver => 'ड्राइवर';

  @override
  String get langSelectionTitle => 'अपनी भाषा चुनें';

  @override
  String get langSelectionSubtitle =>
      'जारी रखने के लिए अपनी पसंदीदा भाषा चुनें';

  @override
  String get langEnglishName => 'English';

  @override
  String get langEnglishSubtitle => 'प्राथमिक भाषा';

  @override
  String get langHindiName => 'हिन्दी (Hindi)';

  @override
  String get langHindiSubtitle => 'मानक हिन्दी';

  @override
  String get langGujaratiName => 'ગુજરાતી (Gujarati)';

  @override
  String get langGujaratiSubtitle => 'क्षेत्रीय गुजराती';

  @override
  String get roleSelectionTitle => 'अपनी भूमिका चुनें';

  @override
  String get roleSelectionSubtitle =>
      'चुनें कि आप अपनी लॉजिस्टिक्स प्रबंधित करने के लिए गुड्स कैरियर का उपयोग कैसे करना चाहते हैं।';

  @override
  String get roleCustomerTitle => 'ग्राहक / माल भेजें';

  @override
  String get roleCustomerDescription =>
      'आसानी से परिवहन खोजें। छोटे पार्सल से लेकर पूरे कंटेनर तक, दुनिया भर में शिप करें।';

  @override
  String get roleDriverTitle => 'ड्राइवर / ट्रांसपोर्टर';

  @override
  String get roleDriverDescription =>
      'ट्रिप पोस्ट करें और कमाएं। विश्वसनीय परिवहन की जरूरत वाले व्यवसायों से जुड़ें।';

  @override
  String get splashInitializing => 'सिस्टम प्रारंभ हो रहा है';

  @override
  String get profileName => 'पूरा नाम';

  @override
  String get profileEmail => 'ईमेल पता';

  @override
  String get profileEmailOptional => 'ईमेल पता (वैकल्पिक)';

  @override
  String get profilePhone => 'फ़ोन नंबर';

  @override
  String get profilePrimaryAddress => 'प्राथमिक पता';

  @override
  String get profileCompanyName => 'कंपनी का नाम';

  @override
  String get profileGstNumber => 'GST नंबर';

  @override
  String get profileGstNumberHint => 'जैसे 27AABCS1429B1ZB';

  @override
  String get profileBusinessEmail => 'व्यापारिक ईमेल';

  @override
  String get profileVehicleNumber => 'वाहन नंबर';

  @override
  String get profileVehicleNumberHint => 'जैसे MH 02 CC 4156';

  @override
  String get profileVehicleType => 'वाहन का प्रकार';

  @override
  String get profileLoadCapacity => 'भार क्षमता (टन)';

  @override
  String get profileSetupTitle => 'अपनी प्रोफ़ाइल बनाएं';

  @override
  String get profileSetupSubtitle => 'चलिए शुरू करते हैं';

  @override
  String get profileCreateButton => 'प्रोफ़ाइल बनाएं';

  @override
  String get profilePhotoPickerTitle => 'प्रोफ़ाइल फ़ोटो';

  @override
  String get profilePhotoTakePhoto => 'फ़ोटो लें';

  @override
  String get profilePhotoChooseGallery => 'गैलरी से चुनें';

  @override
  String get profilePhotoCameraPermissionDenied =>
      'प्रोफ़ाइल फ़ोटो के लिए कैमरा अनुमति आवश्यक है। कृपया सेटिंग्स में कैमरा की अनुमति दें।';

  @override
  String get profilePhotoGalleryPermissionDenied =>
      'प्रोफ़ाइल फ़ोटो के लिए गैलरी अनुमति आवश्यक है। कृपया सेटिंग्स में फ़ोटो की अनुमति दें।';

  @override
  String get profilePhotoLimitedTitle => 'सीमित फ़ोटो पहुंच';

  @override
  String get profilePhotoLimitedMessage =>
      'आपने केवल चुनी हुई फ़ोटो की अनुमति दी है। पूरी गैलरी के लिए सेटिंग्स में पूर्ण फ़ोटो पहुंच दें।';

  @override
  String get profilePhotoAllowFullAccess => 'पूर्ण पहुंच दें';

  @override
  String get profilePhotoContinueWithLimited =>
      'चुनी हुई फ़ोटो के साथ जारी रखें';

  @override
  String get actionOpenSettings => 'सेटिंग्स खोलें';

  @override
  String get shipmentPickup => 'पिकअप स्थान';

  @override
  String get shipmentPickupCity => 'पिकअप शहर';

  @override
  String get shipmentDrop => 'डिलीवरी स्थान';

  @override
  String get shipmentDropCity => 'डिलीवरी शहर';

  @override
  String get shipmentGoods => 'माल का विवरण';

  @override
  String get shipmentGoodsType => 'माल का प्रकार';

  @override
  String get shipmentWeight => 'वजन';

  @override
  String get shipmentDate => 'शिपमेंट की तारीख';

  @override
  String get shipmentPrice => 'अनुमानित मूल्य';

  @override
  String get shipmentPostNew => 'शिपमेंट पोस्ट करें';

  @override
  String get shipmentPostConfirmationTitle => 'पुष्टि';

  @override
  String get shipmentPostSuccessTitle => 'शिपमेंट सफलतापूर्वक पोस्ट हुई';

  @override
  String shipmentPostSuccessBody(String shipmentId) {
    return 'आपकी शिपमेंट सफलतापूर्वक पोस्ट हो गई है। आपकी शिपमेंट आईडी #$shipmentId है';
  }

  @override
  String get shipmentPostBackToHome => 'होम पर वापस जाएं';

  @override
  String get shipmentPostDateLabel => 'तारीख';

  @override
  String get shipmentPostTotalPriceLabel => 'कुल कीमत';

  @override
  String get shipmentEditTitle => 'शिपमेंट संपादित करें';

  @override
  String get shipmentUpdate => 'शिपमेंट अपडेट करें';

  @override
  String get shipmentFormPrecisionLogistics => 'प्रिसिजन लॉजिस्टिक्स';

  @override
  String get shipmentFormHeroTitle => 'आपका माल कहाँ जा रहा है?';

  @override
  String get shipmentFormHeroSubtitle =>
      'सत्यापित कैरियरों से तुरंत बोली पाने के लिए विवरण भरें।';

  @override
  String get shipmentFormFromHint => 'प्रस्थान शहर या वेयरहाउस दर्ज करें';

  @override
  String get shipmentFormToHint => 'गंतव्य पता दर्ज करें';

  @override
  String get shipmentFormVehicleRequirement => 'वाहन आवश्यकता';

  @override
  String get shipmentFormEstWeight => 'अनुमानित वजन';

  @override
  String get shipmentFormEstWeightType => 'वजन इकाई';

  @override
  String get shipmentFormPickupDate => 'पसंदीदा पिकअप तिथि';

  @override
  String get shipmentFormPickupTime => 'पसंदीदा पिकअप समय';

  @override
  String get shipmentFormYourBudget => 'आपका बजट';

  @override
  String get shipmentFormBudgetHint => 'लक्ष्य मूल्य दर्ज करें';

  @override
  String get shipmentFormCommentsLabel => 'अतिरिक्त टिप्पणी (वैकल्पिक)';

  @override
  String get shipmentFormCommentsHint =>
      'इस शिपमेंट के बारे में कोई अतिरिक्त जानकारी दें';

  @override
  String get shipmentFormTerms =>
      'आपने हमारी नियम और शर्तें स्वीकार कर ली हैं।';

  @override
  String get shipmentFormVehicleRequired => 'कृपया वाहन आवश्यकता चुनें';

  @override
  String get shipmentFormScheduleRequired => 'कृपया पिकअप तिथि और समय चुनें';

  @override
  String get shipmentFormTermsRequired => 'कृपया नियम और शर्तें स्वीकार करें';

  @override
  String get shipmentFragile => 'नाज़ुक माल';

  @override
  String get shipmentFragileWarning => 'सावधानी से संभालें — नाज़ुक माल';

  @override
  String get shipmentSpecialInstructions => 'विशेष निर्देश';

  @override
  String get shipmentSpecialInstructionsHint => 'कोई विशेष आवश्यकताएं...';

  @override
  String get shipmentInterestedDrivers => 'इच्छुक ड्राइवर';

  @override
  String get shipmentSelectDriver => 'ड्राइवर चुनें';

  @override
  String get shipmentNoDriversYet => 'अभी तक किसी ड्राइवर ने रुचि नहीं दिखाई';

  @override
  String get shipmentId => 'शिपमेंट ID';

  @override
  String shipmentActiveCount(int count) {
    return '$count सक्रिय शिपमेंट';
  }

  @override
  String get customerHomeBrandTitle => 'Good Carrier';

  @override
  String get customerHomeDriverTrips => 'ड्राइवर यात्राएं';

  @override
  String get customerHomeInterestBadge => 'आपकी रुचि दर्ज है';

  @override
  String get customerHomeEstStartDate => 'अनुमानित प्रारंभ तिथि';

  @override
  String get customerHomeEstEndDate => 'अनुमानित समाप्ति तिथि';

  @override
  String get customerHomeSearchHint => 'गंतव्य या वाहन से खोजें';

  @override
  String customerHomeActiveShipments(int count) {
    return '$count सक्रिय शिपमेंट';
  }

  @override
  String get customerHomeYourShipments => 'आपके शिपमेंट';

  @override
  String get customerNavHome => 'होम';

  @override
  String get customerNavShipments => 'शिपमेंट';

  @override
  String get customerNavNotifications => 'सूचनाएं';

  @override
  String get customerNavProfile => 'प्रोफ़ाइल';

  @override
  String get actionViewDetails => 'विवरण देखें';

  @override
  String get customerHomeFilterSoon => 'उन्नत फ़िल्टर जल्द उपलब्ध होंगे';

  @override
  String get filterSearchTitle => 'फ़िल्टर खोज';

  @override
  String get filterClearAll => 'सब साफ़ करें';

  @override
  String get filterRouteDetails => 'मार्ग विवरण';

  @override
  String get filterFromLabel => 'से';

  @override
  String get filterFromHint => 'प्रस्थान शहर दर्ज करें';

  @override
  String get filterToLabel => 'तक';

  @override
  String get filterToHint => 'गंतव्य दर्ज करें';

  @override
  String get filterPickupDate => 'पिकअप तिथि';

  @override
  String get filterCalendar => 'कैलेंडर';

  @override
  String get filterToday => 'आज';

  @override
  String get filterVehicleClass => 'वाहन वर्ग';

  @override
  String get filterLoadCapacity => 'लोड क्षमता';

  @override
  String get filterApply => 'फ़िल्टर लागू करें';

  @override
  String get customerMyShipment => 'मेरे शिपमेंट';

  @override
  String get customerMyProfile => 'मेरी प्रोफ़ाइल';

  @override
  String get customerRoleLabel => 'ग्राहक';

  @override
  String get customerAccountSettings => 'खाता सेटिंग्स';

  @override
  String get customerEditPersonalInfo => 'व्यक्तिगत जानकारी संपादित करें';

  @override
  String get customerEditPersonalInfoSub => 'नाम, ईमेल, फ़ोन';

  @override
  String get customerEditProfileTitle => 'अपनी प्रोफ़ाइल संपादित करें';

  @override
  String get customerUpdateProfileButton => 'प्रोफ़ाइल अपडेट करें';

  @override
  String get customerDefaultShippingAddress => 'डिफ़ॉल्ट शिपिंग पता';

  @override
  String get customerAddressNotSet => 'अपना शिपिंग पता जोड़ें';

  @override
  String get customerEditAddressTitle => 'पता संपादित करें';

  @override
  String get customerSavedAddresses => 'सहेजे गए पते';

  @override
  String get customerSavedAddressesSub => 'घर, कार्यालय और अन्य';

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
  String get customerReportedTrips => 'रिपोर्ट की गई यात्राएं';

  @override
  String get customerReportedTripsSub => 'रिपोर्ट की गई यात्राएं देखें';

  @override
  String get customerReportedByYouBadge => 'REPORTED BY YOU';

  @override
  String get customerEstimatedPrice => 'Estimated Price';

  @override
  String get customerActivity => 'गतिविधि';

  @override
  String get customerSettingsSub => 'पुश सूचना, गोपनीयता नीति';

  @override
  String get customerHelpSupport => 'सहायता और समर्थन';

  @override
  String get customerHelpSupportSub => 'FAQ और अधिक';

  @override
  String get shipmentEstimatedPay => 'अनुमानित भुगतान';

  @override
  String get shipmentStatusPublished => 'प्रकाशित';

  @override
  String shipmentViewInterest(int count) {
    return 'रुचि देखें ($count)';
  }

  @override
  String get shipmentDetailsTitle => 'शिपमेंट विवरण';

  @override
  String get notificationNewBadge => 'नया';

  @override
  String get tripPostNew => 'ट्रिप पोस्ट करें';

  @override
  String get tripFrom => 'से';

  @override
  String get tripTo => 'तक';

  @override
  String get tripDate => 'ट्रिप की तारीख';

  @override
  String get tripCapacity => 'भार क्षमता';

  @override
  String get tripVehicle => 'वाहन';

  @override
  String get tripId => 'ट्रिप ID';

  @override
  String get tripExpressInterest => 'रुचि दिखाएं';

  @override
  String get tripInterestSubmitted => 'रुचि जमा की गई';

  @override
  String get tripPrice => 'आपका कोटेशन (₹)';

  @override
  String get notificationsTitle => 'सूचनाएं';

  @override
  String get notificationMarkAllRead => 'सभी पढ़ा हुआ चिह्नित करें';

  @override
  String get notificationNoNew => 'आप अप टू डेट हैं!';

  @override
  String get emptyShipments => 'अभी तक कोई शिपमेंट नहीं';

  @override
  String get emptyShipmentsSubtitle =>
      'शुरू करने के लिए अपना पहला शिपमेंट पोस्ट करें';

  @override
  String get customerEmptyShipmentsTitle => 'कोई सक्रिय शिपमेंट नहीं';

  @override
  String get customerEmptyShipmentsDescription =>
      'आपने अभी तक कोई आवश्यकता पोस्ट नहीं की है। सटीक ट्रैकिंग के लिए अपना पहला शिपमेंट जोड़कर शुरू करें।';

  @override
  String get emptyTrips => 'अभी तक कोई ट्रिप नहीं';

  @override
  String get emptyTripsSubtitle =>
      'शिपमेंट अनुरोध पाने के लिए अपना रूट पोस्ट करें';

  @override
  String get emptyNotifications => 'कोई सूचना नहीं';

  @override
  String get emptyHistory => 'कोई इतिहास नहीं मिला';

  @override
  String get errorGeneric => 'कुछ गलत हुआ। कृपया पुनः प्रयास करें।';

  @override
  String get errorNetwork => 'इंटरनेट कनेक्शन नहीं है';

  @override
  String get errorNetworkSubtitle => 'अपना कनेक्शन जांचें और पुनः प्रयास करें';

  @override
  String get errorTimeout =>
      'अनुरोध का समय समाप्त हुआ। कृपया पुनः प्रयास करें।';

  @override
  String get errorUnauthorised => 'सत्र समाप्त हो गया। कृपया पुनः लॉगिन करें।';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsTheme => 'थीम';

  @override
  String get settingsThemeLight => 'लाइट';

  @override
  String get settingsThemeDark => 'डार्क';

  @override
  String get settingsThemeSystem => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageHindi => 'हिन्दी';

  @override
  String get settingsLanguageGujarati => 'ગુજરાતી';

  @override
  String get settingsLogout => 'लॉगआउट';

  @override
  String get settingsLogoutConfirm => 'क्या आप वाकई लॉगआउट करना चाहते हैं?';

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
    return 'संस्करण $version';
  }
}
