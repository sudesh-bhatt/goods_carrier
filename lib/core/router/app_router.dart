import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/customer_profile_setup_screen.dart';
import '../../features/auth/presentation/screens/driver_profile_setup_screen.dart';
import '../../features/auth/presentation/screens/language_selection_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/phone_input_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/terms_screen.dart';
import '../../features/customer/presentation/screens/customer_history_screen.dart';
import '../../features/customer/presentation/screens/customer_home_screen.dart';
import '../../features/customer/presentation/screens/customer_notifications_screen.dart';
import '../../features/customer/presentation/screens/customer_profile_screen.dart';
import '../../features/customer/presentation/screens/post_shipment_screen.dart';
import '../../features/customer/presentation/screens/shipment_detail_screen.dart';
import '../../features/customer/presentation/screens/tracking_screen.dart';
import '../../features/driver/presentation/screens/driver_earnings_screen.dart';
import '../../features/driver/presentation/screens/driver_home_screen.dart';
import '../../features/driver/presentation/screens/driver_notifications_screen.dart';
import '../../features/driver/presentation/screens/driver_profile_screen.dart';
import '../../features/driver/presentation/screens/driver_trip_detail_screen.dart';
import '../../features/driver/presentation/screens/post_trip_screen.dart';
import '../../shared/domain/enums/user_role.dart';
import 'app_routes.dart';

// ─── Router notifier ──────────────────────────────────────────────────────────

/// [ChangeNotifier] that bridges Riverpod's [authProvider] to GoRouter's
/// [refreshListenable]. GoRouter re-evaluates the redirect whenever
/// [AuthState] changes.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}

// ─── Router provider ──────────────────────────────────────────────────────────

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    refreshListenable: notifier,

    // ── Redirect ──────────────────────────────────────────────────────────
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loc  = state.matchedLocation;

      // 1. Authenticated → redirect away from any auth/onboarding path.
      if (auth.isAuthenticated) {
        final isOnAuthPath = _isAuthPath(loc);
        if (isOnAuthPath) {
          return auth.user!.role == UserRole.customer
              ? AppRoutes.customerHome
              : AppRoutes.driverHome;
        }
        return null; // already on a valid home screen
      }

      // 2. Profile setup pending → redirect to the correct setup screen.
      if (auth.needsProfileSetup) {
        final setupPath = auth.selectedRole == UserRole.customer
            ? AppRoutes.customerProfileSetup
            : AppRoutes.driverProfileSetup;
        if (loc != setupPath) return setupPath;
        return null;
      }

      // 3. Unauthenticated → allow free navigation through the onboarding flow;
      //    block any attempt to jump directly into home screens.
      if (loc.startsWith('/customer') || loc.startsWith('/driver')) {
        return AppRoutes.splash;
      }
      return null;
    },

    // ── Routes ───────────────────────────────────────────────────────────
    routes: [
      // ── Auth / Onboarding ──────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (_, __) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.languageSelection,
        builder: (_, __) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.terms,
        builder: (_, __) => const TermsScreen(),
      ),
      GoRoute(
        path: AppRoutes.phoneInput,
        builder: (_, __) => const PhoneInputScreen(),
      ),
      GoRoute(
        path: AppRoutes.otpVerification,
        builder: (_, __) => const OtpVerificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerProfileSetup,
        builder: (_, __) => const CustomerProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.driverProfileSetup,
        builder: (_, __) => const DriverProfileSetupScreen(),
      ),

      // ── Customer screens (Session 4) ───────────────────────────────────
      GoRoute(
        path: AppRoutes.customerHome,
        builder: (_, __) => const CustomerHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.postShipment,
        builder: (_, __) => const PostShipmentScreen(),
      ),
      GoRoute(
        path: AppRoutes.shipmentDetail,        // '/customer/shipment/:id'
        builder: (_, state) => ShipmentDetailScreen(
          shipmentId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.tracking,              // '/customer/tracking/:id'
        builder: (_, state) => TrackingScreen(
          shipmentId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.customerNotifications,
        builder: (_, __) => const CustomerNotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerProfile,
        builder: (_, __) => const CustomerProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerHistory,
        builder: (_, __) => const CustomerHistoryScreen(),
      ),

      // ── Driver screens (Session 5) ────────────────────────────────────
      GoRoute(
        path: AppRoutes.driverHome,
        builder: (_, __) => const DriverHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.postTrip,
        builder: (_, __) => const PostTripScreen(),
      ),
      GoRoute(
        path: AppRoutes.driverTripDetail,         // '/driver/trip/:id'
        builder: (_, state) => DriverTripDetailScreen(
          tripId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.driverNotifications,
        builder: (_, __) => const DriverNotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.driverProfile,
        builder: (_, __) => const DriverProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.driverEarnings,
        builder: (_, __) => const DriverEarningsScreen(),
      ),
    ],

    errorBuilder: (context, state) => _RouterErrorPage(error: state.error),
  );
});

// ─── Helper ───────────────────────────────────────────────────────────────────

bool _isAuthPath(String loc) =>
    loc == AppRoutes.splash ||
    loc == AppRoutes.roleSelection ||
    loc == AppRoutes.languageSelection ||
    loc == AppRoutes.terms ||
    loc == AppRoutes.phoneInput ||
    loc == AppRoutes.otpVerification ||
    loc == AppRoutes.customerProfileSetup ||
    loc == AppRoutes.driverProfileSetup;

// ─── Error page ───────────────────────────────────────────────────────────────

class _RouterErrorPage extends StatelessWidget {
  const _RouterErrorPage({required this.error});
  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Route not found\n${error?.toString() ?? ''}',
            textAlign: TextAlign.center),
      ),
    );
  }
}
