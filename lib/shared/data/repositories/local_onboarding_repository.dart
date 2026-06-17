import '../../domain/entities/onboarding_result.dart';
import '../../domain/enums/onboarding_next_step.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/repositories/i_onboarding_repository.dart';

class LocalOnboardingRepository implements IOnboardingRepository {
  UserRole? _role;

  @override
  Future<OnboardingResult> updateRole(UserRole role) async {
    _role = role;
    return OnboardingResult(
      nextStep: OnboardingNextStep.selectLanguage,
    );
  }

  @override
  Future<OnboardingResult> updateLanguage(String languageCode) async {
    return OnboardingResult(
      nextStep: OnboardingNextStep.acceptAgreement,
      language: languageCode,
    );
  }

  @override
  Future<OnboardingResult> acceptAgreement() async {
    final step = _role == UserRole.driver
        ? OnboardingNextStep.completeDriverProfile
        : OnboardingNextStep.completeCustomerProfile;
    return OnboardingResult(
      nextStep: step,
      agreementAccepted: true,
    );
  }

  @override
  Future<OnboardingResult> fetchStatus() async {
    return const OnboardingResult(
      nextStep: OnboardingNextStep.selectRole,
    );
  }
}
