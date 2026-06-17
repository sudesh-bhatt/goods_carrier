import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/providers/session_expired_provider.dart';
import '../../../../core/providers/shared_preferences_provider.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../../core/utils/profile_image_utils.dart';
import '../../../../shared/data/local/auth_preferences_store.dart';
import '../../../../shared/domain/auth/auth_route_resolver.dart';
import '../../../../shared/domain/entities/otp_session.dart';
import '../../../../shared/domain/entities/user.dart';
import '../../../../shared/domain/enums/onboarding_next_step.dart';
import '../../../../shared/domain/enums/session_phase.dart';
import '../../../../shared/domain/enums/user_role.dart';
import '../../../../shared/domain/repositories/i_auth_repository.dart';
import '../../../../shared/domain/repositories/i_onboarding_repository.dart';

// ─── Legacy status (router compatibility) ─────────────────────────────────────

enum AuthStatus {
  unauthenticated,
  profileSetupPending,
  authenticated,
}

// ─── Auth state ───────────────────────────────────────────────────────────────

class AuthState {
  const AuthState({
    this.sessionPhase = SessionPhase.unauthenticated,
    this.user,
    this.nextStep,
    this.phoneNumber,
    this.countryCode = '+91',
    this.localPhone,
    this.otpSession,
    this.pendingProfileImageUrl,
    this.isLoading = false,
    this.isRestoringSession = false,
    this.error,
  });

  final SessionPhase sessionPhase;
  final User? user;
  final OnboardingNextStep? nextStep;
  final String? phoneNumber;
  final String countryCode;
  final String? localPhone;
  final OtpSession? otpSession;
  final String? pendingProfileImageUrl;
  final bool isLoading;
  final bool isRestoringSession;
  final String? error;

  AuthStatus get status {
    switch (sessionPhase) {
      case SessionPhase.unauthenticated:
        return AuthStatus.unauthenticated;
      case SessionPhase.onboarding:
        return AuthStatus.profileSetupPending;
      case SessionPhase.authenticated:
        return AuthStatus.authenticated;
    }
  }

  bool get isAuthenticated => sessionPhase == SessionPhase.authenticated;
  bool get needsProfileSetup => sessionPhase == SessionPhase.onboarding;
  bool get isUnauthenticated => sessionPhase == SessionPhase.unauthenticated;

  UserRole? get selectedRole => user?.role;

  String? get routeForCurrentStep => routeForNextStep(nextStep, user);

