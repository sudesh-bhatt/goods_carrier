import '../enums/onboarding_next_step.dart';
import 'user.dart';

class AuthResult {
  const AuthResult({
    this.token,
    required this.user,
    this.nextStep,
  });

  final String? token;
  final User user;
  final OnboardingNextStep? nextStep;

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>?;
    return AuthResult(
      token: json['token'] as String?,
      user: userJson != null
          ? User.fromJson(userJson)
          : User.fromJson(json),
      nextStep: OnboardingNextStep.fromApi(json['next_step'] as String?),
    );
  }
}
