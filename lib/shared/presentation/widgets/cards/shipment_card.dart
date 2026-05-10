import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/num_ext.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/string_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../shared/domain/entities/shipment.dart';
import '../buttons/app_button.dart';
import '../route/route_timeline.dart';
import '../status/fragile_banner.dart';
import '../status/status_chip.dart';

/// Card displaying a customer [Shipment] summary.
///
/// Shows TRK-ID, route timeline, pickup date, goods weight + vehicle type,
/// price, fragile banner (when applicable), and an optional action CTA.
///
/// ```dart
/// // Customer home — "View Details" primary button
/// ShipmentCard(
///   shipment: s,
///   onTap: () => context.push('/shipment/${s.id}'),
///   actionLabel: context.l10n.actionSelect,
///   onAction: () => ...,
/// );
///
/// // Driver feed — "View Details" outline button
/// ShipmentCard(
///   shipment: s,
///   onTap: () => ...,
///   actionLabel: context.l10n.tripExpressInterest,
///   actionVariant: AppButtonVariant.secondary,
///   onAction: () => ...,
/// );
/// ```
class ShipmentCard extends StatelessWidget {
  const ShipmentCard({
    super.key,
    required this.shipment,
    this.onTap,
    this.actionLabel,
    this.onAction,
    this.actionVariant = AppButtonVariant.primary,
    this.showStatus = true,
    this.showPrice = true,
  });

  final Shipment shipment;
  final VoidCallback? onTap;

  /// When supplied, renders a full-width CTA button at the card bottom.
  final String? actionLabel;
  final VoidCallback? onAction;
  final AppButtonVariant actionVariant;

  final bool showStatus;
  final bool showPrice;

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
        padding: EdgeInsets.all(AppDimensions.base.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header row: TRK-ID + Status chip ─────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  shipment.id,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: colors.orangeText,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                if (showStatus)
                  StatusChip.shipment(
                    context: context,
                    status: shipment.status,
                  ),
              ],
            ),

            SizedBox(height: AppDimensions.md.h),

            // ── Route timeline ────────────────────────────────────────────
            RouteTimeline(
              fromCity: shipment.pickup.city,
              toCity: shipment.drop.city,
              compact: true,
            ),

            SizedBox(height: AppDimensions.md.h),

            // ── Fragile banner ────────────────────────────────────────────
            if (shipment.goods.isFragile) ...[
              const FragileBanner(),
              SizedBox(height: AppDimensions.sm.h),
            ],

            // ── Meta row: date · weight · vehicle ─────────────────────────
            _MetaRow(shipment: shipment),

            // ── Price ─────────────────────────────────────────────────────
            if (showPrice) ...[
              SizedBox(height: AppDimensions.sm.h),
              Divider(color: colors.divider, thickness: 1, height: 1),
              SizedBox(height: AppDimensions.sm.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.shipmentPrice,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  Text(
                    shipment.estimatedPrice.inr,
                    style: context.textTheme.titleSmall?.copyWith(
                      color: colors.orangeText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],

            // ── Action button ─────────────────────────────────────────────
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: AppDimensions.md.h),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                variant: actionVariant,
                height: 40,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Meta row ─────────────────────────────────────────────────────────────────

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.shipment});
  final Shipment shipment;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        _MetaItem(
          icon: Icons.calendar_today_outlined,
          label: shipment.pickupDateTime.shortDate,
          color: colors.textSecondary,
        ),
        SizedBox(width: AppDimensions.md.w),
        _MetaItem(
          icon: Icons.scale_outlined,
          label: shipment.goods.weightLabel,
          color: colors.textSecondary,
        ),
        SizedBox(width: AppDimensions.md.w),
        _MetaItem(
          icon: Icons.local_shipping_outlined,
          label: shipment.vehicleType.label,
          color: colors.textSecondary,
        ),
      ],
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppDimensions.iconSm.w, color: color),
        SizedBox(width: 4.w),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
