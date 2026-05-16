import 'package:flutter/material.dart';

import '../../../../core/extensions/num_ext.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/string_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/domain/entities/shipment.dart';
import '../../../../shared/domain/enums/shipment_status.dart';
import '../../../../shared/presentation/widgets/buttons/app_button.dart';

/// Home feed trip card — Figma Customer Home (`2013:1440`).
class CustomerHomeTripCard extends StatelessWidget {
  const CustomerHomeTripCard({
    super.key,
    required this.shipment,
    required this.onTap,
    required this.onViewDetails,
  });

  final Shipment shipment;
  final VoidCallback onTap;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final showInterestBadge =
        shipment.status == ShipmentStatus.interestReceived ||
            shipment.interestedDriverIds.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: context.cardShadow,
        ),
        padding: EdgeInsets.all(22.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showInterestBadge) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  l10n.customerHomeInterestBadge,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_BOLD,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: const Color(0xFF1565C0),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
            _RouteBlock(
              fromLabel: l10n.tripFrom.toLowerCase(),
              fromCity: shipment.pickup.city,
              toLabel: l10n.tripTo.toLowerCase(),
              toCity: shipment.drop.city,
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.only(top: 16.h),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colors.divider)),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _MetaCell(
                          label: l10n.customerHomeEstStartDate,
                          value: shipment.pickupDateTime.displayDateTime,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _MetaCell(
                          label: l10n.customerHomeEstEndDate,
                          value: shipment.dropDateTime.displayDateTime,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _MetaCell(
                          label: l10n.tripVehicle,
                          value: shipment.vehicleType.label,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _MetaCell(
                          label: l10n.tripCapacity,
                          value: shipment.vehicleType.capacityLabel
                              .replaceFirst('Cap: ', ''),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.shipmentPrice.toUpperCase(),
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_REGULAR,
                          fontSize: 11.sp,
                          color: colors.textHint,
                        ),
                      ),
                      Text(
                        shipment.estimatedPrice.inr,
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_EXTRABOLD,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: colors.orangeText,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 140.w,
                  child: AppButton(
                    label: l10n.actionViewDetails,
                    onPressed: onViewDetails,
                    height: 44,
                    variant: AppButtonVariant.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteBlock extends StatelessWidget {
  const _RouteBlock({
    required this.fromLabel,
    required this.fromCity,
    required this.toLabel,
    required this.toCity,
  });

  final String fromLabel;
  final String fromCity;
  final String toLabel;
  final String toCity;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RouteRow(
          label: fromLabel,
          city: fromCity,
          icon: Icons.location_on_rounded,
          iconColor: colors.primary,
        ),
        SizedBox(height: 12.h),
        _RouteRow(
          label: toLabel,
          city: toCity,
          icon: Icons.navigation_rounded,
          iconColor: colors.routeTimelineDot,
        ),
      ],
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({
    required this.label,
    required this.city,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String city;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_REGULAR,
            fontSize: 12.sp,
            color: context.colors.textHint,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Icon(icon, size: 18.w, color: iconColor),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                city,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_BOLD,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetaCell extends StatelessWidget {
  const _MetaCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_REGULAR,
            fontSize: 11.sp,
            color: colors.textHint,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_SEMIBOLD,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
