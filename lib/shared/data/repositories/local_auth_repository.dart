import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/network/api_constants.dart';
import '../../../core/utils/auth_token_utils.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/otp_session.dart';
import '../../domain/entities/user.dart';
import '../../domain/enums/onboarding_next_step.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../local/auth_preferences_store.dart';

/// Dummy auth repository for offline dev when [USE_REMOTE_API=false].
class LocalAuthRepository implements IAuthRepository {
  LocalAuthRepository(
    this._storage, {
    required AuthPreferencesStore prefsStore,
  }) : _prefsStore = prefsStore;

  final FlutterSecureStorage _storage;
  final AuthPreferencesStore _prefsStore;

  String? _otpReferenceId;
  int _resendRemaining = 0;

  static Future<void> _delay([int ms = 700]) =>
      Future.delayed(Duration(milliseconds: ms));

  @override
  Future<OtpSession> sendOtp({
    required String countryCode,
    required String phone,
  }) async {
    await _delay(800);
    _otpReferenceId = 'LOCAL-OTP-${DateTime.now().millisecondsSinceEpoch}';
    _resendRemaining = 3;
    await saveOtpReferenceId(_otpReferenceId!);
    return OtpSession(
      referenceId: _otpReferenceId!,
      otpExpiresIn: 300,
      resendRemaining: _resendRemaining,
    );
  }

  @override
  Future<AuthResult> verifyOtp({
    required String referenceId,
    required String otp,
  }) async {
    await _delay(600);
    if (otp.length != 4) throw Exception('Invalid OTP');
    const token = 'local_dummy_token';
    await saveToken(token);
    return AuthResult(
      token: token,
      user: User(
        id: 'local-1',
        phone: '9876543210',
        countryCode: '+91',
      ),
      nextStep: OnboardingNextStep.selectRole,
    );
  }

  @override
  Future<OtpSession> resendOtp({required String referenceId}) async {
    if (_resendRemaining <= 0) {
      throw Exception('Resend limit reached');
    }
    await _delay(400);
    _resendRemaining--;
    return OtpSession(
      referenceId: referenceId,
      otpExpiresIn: 300,
      resendRemaining: _resendRemaining,
    );
  }

  @override
  Future<AuthResult> fetchMe() async {
    await _delay(300);
    return AuthResult(
      user: User(id: 'local-1', phone: '9876543210', countryCode: '+91'),
      nextStep: OnboardingNextStep.selectRole,
    );
  }

  @override
  Future<void> logout() => clearSession();

  @override
  Future<User> createCustomerProfile({
    required String name,
    required String phone,
    required String address,
    String? email,
    String? profileImageUrl,
  }) async {
    await _delay();
    return User(
      id: 'USR-${DateTime.now().millisecondsSinceEpoch % 9999}',
      name: name,
      phone: phone,
      email: email ?? '',
      role: UserRole.customer,
      address: address,
      profileImageUrl: profileImageUrl,
      profileCompleted: true,
    );
  }

  @override
  Future<User> updateCustomerProfile({
    required String name,
    required String address,
    String? email,
    String? profileImageUrl,
  }) async {
    await _delay();
    return User(
      id: 'local-1',
      name: name,
      phone: '9876543210',
      email: email ?? '',
      role: UserRole.customer,
      address: address,
      profileImageUrl: profileImageUrl,
      profileCompleted: true,
    );
  }

  @override
  Future<User> createDriverProfile({
    required String fullName,
    required String city,
    required String postalCode,
    required String fullAddress,
    String? email,
    String? companyName,
    String? gstName,
    String? gstNumber,
    String? businessEmail,
    String? businessCountryCode,
    String? businessPhone,
    String? profileImageUrl,
  }) async {
    await _delay();
    return User(
      id: 'USR-${DateTime.now().millisecondsSinceEpoch % 9999}',
      name: fullName,
      phone: '9876543210',
      email: email ?? '',
      role: UserRole.driver,
      address: [fullAddress, '$city, $postalCode']
          .where((part) => part.trim().isNotEmpty)
          .join('\n'),
      city: city,
      postalCode: postalCode,
      fullAddress: fullAddress,
      companyName: companyName,
      gstName: gstName,
      gstNumber: gstNumber,
      businessEmail: businessEmail,
      businessCountryCode: businessCountryCode,
      businessPhone: businessPhone,
      profileImageUrl: profileImageUrl,
      profileCompleted: true,
    );
  }

  @override
  Future<User> updateDriverProfile({
    required String fullName,
    required String city,
    required String postalCode,
    required String fullAddress,
    String? email,
    String? companyName,
    String? gstName,
    String? gstNumber,
    String? businessEmail,
    String? businessCountryCode,
    String? businessPhone,
    String? profileImageUrl,
  }) =>
      createDriverProfile(
        fullName: fullName,
        city: city,
        postalCode: postalCode,
        fullAddress: fullAddress,
        email: email,
        companyName: companyName,
        gstName: gstName,
        gstNumber: gstNumber,
        businessEmail: businessEmail,
        businessCountryCode: businessCountryCode,
        businessPhone: businessPhone,
        profileImageUrl: profileImageUrl,
      );

  @override
  Future<void> saveToken(String token) async {
    final bearer = AuthTokenUtils.bearerValue(token);
    if (bearer.isEmpty) return;
    await _storage.write(key: ApiConstants.kAuthToken, value: bearer);
    await _prefsStore.saveAuthBearerToken(bearer);
  }

  @override
  Future<void> saveOtpReferenceId(String referenceId) =>
      _storage.write(key: ApiConstants.kOtpReferenceId, value: referenceId);

  @override
  Future<String?> getToken() async {
    final fromSecure = await _storage.read(key: ApiConstants.kAuthToken);
    if (fromSecure != null && fromSecure.isNotEmpty) return fromSecure;
    return _prefsStore.loadAuthBearerToken();
  }

  @override
  Future<String?> getOtpReferenceId() =>
      _storage.read(key: ApiConstants.kOtpReferenceId);

  @override
  Future<void> clearSession() => Future.wait([
        _storage.delete(key: ApiConstants.kAuthToken),
        _storage.delete(key: ApiConstants.kAccessToken),
        _storage.delete(key: ApiConstants.kRefreshToken),
        _storage.delete(key: ApiConstants.kOtpReferenceId),
        _prefsStore.clearAuthBearerToken(),
      ]);
}
