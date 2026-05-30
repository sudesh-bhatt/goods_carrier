import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/network/api_constants.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';

/// REST implementation of [IAuthRepository] — wires to Firebase Auth in
/// Session 8. For now this talks directly to the Goods Carrier backend.
class RemoteAuthRepository implements IAuthRepository {
  RemoteAuthRepository({required this.dio, required this.storage});

  final Dio                  dio;
  final FlutterSecureStorage storage;

  @override
  Future<void> sendOtp(String phoneNumber) =>
      dio.post(ApiConstants.sendOtp, data: {'phone': phoneNumber});

  @override
  Future<Map<String, String>> verifyOtp(
      String phoneNumber, String otp) async {
    final response = await dio.post(
      ApiConstants.verifyOtp,
      data: {'phone': phoneNumber, 'otp': otp},
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return {
      'access_token':  data['access_token']  as String,
      'refresh_token': data['refresh_token'] as String,
    };
  }

  @override
  Future<User> createCustomerProfile({
    required String name,
    required String phone,
    required String address,
    String? email,
  }) async {
    final response = await dio.post(
      ApiConstants.customerProfile,
      data: {
        'name':    name,
        'phone':   phone,
        'address': address,
        if (email != null && email.isNotEmpty) 'email': email,
      },
    );
    return User.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<User> createDriverProfile({
    required String name,
    String? email,
    String? address,
    String? companyName,
    String? gstName,
    String? gstNumber,
    String? businessEmail,
    String? businessPhone,
  }) async {
    final response = await dio.post(
      ApiConstants.driverProfile,
      data: {
        'name': name,
        if (email != null && email.isNotEmpty) 'email': email,
        if (address != null && address.isNotEmpty) 'address': address,
        if (companyName != null && companyName.isNotEmpty) 'company_name': companyName,
        if (gstName != null && gstName.isNotEmpty) 'gst_name': gstName,
        if (gstNumber != null && gstNumber.isNotEmpty) 'gst_number': gstNumber,
        if (businessEmail != null && businessEmail.isNotEmpty) 'business_email': businessEmail,
        if (businessPhone != null && businessPhone.isNotEmpty) 'business_phone': businessPhone,
      },
    );
    return User.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) =>
      Future.wait([
        storage.write(key: ApiConstants.kAccessToken,  value: accessToken),
        storage.write(key: ApiConstants.kRefreshToken, value: refreshToken),
      ]);

  @override
  Future<void> clearTokens() =>
      Future.wait([
        storage.delete(key: ApiConstants.kAccessToken),
        storage.delete(key: ApiConstants.kRefreshToken),
      ]);

  @override
  Future<String?> getAccessToken() =>
      storage.read(key: ApiConstants.kAccessToken);
}
