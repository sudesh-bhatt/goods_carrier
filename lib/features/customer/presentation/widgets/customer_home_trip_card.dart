import 'package:flutter/material.dart';

import '../../../../core/extensions/num_ext.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/string_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/domain/entities/shipment.dart';
import '../../../../shared/domain/enums/shipment_status.dart';
/// Home feed trip card — Figma Customer Home (`1:1439`).
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
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color.fromRGBO(195, 198, 215, 0.05),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.03),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(21.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showInterestBadge) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF048FF5),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  l10n.customerHomeInterestBadge,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_BOLD,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: Colors.white,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.shipmentPrice.toUpperCase(),
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_MEDIUM,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF434655),
                        ),
                      ),
                      Text(
                        shipment.estimatedPrice.inr,
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_EXTRABOLD,
                          fontSize: 21.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                _ViewDetailsButton(
                  label: l10n.actionViewDetails,
                  onPressed: onViewDetails,
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

/// Figma outline button — 140×44, padding 10×25, 14.5px label, single line.
class _ViewDetailsButton extends StatelessWidget {
  const _ViewDetailsButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: 140.w,
      height: 44.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 10.h),
          minimumSize: Size(140.w, 44.h),
          fixedSize: Size(140.w, 44.h),
          alignment: Alignment.center,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          side: BorderSide(color: colors.primary, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          softWrap: false,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_SEMIBOLD,
            fontSize: 14.5.sp,
            fontWeight: FontWeight.w600,
            height: 1,
            color: colors.primary,
          ),
        ),
      ),
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
