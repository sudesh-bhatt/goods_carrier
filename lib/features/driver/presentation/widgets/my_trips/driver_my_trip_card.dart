import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../../core/extensions/size_ext.dart';
import '../../../../../core/extensions/theme_ext.dart';
import '../../../../../res/font_res.dart';
import '../../../../../core/utils/vehicle_number_utils.dart';
import '../../../../../shared/domain/entities/driver_trip.dart';
import '../../../../../shared/domain/entities/driver_trip_display.dart';
import '../../models/driver_trip_list_badge.dart';
import 'driver_my_trip_tokens.dart';

String formatDriverTripSchedule(DateTime dateTime) {
  final date = DateFormat('d MMMM yyyy').format(dateTime);
  final time = DateFormat('hh:mma').format(dateTime);
  return '$date | $time';
}

/// Figma My Trips list card — node `1:3967`.
class DriverMyTripListCard extends StatelessWidget {
  const DriverMyTripListCard({
    super.key,
    required this.trip,
    required this.onViewRequests,
    this.onEdit,
    this.onDelete,
  });

  final DriverTrip trip;
  final VoidCallback onViewRequests;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final badge = listBadgeFor(trip);
    final requestLabel = l10n.driverViewRequestCount(trip.interestRequestCount);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.8.w),
      decoration: BoxDecoration(
        color: DriverMyTripTokens.cardFill,
        borderRadius: BorderRadius.circular(12.48.r),
        border: Border.all(color: DriverMyTripTokens.cardBorder, width: 1.04),
        boxShadow: const [DriverMyTripTokens.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TripRouteHeader(
            trip: trip,
            badge: badge,
            badgeLabel: driverTripBadgeLabel(l10n, badge),
          ),
          SizedBox(height: 16.64.h),
          DriverMyTripDetailsGrid(trip: trip),
          SizedBox(height: 16.64.h),
          DriverMyTripPriceBlock(price: trip.estimatedPrice),
          SizedBox(height: 16.64.h),
          Row(
            children: [
              Expanded(
                child: _PrimaryActionButton(
                  label: requestLabel,
                  onTap: onViewRequests,
                ),
              ),
              if (onEdit != null) ...[
                SizedBox(width: 8.w),
                _IconActionButton(
                  icon: Icons.edit_outlined,
                  iconColor: DriverMyTripTokens.heading,
                  onTap: onEdit!,
                ),
              ],
              if (onDelete != null) ...[
                SizedBox(width: 8.w),
                _IconActionButton(
                  icon: Icons.delete_outline_rounded,
                  iconColor: DriverMyTripTokens.deleteIcon,
                  onTap: onDelete!,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TripRouteHeader extends StatelessWidget {
  const _TripRouteHeader({
    required this.trip,
    required this.badge,
    required this.badgeLabel,
  });

  final DriverTrip trip;
  final DriverTripListBadge badge;
  final String badgeLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LocationRow(
                label: context.l10n.driverTripPickupLabel,
                city: trip.fromCity,
                icon: Icons.location_on_outlined,
              ),
              SizedBox(height: 10.h),
              _LocationRow(
                label: context.l10n.driverTripDropLabel,
                city: trip.toCity,
                icon: Icons.near_me_outlined,
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        _StatusPill(label: badgeLabel, badge: badge),
      ],
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.label,
    required this.city,
    required this.icon,
  });

  final String label;
  final String city;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_MEDIUM,
            fontSize: 10.4.sp,
            fontWeight: FontWeight.w500,
            height: 16 / 10.4,
            color: DriverMyTripTokens.labelGrey,
          ),
        ),
        SizedBox(height: 5.h),
        Row(
          children: [
            Icon(icon, size: 18.w, color: DriverMyTripTokens.primary),
            SizedBox(width: 10.w),
            Flexible(
              child: Text(
                city,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_EXTRABOLD,
                  fontSize: 18.72.sp,
                  fontWeight: FontWeight.w800,
                  height: 23 / 18.72,
                  color: DriverMyTripTokens.heading,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.badge});

  final String label;
  final DriverTripListBadge badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: badge.background,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: FontRes.MANROPE_BOLD,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          height: 15 / 10,
          letterSpacing: -0.5,
          color: badge.foreground,
        ),
      ),
    );
  }
}

class DriverMyTripDetailsGrid extends StatelessWidget {
  const DriverMyTripDetailsGrid({
    super.key,
    required this.trip,
    this.includeVehicleNumber = false,
  });

  final DriverTrip trip;
  final bool includeVehicleNumber;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 17.68.h),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: DriverMyTripTokens.sectionDivider, width: 1.04),
          bottom: BorderSide(color: DriverMyTripTokens.sectionDivider, width: 1.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DetailCell(
                  label: l10n.driverTripFormEstStartDate.toUpperCase(),
                  value: formatDriverTripSchedule(trip.estimatedStartDate),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _DetailCell(
                  label: l10n.driverTripFormEstEndDate.toUpperCase(),
                  value: formatDriverTripSchedule(trip.estimatedEndDate),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.64.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DetailCell(
                  label: l10n.driverTripFormVehicleCategory.toUpperCase(),
                  value: trip.vehicleCategory.label,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _DetailCell(
                  label: l10n.driverTripCapacityLabel,
                  value: trip.loadCapacityLabel,
                ),
              ),
            ],
          ),
          if (includeVehicleNumber) ...[
            SizedBox(height: 16.64.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _DetailCell(
                    label: l10n.profileVehicleNumber.toUpperCase(),
                    value: trip.vehicleNumber.trim().isEmpty
                        ? '—'
                        : VehicleNumberUtils.format(trip.vehicleNumber),
                  ),
                ),
                SizedBox(width: 16.w),
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailCell extends StatelessWidget {
  const _DetailCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_MEDIUM,
            fontSize: 10.4.sp,
            fontWeight: FontWeight.w500,
            height: 16 / 10.4,
            color: DriverMyTripTokens.labelGrey,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_SEMIBOLD,
            fontSize: 12.48.sp,
            fontWeight: FontWeight.w600,
            height: 17 / 12.48,
            color: DriverMyTripTokens.heading,
          ),
        ),
      ],
    );
  }
}

class DriverMyTripPriceBlock extends StatelessWidget {
  const DriverMyTripPriceBlock({super.key, required this.price});

  final double price;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.driverTripFormEstPrice.toUpperCase(),
          style: TextStyle(
            fontFamily: FontRes.MANROPE_MEDIUM,
            fontSize: 10.4.sp,
            fontWeight: FontWeight.w500,
            height: 16 / 10.4,
            color: DriverMyTripTokens.labelGrey,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '₹${price.toStringAsFixed(0)}',
          style: TextStyle(
            fontFamily: FontRes.MANROPE_EXTRABOLD,
            fontSize: 20.8.sp,
            fontWeight: FontWeight.w800,
            height: 29 / 20.8,
            letterSpacing: -1.04,
            color: DriverMyTripTokens.primary,
          ),
        ),
      ],
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DriverMyTripTokens.primary,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          height: 40.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.visibility_outlined, size: 14.w, color: Colors.white),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_BOLD,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  height: 16 / 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DriverMyTripTokens.actionFill,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          width: 34.5.w,
          height: 40.h,
          child: Icon(icon, size: 18.w, color: iconColor),
        ),
      ),
    );
  }
}
