import 'package:flutter/material.dart';

import '../../../../../core/extensions/size_ext.dart';
import '../../../../../res/font_res.dart';
import '../../../../../shared/domain/enums/driver_vehicle_status.dart';
import '../../../../../shared/presentation/widgets/network/dio_network_icon.dart';
import 'driver_vehicle_tokens.dart';

class DriverVehicleStatusBadge extends StatelessWidget {
  const DriverVehicleStatusBadge({super.key, required this.status});

  final DriverVehicleStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label, showDot) = switch (status) {
      DriverVehicleStatus.active => (
          DriverVehicleTokens.activeBadgeBg,
          DriverVehicleTokens.activeBadgeText,
          'ACTIVE',
          true,
        ),
      DriverVehicleStatus.inMaintenance => (
          DriverVehicleTokens.maintenanceBg,
          DriverVehicleTokens.mutedGrey,
          'IN MAINTENANCE',
          false,
        ),
      DriverVehicleStatus.inTransit => (
          DriverVehicleTokens.statusBlueBg,
          DriverVehicleTokens.statusBlueText,
          'IN TRANSIT',
          false,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6.w,
              height: 6.w,
              decoration: const BoxDecoration(
                color: DriverVehicleTokens.activeGreen,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 4.w),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: FontRes.MANROPE_EXTRABOLD,
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              height: 15 / 10,
              letterSpacing: showDot ? -0.5 : 0,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class DriverVehicleIconBadge extends StatelessWidget {
  const DriverVehicleIconBadge({
    super.key,
    required this.icon,
    this.iconUrl,
    this.tint = DriverVehicleTokens.accentOrange,
    this.background = DriverVehicleTokens.iconOrangeBg,
    this.size = 64,
    this.iconSize = 24,
    this.radius = 24,
  });

  final IconData icon;
  final String? iconUrl;
  final Color tint;
  final Color background;
  final double size;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(icon, size: iconSize.w, color: tint);
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius.r),
      ),
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      child: VehicleTypeNetworkIcon(
        iconUrl: iconUrl,
        color: tint,
        size: iconSize.w,
        fallback: fallback,
      ),
    );
  }
}

IconData vehicleTypeIcon(String? name) {
  final lower = name?.toLowerCase() ?? '';
  if (lower.contains('refrigerat') || lower.contains('cold')) {
    return Icons.ac_unit_rounded;
  }
  if (lower.contains('van') || lower.contains('mini')) {
    return Icons.airport_shuttle_rounded;
  }
  if (lower.contains('trailer') || lower.contains('flatbed')) {
    return Icons.local_shipping_outlined;
  }
  if (lower.contains('tempo')) {
    return Icons.airport_shuttle_rounded;
  }
  if (lower.contains('pickup')) {
    return Icons.fire_truck_outlined;
  }
  return Icons.local_shipping_rounded;
}

(Color, Color) vehicleIconColors(DriverVehicleStatus status) {
  if (status == DriverVehicleStatus.inMaintenance) {
    return (DriverVehicleTokens.mutedGrey, DriverVehicleTokens.maintenanceBg);
  }
  return (DriverVehicleTokens.accentOrange, DriverVehicleTokens.iconOrangeBg);
}
