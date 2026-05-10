import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/presentation/widgets/cards/shipment_card.dart';
import '../../../../shared/presentation/widgets/feedback/empty_state.dart';
import '../../../../shared/presentation/widgets/feedback/skeleton_card.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/customer_notifications_provider.dart';
import '../providers/customer_shipments_provider.dart';

/// Customer landing screen.
///
/// Displays the user's active + pending shipments with a FAB to post a new one.
/// The AppBar badge reflects unread notification count from
/// [customerUnreadCountProvider].
class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors       = context.colors;
    final state        = ref.watch(customerShipmentsProvider);
    final user         = ref.watch(authProvider).user;
    final unreadCount  = ref.watch(customerUnreadCountProvider);
    final activeList   = state.active;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBarWidget(
        title: context.l10n.appName,
        leadingType: AppBarLeadingType.none,
        actions: [
          AppBarAction(
            icon: Icons.notifications_outlined,
            badgeCount: unreadCount,
            onTap: () => context.push(AppRoutes.customerNotifications),
          ),
          AppBarAction(
            icon: Icons.person_outline_rounded,
            onTap: () => context.push(AppRoutes.customerProfile),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: colors.primary,
          // Session 7: replace with actual refresh call
          onRefresh: () => Future.delayed(const Duration(milliseconds: 600)),
          child: CustomScrollView(
          slivers: [
            // ── Greeting header ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppDimensions.screenPadding.w,
                  AppDimensions.xl.h,
                  AppDimensions.screenPadding.w,
                  AppDimensions.base.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user?.name.split(' ').first ?? 'there'} 👋',
                      style: context.textTheme.headlineSmall?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: AppDimensions.xs.h),
                    Text(
                      activeList.isEmpty
                          ? context.l10n.emptyShipmentsSubtitle
                          : context.l10n.shipmentActiveCount(activeList.length),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Loading skeletons ─────────────────────────────────────────
            if (state.isLoading)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, __) => Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.screenPadding.w,
                      vertical: AppDimensions.sm.h,
                    ),
                    child: const SkeletonCard(),
                  ),
                  childCount: 3,
                ),
              )

            // ── Empty state ───────────────────────────────────────────────
            else if (activeList.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.only(bottom: AppDimensions.xxxl.h),
                  child: EmptyState(
                    headline: context.l10n.emptyShipments,
                    subtitle: context.l10n.emptyShipmentsSubtitle,
                    fallbackIcon: Icons.local_shipping_outlined,
                    actionLabel: context.l10n.shipmentPostNew,
                    onAction: () => context.push(AppRoutes.postShipment),
                  ),
                ),
              )

            // ── Active shipments list ──────────────────────────────────────
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenPadding.w,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final shipment = activeList[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: AppDimensions.base.h),
                        child: ShipmentCard(
                          shipment: shipment,
                          actionLabel: context.l10n.actionSelect,
                          onAction: () => context.push(
                            AppRoutes.shipmentDetailOf(shipment.id),
                          ),
                          onTap: () => context.push(
                            AppRoutes.shipmentDetailOf(shipment.id),
                          ),
                        ),
                      );
                    },
                    childCount: activeList.length,
                  ),
                ),
              ),

            // ── History shortcut ──────────────────────────────────────────
            if (activeList.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppDimensions.screenPadding.w,
                    AppDimensions.sm.h,
                    AppDimensions.screenPadding.w,
                    AppDimensions.xxxl.h,
                  ),
                  child: TextButton.icon(
                    onPressed: () => context.push(AppRoutes.customerHistory),
                    icon: const Icon(Icons.history_rounded),
                    label: Text(context.l10n.emptyHistory),
                  ),
                ),
              ),
          ],
          ),
        ),
      ),

      // ── FAB ──────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.postShipment),
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          context.l10n.shipmentPostNew,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
