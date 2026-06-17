/// Backend `next_step` values returned after auth and onboarding APIs.
enum OnboardingNextStep {
  selectRole('select_role'),
  selectLanguage('select_language'),
  acceptAgreement('accept_agreement'),
  completeCustomerProfile('complete_customer_profile'),
  completeDriverProfile('complete_driver_profile'),
  customerDashboard('customer_dashboard'),
  driverDashboard('driver_dashboard'),
  home('home');

  const OnboardingNextStep(this.apiValue);

  final String apiValue;

  static OnboardingNextStep? fromApi(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final step in OnboardingNextStep.values) {
      if (step.apiValue == value) return step;
    }
    return null;
  }
}
