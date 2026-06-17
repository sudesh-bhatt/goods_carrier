import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../../core/network/app_exception.dart';
import '../../../domain/entities/auth_result.dart';
import '../../../domain/entities/otp_session.dart';
import '../../../domain/entities/user.dart';

class AuthApiClient {
  AuthApiClient(this._dio);

  final Dio _dio;

  Future<OtpSession> sendOtp({
    required String countryCode,
    required String phone,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.sendOtp,
      data: {
        'country_code': countryCode,
        'phone': phone,
      },
    );
    return OtpSession.fromJson(ApiEnvelope.parseData(response.data));
  }

  Future<AuthResult> verifyOtp({
    required String referenceId,
    required String otp,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.verifyOtp,
      data: {
        'reference_id': referenceId,
        'otp': otp,
      },
    );
    return AuthResult.fromJson(ApiEnvelope.parseData(response.data));
  }

  Future<OtpSession> resendOtp({required String referenceId}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.resendOtp,
      data: {'reference_id': referenceId},
    );
    return OtpSession.fromJson(ApiEnvelope.parseData(response.data));
  }

  Future<AuthResult> fetchMe() async {
    final response = await _dio.get<Map<String, dynamic>>(ApiConstants.authMe);
    return AuthResult.fromJson(ApiEnvelope.parseData(response.data));
  }

  Future<void> logout() async {
    await _dio.post<void>(ApiConstants.authLogout);
  }

  Future<User> createCustomerProfile({
    required String name,
    required String phone,
    required String address,
    String? email,
    String? profileImageUrl,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.customerProfile,
      data: {
        'name': name,
        if (email != null && email.isNotEmpty) 'email': email,
        'primary_address_text': address,
        if (profileImageUrl != null && profileImageUrl.isNotEmpty)
          'profile_image_url': profileImageUrl,
      },
    );
    return User.fromJson(ApiEnvelope.parseData(response.data));
  }

  /// Uploads a local avatar file; returns the server URL for profile APIs.
  Future<String> uploadCustomerAvatar(String localFilePath) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.customerProfileAvatar,
      data: FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          localFilePath,
          filename: localFilePath.split(Platform.pathSeparator).last,
        ),
      }),
    );
    return _parseUploadedImageUrl(ApiEnvelope.parseData(response.data));
  }

  Future<User> updateCustomerProfile({
    required String name,
    required String address,
    String? email,
    String? profileImageUrl,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      ApiConstants.customerProfile,
      data: {
        'name': name,
        if (email != null && email.isNotEmpty) 'email': email,
        'primary_address_text': address,
        if (profileImageUrl != null && profileImageUrl.isNotEmpty)
          'profile_image_url': profileImageUrl,
      },
    );
    return User.fromJson(ApiEnvelope.parseData(response.data));
  }

  static String _parseUploadedImageUrl(Map<String, dynamic> data) {
    final user = data['user'];
    if (user is Map<String, dynamic>) {
      final avatar = user['avatar'] as String?;
      if (avatar != null && avatar.isNotEmpty) return avatar;

      final profileImage = user['profile_image_url'] as String?;
      if (profileImage != null && profileImage.isNotEmpty) return profileImage;
    }

    for (final key in ['avatar', 'profile_image_url', 'url', 'path']) {
      final value = data[key];
      if (value is String && value.isNotEmpty) return value;
    }
    throw const BadRequestException('Avatar upload returned no image URL');
  }

  Future<User> createDriverProfile({
    required String name,
    required String phone,
    String? email,
    String? address,
    String? companyName,
    String? gstName,
    String? gstNumber,
    String? businessEmail,
    String? businessPhone,
    String? profileImageUrl,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.driverProfile,
      data: {
        'name': name,
        'phone': phone,
        if (email != null && email.isNotEmpty) 'email': email,
        if (address != null && address.isNotEmpty) 'address': address,
        if (companyName != null && companyName.isNotEmpty)
          'company_name': companyName,
        if (gstName != null && gstName.isNotEmpty) 'gst_name': gstName,
        if (gstNumber != null && gstNumber.isNotEmpty) 'gst_number': gstNumber,
        if (businessEmail != null && businessEmail.isNotEmpty)
          'business_email': businessEmail,
        if (businessPhone != null && businessPhone.isNotEmpty)
          'business_phone': businessPhone,
        if (profileImageUrl != null && profileImageUrl.isNotEmpty)
          'profile_image_url': profileImageUrl,
      },
    );
    return User.fromJson(ApiEnvelope.parseData(response.data));
  }
}
