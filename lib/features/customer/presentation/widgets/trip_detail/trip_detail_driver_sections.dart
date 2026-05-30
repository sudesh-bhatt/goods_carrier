import 'package:flutter/material.dart';

import '../../../../../core/extensions/num_ext.dart';
import '../../../../../core/extensions/size_ext.dart';
import '../../../../../core/extensions/string_ext.dart';
import '../../../../../res/font_res.dart';
import '../../../../../shared/domain/entities/shipment.dart';
import 'trip_detail_tokens.dart';

/// White summary card — Figma driver Shipment Details (`1:916`) trip card.
class TripDetailDriverSummaryCard extends StatelessWidget {
  const TripDetailDriverSummaryCard({
    super.key,
    required this.shipment,
    required this.shipmentIdLabel,
    required this.estimatedPayLabel,
    required this.fromLabel,
    required this.toLabel,
  });

  final Shipment shipment;
  final String shipmentIdLabel;
  final String estimatedPayLabel;
  final String fromLabel;
  final String toLabel;

  String get _displayId =>
      shipment.id.startsWith('#') ? shipment.id : '#${shipment.id}';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
      decoration: BoxDecoration(
        color: TripDetailTokens.summaryCardBg,
        borderRadius: BorderRadius.circular(TripDetailTokens.cardRadius.r),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shipmentIdLabel.toUpperCase(),
                      style: _labelStyle(),
                    ),
                    Text(
                      _displayId,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_EXTRABOLD,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        height: 28 / 20,
                        color: TripDetailTokens.bodyDark,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    shipment.estimatedPrice.inr,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_EXTRABOLD,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      height: 28 / 18,
                      color: TripDetailTokens.estimatedPayBrown,
                    ),
                  ),
                  Text(
                    estimatedPayLabel,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_MEDIUM,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                      color: TripDetailTokens.routeLabel,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24.h),
          _CompactRouteSection(
            fromLabel: fromLabel,
            fromCity: shipment.pickup.city,
            toLabel: toLabel,
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
        ],
      ),
    );
  }
}

/// Goods details bento — Figma `1:916`.
class TripDetailGoodsSection extends StatelessWidget {
  const TripDetailGoodsSection({
    super.key,
    required this.shipment,
    required this.sectionTitle,
    required this.typeLabel,
    required this.weightLabel,
    required this.fragileLabel,
  });

