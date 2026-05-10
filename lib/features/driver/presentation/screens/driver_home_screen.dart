import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/presentation/widgets/cards/driver_trip_card.dart';
import '../../../../shared/presentation/widgets/feedback/empty_state.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/driver_notifications_provider.dart';
import '../providers/driver_shipment_requests_provider.dart';
import '../providers/driver_trips_provider.dart';
import '../widgets/express_interest_sheet.dart';
import '../widgets/shipment_request_card.dart';

/// Driver landing screen.
///
/// Two sections:
///  1. "My Active Trips" — [DriverTripCard] list from [driverTripsProvider]
///  2. "Available Requests" — [ShipmentRequestCard] feed from
///     [driverShipmentRequestsProvider], filtered to pending shipments
///
/// AppBar shows notification badge + profile action.
/// FAB → [PostTripScreen].
class DriverHomeScreen extends ConsumerWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors       = context.colors;
    final user         = ref.watch(authProvider).user;
    final tripsState   = ref.watch(driverTripsProvider);
    final requestState = ref.watch(driverShipmentRequestsProvider);
    final unreadCount  = ref.watch(driverUnreadCountProvider);

    final activeTrips  = tripsState.active;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBarWidget(
        title: context.l10n.appName,
        leadingType: AppBarLeadingType.none,
        actions: [
          AppBarAction(
            icon: Icons.notifications_outlined,
            badgeCount: unreadCount,
            onTap: () => context.push(AppRoutes.driverNotifications),
          ),
          AppBarAction(
            icon: Icons.person_outline_rounded,
            onTap: () => context.push(AppRoutes.driverProfile),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: colors.primary,
          // Session 7: replace with actual data refresh call
          onRefresh: () => Future.delayed(const Duration(milliseconds: 600)),
          child: CustomScrollView(
          slivers: [
            // ── Greeting ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppDimensions.screenPadding.w,
                  AppDimensions.xl.h,
                  AppDimensions.screenPadding.w,
                  AppDimensions.base.h,
                ),
                child: Text(
                  'Ready to roll, ${user?.name.split(' ').first ?? 'Driver'} 🚛',
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            // ── My Active Trips ───────────────────────────────────────────
            if (activeTrips.isNotEmpty) ...[
              _SectionHeader(
                title: 'My Active Trips',
                actionLabel: 'All trips',
                onAction: () => context.push(AppRoutes.driverProfile),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.screenPadding.w),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final trip = activeTrips[i];
                      return Padding(
                        padding: EdgeInsets.only(bottom: AppDimensions.base.h),
                        child: DriverTripCard(
                          trip: trip,
                          actionLabel: 'View Detail',
                          onAction: () => context.push(
                              AppRoutes.driverTripDetailOf(trip.id)),
                          onTap: () => context.push(
                              AppRoutes.driverTripDetailOf(trip.id)),
                        ),
                      );
                    },
                    childCount: activeTrips.length,
                  ),
                ),
              ),
            ],

            // ── Available Requests section header ─────────────────────────
            _SectionHeader(
              title: 'Available Requests',
              actionLabel: '',
              onAction: null,
            ),

            // ── Loading ───────────────────────────────────────────────────
            if (requestState.all.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.only(bottom: AppDimensions.xxxl.h),
                  child: EmptyState(
                    headline: context.l10n.emptyShipments,
                    subtitle:
                        'No shipment requests available in your area right now',
                    fallbackIcon: Icons.search_off_rounded,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppDimensions.screenPadding.w,
                  0,
                  AppDimensions.screenPadding.w,
                  AppDimensions.xxxl.h,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final shipment = requestState.all[i];
                      return Padding(
                        padding: EdgeInsets.only(bottom: AppDimensions.base.h),
                        child: ShipmentRequestCard(
                          shipment:     shipment,
                          hasExpressed: requestState.hasExpressed(shipment.id),
                          onExpress: () async {
                            await ExpressInterestSheet.show(
                              ctx,
                              shipment: shipment,
                            );
                          },
                        ),
                      );
                    },
                    childCount: requestState.all.length,
                  ),
                ),
              ),
          ],
          ),
        ),
      ),

      // ── FAB ──────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.postTrip),
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_road_rounded),
        label: Text(
          context.l10n.tripPostNew,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.screenPadding.w,
          AppDimensions.sm.h,
          AppDimensions.screenPadding.w,
          AppDimensions.sm.h,
        ),
        child: Row(
          children: [
            Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            if (onAction != null && actionLabel.isNotEmpty)
              GestureDetector(
                onTap: onAction,
                child: Text(
                  actionLabel,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
