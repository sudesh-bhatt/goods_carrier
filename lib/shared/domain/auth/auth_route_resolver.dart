import '../../../core/router/app_routes.dart';
import '../enums/onboarding_next_step.dart';
import '../enums/session_phase.dart';
import '../enums/user_role.dart';
import '../entities/user.dart';

/// Maps API [next_step] + [user] to a GoRouter location.
String? routeForNextStep(OnboardingNextStep? step, User? user) {
  switch (step) {
    case OnboardingNextStep.selectRole:
      return AppRoutes.roleSelection;
    case OnboardingNextStep.selectLanguage:
      return AppRoutes.languageSelection;
    case OnboardingNextStep.acceptAgreement:
      return AppRoutes.terms;
    case OnboardingNextStep.completeCustomerProfile:
      return AppRoutes.customerProfileSetup;
    case OnboardingNextStep.completeDriverProfile:
      return AppRoutes.driverProfileSetup;
    case OnboardingNextStep.customerDashboard:
      return _routeForRoleHome(user, isCustomer: true);
    case OnboardingNextStep.driverDashboard:
      return _routeForRoleHome(user, isCustomer: false);
    case OnboardingNextStep.home:
      if (user?.role == UserRole.customer) {
        return _routeForRoleHome(user, isCustomer: true);
      }
      if (user?.role == UserRole.driver) {
        return _routeForRoleHome(user, isCustomer: false);
      }
      return AppRoutes.roleSelection;
    case null:
      if (user?.profileCompleted == true && user?.role != null) {
        return user!.isCustomer ? AppRoutes.customerHome : AppRoutes.driverHome;
      }
      if (user?.role == UserRole.customer) {
        return AppRoutes.customerProfileSetup;
      }
      if (user?.role == UserRole.driver) {
        return AppRoutes.driverProfileSetup;
      }
      return AppRoutes.roleSelection;
  }
}

String _routeForRoleHome(User? user, {required bool isCustomer}) {
  if (user?.profileCompleted == true) {
    return isCustomer ? AppRoutes.customerHome : AppRoutes.driverHome;
  }
  return isCustomer
      ? AppRoutes.customerProfileSetup
      : AppRoutes.driverProfileSetup;
}

/// Session phase after a successful auth/onboarding API call.
SessionPhase sessionPhaseFor(User? user, {required bool hasToken}) {
  if (!hasToken) return SessionPhase.unauthenticated;
  if (user?.profileCompleted == true && user?.role != null) {
    return SessionPhase.authenticated;
  }
  return SessionPhase.onboarding;
}

/// Whether [step] means the user can enter their role home shell.
bool isDashboardNextStep(OnboardingNextStep? step) =>
    step == OnboardingNextStep.customerDashboard ||
    step == OnboardingNextStep.driverDashboard ||
    step == OnboardingNextStep.home;

SessionPhase sessionPhaseAfterOnboardingStep(
  OnboardingNextStep? step,
  User? user, {
  required bool hasToken,
}) {
  if (isDashboardNextStep(step)) {
    return user?.profileCompleted == true
        ? SessionPhase.authenticated
        : SessionPhase.onboarding;
  }
  return sessionPhaseFor(user, hasToken: hasToken);
}
