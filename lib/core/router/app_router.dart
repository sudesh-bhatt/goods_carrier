import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/customer_profile_setup_screen.dart';
import '../../features/auth/presentation/screens/driver_profile_setup_screen.dart';
import '../../features/auth/presentation/screens/language_selection_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/terms_screen.dart';
import '../../features/customer/presentation/screens/add_address_screen.dart';
import '../../features/customer/presentation/screens/customer_edit_profile_screen.dart';
import '../../features/customer/presentation/screens/customer_settings_screen.dart';
import '../../features/customer/presentation/screens/reported_trips_screen.dart';
import '../../features/customer/presentation/screens/saved_addresses_screen.dart';
import '../../features/customer/presentation/screens/customer_main_shell_screen.dart';
import '../../features/customer/presentation/widgets/customer_tab_slide_container.dart';
import '../../features/customer/presentation/screens/shipment_form_screen.dart';
import '../../features/customer/presentation/screens/shipment_post_confirmation_screen.dart';
import '../../features/customer/presentation/models/shipment_post_confirmation_args.dart';
import '../../features/customer/presentation/screens/shipment_detail_screen.dart';
import '../../features/customer/presentation/screens/tracking_screen.dart';
import '../../features/customer/presentation/tabs/customer_home_tab.dart';
import '../../features/customer/presentation/tabs/customer_notifications_tab.dart';
import '../../features/customer/presentation/tabs/customer_profile_tab.dart';
import '../../features/customer/presentation/tabs/customer_shipments_tab.dart';
import '../../features/driver/presentation/screens/driver_earnings_screen.dart';
import '../../features/driver/presentation/screens/driver_home_screen.dart';
import '../../features/driver/presentation/screens/driver_notifications_screen.dart';
import '../../features/driver/presentation/screens/driver_profile_screen.dart';
import '../../features/driver/presentation/screens/driver_trip_detail_screen.dart';
import '../../features/driver/presentation/screens/post_trip_screen.dart';
import '../../shared/domain/enums/user_role.dart';
import 'app_routes.dart';

// ─── Router notifier ──────────────────────────────────────────────────────────

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

    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loc = state.matchedLocation;

      if (auth.isAuthenticated) {
        final isOnAuthPath = _isAuthPath(loc);
        if (isOnAuthPath && loc != AppRoutes.splash) {
          return auth.user!.role == UserRole.customer
              ? AppRoutes.customerHome
              : AppRoutes.driverHome;
        }
        return null;
      }

      if (auth.needsProfileSetup) {
        final setupPath = auth.selectedRole == UserRole.customer
            ? AppRoutes.customerProfileSetup
            : AppRoutes.driverProfileSetup;
        if (loc != setupPath) return setupPath;
        return null;
      }

      if (loc.startsWith('/customer') || loc.startsWith('/driver')) {
        return AppRoutes.splash;
      }
      return null;
    },

    routes: [
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
        path: AppRoutes.loginScreen,
        builder: (_, __) => const LoginScreen(),
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

      // ── Customer main shell (single scaffold, tab bodies only) ─────────
      StatefulShellRoute(
        builder: (context, state, navigationShell) {
          return CustomerMainShellScreen(navigationShell: navigationShell);
        },
        navigatorContainerBuilder: (context, navigationShell, children) {
          return CustomerTabSlideContainer(
            currentIndex: navigationShell.currentIndex,
            children: children,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.customerHome,
                builder: (_, __) => const CustomerHomeTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.customerHistory,
                builder: (_, __) => const CustomerShipmentsTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.customerNotifications,
                builder: (_, __) => const CustomerNotificationsTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.customerProfile,
                builder: (_, __) => const CustomerProfileTab(),
              ),
            ],
          ),
        ],
      ),

      // ── Customer full-screen flows (outside shell) ─────────────────────
      GoRoute(
        path: AppRoutes.customerEditProfile,
        builder: (_, __) => const CustomerEditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerSettings,
        builder: (_, __) => const CustomerSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerReportedTrips,
        builder: (_, __) => const ReportedTripsScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerSavedAddresses,
        builder: (_, __) => const SavedAddressesScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerAddAddress,
        builder: (_, __) => const AddAddressScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerEditAddress,
        builder: (_, state) => AddAddressScreen(
          addressId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: AppRoutes.postShipment,
        builder: (_, __) => const ShipmentFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.shipmentPostConfirmation,
        builder: (_, state) {
          final extra = state.extra;
          if (extra is! ShipmentPostConfirmationArgs) {
            return const SizedBox.shrink();
          }
          return ShipmentPostConfirmationScreen(args: extra);
        },
      ),
      GoRoute(
        path: AppRoutes.editShipment,
        builder: (_, state) => ShipmentFormScreen(
          shipmentId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: AppRoutes.shipmentDetail,
        builder: (_, state) => ShipmentDetailScreen(
          shipmentId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.tracking,
        builder: (_, state) => TrackingScreen(
          shipmentId: state.pathParameters['id']!,
        ),
      ),

      GoRoute(
        path: AppRoutes.driverHome,
        builder: (_, __) => const DriverHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.postTrip,
        builder: (_, __) => const PostTripScreen(),
      ),
      GoRoute(
        path: AppRoutes.driverTripDetail,
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

bool _isAuthPath(String loc) =>
    loc == AppRoutes.splash ||
    loc == AppRoutes.roleSelection ||
    loc == AppRoutes.languageSelection ||
    loc == AppRoutes.terms ||
    loc == AppRoutes.loginScreen ||
    loc == AppRoutes.otpVerification ||
    loc == AppRoutes.customerProfileSetup ||
    loc == AppRoutes.driverProfileSetup;

class _RouterErrorPage extends StatelessWidget {
  const _RouterErrorPage({required this.error});
  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Route not found\n${error?.toString() ?? ''}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
