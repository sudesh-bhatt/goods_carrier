import '../../../../domain/entities/onboarding_result.dart';
import '../../../../domain/enums/user_role.dart';
import '../../../../domain/repositories/i_onboarding_repository.dart';
import '../../../api/onboarding/onboarding_api_client.dart';

class RemoteOnboardingRepository implements IOnboardingRepository {
  RemoteOnboardingRepository(this._api);

  final OnboardingApiClient _api;

  @override
  Future<OnboardingResult> updateRole(UserRole role) => _api.updateRole(role);

  @override
  Future<OnboardingResult> updateLanguage(String languageCode) =>
      _api.updateLanguage(languageCode);

  @override
  Future<OnboardingResult> acceptAgreement() => _api.acceptAgreement();

  @override
  Future<OnboardingResult> fetchStatus() => _api.fetchStatus();
}
