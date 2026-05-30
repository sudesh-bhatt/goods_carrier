import '../entities/user.dart';

/// Contract for authentication and profile operations.
abstract class IAuthRepository {
  // ── OTP flow ──────────────────────────────────────────────────────────────

  /// Triggers an OTP SMS to [phoneNumber] (E.164 format: +91XXXXXXXXXX).
  Future<void> sendOtp(String phoneNumber);

  /// Validates [otp] for [phoneNumber]. On success returns a map containing
  /// `access_token` and `refresh_token`. Throws [UnauthorisedException] on
  /// mismatch.
  Future<Map<String, String>> verifyOtp(String phoneNumber, String otp);

  // ── Profile setup ─────────────────────────────────────────────────────────

  /// Creates a customer profile on the server and returns the [User].
  Future<User> createCustomerProfile({
    required String name,
    required String phone,
    required String address,
    String? email,
  });

  /// Creates a driver profile on the server and returns the [User].
  Future<User> createDriverProfile({
    required String name,
    String? email,
    String? address,
    String? companyName,
    String? gstName,
    String? gstNumber,
    String? businessEmail,
    String? businessPhone,
  });

  // ── Token management ──────────────────────────────────────────────────────

  /// Persists [accessToken] and [refreshToken] in secure storage.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Deletes all stored tokens. Called on logout.
  Future<void> clearTokens();

  /// Returns the stored access token, or `null` if unauthenticated.
  Future<String?> getAccessToken();
}
