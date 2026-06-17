/// Session phase for routing and UI state.
enum SessionPhase {
  /// No valid token — show login.
  unauthenticated,

  /// Token present but onboarding or profile incomplete.
  onboarding,

  /// Token present and profile complete — show home.
  authenticated,
}
