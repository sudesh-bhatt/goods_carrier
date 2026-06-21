import 'package:flutter/material.dart';

import '../../../../../core/extensions/size_ext.dart';
import '../../../../../res/font_res.dart';
import '../../../../../shared/domain/entities/driver_vehicle.dart';
import 'driver_vehicle_status_badge.dart';
import 'driver_vehicle_tokens.dart';

/// Vehicle list card — Figma `1:2`.
class DriverVehicleCard extends StatelessWidget {
  const DriverVehicleCard({
    super.key,
    required this.vehicle,
    required this.capacityLabel,
    this.onTap,
  });

  final DriverVehicle vehicle;
  final String capacityLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (iconColor, iconBg) = vehicleIconColors(vehicle.status);
    final icon = vehicleTypeIcon(vehicle.displayTypeName);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(32.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: DriverVehicleTokens.borderLight),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.04),
                blurRadius: 24,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DriverVehicleIconBadge(
                    icon: icon,
                    tint: iconColor,
                    background: iconBg,
                  ),
                  DriverVehicleStatusBadge(status: vehicle.status),
                ],
              ),
              SizedBox(height: 40.h),
              Text(
                vehicle.displayTypeName,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_BOLD,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  height: 28 / 20,
                  letterSpacing: -0.5,
                  color: DriverVehicleTokens.titleDark,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                vehicle.vehicleNumber,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_MEDIUM,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  height: 24 / 16,
                  color: DriverVehicleTokens.mutedGrey,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.only(top: 24.h),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: DriverVehicleTokens.dividerLight),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            capacityLabel.toUpperCase(),
                            style: TextStyle(
                              fontFamily: FontRes.MANROPE_BOLD,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              height: 16 / 12,
                              letterSpacing: 1.2,
                              color: const Color.fromRGBO(67, 70, 85, 0.6),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            vehicle.capacityLabel,
                            style: TextStyle(
                              fontFamily: FontRes.MANROPE_EXTRABOLD,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              height: 24 / 16,
                              color: DriverVehicleTokens.titleDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: DriverVehicleTokens.cardFill,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 20.w,
                        color: DriverVehicleTokens.titleDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
