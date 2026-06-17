import '../enums/onboarding_next_step.dart';
import 'user.dart';

class OnboardingResult {
  const OnboardingResult({
    this.user,
    this.nextStep,
    this.language,
    this.languageLabel,
    this.agreementAccepted,
  });

  final User? user;
  final OnboardingNextStep? nextStep;
  final String? language;
  final String? languageLabel;
  final bool? agreementAccepted;

  factory OnboardingResult.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    return OnboardingResult(
      user: userJson is Map<String, dynamic> ? User.fromJson(userJson) : null,
      nextStep: OnboardingNextStep.fromApi(json['next_step'] as String?),
      language: json['language'] as String?,
      languageLabel: json['language_label'] as String?,
      agreementAccepted: json['agreement_accepted'] as bool?,
    );
  }
}