  final Shipment shipment;
  final String sectionTitle;
  final String typeLabel;
  final String weightLabel;
  final String fragileLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: TripDetailTokens.cardBg,
        borderRadius: BorderRadius.circular(TripDetailTokens.cardRadius.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 20.w,
                color: TripDetailTokens.estimatedPayBrown,
              ),
              SizedBox(width: 8.w),
              Text(
                sectionTitle.toUpperCase(),
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_BOLD,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  height: 20 / 14,
                  letterSpacing: 0.7,
                  color: TripDetailTokens.bodyDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _GoodsTile(
                  label: typeLabel,
                  value: shipment.goods.type,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _GoodsTile(
                  label: weightLabel,
                  value: shipment.goods.weightLabel.toUpperCase(),
                ),
              ),
            ],
          ),
          if (shipment.goods.isFragile) ...[
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: TripDetailTokens.fragileBannerBg,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16.w,
                    color: TripDetailTokens.estimatedPayBrown,
                  ),
                  SizedBox(width: 11.w),
                  Expanded(
                    child: Text(
                      fragileLabel,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_BOLD,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        height: 16 / 12,
                        color: TripDetailTokens.fragileBannerText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pickup + drop locations — Figma `1:916` location section.
class TripDetailDriverLocationSection extends StatelessWidget {
  const TripDetailDriverLocationSection({
    super.key,
    required this.shipment,
    required this.pickupLabel,
    required this.dropLabel,
  });

  final Shipment shipment;
  final String pickupLabel;
  final String dropLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: TripDetailTokens.cardBg,
        borderRadius: BorderRadius.circular(TripDetailTokens.cardRadius.r),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 12.w,
            top: 32.h,
            bottom: 32.h,
            child: Container(
              width: 2.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    TripDetailTokens.estimatedPayBrown.withValues(alpha: 0.2),
                    TripDetailTokens.dropPinOrange.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LocationRow(
                icon: Icons.location_on,
                iconColor: TripDetailTokens.estimatedPayBrown,
                label: pickupLabel,
                address: shipment.pickup.fullAddress,
                schedule: shipment.pickupDateTime.locationScheduleLabel,
              ),
              SizedBox(height: 32.h),
              _LocationRow(
                icon: Icons.location_on,
                iconColor: TripDetailTokens.dropPinOrange,
                label: dropLabel,
                address: shipment.drop.fullAddress,
                schedule: shipment.dropDateTime.locationScheduleLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Vehicle requirement + match badge — Figma `1:916`.
class TripDetailVehicleMatchSection extends StatelessWidget {
  const TripDetailVehicleMatchSection({
    super.key,
    required this.shipment,
    required this.sectionLabel,
    required this.matchLabel,
  });

  final Shipment shipment;
  final String sectionLabel;
  final String matchLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: TripDetailTokens.cardBg,
        borderRadius: BorderRadius.circular(TripDetailTokens.cardRadius.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionLabel.toUpperCase(),
            style: _labelStyle(),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.local_shipping_outlined,
                  size: 28.w,
                  color: TripDetailTokens.estimatedPayBrown,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shipment.vehicleType.label,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_EXTRABOLD,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        height: 24 / 16,
                        color: TripDetailTokens.bodyDark,
                      ),
                    ),
                    Text(
                      'Capacity: ${shipment.vehicleType.capacityDisplay}',
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_REGULAR,
                        fontSize: 12.sp,
                        height: 16 / 12,
                        color: TripDetailTokens.routeLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: TripDetailTokens.matchBadgeBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 12.w,
                  color: TripDetailTokens.matchBadgeBlue,
                ),
                SizedBox(width: 8.w),
                Text(
                  matchLabel.toUpperCase(),
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_BOLD,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    letterSpacing: 0.5,
                    color: TripDetailTokens.matchBadgeBlue,
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

class _CompactRouteSection extends StatelessWidget {
  const _CompactRouteSection({
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 12.w,
          height: 80.h,
          child: Column(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: TripDetailTokens.estimatedPayBrown,
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
                  color: TripDetailTokens.estimatedPayBrown,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: SizedBox(
            height: 80.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _RouteStop(label: fromLabel, city: fromCity),
                _RouteStop(label: toLabel, city: toCity),
              ],
            ),
          ),
        ),
      ],
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
        Text(label, style: _labelStyle()),
        Text(
          city,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_BOLD,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            height: 24 / 16,
            color: TripDetailTokens.bodyDark,
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
        Icon(icon, size: 14.w, color: TripDetailTokens.routeLabel),
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
                  color: TripDetailTokens.bodyDark,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                secondary,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_REGULAR,
                  fontSize: 11.sp,
                  height: 14 / 11,
                  color: TripDetailTokens.routeLabel,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoodsTile extends StatelessWidget {
  const _GoodsTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: _labelStyle(),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: FontRes.MANROPE_BOLD,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              height: 24 / 16,
              color: TripDetailTokens.bodyDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.address,
    required this.schedule,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String address;
  final String schedule;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24.w,
          height: 24.w,
          decoration: BoxDecoration(
            color: iconColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: iconColor.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(icon, size: 12.w, color: Colors.white),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(), style: _labelStyle()),
              Text(
                address,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_BOLD,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  height: 24 / 16,
                  color: TripDetailTokens.bodyDark,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                schedule,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_REGULAR,
                  fontSize: 12.sp,
                  height: 16 / 12,
                  color: TripDetailTokens.routeLabel.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

TextStyle _labelStyle() => TextStyle(
      fontFamily: FontRes.MANROPE_BOLD,
      fontSize: 10.sp,
      fontWeight: FontWeight.w700,
      letterSpacing: 1,
      height: 1.5,
      color: TripDetailTokens.routeLabel,
    );

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
