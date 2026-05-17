import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/num_ext.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/presentation/widgets/buttons/app_button.dart';
import '../../../../shared/presentation/widgets/feedback/error_view.dart';
import '../widgets/customer_light_chrome.dart';
import '../widgets/customer_subscreen_header.dart';
import '../../../../shared/presentation/widgets/navigation/confirmation_bottom_sheet.dart';
import '../../../../shared/presentation/widgets/route/route_timeline.dart';
import '../../../../shared/presentation/widgets/status/fragile_banner.dart';
import '../../../../shared/presentation/widgets/status/status_chip.dart';
import '../providers/customer_shipments_provider.dart';
import '../widgets/driver_detail_sheet.dart';

/// Full detail view for a single customer shipment.
///
/// Receives [shipmentId] via GoRouter path parameter `:id`.
/// Shows goods details, route, interested drivers, and cancel CTA for pending.
class ShipmentDetailScreen extends ConsumerWidget {
  const ShipmentDetailScreen({super.key, required this.shipmentId});

  final String shipmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors   = context.colors;
    final state    = ref.watch(customerShipmentsProvider);
    final shipment = state.shipments.where((s) => s.id == shipmentId).firstOrNull;

    if (shipment == null) {
      return Scaffold(
        appBar: CustomerSubscreenHeader(
          title: context.l10n.shipmentDetailsTitle,
        ),
        body: const ErrorView(message: 'Shipment not found.'),
      );
    }

