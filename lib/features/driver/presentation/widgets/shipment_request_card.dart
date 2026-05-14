import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/num_ext.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../shared/domain/entities/shipment.dart';
import '../../../../shared/presentation/widgets/route/route_timeline.dart';
import '../../../../shared/presentation/widgets/status/fragile_banner.dart';
import '../../../../shared/presentation/widgets/status/status_chip.dart';

/// Card in the driver's shipment-request feed.
///
/// Shows TRK-ID, route, goods summary, vehicle required, price estimate, and
/// a "Express Interest" CTA. Uses [compact] RouteTimeline variant.
///
/// ```dart
/// ShipmentRequestCard(
///   shipment:  s,
///   hasExpressed: false,
///   onExpress: () => ExpressInterestSheet.show(context, shipment: s),
/// )
/// ```
class ShipmentRequestCard extends StatelessWidget {
  const ShipmentRequestCard({
    super.key,
    required this.shipment,
    required this.hasExpressed,
    required this.onExpress,
    this.onTap,
  });

  final Shipment shipment;
  final bool hasExpressed;
  final VoidCallback onExpress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg.r),
          boxShadow: context.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ─────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.base.w,
                AppDimensions.base.h,
                AppDimensions.base.w,
                AppDimensions.sm.h,
              ),
              child: Row(
                children: [
                  // TRK-ID chip
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.sm.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
                    ),
                    child: Text(
                      shipment.id,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  StatusChip.shipment(context: context, status: shipment.status),
                ],
              ),
            ),

            // ── Route timeline ─────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.base.w),
              child: RouteTimeline(
                fromCity: shipment.pickup.city,
                toCity:   shipment.drop.city,
                compact:  true,
              ),
            ),

            // ── Fragile banner ─────────────────────────────────────────
            if (shipment.goods.isFragile) ...[
              SizedBox(height: AppDimensions.xs.h),
              const FragileBanner(),
            ],

            // ── Meta row ───────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.base.w,
                AppDimensions.sm.h,
                AppDimensions.base.w,
                0,
              ),
              child: Wrap(
                spacing: AppDimensions.base.w,
                runSpacing: 4.h,
                children: [
                  _MetaChip(
                    icon: Icons.category_outlined,
                    label: shipment.goods.type,
                  ),
                  _MetaChip(
                    icon: Icons.scale_outlined,
                    label: shipment.goods.weightLabel,
                  ),
                  _MetaChip(
                    icon: Icons.local_shipping_outlined,
                    label: shipment.vehicleType.label,
                  ),
                  _MetaChip(
                    icon: Icons.calendar_today_outlined,
                    label:
                        '${shipment.pickupDateTime.day}/${shipment.pickupDateTime.month}',
                  ),
                ],
              ),
            ),

            // ── Divider + price + CTA ──────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.base.w,
                vertical: AppDimensions.sm.h,
              ),
              child: Divider(height: 1, color: colors.divider),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.base.w,
                0,
                AppDimensions.base.w,
                AppDimensions.base.h,
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.shipmentPrice,
                        style: context.textTheme.bodySmall?.copyWith(
                            color: colors.textHint),
                      ),
                      Text(
                        shipment.estimatedPrice.inr,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Express Interest / Already expressed
                  hasExpressed
                      ? Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.base.w,
                            vertical: AppDimensions.sm.h,
                          ),
                          decoration: BoxDecoration(
                            color: colors.success.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_outline_rounded,
                                  size: 16.w, color: colors.success),
                              SizedBox(width: 4.w),
                              Text(
                                context.l10n.tripInterestSubmitted,
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: colors.success,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        )
                      : FilledButton(
                          onPressed: onExpress,
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.primary,
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.base.w,
                              vertical: AppDimensions.sm.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMd.r),
                            ),
                          ),
                          child: Text(
                            context.l10n.tripExpressInterest,
                            style: context.textTheme.labelMedium?.copyWith(
                              color: colors.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Meta chip ────────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String   label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13.w, color: colors.textHint),
        SizedBox(width: 3.w),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
