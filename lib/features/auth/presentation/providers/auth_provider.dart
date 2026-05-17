import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../../../core/providers/shared_preferences_provider.dart';
import '../../../../shared/data/local/auth_preferences_store.dart';
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
  final User? user;

  /// Set after role selection screen; drives profile-setup routing.
  final UserRole? selectedRole;

  /// Set after [LoginScreen]; displayed on OtpVerificationScreen.
  final String? phoneNumber;

  final bool isLoading;
  final String? error;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get needsProfileSetup => status == AuthStatus.profileSetupPending;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    UserRole? selectedRole,
    String? phoneNumber,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: clearUser ? null : (user ?? this.user),
        selectedRole: selectedRole ?? this.selectedRole,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo, this._prefsStore) : super(const AuthState()) {
    _restoreFromPreferences();
    _tryRestoreSession();
  }

  final IAuthRepository _repo;
  final AuthPreferencesStore _prefsStore;

  void _restoreFromPreferences() {
    final user = _prefsStore.loadUser();
    if (user == null) return;

    state = AuthState(
      status: AuthStatus.authenticated,
      user: user,
      selectedRole: user.role,
      phoneNumber: user.phone,
    );
  }

  Future<void> _persistUser(User user) => _prefsStore.saveUser(user);

  /// On cold start, checks secure storage for a valid access token.
  ///
  /// Profile restore from [AuthPreferencesStore] is handled synchronously in
  /// [_restoreFromPreferences]. Tokens remain for future remote API use.
  Future<void> _tryRestoreSession() async {
    if (state.isAuthenticated) return;

    try {
      final token = await _repo.getAccessToken();
      if (token != null) {
        final user = _prefsStore.loadUser();
        if (user != null) {
          state = AuthState(
            status: AuthStatus.authenticated,
            user: user,
            selectedRole: user.role,
            phoneNumber: user.phone,
          );
        }
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

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repo.sendOtp(phone);
      state = state.copyWith(phoneNumber: phone, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> verifyOtp(String otp) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final tokens = await _repo.verifyOtp(state.phoneNumber ?? '', otp);
      await _repo.saveTokens(
        accessToken: tokens['access_token']!,
        refreshToken: tokens['refresh_token']!,
      );

      final savedUser = _prefsStore.loadUser();
      if (savedUser != null) {
        await _persistUser(savedUser);
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: savedUser,
          selectedRole: savedUser.role,
          isLoading: false,
        );
        return;
      }

      state = state.copyWith(
        status: AuthStatus.profileSetupPending,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Profile setup ──────────────────────────────────────────────────────────

  Future<void> submitCustomerProfile({
    required String name,
    required String phone,
    required String address,
    String? email,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repo.createCustomerProfile(
        name: name,
        phone: phone,
        address: address,
        email: email,
      );
      await _persistUser(user);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> submitDriverProfile({
    required String name,
    required String vehicleNumber,
    required String vehicleType,
    required double capacityTons,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repo.createDriverProfile(
        name: name,
        vehicleNumber: vehicleNumber,
        vehicleType: vehicleType,
        capacityTons: capacityTons,
      );
      await _persistUser(user);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    try {
      await _repo.clearTokens();
      await _prefsStore.clearUser();
    } catch (_) {
      await _prefsStore.clearUser();
    }
    state = const AuthState();
  }

  // ── Dev helpers ────────────────────────────────────────────────────────────

  void loginAsDummyUser(User user) {
    _persistUser(user);
    state = AuthState(
      status: AuthStatus.authenticated,
      user: user,
      selectedRole: user.role,
    );
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(
    ref.read(authRepositoryProvider),
    AuthPreferencesStore(ref.read(sharedPreferencesProvider)),
  ),
);
