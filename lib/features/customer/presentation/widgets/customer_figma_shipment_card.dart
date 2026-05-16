import 'package:flutter/material.dart';

import '../../../../core/extensions/num_ext.dart';
import '../../../../core/extensions/string_ext.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/domain/entities/shipment.dart';
import '../../../../shared/domain/enums/shipment_status.dart';
import '../../../../shared/presentation/widgets/buttons/app_button.dart';
import '../../../../shared/presentation/widgets/route/route_timeline.dart';

/// Shipment list card — [Figma My Shipment](https://www.figma.com/design/wT5NdNeg7YVPPcq1nY9D2P/Goods-Carrier--Copy-?node-id=2013-2327).
class CustomerFigmaShipmentCard extends StatelessWidget {
  const CustomerFigmaShipmentCard({
    super.key,
    required this.shipment,
    required this.onTap,
    this.onPrimaryAction,
    this.primaryActionLabel,
    this.interestCount,
  });

  final Shipment shipment;
  final VoidCallback onTap;
  final VoidCallback? onPrimaryAction;
  final String? primaryActionLabel;
  final int? interestCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: context.cardShadow,
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.shipmentId,
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_REGULAR,
                          fontSize: 12.sp,
                          color: colors.textHint,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        shipment.id,
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_EXTRABOLD,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: shipment.status),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shipment.estimatedPrice.inr,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_EXTRABOLD,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: colors.orangeText,
                      ),
                    ),
                    Text(
                      l10n.shipmentEstimatedPay,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_REGULAR,
                        fontSize: 12.sp,
                        color: colors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            RouteTimeline(
              fromCity: shipment.pickup.city,
              toCity: shipment.drop.city,
              compact: true,
            ),
            SizedBox(height: 16.h),
            Divider(color: colors.divider, height: 1),
            SizedBox(height: 12.h),
            Row(
              children: [
                _MetaChip(
                  icon: Icons.calendar_today_outlined,
                  line1: shipment.pickupDateTime.shortDate,
                  line2: shipment.pickupDateTime.displayTime,
                ),
                SizedBox(width: 16.w),
                _MetaChip(
                  icon: Icons.local_shipping_outlined,
                  line1: shipment.vehicleType.label,
                  line2: shipment.vehicleType.capacityLabel,
                ),
              ],
            ),
            if (primaryActionLabel != null && onPrimaryAction != null) ...[
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: primaryActionLabel!,
                      onPressed: onPrimaryAction,
                      height: 40,
                    ),
                  ),
                  if (interestCount != null && interestCount! > 0) ...[
                    SizedBox(width: 8.w),
                    Material(
                      color: colors.inputFill,
                      borderRadius: BorderRadius.circular(12.r),
                      child: InkWell(
                        onTap: onTap,
                        borderRadius: BorderRadius.circular(12.r),
                        child: SizedBox(
                          width: 40.w,
                          height: 40.w,
                          child: Icon(
                            Icons.more_horiz_rounded,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ShipmentStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (label, bg, fg) = switch (status) {
      ShipmentStatus.pending => (
          context.l10n.shipmentStatusPublished,
          colors.primary.withValues(alpha: 0.12),
          colors.primaryDark,
        ),
      ShipmentStatus.interestReceived => (
          status.label,
          colors.warningBackground,
          colors.selectedText,
        ),
      ShipmentStatus.assigned => (
          status.label,
          colors.primary.withValues(alpha: 0.12),
          colors.primaryDark,
        ),
      ShipmentStatus.inTransit => (
          status.label,
          const Color(0xFFE3F2FD),
          const Color(0xFF1565C0),
        ),
      ShipmentStatus.delivered => (
          status.label,
          colors.success.withValues(alpha: 0.12),
          colors.success,
        ),
      ShipmentStatus.cancelled => (
          status.label,
          colors.error.withValues(alpha: 0.1),
          colors.error,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: FontRes.MANROPE_SEMIBOLD,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.line1,
    required this.line2,
  });

  final IconData icon;
  final String line1;
  final String line2;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14.w, color: colors.textHint),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line1,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_SEMIBOLD,
                    fontSize: 12.sp,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  line2,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_REGULAR,
                    fontSize: 11.sp,
                    color: colors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
