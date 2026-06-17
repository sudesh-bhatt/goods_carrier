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
import '../../features/customer/presentation/screens/support_center_screen.dart';
import '../../features/customer/presentation/screens/reported_trips_screen.dart';
import '../../features/customer/presentation/screens/saved_addresses_screen.dart';
import '../../features/customer/presentation/screens/shipment_form_screen.dart';
import '../../features/customer/presentation/screens/shipment_post_confirmation_screen.dart';
import '../../features/customer/presentation/models/shipment_post_confirmation_args.dart';
import '../../features/customer/presentation/screens/cancel_shipment_screen.dart';
import '../../features/customer/presentation/models/report_trip_confirmation_args.dart';
import '../../features/customer/presentation/models/report_trip_screen_args.dart';
import '../../features/customer/presentation/screens/customer_trip_detail_screen.dart';
import '../../features/customer/presentation/widgets/trip_detail/trip_detail_tokens.dart';
import '../../features/customer/presentation/screens/report_trip_screen.dart';
import '../../features/customer/presentation/screens/report_trip_success_screen.dart';
import '../../features/customer/presentation/models/shipment_cancel_confirmation_args.dart';
import '../../features/customer/presentation/screens/shipment_cancel_success_screen.dart';
import '../../features/customer/presentation/screens/shipment_detail_screen.dart';
import '../../features/customer/presentation/screens/tracking_screen.dart';
import '../../features/customer/presentation/tabs/customer_home_tab.dart';
import '../../features/customer/presentation/tabs/customer_notifications_tab.dart';
import '../../features/customer/presentation/tabs/customer_profile_tab.dart';
import '../../features/customer/presentation/tabs/customer_shipments_tab.dart';
import '../../features/driver/presentation/screens/driver_earnings_screen.dart';
import '../../shared/domain/enums/user_role.dart';
import '../../shared/presentation/screens/app_main_shell_screen.dart';
import '../../shared/presentation/widgets/navigation/app_tab_slide_container.dart';
import '../../features/driver/presentation/screens/driver_interest_success_screen.dart';
import '../../features/driver/presentation/models/driver_interest_success_args.dart';
import '../../features/driver/presentation/screens/cancel_trip_screen.dart';
import '../../features/driver/presentation/screens/driver_trip_detail_screen.dart';
import '../../features/driver/presentation/screens/trip_cancel_success_screen.dart';
import '../../features/driver/presentation/models/trip_cancel_confirmation_args.dart';
import '../../features/driver/presentation/screens/post_trip_screen.dart';
import '../../features/driver/presentation/tabs/driver_home_tab.dart';
import '../../features/driver/presentation/tabs/driver_my_trips_tab.dart';
import '../../features/driver/presentation/tabs/driver_notifications_tab.dart';
import '../../features/driver/presentation/tabs/driver_profile_tab.dart';
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

      if (loc == AppRoutes.splash) return null;

      if (auth.isAuthenticated) {
        if (loc == AppRoutes.terms) {
          return auth.user?.role == UserRole.driver
              ? AppRoutes.driverHome
              : AppRoutes.customerHome;
        }
        if (_isAuthFlowPath(loc)) {
          return auth.user?.role == UserRole.driver
              ? AppRoutes.driverHome
              : AppRoutes.customerHome;
        }
        return null;
      }

      if (auth.needsProfileSetup) {
        final target = auth.routeForCurrentStep;
        if (target != null && loc != target) return target;
        if (loc == AppRoutes.loginScreen || loc == AppRoutes.otpVerification) {
          return target ?? AppRoutes.roleSelection;
        }
        return null;
      }

      if (loc.startsWith('/customer') || loc.startsWith('/driver')) {
        return AppRoutes.loginScreen;
      }
      if (_isOnboardingOnlyPath(loc)) {
        return AppRoutes.loginScreen;
      }
      if (loc == AppRoutes.loginScreen || loc == AppRoutes.otpVerification) {
        return null;
      }
      return AppRoutes.loginScreen;
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
        builder: (_, state) {
          final document = state.extra is LegalDocument
              ? state.extra! as LegalDocument
              : LegalDocument.terms;
          return TermsScreen(document: document);
        },
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
          return AppMainShellScreen(
            role: UserRole.customer,
            navigationShell: navigationShell,
          );
        },
        navigatorContainerBuilder: (context, navigationShell, children) {
          return AppTabSlideContainer(
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
        path: AppRoutes.customerSupportCenter,
        builder: (_, __) => const SupportCenterScreen(),
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
        path: AppRoutes.cancelShipment,
        builder: (_, state) => CancelShipmentScreen(
          shipmentId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.shipmentCancelSuccess,
        builder: (_, state) {
          final extra = state.extra;
          if (extra is! ShipmentCancelConfirmationArgs) {
            return const SizedBox.shrink();
          }
          return ShipmentCancelSuccessScreen(args: extra);
        },
      ),
      GoRoute(
        path: AppRoutes.reportTripSuccess,
        builder: (_, state) {
          final extra = state.extra;
          if (extra is! ReportTripConfirmationArgs) {
            return const SizedBox.shrink();
          }
          return ReportTripSuccessScreen(args: extra);
        },
      ),
      GoRoute(
        path: AppRoutes.shipmentDetail,
        builder: (_, state) => ShipmentDetailScreen(
          shipmentId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.reportTrip,
        builder: (_, state) {
          final extra = state.extra;
          if (extra is ReportTripScreenArgs) {
            return ReportTripScreen(shipment: extra.shipment);
          }
          return ReportTripScreen(
            shipmentId: state.pathParameters['id']!,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.customerTripDetail,
        builder: (_, state) => CustomerTripDetailScreen(
          shipmentId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.tracking,
        builder: (_, state) => TrackingScreen(
          shipmentId: state.pathParameters['id']!,
        ),
      ),

      // ── Driver main shell (single scaffold, tab bodies only) ─────────
      StatefulShellRoute(
        builder: (context, state, navigationShell) {
          return AppMainShellScreen(
            role: UserRole.driver,
            navigationShell: navigationShell,
          );
        },
        navigatorContainerBuilder: (context, navigationShell, children) {
          return AppTabSlideContainer(
            currentIndex: navigationShell.currentIndex,
            children: children,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.driverHome,
                builder: (_, __) => const DriverHomeTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.driverMyTrips,
                builder: (_, __) => const DriverMyTripsTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.driverNotifications,
                builder: (_, __) => const DriverNotificationsTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.driverProfile,
                builder: (_, __) => const DriverProfileTab(),
              ),
            ],
          ),
        ],
      ),

      // ── Driver full-screen flows (outside shell) ─────────────────────
      // Static paths like `/driver/trip/cancel-success` must be registered
      // before `/driver/trip/:id` or GoRouter treats `cancel-success` as an id.
      GoRoute(
        path: AppRoutes.postTrip,
        builder: (_, __) => const PostTripScreen(),
      ),
      GoRoute(
        path: AppRoutes.editTrip,
        builder: (_, state) => PostTripScreen(
          tripId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: AppRoutes.tripCancelSuccess,
        builder: (_, state) {
          final extra = state.extra;
          if (extra is! TripCancelConfirmationArgs) {
            return const _RouterErrorPage(
              error: FormatException('Missing trip cancel success args'),
            );
          }
          return TripCancelSuccessScreen(args: extra);
        },
      ),
      GoRoute(
        path: AppRoutes.cancelTrip,
        builder: (_, state) => CancelTripScreen(
          tripId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.driverTripDetail,
        builder: (_, state) => DriverTripDetailScreen(
          tripId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.driverInterestSuccess,
        builder: (_, state) {
          final extra = state.extra;
          if (extra is! DriverInterestSuccessArgs) {
            return const _RouterErrorPage(
              error: FormatException('Missing interest success args'),
            );
          }
          return DriverInterestSuccessScreen(args: extra);
        },
      ),
      GoRoute(
        path: AppRoutes.driverShipmentDetail,
        builder: (_, state) => CustomerTripDetailScreen(
          shipmentId: state.pathParameters['id']!,
          audience: TripDetailAudience.driver,
        ),
      ),
      GoRoute(
        path: AppRoutes.driverEditProfile,
        builder: (_, __) => const DriverProfilePage(isEditMode: true),
      ),
      GoRoute(
        path: AppRoutes.driverEarnings,
        builder: (_, __) => const DriverEarningsScreen(),
      ),
    ],

    errorBuilder: (context, state) => _RouterErrorPage(error: state.error),
  );
});

/// Auth/onboarding paths — authenticated users are sent to their home shell.
bool _isAuthFlowPath(String loc) =>
    loc == AppRoutes.roleSelection ||
    loc == AppRoutes.languageSelection ||
    loc == AppRoutes.loginScreen ||
    loc == AppRoutes.otpVerification ||
    loc == AppRoutes.customerProfileSetup ||
    loc == AppRoutes.driverProfileSetup;

/// Onboarding paths that require a token (block when unauthenticated).
bool _isOnboardingOnlyPath(String loc) =>
    loc == AppRoutes.roleSelection ||
    loc == AppRoutes.languageSelection ||
    loc == AppRoutes.terms ||
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
