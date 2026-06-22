import 'package:flutter/material.dart';

import '../../../../core/extensions/num_ext.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/string_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/domain/entities/shipment.dart';

/// Driver home feed card — Figma Shipment List From Customer (`1:423`).
class DriverHomeShipmentCard extends StatelessWidget {
  const DriverHomeShipmentCard({
    super.key,
    required this.shipment,
    required this.onViewDetails,
    this.onTap,
  });

  final Shipment shipment;
  final VoidCallback onViewDetails;
  final VoidCallback? onTap;

  static const _labelColor = Color(0xFF594136);
  static const _titleColor = Color(0xFF161C20);
  static const _routeAccent = Color(0xFF9F4200);

  String get _displayId =>
      shipment.id.startsWith('#') ? shipment.id : '#${shipment.id}';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap ?? onViewDetails,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A161C20),
              blurRadius: 40,
              offset: Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.driverHomeShipmentId.toUpperCase(),
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_BOLD,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    height: 15 / 10,
                    color: _labelColor,
                  ),
                ),
                Text(
                  _displayId,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_EXTRABOLD,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    height: 28 / 20,
                    color: _titleColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            _RouteSection(
              fromLabel: l10n.tripFrom.toUpperCase(),
              fromCity: shipment.pickup.city,
              toLabel: l10n.tripTo.toUpperCase(),
              toCity: shipment.drop.city,
            ),
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.only(top: 17.h),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFFE2BFB0).withValues(alpha: 0.15),
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _MetaColumn(
                      icon: Icons.calendar_today_outlined,
                      primary: shipment.pickupDateTime.displayDate,
                      secondary: shipment.pickupDateTime.displayTime,
                    ),
                  ),
                  Expanded(
                    child: _MetaColumn(
                      icon: Icons.local_shipping_outlined,
                      primary: shipment.vehicleType.label,
                      secondary: shipment.vehicleType.capacityLabel,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.only(top: 4.16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.shipmentPrice.toUpperCase(),
                          style: TextStyle(
                            fontFamily: FontRes.MANROPE_MEDIUM,
                            fontSize: 10.4.sp,
                            fontWeight: FontWeight.w500,
                            height: 16 / 10.4,
                            color: const Color(0xFF434655),
                          ),
                        ),
                        Text(
                          shipment.estimatedPrice.inr,
                          style: TextStyle(
                            fontFamily: FontRes.MANROPE_EXTRABOLD,
                            fontSize: 20.8.sp,
                            fontWeight: FontWeight.w800,
                            height: 29 / 20.8,
                            letterSpacing: -1.04,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  _ViewDetailsButton(
                    label: l10n.actionViewDetails,
                    onPressed: onViewDetails,
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

class _RouteSection extends StatelessWidget {
  const _RouteSection({
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
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 12.w,
            child: Column(
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: DriverHomeShipmentCard._routeAccent,
                      width: 2,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: CustomPaint(
                      painter: _DashedGradientLinePainter(),
                      size: Size(2.w, double.infinity),
                    ),
                  ),
                ),
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: const BoxDecoration(
                    color: DriverHomeShipmentCard._routeAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _RouteStop(label: fromLabel, city: fromCity),
                _RouteStop(label: toLabel, city: toCity),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteStop extends StatelessWidget {
  const _RouteStop({required this.label, required this.city});

  final String label;
  final String city;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_BOLD,
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            height: 15 / 10,
            color: DriverHomeShipmentCard._labelColor,
          ),
        ),
        Text(
          city,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_BOLD,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            height: 24 / 16,
            color: DriverHomeShipmentCard._titleColor,
          ),
        ),
      ],
    );
  }
}

class _MetaColumn extends StatelessWidget {
  const _MetaColumn({
    required this.icon,
    required this.primary,
    required this.secondary,
  });

  final IconData icon;
  final String primary;
  final String secondary;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14.w, color: DriverHomeShipmentCard._labelColor),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                primary,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_BOLD,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  height: 14 / 11,
                  color: DriverHomeShipmentCard._titleColor,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                secondary,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_REGULAR,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                  height: 14 / 11,
                  color: DriverHomeShipmentCard._labelColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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
    final borderRadius = BorderRadius.circular(8.32.r);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: borderRadius,
        child: Ink(
          width: 140.w,
          height: 43.88.h,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(color: colors.primary, width: 1.04),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 24.96.w,
            vertical: 10.4.h,
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_SEMIBOLD,
                  fontSize: 14.56.sp,
                  fontWeight: FontWeight.w600,
                  height: 21 / 14.56,
                  color: colors.primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedGradientLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashHeight = 4.0;
    const dashGap = 4.0;
    var y = 0.0;
    while (y < size.height) {
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF8D7164),
            const Color(0xFF8D7164).withValues(alpha: 0),
          ],
          stops: const [0.33, 0.33],
        ).createShader(Rect.fromLTWH(0, y, size.width, dashHeight));
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, dashHeight), paint);
      y += dashHeight + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
