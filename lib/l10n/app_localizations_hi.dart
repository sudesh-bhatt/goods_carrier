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
  String get authResendOtp => 'OTP पुनः भेजें';

  @override
  String authResendIn(int seconds) {
    return '$seconds सेकंड में पुनः भेजें';
  }

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
  String get profilePhone => 'फ़ोन नंबर';

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
  String get profileSetupTitle => 'अपना प्रोफ़ाइल पूरा करें';

  @override
  String get profileSetupSubtitle => 'चलिए शुरू करते हैं';

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
  String settingsVersion(String version) {
    return 'संस्करण $version';
  }
}