  AuthState copyWith({
    SessionPhase? sessionPhase,
    User? user,
    OnboardingNextStep? nextStep,
    String? phoneNumber,
    String? countryCode,
    String? localPhone,
    OtpSession? otpSession,
    String? pendingProfileImageUrl,
    bool? isLoading,
    bool? isRestoringSession,
    String? error,
    bool clearError = false,
    bool clearUser = false,
    bool clearOtpSession = false,
    bool clearPendingProfileImage = false,
    bool clearNextStep = false,
  }) =>
      AuthState(
        sessionPhase: sessionPhase ?? this.sessionPhase,
        user: clearUser ? null : (user ?? this.user),
        nextStep: clearNextStep ? null : (nextStep ?? this.nextStep),
        phoneNumber: phoneNumber ?? this.phoneNumber,
        countryCode: countryCode ?? this.countryCode,
        localPhone: localPhone ?? this.localPhone,
        otpSession: clearOtpSession ? null : (otpSession ?? this.otpSession),
        pendingProfileImageUrl: clearPendingProfileImage
            ? null
            : (pendingProfileImageUrl ?? this.pendingProfileImageUrl),
        isLoading: isLoading ?? this.isLoading,
        isRestoringSession: isRestoringSession ?? this.isRestoringSession,
        error: clearError ? null : (error ?? this.error),
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(
    this._ref,
    this._authRepo,
    this._onboardingRepo,
    this._prefsStore,
  ) : super(const AuthState()) {
    _restoreFromPreferences();
    _ref.listen<int>(sessionExpiredSignalProvider, (previous, next) {
      if (next > (previous ?? 0)) {
        handleSessionExpired();
      }
    });
  }

  final Ref _ref;
  final IAuthRepository _authRepo;
  final IOnboardingRepository _onboardingRepo;
  final AuthPreferencesStore _prefsStore;

  void _restoreFromPreferences() {
    final user = _prefsStore.loadUser();
    final nextStep = _prefsStore.loadNextStep();
    final pendingImage = _prefsStore.loadPendingProfileImage();
    if (user == null) {
      if (pendingImage != null) {
        state = state.copyWith(pendingProfileImageUrl: pendingImage);
      }
      return;
    }

    state = AuthState(
      sessionPhase: sessionPhaseFor(user, hasToken: true),
      user: user,
      nextStep: nextStep,
      phoneNumber: user.displayPhone,
      countryCode: user.countryCode,
      localPhone: user.phone,
      pendingProfileImageUrl: pendingImage,
    );
  }

  Future<void> _persistSession({
    required User user,
    OnboardingNextStep? nextStep,
  }) async {
    await _prefsStore.saveUser(user, nextStep: nextStep);
  }

  Future<void> restoreSession() async {
    state = state.copyWith(isRestoringSession: true, clearError: true);
    try {
      final token = await _authRepo.getToken();
      if (token == null || token.isEmpty) {
        state = state.copyWith(
          sessionPhase: SessionPhase.unauthenticated,
          isRestoringSession: false,
        );
        return;
      }

      final result = await _authRepo.fetchMe();
      final user = result.user;
      final nextStep = result.nextStep ?? _prefsStore.loadNextStep();
      final phase = sessionPhaseFor(user, hasToken: true);

      await _persistSession(user: user, nextStep: nextStep);
      state = state.copyWith(
        sessionPhase: phase,
        user: user,
        nextStep: nextStep,
        phoneNumber: user.displayPhone,
        countryCode: user.countryCode,
        localPhone: user.phone,
        isRestoringSession: false,
      );
    } catch (e) {
      await _authRepo.clearSession();
      await _prefsStore.clearUser();
      state = AuthState(
        isRestoringSession: false,
        error: ApiExceptionMapper.userMessage(e),
      );
    }
  }

  Future<void> sendOtp(String phoneE164) async {
    final split = PhoneUtils.splitE164(phoneE164);
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      phoneNumber: phoneE164,
      countryCode: split.dialCode,
      localPhone: split.localNumber,
    );
    try {
      final session = await _authRepo.sendOtp(
        countryCode: split.dialCode,
        phone: split.localNumber,
      );
      state = state.copyWith(isLoading: false, otpSession: session);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiExceptionMapper.userMessage(e),
      );
    }
  }

  Future<String?> verifyOtp(String otp) async {
    final referenceId =
        state.otpSession?.referenceId ?? await _authRepo.getOtpReferenceId();
    if (referenceId == null || referenceId.isEmpty) {
      state = state.copyWith(error: 'OTP session expired. Please resend OTP.');
      return null;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _authRepo.verifyOtp(
        referenceId: referenceId,
        otp: otp,
      );
      final user = result.user;
      final nextStep = result.nextStep;
      final phase = sessionPhaseFor(user, hasToken: true);

      await _persistSession(user: user, nextStep: nextStep);
      state = state.copyWith(
        sessionPhase: phase,
        user: user,
        nextStep: nextStep,
        isLoading: false,
        clearOtpSession: true,
      );
      return routeForNextStep(nextStep, user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiExceptionMapper.userMessage(e),
      );
      return null;
    }
  }

  Future<void> resendOtp() async {
    if ((state.otpSession?.resendRemaining ?? 0) <= 0) {
      return;
    }

    final referenceId =
        state.otpSession?.referenceId ?? await _authRepo.getOtpReferenceId();
    if (referenceId == null || referenceId.isEmpty) {
      if (state.phoneNumber != null) {
        await sendOtp(state.phoneNumber!);
      }
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final session = await _authRepo.resendOtp(referenceId: referenceId);
      state = state.copyWith(isLoading: false, otpSession: session);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiExceptionMapper.userMessage(e),
      );
    }
  }

  Future<String?> submitOnboardingRole(UserRole role) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _onboardingRepo.updateRole(role);
      final user = (result.user ?? state.user)?.copyWith(role: role);
      if (user == null) {
        throw Exception('User not available');
      }
      await _persistSession(user: user, nextStep: result.nextStep);
      state = state.copyWith(
        sessionPhase: sessionPhaseFor(user, hasToken: true),
        user: user,
        nextStep: result.nextStep,
        isLoading: false,
      );
      return routeForNextStep(result.nextStep, user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiExceptionMapper.userMessage(e),
      );
      return null;
    }
  }

  Future<String?> submitOnboardingLanguage(String languageCode) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _onboardingRepo.updateLanguage(languageCode);
      final user =
          state.user?.copyWith(language: result.language ?? languageCode);
      if (user != null) {
        await _persistSession(user: user, nextStep: result.nextStep);
      }
      state = state.copyWith(
        user: user,
        nextStep: result.nextStep,
        isLoading: false,
      );
      return routeForNextStep(result.nextStep, user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiExceptionMapper.userMessage(e),
      );
      return null;
    }
  }

  Future<String?> acceptOnboardingAgreement() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _onboardingRepo.acceptAgreement();
      final user = state.user?.copyWith(
        agreementAccepted: result.agreementAccepted ?? true,
      );
      final nextStep = result.nextStep;
      final phase = sessionPhaseAfterOnboardingStep(
        nextStep,
        user,
        hasToken: true,
      );
      if (user != null) {
        await _persistSession(user: user, nextStep: nextStep);
      }
      state = state.copyWith(
        sessionPhase: phase,
        user: user,
        nextStep: nextStep,
        isLoading: false,
      );
      return routeForNextStep(nextStep, user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiExceptionMapper.userMessage(e),
      );
      return null;
    }
  }

  Future<void> stageProfileImage(String localPath) async {
    final current = state.user;
    if (current != null) {
      final updated = current.copyWith(profileImageUrl: localPath);
      await _persistSession(user: updated, nextStep: state.nextStep);
      state = state.copyWith(user: updated);
      return;
    }

    await _prefsStore.savePendingProfileImage(localPath);
    state = state.copyWith(pendingProfileImageUrl: localPath);
  }

  Future<String?> submitCustomerProfile({
    required String name,
    required String phone,
    required String address,
    String? email,
    String? profileImageUrl,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final imageUrl = ProfileImageUtils.resolveForApiSubmission(
        savedReference: profileImageUrl ?? state.pendingProfileImageUrl,
      );
      final user = await _authRepo.createCustomerProfile(
        name: name,
        phone: phone,
        address: address,
        email: email,
        profileImageUrl: imageUrl,
      );
      final completed = user.copyWith(
        role: UserRole.customer,
        profileCompleted: true,
      );
      await _persistSession(user: completed, nextStep: OnboardingNextStep.home);
      await _prefsStore.clearPendingProfileImage();
      state = state.copyWith(
        sessionPhase: SessionPhase.authenticated,
        user: completed,
        nextStep: OnboardingNextStep.home,
        phoneNumber: completed.displayPhone,
        clearPendingProfileImage: true,
        isLoading: false,
      );
      return AppRoutes.customerHome;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiExceptionMapper.userMessage(e),
      );
      return null;
    }
  }

  Future<String?> submitDriverProfile({
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
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _authRepo.createDriverProfile(
        name: name,
        phone: phone,
        email: email,
        address: address,
        companyName: companyName,
        gstName: gstName,
        gstNumber: gstNumber,
        businessEmail: businessEmail,
        businessPhone: businessPhone,
        profileImageUrl: profileImageUrl,
      );
      final completed = user.copyWith(
        role: UserRole.driver,
        profileCompleted: true,
      );
      await _persistSession(user: completed, nextStep: OnboardingNextStep.home);
      await _prefsStore.clearPendingProfileImage();
      state = state.copyWith(
        sessionPhase: SessionPhase.authenticated,
        user: completed,
        nextStep: OnboardingNextStep.home,
        phoneNumber: completed.displayPhone,
        clearPendingProfileImage: true,
        isLoading: false,
      );
      return AppRoutes.driverHome;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiExceptionMapper.userMessage(e),
      );
      return null;
    }
  }

  Future<bool> updateCustomerProfile({
    required String name,
    required String phone,
    required String address,
    String? email,
    String? profileImageUrl,
  }) async {
    final current = state.user;
    if (current == null) {
      state = state.copyWith(error: 'No logged-in user');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updated = await _authRepo.updateCustomerProfile(
        name: name,
        address: address,
        email: email,
        profileImageUrl: profileImageUrl,
      );
      await _persistSession(user: updated, nextStep: state.nextStep);
      state = state.copyWith(
        user: updated,
        phoneNumber: updated.displayPhone,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiExceptionMapper.userMessage(e),
      );
      return false;
    }
  }

  Future<bool> updateDriverProfile({
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
    final current = state.user;
    if (current == null) {
      state = state.copyWith(error: 'No logged-in user');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updated = current.copyWith(
        name: name,
        phone: phone,
        email: email ?? '',
        address: address,
        companyName: companyName,
        gstName: gstName,
        gstNumber: gstNumber,
        businessEmail: businessEmail,
        businessPhone: businessPhone,
        profileImageUrl: profileImageUrl ?? current.profileImageUrl,
      );
      await _persistSession(user: updated, nextStep: state.nextStep);
      state = state.copyWith(
        user: updated,
        phoneNumber: updated.displayPhone,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiExceptionMapper.userMessage(e),
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authRepo.logout();
    } catch (_) {
      await _authRepo.clearSession();
    }
    await _prefsStore.clearUser();
    await _prefsStore.clearPendingProfileImage();
    state = const AuthState();
  }

  Future<void> handleSessionExpired() async {
    await _authRepo.clearSession();
    await _prefsStore.clearUser();
    state = const AuthState(
      error: 'Session expired. Please log in again.',
    );
  }

  void loginAsDummyUser(User user) {
    _persistSession(user: user, nextStep: OnboardingNextStep.home);
    state = AuthState(
      sessionPhase: SessionPhase.authenticated,
      user: user,
      nextStep: OnboardingNextStep.home,
      phoneNumber: user.displayPhone,
    );
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(
    ref,
    ref.read(authRepositoryProvider),
    ref.read(onboardingRepositoryProvider),
    AuthPreferencesStore(ref.read(sharedPreferencesProvider)),
  ),
);
