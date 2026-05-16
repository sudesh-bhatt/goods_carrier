import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/network/api_constants.dart';
import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/repositories/i_auth_repository.dart';

/// Dummy auth repository.
///
/// OTP: accepts any 4-digit code.
/// Profile: builds a [User] from the submitted data; no network call.
/// Tokens: reads/writes from [FlutterSecureStorage].
class LocalAuthRepository implements IAuthRepository {
  LocalAuthRepository(this._storage);

  final FlutterSecureStorage _storage;

  static Future<void> _delay([int ms = 700]) =>
      Future.delayed(Duration(milliseconds: ms));

  @override
  Future<void> sendOtp(String phoneNumber) => _delay(800);

  @override
  Future<Map<String, String>> verifyOtp(
      String phoneNumber, String otp) async {
    await _delay(600);
    // Dummy: any 4-digit code succeeds
    if (otp.length != 4) throw Exception('Invalid OTP');
    // Return fake tokens — stored by caller
    return {
      'access_token':  'dummy_access_${DateTime.now().millisecondsSinceEpoch}',
      'refresh_token': 'dummy_refresh_${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  @override
  Future<User> createCustomerProfile({
    required String name,
    required String phone,
    required String address,
    String? email,
  }) async {
    await _delay();
    return User(
      id:      'USR-${DateTime.now().millisecondsSinceEpoch % 9999}',
      name:    name,
      phone:   phone,
      email:   email ?? '',
      role:    UserRole.customer,
      address: address,
    );
  }

  @override
  Future<User> createDriverProfile({
    required String name,
    required String vehicleNumber,
    required String vehicleType,
    required double capacityTons,
  }) async {
    await _delay();
    return User(
      id:    'USR-${DateTime.now().millisecondsSinceEpoch % 9999}',
      name:  name,
      phone: await _storage.read(key: 'otp_phone') ?? '',
      email: '',
      role:  UserRole.driver,
    );
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) =>
      Future.wait([
        _storage.write(key: ApiConstants.kAccessToken,  value: accessToken),
        _storage.write(key: ApiConstants.kRefreshToken, value: refreshToken),
      ]);

  @override
  Future<void> clearTokens() =>
      Future.wait([
        _storage.delete(key: ApiConstants.kAccessToken),
        _storage.delete(key: ApiConstants.kRefreshToken),
      ]);

  @override
  Future<String?> getAccessToken() =>
      _storage.read(key: ApiConstants.kAccessToken);
}
