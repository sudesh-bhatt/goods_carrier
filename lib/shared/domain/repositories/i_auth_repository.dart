import '../entities/auth_result.dart';
import '../entities/otp_session.dart';
import '../entities/user.dart';

/// Contract for authentication and token operations.
abstract class IAuthRepository {
  Future<OtpSession> sendOtp({
    required String countryCode,
    required String phone,
  });

  Future<AuthResult> verifyOtp({
    required String referenceId,
    required String otp,
  });

  Future<OtpSession> resendOtp({required String referenceId});

  Future<AuthResult> fetchMe();

  Future<void> logout();

  Future<User> createCustomerProfile({
    required String name,
    required String phone,
    required String address,
    String? email,
    String? profileImageUrl,
  });

  Future<User> updateCustomerProfile({
    required String name,
    required String address,
    String? email,
    String? profileImageUrl,
  });

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
  });

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
  });

  Future<User> getDriverProfile();

  Future<void> saveToken(String token);

  Future<void> saveOtpReferenceId(String referenceId);

  Future<String?> getToken();

  Future<String?> getOtpReferenceId();

  Future<void> clearSession();
}
