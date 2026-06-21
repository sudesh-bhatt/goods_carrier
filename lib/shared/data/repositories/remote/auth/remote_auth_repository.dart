import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../../core/network/api_constants.dart';
import '../../../../../core/utils/auth_token_utils.dart';
import '../../../../../core/utils/profile_image_utils.dart';
import '../../../../domain/entities/auth_result.dart';
import '../../../../domain/entities/otp_session.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/repositories/i_auth_repository.dart';
import '../../../api/auth/auth_api_client.dart';
import '../../../local/auth_preferences_store.dart';

class RemoteAuthRepository implements IAuthRepository {
  RemoteAuthRepository({
    required AuthApiClient apiClient,
    required FlutterSecureStorage storage,
    required AuthPreferencesStore prefsStore,
  })  : _api = apiClient,
        _storage = storage,
        _prefsStore = prefsStore;

  final AuthApiClient _api;
  final FlutterSecureStorage _storage;
  final AuthPreferencesStore _prefsStore;

  @override
  Future<OtpSession> sendOtp({
    required String countryCode,
    required String phone,
  }) async {
    final session = await _api.sendOtp(countryCode: countryCode, phone: phone);
    await saveOtpReferenceId(session.referenceId);
    return session;
  }

  @override
  Future<AuthResult> verifyOtp({
    required String referenceId,
    required String otp,
  }) async {
    final result = await _api.verifyOtp(referenceId: referenceId, otp: otp);
    final token = result.token;
    if (token != null && token.isNotEmpty) {
      await saveToken(token);
    }
    return result;
  }

  @override
  Future<OtpSession> resendOtp({required String referenceId}) =>
      _api.resendOtp(referenceId: referenceId);

  @override
  Future<AuthResult> fetchMe() async {
    final result = await _api.fetchMe();
    final token = result.token;
    if (token != null && token.isNotEmpty) {
      await saveToken(token);
    }
    return result;
  }

  @override
  Future<void> logout() async {
    try {
      await _api.logout();
    } finally {
      await clearSession();
    }
  }

  @override
  Future<User> createCustomerProfile({
    required String name,
    required String phone,
    required String address,
    String? email,
    String? profileImageUrl,
  }) async {
    final resolvedImageUrl = await _resolveCustomerProfileImageUrl(
      profileImageUrl,
    );
    return _api.createCustomerProfile(
      name: name,
      phone: phone,
      address: address,
      email: email,
      profileImageUrl: resolvedImageUrl,
    );
  }

  @override
  Future<User> updateCustomerProfile({
    required String name,
    required String address,
    String? email,
    String? profileImageUrl,
  }) async {
    final resolvedImageUrl = await _resolveCustomerProfileImageUrl(
      profileImageUrl,
    );
    return _api.updateCustomerProfile(
      name: name,
      address: address,
      email: email,
      profileImageUrl: resolvedImageUrl,
    );
  }

  Future<String?> _resolveCustomerProfileImageUrl(String? imageRef) async {
    if (imageRef == null || imageRef.isEmpty) return null;
    if (ProfileImageUtils.isRemoteUrl(imageRef)) return imageRef;
    if (ProfileImageUtils.isServerRelativePath(imageRef)) return imageRef;
    if (!ProfileImageUtils.isLocalFileAvailable(imageRef)) return null;

    final localPath = ProfileImageUtils.normalizePath(imageRef)!;
    return _api.uploadCustomerAvatar(localPath);
  }

  Future<String?> _resolveDriverProfileImageUrl(String? imageRef) async {
    if (imageRef == null || imageRef.isEmpty) return null;
    if (ProfileImageUtils.isRemoteUrl(imageRef)) return imageRef;
    if (ProfileImageUtils.isServerRelativePath(imageRef)) return imageRef;
    if (!ProfileImageUtils.isLocalFileAvailable(imageRef)) return null;

    final localPath = ProfileImageUtils.normalizePath(imageRef)!;
    return _api.uploadDriverAvatar(localPath);
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
    final resolvedImageUrl = await _resolveDriverProfileImageUrl(
      profileImageUrl,
    );
    return _api.createDriverProfile(
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
      profileImageUrl: resolvedImageUrl,
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
  }) async {
    final resolvedImageUrl = await _resolveDriverProfileImageUrl(
      profileImageUrl,
    );
    return _api.updateDriverProfile(
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
      profileImageUrl: resolvedImageUrl,
    );
  }

  @override
  Future<User> getDriverProfile() => _api.getDriverProfile();

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
    final fromSecure = await _storage.read(key: ApiConstants.kAuthToken) ??
        await _storage.read(key: ApiConstants.kAccessToken);
    if (fromSecure != null && fromSecure.isNotEmpty) return fromSecure;
    return _prefsStore.loadAuthBearerToken();
  }

  @override
  Future<String?> getOtpReferenceId() =>
      _storage.read(key: ApiConstants.kOtpReferenceId);

  @override
  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: ApiConstants.kAuthToken),
      _storage.delete(key: ApiConstants.kAccessToken),
      _storage.delete(key: ApiConstants.kRefreshToken),
      _storage.delete(key: ApiConstants.kOtpReferenceId),
      _prefsStore.clearAuthBearerToken(),
    ]);
  }
}