    return CustomerLightChrome(
      child: Scaffold(
      backgroundColor: colors.background,
      appBar: CustomerSubscreenHeader(
        title: context.l10n.shipmentDetailsTitle,
        trailing: shipment.isPending
            ? IconButton(
                icon: const Icon(Icons.my_location_outlined),
                onPressed: () =>
                    context.push(AppRoutes.trackingOf(shipment.id)),
              )
            : SizedBox(width: 32.w),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.screenPadding.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppDimensions.xl.h),

                    // ── Status row ────────────────────────────────────────
                    Row(
                      children: [
                        StatusChip.shipment(
                            context: context, status: shipment.status),
                        const Spacer(),
                        Text(
                          shipment.estimatedPrice.inr,
                          style: context.textTheme.titleLarge?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: AppDimensions.xl.h),

                    // ── Route ─────────────────────────────────────────────
                    _SectionCard(
                      title: 'Route',
                      child: RouteTimeline(
                        fromCity:     shipment.pickup.city,
                        toCity:       shipment.drop.city,
                        fromSubtitle: shipment.pickup.fullAddress,
                        toSubtitle:   shipment.drop.fullAddress,
                      ),
                    ),

                    SizedBox(height: AppDimensions.base.h),

                    // ── Addresses ─────────────────────────────────────────
                    _SectionCard(
                      title: 'Locations',
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.location_on_outlined,
                            label: context.l10n.shipmentPickup,
                            value: shipment.pickup.fullAddress,
                          ),
                          Divider(height: AppDimensions.xl.h, color: colors.divider),
                          _DetailRow(
                            icon: Icons.flag_outlined,
                            label: context.l10n.shipmentDrop,
                            value: shipment.drop.fullAddress,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppDimensions.base.h),

                    // ── Goods details ──────────────────────────────────────
                    _SectionCard(
                      title: context.l10n.shipmentGoods,
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.category_outlined,
                            label: context.l10n.shipmentGoodsType,
                            value: shipment.goods.type,
                          ),
                          Divider(height: AppDimensions.xl.h, color: colors.divider),
                          _DetailRow(
                            icon: Icons.scale_outlined,
                            label: context.l10n.shipmentWeight,
                            value: shipment.goods.weightLabel,
                          ),
                          Divider(height: AppDimensions.xl.h, color: colors.divider),
                          _DetailRow(
                            icon: Icons.local_shipping_outlined,
                            label: context.l10n.profileVehicleType,
                            value: shipment.vehicleType.label,
                          ),
                          if (shipment.goods.specialInstructions != null) ...[
                            Divider(height: AppDimensions.xl.h, color: colors.divider),
                            _DetailRow(
                              icon: Icons.notes_outlined,
                              label: context.l10n.shipmentSpecialInstructions,
                              value: shipment.goods.specialInstructions!,
                            ),
                          ],
                        ],
                      ),
                    ),

                    if (shipment.goods.isFragile) ...[
                      SizedBox(height: AppDimensions.base.h),
                      const FragileBanner(),
                    ],

                    SizedBox(height: AppDimensions.base.h),

                    // ── Schedule ──────────────────────────────────────────
                    _SectionCard(
                      title: 'Schedule',
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Pickup',
                            value:
                                '${shipment.pickupDateTime.day}/${shipment.pickupDateTime.month}/${shipment.pickupDateTime.year}',
                          ),
                          Divider(height: AppDimensions.xl.h, color: colors.divider),
                          _DetailRow(
                            icon: Icons.event_available_outlined,
                            label: 'Expected Delivery',
                            value:
                                '${shipment.dropDateTime.day}/${shipment.dropDateTime.month}/${shipment.dropDateTime.year}',
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppDimensions.xl.h),
                  ],
                ),
              ),
            ),

            // ── Interested drivers ─────────────────────────────────────────
            if (shipment.interestedDriverIds.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.screenPadding.w),
                  child: Text(
                    context.l10n.shipmentInterestedDrivers,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: AppDimensions.base.h)),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final driverId = shipment.interestedDriverIds[i];
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppDimensions.screenPadding.w,
                        0,
                        AppDimensions.screenPadding.w,
                        AppDimensions.sm.h,
                      ),
                      child: _InterestedDriverCard(
                        driverId: driverId,
                        onSelect: () => DriverDetailSheet.show(
                          context,
                          driverId:   driverId,
                          shipmentId: shipment.id,
                        ),
                      ),
                    );
                  },
                  childCount: shipment.interestedDriverIds.length,
                ),
              ),
            ],

            // ── No drivers yet ─────────────────────────────────────────────
            if (shipment.interestedDriverIds.isEmpty && shipment.isPending)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.screenPadding.w),
                  child: Container(
                    padding: EdgeInsets.all(AppDimensions.xl.w),
                    decoration: BoxDecoration(
                      color: colors.cardBackground,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMd.r),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.people_outline_rounded,
                              size: 48.w, color: colors.textHint),
                          SizedBox(height: AppDimensions.sm.h),
                          Text(
                            context.l10n.shipmentNoDriversYet,
                            style: context.textTheme.bodyMedium?.copyWith(
                                color: colors.textHint),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            SliverToBoxAdapter(child: SizedBox(height: AppDimensions.xxxl.h)),
          ],
        ),
      ),

      // ── Cancel CTA (pending only) ─────────────────────────────────────────
      bottomNavigationBar: shipment.isPending
          ? SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppDimensions.screenPadding.w,
                  AppDimensions.sm.h,
                  AppDimensions.screenPadding.w,
                  AppDimensions.base.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppButton(
                      label: context.l10n.shipmentEditTitle,
                      onPressed: () => context.push(
                        AppRoutes.editShipmentOf(shipment.id),
                      ),
                    ),
                    SizedBox(height: AppDimensions.sm.h),
                    AppButton(
                      label: 'Cancel Shipment',
                      variant: AppButtonVariant.secondary,
                      onPressed: () async {
                    final confirmed = await ConfirmationBottomSheet.show(
                      context,
                      title:       'Cancel Shipment?',
                      body:        'This will cancel shipment ${shipment.id}. This action cannot be undone.',
                      confirmLabel: context.l10n.actionYes,
                      isDangerous:  true,
                    );
                    if (confirmed == true && context.mounted) {
                      ref
                          .read(customerShipmentsProvider.notifier)
                          .cancelShipment(shipment.id);
                      context.pop();
                    }
                  },
                    ),
                  ],
                ),
              ),
            )
          : null,
    ),
    );
  }
}

// ─── Section card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.all(AppDimensions.base.w),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.labelMedium?.copyWith(
              color: colors.textHint,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: AppDimensions.sm.h),
          child,
        ],
      ),
    );
  }
}

// ─── Detail row ───────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String   label;
  final String   value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppDimensions.iconMd.w, color: colors.primary),
        SizedBox(width: AppDimensions.sm.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                    color: colors.textHint),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Interested driver card ────────────────────────────────────────────────────

class _InterestedDriverCard extends StatelessWidget {
  const _InterestedDriverCard({
    required this.driverId,
    required this.onSelect,
  });

  final String driverId;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        padding: EdgeInsets.all(AppDimensions.base.w),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
          boxShadow: context.cardShadow,
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.drive_eta_outlined,
                  size: AppDimensions.iconBase.w, color: colors.primary),
            ),
            SizedBox(width: AppDimensions.sm.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Driver $driverId',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Tap to view profile & select',
                    style: context.textTheme.bodySmall?.copyWith(
                        color: colors.textHint),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: colors.textHint, size: AppDimensions.iconBase.w),
          ],
        ),
      ),
    );
  }
}
