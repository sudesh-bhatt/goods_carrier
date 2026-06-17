import '../entities/onboarding_result.dart';
import '../enums/user_role.dart';

abstract class IOnboardingRepository {
  Future<OnboardingResult> updateRole(UserRole role);

  Future<OnboardingResult> updateLanguage(String languageCode);

  Future<OnboardingResult> acceptAgreement();

  Future<OnboardingResult> fetchStatus();
}
