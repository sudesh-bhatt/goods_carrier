import 'package:flutter/material.dart';
import 'package:goods_carrier/core/extensions/string_ext.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/num_ext.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../shared/domain/entities/driver_trip.dart';
import '../buttons/app_button.dart';
import '../route/route_timeline.dart';
import '../status/status_chip.dart';

/// Card displaying a driver [DriverTrip] summary.
///
/// Shows VB-ID, driver name, route timeline, dates, vehicle details,
/// capacity, price estimate, and an optional action CTA.
///
/// ```dart
/// // Driver "My Trip" list
/// DriverTripCard(
///   trip: trip,
///   onTap: () => context.push('/trip/${trip.id}'),
/// );
///
/// // Customer shipment detail — interested driver list
/// DriverTripCard(
///   trip: trip,
///   actionLabel: context.l10n.shipmentSelectDriver,
///   onAction: () => _selectDriver(trip.driverId),
/// );
/// ```
class DriverTripCard extends StatelessWidget {
  const DriverTripCard({
    super.key,
    required this.trip,
    this.onTap,
    this.actionLabel,
    this.onAction,
    this.actionVariant = AppButtonVariant.primary,
    this.showStatus = true,
    this.showDriverInfo = true,
  });

  final DriverTrip trip;
  final VoidCallback? onTap;
  final String? actionLabel;
  final VoidCallback? onAction;
  final AppButtonVariant actionVariant;
  final bool showStatus;

  /// Whether to show the driver name + vehicle-number header row.
  /// Set false when card is rendered inside a driver's own "My Trips" list.
  final bool showDriverInfo;

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
            // ── Header: VB-ID + Status chip ───────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  trip.id,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: colors.orangeText,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                if (showStatus)
                  StatusChip.trip(context: context, status: trip.status),
              ],
            ),

            // ── Driver info row ────────────────────────────────────────────
            if (showDriverInfo) ...[
              SizedBox(height: AppDimensions.xs.h),
              Row(
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    size: AppDimensions.iconSm.w,
                    color: colors.textSecondary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    trip.driverName,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: AppDimensions.md.w),
                  Icon(
                    Icons.directions_car_outlined,
                    size: AppDimensions.iconSm.w,
                    color: colors.textSecondary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    trip.vehicleNumber,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: AppDimensions.md.h),

            // ── Route timeline ────────────────────────────────────────────
            RouteTimeline(
              fromCity: trip.fromCity,
              toCity: trip.toCity,
              compact: true,
            ),

            SizedBox(height: AppDimensions.md.h),

            // ── Meta row: date · vehicle · capacity ────────────────────────
            _TripMetaRow(trip: trip),

            // ── Price ─────────────────────────────────────────────────────
            SizedBox(height: AppDimensions.sm.h),
            Divider(color: colors.divider, thickness: 1, height: 1),
            SizedBox(height: AppDimensions.sm.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.tripPrice,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                Text(
                  trip.estimatedPrice.inr,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: colors.orangeText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            // ── Action CTA ────────────────────────────────────────────────
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

class _TripMetaRow extends StatelessWidget {
  const _TripMetaRow({required this.trip});
  final DriverTrip trip;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Wrap(
      spacing: AppDimensions.md.w,
      runSpacing: AppDimensions.xs.h,
      children: [
        _MetaItem(
          icon: Icons.calendar_today_outlined,
          label: trip.estimatedStartDate.shortDate,
          color: colors.textSecondary,
        ),
        _MetaItem(
          icon: Icons.local_shipping_outlined,
          label: trip.vehicleCategory.label,
          color: colors.textSecondary,
        ),
        _MetaItem(
          icon: Icons.scale_outlined,
          label: '${trip.loadCapacityTons.toStringAsFixed(0)}T cap',
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
