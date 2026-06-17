import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../domain/entities/onboarding_result.dart';
import '../../../domain/enums/user_role.dart';

class OnboardingApiClient {
  OnboardingApiClient(this._dio);

  final Dio _dio;

  Future<OnboardingResult> updateRole(UserRole role) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.onboardingRole,
      data: {'role': role.name},
    );
    return OnboardingResult.fromJson(ApiEnvelope.parseData(response.data));
  }

  Future<OnboardingResult> updateLanguage(String languageCode) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.onboardingLanguage,
      data: {'language': languageCode},
    );
    return OnboardingResult.fromJson(ApiEnvelope.parseData(response.data));
  }

  Future<OnboardingResult> acceptAgreement() async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.onboardingAcceptAgreement,
      data: {'accepted': true},
    );
    return OnboardingResult.fromJson(ApiEnvelope.parseData(response.data));
  }

  Future<OnboardingResult> fetchStatus() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.onboardingStatus,
    );
    return OnboardingResult.fromJson(ApiEnvelope.parseData(response.data));
  }
}
