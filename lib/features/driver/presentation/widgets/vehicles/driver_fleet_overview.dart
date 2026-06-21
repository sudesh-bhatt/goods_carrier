import 'package:flutter/material.dart';

import '../../../../../core/extensions/size_ext.dart';
import '../../../../../res/font_res.dart';
import '../../../../../shared/domain/models/driver_vehicle_list_result.dart';
import 'driver_vehicle_tokens.dart';

class DriverFleetOverview extends StatelessWidget {
  const DriverFleetOverview({
    super.key,
    required this.summary,
    required this.sectionLabel,
    required this.title,
    required this.totalActiveLabel,
    required this.inTransitLabel,
  });

  final DriverVehicleFleetSummary summary;
  final String sectionLabel;
  final String title;
  final String totalActiveLabel;
  final String inTransitLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionLabel,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_MEDIUM,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            height: 20 / 14,
            color: DriverVehicleTokens.mutedGrey,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          title,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_EXTRABOLD,
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            height: 32 / 24,
            letterSpacing: -0.6,
            color: DriverVehicleTokens.titleDark,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: totalActiveLabel,
                value: summary.totalActive.toString().padLeft(2, '0'),
                valueColor: DriverVehicleTokens.accentOrange,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _StatCard(
                label: inTransitLabel,
                value: summary.inTransit.toString().padLeft(2, '0'),
                valueColor: DriverVehicleTokens.activeGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: DriverVehicleTokens.cardFill,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color.fromRGBO(195, 198, 215, 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: FontRes.MANROPE_BOLD,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              height: 16 / 12,
              letterSpacing: 1.2,
              color: DriverVehicleTokens.mutedGrey,
            ),
          ),
          SizedBox(height: 3.5.h),
          Text(
            value,
            style: TextStyle(
              fontFamily: FontRes.MANROPE_EXTRABOLD,
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              height: 32 / 24,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
