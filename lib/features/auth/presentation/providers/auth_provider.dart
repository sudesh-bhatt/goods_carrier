import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../../../shared/domain/entities/user.dart';
import '../../../../shared/domain/enums/user_role.dart';
import '../../../../shared/domain/repositories/i_auth_repository.dart';

// ─── Auth status ──────────────────────────────────────────────────────────────

enum AuthStatus {
  /// Not logged in — show splash → role → language → terms → phone → otp.
  unauthenticated,

  /// OTP verified, profile form not yet submitted.
  profileSetupPending,

  /// Fully authenticated — show home screen for their role.
  authenticated,
}

// ─── Auth state ───────────────────────────────────────────────────────────────

class AuthState {
  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.user,
    this.selectedRole,
    this.phoneNumber,
    this.isLoading = false,
    this.error,
  });

  final AuthStatus status;
  final User?      user;

  /// Set after role selection screen; drives profile-setup routing.
  final UserRole? selectedRole;

  /// Set after PhoneInputScreen; displayed on OtpVerificationScreen.
  final String? phoneNumber;

  final bool    isLoading;
  final String? error;

  bool get isAuthenticated   => status == AuthStatus.authenticated;
  bool get needsProfileSetup => status == AuthStatus.profileSetupPending;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;

  AuthState copyWith({
    AuthStatus? status,
    User?       user,
    UserRole?   selectedRole,
    String?     phoneNumber,
    bool?       isLoading,
    String?     error,
    bool        clearError = false,
    bool        clearUser  = false,
  }) =>
      AuthState(
        status:       status       ?? this.status,
        user:         clearUser    ? null : (user ?? this.user),
        selectedRole: selectedRole ?? this.selectedRole,
        phoneNumber:  phoneNumber  ?? this.phoneNumber,
        isLoading:    isLoading    ?? this.isLoading,
        error:        clearError   ? null : (error ?? this.error),
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo) : super(const AuthState()) {
    _tryRestoreSession();
  }

  final IAuthRepository _repo;

  // ── Session restore ────────────────────────────────────────────────────────

  /// On cold start, checks secure storage for a valid access token.
  ///
  /// Local mode: no token is ever stored by [LocalAuthRepository], so this
  /// always leaves state as [AuthStatus.unauthenticated].
  /// Remote mode: if a token exists the app skips the auth flow.
  /// A full implementation would call a /me endpoint to fetch the User.
  Future<void> _tryRestoreSession() async {
    try {
      final token = await _repo.getAccessToken();
      if (token != null) {
        // TODO(remote): call /me and populate state.user before flipping to
        // authenticated.  Skipped here — LocalAuthRepository never stores
        // a token so this branch is never reached in dev mode.
      }
    } catch (_) {
      // Silently swallow — worst case the user re-authenticates.
    }
  }

  // ── Role selection ─────────────────────────────────────────────────────────

  void selectRole(UserRole role) {
    state = state.copyWith(selectedRole: role, clearError: true);
  }

  // ── OTP flow ───────────────────────────────────────────────────────────────

  /// Trigger OTP SMS to [phone].
  ///
  /// Local mode: simulates an 800 ms network delay and always succeeds.
  /// Remote mode: POST /auth/otp/send.
  Future<void> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repo.sendOtp(phone);
      state = state.copyWith(phoneNumber: phone, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Validate [otp] entered by the user.
  ///
  /// Local mode: any 4-digit code succeeds.
  /// Remote mode: POST /auth/otp/verify → receives access + refresh tokens,
  /// persists them in secure storage, then transitions to
  /// [AuthStatus.profileSetupPending].
  Future<void> verifyOtp(String otp) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final tokens = await _repo.verifyOtp(state.phoneNumber ?? '', otp);
      await _repo.saveTokens(
        accessToken:  tokens['access_token']!,
        refreshToken: tokens['refresh_token']!,
      );
      state = state.copyWith(
        status:    AuthStatus.profileSetupPending,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Profile setup ──────────────────────────────────────────────────────────

  /// Submit customer profile form.
  ///
  /// Local mode: builds a dummy [User] and moves to [AuthStatus.authenticated].
  /// Remote mode: POST /customer/profile → returns the persisted [User].
  Future<void> submitCustomerProfile({
    required String name,
    required String email,
    String? companyName,
    String? gstNumber,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repo.createCustomerProfile(
        name:        name,
        email:       email,
        companyName: companyName,
        gstNumber:   gstNumber,
      );
      state = state.copyWith(
        status:    AuthStatus.authenticated,
        user:      user,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Submit driver profile form.
  ///
  /// Local mode: builds a dummy [User] and moves to [AuthStatus.authenticated].
  /// Remote mode: POST /driver/profile → returns the persisted [User].
  Future<void> submitDriverProfile({
    required String name,
    required String vehicleNumber,
    required String vehicleType,
    required double capacityTons,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repo.createDriverProfile(
        name:          name,
        vehicleNumber: vehicleNumber,
        vehicleType:   vehicleType,
        capacityTons:  capacityTons,
      );
      state = state.copyWith(
        status:    AuthStatus.authenticated,
        user:      user,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  /// Clears tokens from secure storage and resets state to unauthenticated.
  Future<void> logout() async {
    try {
      await _repo.clearTokens();
    } catch (_) {
      // Clear local state regardless of remote failure.
    }
    state = const AuthState();
  }

  // ── Dev helpers ────────────────────────────────────────────────────────────

  /// Skip the full auth flow with a pre-built dummy user.
  /// Only used by the debug quick-login on the role-selection screen.
  void loginAsDummyUser(User user) {
    state = AuthState(
      status:       AuthStatus.authenticated,
      user:         user,
      selectedRole: user.role,
    );
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(authRepositoryProvider)),
);
