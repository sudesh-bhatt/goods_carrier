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
    required String email,
    String? companyName,
    String? gstNumber,
  }) async {
    final response = await dio.post(
      ApiConstants.customerProfile,
      data: {
        'name':  name,
        'email': email,
        if (companyName != null) 'company_name': companyName,
        if (gstNumber   != null) 'gst_number':   gstNumber,
      },
    );
    return User.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<User> createDriverProfile({
    required String name,
    required String vehicleNumber,
    required String vehicleType,
    required double capacityTons,
  }) async {
    final response = await dio.post(
      ApiConstants.driverProfile,
      data: {
        'name':           name,
        'vehicle_number': vehicleNumber,
        'vehicle_type':   vehicleType,
        'capacity_tons':  capacityTons,
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
