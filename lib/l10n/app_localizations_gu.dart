// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get appName => 'ગુડ્સ કેરિયર';

  @override
  String get appTagline => 'લોજિસ્ટિક્સ સરળ બનાવો';

  @override
  String get actionSave => 'સાચવો';

  @override
  String get actionCancel => 'રદ કરો';

  @override
  String get actionConfirm => 'પુષ્ટિ કરો';

  @override
  String get actionContinue => 'ચાલુ રાખો';

  @override
  String get actionSubmit => 'સબમિટ કરો';

  @override
  String get actionBack => 'પાછળ';

  @override
  String get actionRetry => 'ફરી પ્રયાસ';

  @override
  String get actionDone => 'થઈ ગયું';

  @override
  String get actionEdit => 'સંપાદિત કરો';

  @override
  String get actionDelete => 'કાઢી નાખો';

  @override
  String get actionSelect => 'પસંદ કરો';

  @override
  String get actionClose => 'બંધ કરો';

  @override
  String get actionYes => 'હા';

  @override
  String get actionNo => 'ના';

  @override
  String get actionNext => 'આગળ';

  @override
  String get actionSkip => 'છોડો';

  @override
  String get actionAdd => 'ઉમેરો';

  @override
  String get actionRemove => 'દૂર કરો';

  @override
  String get actionSearch => 'શોધો';

  @override
  String get actionFilter => 'ફિલ્ટર';

  @override
  String get actionShare => 'શેર કરો';

  @override
  String get actionCopy => 'કૉપિ કરો';

  @override
  String get labelLoading => 'લોડ થઈ રહ્યું છે...';

  @override
  String get labelError => 'કંઈક ખોટું થઈ ગયું';

  @override
  String get labelNoData => 'કોઈ ડેટા ઉપલબ્ધ નથી';

  @override
  String get labelOptional => 'વૈકલ્પિક';

  @override
  String get labelRequired => 'જરૂરી';

  @override
  String get labelToday => 'આજે';

  @override
  String get labelYesterday => 'ગઈ કાલે';

  @override
  String get labelAll => 'બધા';

  @override
  String get labelNew => 'નવું';

  @override
  String validationFieldRequired(String fieldName) {
    return '$fieldName જરૂરી છે';
  }

  @override
  String get validationPhoneRequired => 'ફોન નંબર જરૂરી છે';

  @override
  String get validationPhoneInvalid => 'માન્ય 10-અંકનો મોબાઇલ નંબર દાખલ કરો';

  @override
  String get validationGstRequired => 'GST નંબર જરૂરી છે';

  @override
  String get validationGstInvalid =>
      'માન્ય GST નંબર દાખલ કરો (દા.ત. 27AABCS1429B1ZB)';

  @override
  String get validationVehicleRequired => 'વાહન નંબર જરૂરી છે';

  @override
  String get validationVehicleInvalid =>
      'માન્ય વાહન નંબર દાખલ કરો (દા.ત. MH02CC4156)';

  @override
  String get validationEmailRequired => 'ઈમેઇલ જરૂરી છે';

  @override
  String get validationEmailInvalid => 'માન્ય ઈમેઇલ સરનામું દાખલ કરો';

  @override
  String get validationOtpInvalid => '6-અંકનો OTP દાખલ કરો';

  @override
  String get validationOtpDigitsOnly => 'OTP માત્ર 6 અંકનો હોવો જોઈએ';

  @override
  String get statusPending => 'પ્રતીક્ષારત';

  @override
  String get statusInterestReceived => 'રસ પ્રાપ્ત થઈ';

  @override
  String get statusAssigned => 'સોંપાયેલ';

  @override
  String get statusInTransit => 'પ્રવાહ​માં';

  @override
  String get statusDelivered => 'ડિલિવર';

  @override
  String get statusCancelled => 'રદ';

  @override
  String get tripStatusActive => 'સક્રિય';

  @override
  String get tripStatusPendingConfirmation => 'પુષ્ટિ બાકી';

  @override
  String get tripStatusConfirmed => 'પુષ્ટિ થઈ';

  @override
  String get tripStatusCompleted => 'પૂર્ણ';

  @override
  String get tripStatusCancelled => 'રદ';

  @override
  String get vehicleMini => 'મિની';

  @override
  String get vehicleMiniCapacity => '500 KG સુધી';

  @override
  String get vehiclePickupTruck => 'પિકઅપ ટ્રક';

  @override
  String get vehiclePickupTruckCapacity => '1.5 ટન સુધી';

  @override
  String get vehicleTruck => 'ટ્રક';

  @override
  String get vehicleTruckCapacity => '5 ટન સુધી';

  @override
  String get vehicleHeavyDuty => 'હેવી ડ્યૂટી';

  @override
  String get vehicleHeavyDutyCapacity => '20 ટન સુધી';

  @override
  String get authWelcome => 'ગુડ્સ કેરિયરમાં આપનું સ્વાગત છે';

  @override
  String get authLoginBrandLine => 'આપનો વિશ્વસ્ત લોજિસ્ટિક્સ ભાગીદાર';

  @override
  String get authLoginHeadline => 'માર્કેટપ્લેસમાં આપનું સ્વાગત છે';

  @override
  String get authCountryCodeInd => 'IND  +91';

  @override
  String get authPhoneDigitsPlaceholder => '000-000-0000';

  @override
  String get authSubtitle => 'આપનો વિશ્વસ્ત લોજિસ્ટિક્સ ભાગીદાર';

  @override
  String get authPhoneLabel => 'ફોન નંબર';

  @override
  String get authPhoneHint => '+91 XXXXX XXXXX';

  @override
  String get authSendOtp => 'OTP મોકલો';

  @override
  String get authVerifyOtp => 'OTP ચકાસો';

  @override
  String get authVerifyNumberTitle => 'નંબર ચકાસો';

  @override
  String get authEnterOtp => 'OTP દાખલ કરો';

  @override
  String get authOtpCodeSentPrefix => 'મોકલેલ 4-અંકનો કોડ દાખલ કરો';

  @override
  String get authVerifyAndContinue => 'ચકાસો અને ચાલુ રાખો';

  @override
  String get authResendOtp => 'OTP ફરી મોકલો';

  @override
  String get authResendSms => 'SMS ફરી મોકલો';

  @override
  String get authResendCodeIn => 'કોડ ફરી મોકલો';

  @override
  String authResendIn(int seconds) {
    return '$seconds સેકન્ડમાં ફરી મોકલો';
  }

  @override
  String get authHavingTrouble => 'મુશ્કેલી છે? ';

  @override
  String get authNeedHelp => 'મદદ જોઈએ';

  @override
  String get authEncryptedVerification => 'એન્ડ-ટુ-એન્ડ એન્ક્રિપ્ટેડ ચકાસણી';

  @override
  String get authLoginSubtitle =>
      'સુરક્ષિત લૉગિન કોડ મેળવવા આપનો ફોન નંબર દાખલ કરો.';

  @override
  String get authPrivacyPolicy => 'ગોપનીયતા નીતિ';

  @override
  String get authHelpCenter => 'સહાય કેન્દ્ર';

  @override
  String get authFeatureVerifiedTitle => 'ચકાસાયેલ કેરિયર';

  @override
  String get authFeatureVerifiedDesc =>
      '50,000+ વિશ્વસ્ત લોજિસ્ટિક્સ વ્યાવસાયિકો સાથે જોડાઓ.';

  @override
  String get authFeatureSecureTitle => 'સુરક્ષિત ચૂકવણી';

  @override
  String get authFeatureSecureDesc =>
      'એન્ક્રિપ્ટેડ વ્યવહારો અને વિશ્વસ્ત એસ્ક્રો.';

  @override
  String get authIAmCustomer => 'હું ગ્રાહક છું';

  @override
  String get authIAmDriver => 'હું ડ્રાઇવર છું';

  @override
  String get authTermsPrefix => 'ચાલુ રાખીને, આપ અમારી ';

  @override
  String get authTermsLink => 'નિયમો અને શરતો';

  @override
  String authOtpSentTo(String phone) {
    return '$phone પર OTP મોકલ્યો';
  }

  @override
  String get roleCustomer => 'ગ્રાહક';

  @override
  String get roleDriver => 'ડ્રાઇવર';

  @override
  String get langSelectionTitle => 'આપની ભાષા પસંદ કરો';

  @override
  String get langSelectionSubtitle => 'ચાલુ રાખવા આપની પસંદીદા ભાષા પસંદ કરો';

  @override
  String get langEnglishName => 'English';

  @override
  String get langEnglishSubtitle => 'પ્રાથમિક ભાષા';

  @override
  String get langHindiName => 'हिन्दी (Hindi)';

  @override
  String get langHindiSubtitle => 'પ્રમાણભૂત હિન્દી';

  @override
  String get langGujaratiName => 'ગુજરાતી (Gujarati)';

  @override
  String get langGujaratiSubtitle => 'પ્રાદેશિક ગુજરાતી';

  @override
  String get roleSelectionTitle => 'આપની ભૂમિકા પસંદ કરો';

  @override
  String get roleSelectionSubtitle =>
      'આપ આપની લોજિસ્ટિક્સ સંચાલિત કરવા ગુડ્સ કેરિયરનો ઉપયોગ કેવી રીતે કરવા માંગો છો તે પસંદ કરો.';

  @override
  String get roleCustomerTitle => 'ગ્રાહક / માલ મોકલો';

  @override
  String get roleCustomerDescription =>
      'સરળતાથી પરિવહન શોધો. નાના પાર્સલથી લઈ પૂરા કન્ટેઇનર સુધી, વૈશ્વિક સ્તરે શિપ કરો.';

  @override
  String get roleDriverTitle => 'ડ્રાઇવર / ટ્રાન્સપોર્ટર';

  @override
  String get roleDriverDescription =>
      'ટ્રિપ પોસ્ટ કરો અને કમાઓ. વિશ્વસનીય પરિવહન ઇચ્છતા વ્યવસાયો સાથે જોડાઓ.';

  @override
  String get splashInitializing => 'સિસ્ટમ શરૂ થઈ રહ્યું છે';

  @override
  String get profileName => 'પૂરું નામ';

  @override
  String get profileEmail => 'ઈમેઇલ સરનામું';

  @override
  String get profileEmailOptional => 'ઈમેઇલ સરનામું (વૈકલ્પિક)';

  @override
  String get profilePhone => 'ફોન નંબર';

  @override
  String get profilePrimaryAddress => 'પ્રાથમિક સરનામું';

  @override
  String get profileCompanyName => 'કંપનીનું નામ';

  @override
  String get profileGstNumber => 'GST નંબર';

  @override
  String get profileGstNumberHint => 'દા.ત. 27AABCS1429B1ZB';

  @override
  String get profileBusinessEmail => 'વ્યાપારી ઈમેઇલ';

  @override
  String get profileVehicleNumber => 'વાહન નંબર';

  @override
  String get profileVehicleNumberHint => 'દા.ત. MH 02 CC 4156';

  @override
  String get profileVehicleType => 'વાહનનો પ્રકાર';

  @override
  String get profileLoadCapacity => 'ભાર ક્ષમતા (ટન)';

  @override
  String get profileSetupTitle => 'આપની પ્રોફાઇલ બનાવો';

  @override
  String get profileSetupSubtitle => 'ચાલો શરૂ કરીએ';

  @override
  String get profileCreateButton => 'પ્રોફાઇલ બનાવો';

  @override
  String get profilePhotoPickerTitle => 'પ્રોફાઇલ ફોટો';

  @override
  String get profilePhotoTakePhoto => 'ફોટો લો';

  @override
  String get profilePhotoChooseGallery => 'ગેલેરીમાંથી પસંદ કરો';

  @override
  String get profilePhotoCameraPermissionDenied =>
      'પ્રોફાઇલ ફોટો માટે કેમેરા પરવાનગી જરૂરી છે. સેટિંગ્સમાં કેમેરા મંજૂર કરો.';

  @override
  String get profilePhotoGalleryPermissionDenied =>
      'પ્રોફાઇલ ફોટો માટે ગેલેરી પરવાનગી જરૂરી છે. સેટિંગ્સમાં ફોટો મંજૂર કરો.';

  @override
  String get profilePhotoLimitedTitle => 'મર્યાદિત ફોટો ઍક્સેસ';

  @override
  String get profilePhotoLimitedMessage =>
      'તમે માત્ર પસંદ કરેલા ફોટાની પરવાનગી આપી છે. સંપૂર્ણ ગેલેરી માટે સેટિંગ્સમાં પૂર્ણ ફોટો ઍક્સેસ મંજૂર કરો.';

  @override
  String get profilePhotoAllowFullAccess => 'પૂર્ણ ઍક્સેસ મંજૂર કરો';

  @override
  String get profilePhotoContinueWithLimited =>
      'પસંદ કરેલા ફોટા સાથે ચાલુ રાખો';

  @override
  String get actionOpenSettings => 'સેટિંગ્સ ખોલો';

  @override
  String get shipmentPickup => 'પિકઅપ સ્થાન';

  @override
  String get shipmentPickupCity => 'પિકઅપ શહેર';

  @override
  String get shipmentDrop => 'ડ્રૉપ સ્થાન';

  @override
  String get shipmentDropCity => 'ડ્રૉપ શહેર';

  @override
  String get shipmentGoods => 'માલની વિગત';

  @override
  String get shipmentGoodsType => 'માલનો પ્રકાર';

  @override
  String get shipmentWeight => 'વજન';

  @override
  String get shipmentDate => 'શિપમેન્ટ તારીખ';

  @override
  String get shipmentPrice => 'અંદાજિત ભાવ';

  @override
  String get shipmentPostNew => 'શિપમેન્ટ પોસ્ટ કરો';

  @override
  String get shipmentFragile => 'નાજુક માલ';

  @override
  String get shipmentFragileWarning => 'સાવધાનીથી સંભાળો — નાજુક માલ';

  @override
  String get shipmentSpecialInstructions => 'ખાસ સૂચનાઓ';

  @override
  String get shipmentSpecialInstructionsHint => 'કોઈ ખાસ જરૂરિયાત...';

  @override
  String get shipmentInterestedDrivers => 'રસ ધરાવતા ડ્રાઇવર';

  @override
  String get shipmentSelectDriver => 'ડ્રાઇવર પસંદ કરો';

  @override
  String get shipmentNoDriversYet => 'હજી સુધી કોઈ ડ્રાઇવરે રસ દર્શાવ્યો નથી';

  @override
  String get shipmentId => 'શિપમેન્ટ ID';

  @override
  String shipmentActiveCount(int count) {
    return '$count સક્રિય શિપમેન્ટ';
  }

  @override
  String get customerHomeBrandTitle => 'Good Carrier';

  @override
  String get customerHomeDriverTrips => 'ડ્રાઇવર ટ્રિપ્સ';

  @override
  String get customerHomeInterestBadge => 'તમારી રુચિ નોંધાઈ છે';

  @override
  String get customerHomeEstStartDate => 'અંદાજિત શરૂઆત તારીખ';

  @override
  String get customerHomeEstEndDate => 'અંદાજિત અંત તારીખ';

  @override
  String get customerHomeSearchHint => 'ગંતવ્ય અથવા વાહન દ્વારા શોધો';

  @override
  String customerHomeActiveShipments(int count) {
    return '$count સક્રિય શિપમેન્ટ';
  }

  @override
  String get customerHomeYourShipments => 'તમારા શિપમેન્ટ';

  @override
  String get customerNavHome => 'હોમ';

  @override
  String get customerNavShipments => 'શિપમેન્ટ';

  @override
  String get customerNavNotifications => 'સૂચનાઓ';

  @override
  String get customerNavProfile => 'પ્રોફાઇલ';

  @override
  String get actionViewDetails => 'વિગતો જુઓ';

  @override
  String get customerHomeFilterSoon => 'અદ્યતન ફિલ્ટર ટૂંક સમયમાં ઉપલબ્ધ થશે';

  @override
  String get filterSearchTitle => 'ફિલ્ટર શોધ';

  @override
  String get filterClearAll => 'બધું સાફ કરો';

  @override
  String get filterRouteDetails => 'માર્ગ વિગતો';

  @override
  String get filterFromLabel => 'થી';

  @override
  String get filterFromHint => 'મૂળ શહેર દાખલ કરો';

  @override
  String get filterToLabel => 'સુધી';

  @override
  String get filterToHint => 'ગંતવ્ય દાખલ કરો';

  @override
  String get filterPickupDate => 'પિકઅપ તારીખ';

  @override
  String get filterCalendar => 'કેલેન્ડર';

  @override
  String get filterToday => 'આજે';

  @override
  String get filterVehicleClass => 'વાહન વર્ગ';

  @override
  String get filterLoadCapacity => 'લોડ ક્ષમતા';

  @override
  String get filterApply => 'ફિલ્ટર લાગુ કરો';

  @override
  String get customerMyShipment => 'મારા શિપમેન્ટ';

  @override
  String get customerMyProfile => 'મારી પ્રોફાઇલ';

  @override
  String get customerRoleLabel => 'ગ્રાહક';

  @override
  String get customerAccountSettings => 'એકાઉન્ટ સેટિંગ્સ';

  @override
  String get customerEditPersonalInfo => 'વ્યક્તિગત માહિતી સંપાદિત કરો';

  @override
  String get customerEditPersonalInfoSub => 'નામ, ઈમેલ, ફોન અને સરનામું';

  @override
  String get customerSavedAddresses => 'સાચવેલા સરનામાં';

  @override
  String get customerSavedAddressesSub => 'ઘર, ઓફિસ અને અન્ય';

  @override
  String get customerReportedTrips => 'રિપોર્ટ કરેલી ટ્રિપ';

  @override
  String get customerReportedTripsSub => 'રિપોર્ટ કરેલી ટ્રિપ જુઓ';

  @override
  String get customerActivity => 'પ્રવૃત્તિ';

  @override
  String get customerHelpSupport => 'મદદ અને સપોર્ટ';

  @override
  String get customerHelpSupportSub => 'FAQ અને વધુ';

  @override
  String get shipmentEstimatedPay => 'અંદાજિત ચુકવણી';

  @override
  String get shipmentStatusPublished => 'પ્રકાશિત';

  @override
  String shipmentViewInterest(int count) {
    return 'રુચિ જુઓ ($count)';
  }

  @override
  String get shipmentDetailsTitle => 'શિપમેન્ટ વિગતો';

  @override
  String get notificationNewBadge => 'નવું';

  @override
  String get tripPostNew => 'ટ્રિપ પોસ્ટ કરો';

  @override
  String get tripFrom => 'થી';

  @override
  String get tripTo => 'સુધી';

  @override
  String get tripDate => 'ટ્રિપ તારીખ';

  @override
  String get tripCapacity => 'ભાર ક્ષમતા';

  @override
  String get tripVehicle => 'વાહન';

  @override
  String get tripId => 'ટ્રિપ ID';

  @override
  String get tripExpressInterest => 'રસ દર્શાવો';

  @override
  String get tripInterestSubmitted => 'રસ સ્વીકારાયો';

  @override
  String get tripPrice => 'આપનું ક્વોટ (₹)';

  @override
  String get notificationsTitle => 'સૂચનાઓ';

  @override
  String get notificationMarkAllRead => 'બધી વાંચેલ ગણો';

  @override
  String get notificationNoNew => 'બધું અપ ટૂ ડેટ છે!';

  @override
  String get emptyShipments => 'હજી કોઈ શિપમેન્ટ નથી';

  @override
  String get emptyShipmentsSubtitle =>
      'પ્રારંભ કરવા આપનો પ્રથમ શિપમેન્ટ પોસ્ટ કરો';

  @override
  String get emptyTrips => 'હજી કોઈ ટ્રિપ નથી';

  @override
  String get emptyTripsSubtitle => 'શિપમેન્ટ વિનંતીઓ મેળવવા આપનો રૂટ પોસ્ટ કરો';

  @override
  String get emptyNotifications => 'કોઈ સૂચના નથી';

  @override
  String get emptyHistory => 'કોઈ ઇતિહાસ મળ્યો નહીં';

  @override
  String get errorGeneric => 'કંઈક ખોટું થઈ ગયું. કૃપા કરી ફરી પ્રયાસ કરો.';

  @override
  String get errorNetwork => 'ઇન્ટરનેટ કનેક્શન નથી';

  @override
  String get errorNetworkSubtitle => 'આપનું કનેક્શન તપાસો અને ફરી પ્રયાસ કરો';

  @override
  String get errorTimeout => 'વિનંતી સમય-સમાપ્ત. કૃપા કરી ફરી પ્રયાસ કરો.';

  @override
  String get errorUnauthorised => 'સત્ર સમાપ્ત. કૃપા કરી ફરી લૉગિન કરો.';

  @override
  String get settingsTitle => 'સેટિંગ્સ';

  @override
  String get settingsLanguage => 'ભાષા';

  @override
  String get settingsTheme => 'થીમ';

  @override
  String get settingsThemeLight => 'લાઇટ';

  @override
  String get settingsThemeDark => 'ડાર્ક';

  @override
  String get settingsThemeSystem => 'સિસ્ટમ ડિફૉલ્ટ';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageHindi => 'हिन्दी';

  @override
  String get settingsLanguageGujarati => 'ગુજરાતી';

  @override
  String get settingsLogout => 'લૉગઆઉટ';

  @override
  String get settingsLogoutConfirm => 'શું આપ ખરેખર લૉગઆઉટ કરવા માંગો છો?';

  @override
  String settingsVersion(String version) {
    return 'આવૃત્તિ $version';
  }
}
