import 'package:flutter/material.dart';

import '../../../../../core/dummy/dummy_user.dart';
import '../../../../../core/extensions/size_ext.dart';
import '../../../../../core/extensions/string_ext.dart';
import '../../../../../res/font_res.dart';
import 'trip_detail_tokens.dart';

/// Route block — Figma `1:2117` section 1.
class TripDetailRouteSection extends StatelessWidget {
  const TripDetailRouteSection({
    super.key,
    required this.fromCity,
    required this.toCity,
    required this.fromLabel,
    required this.toLabel,
  });

  final String fromCity;
  final String toCity;
  final String fromLabel;
  final String toLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: TripDetailTokens.cardBg,
        borderRadius: BorderRadius.circular(TripDetailTokens.cardRadius.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RouteTimelineIndicator(),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RouteEndpoint(label: fromLabel, city: fromCity),
                SizedBox(height: 32.h),
                _RouteEndpoint(label: toLabel, city: toCity),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteTimelineIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Column(
        children: [
          Container(
            width: 16.w,
            height: 16.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: TripDetailTokens.routeRing, width: 2),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 6.w,
              height: 6.w,
              decoration: const BoxDecoration(
                color: TripDetailTokens.routeRing,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            width: 2.w,
            height: 64.h,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF8D7164),
                  Color(0x008D7164),
                ],
                stops: [0.5, 0.5],
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Icon(
            Icons.location_on,
            size: 16.w,
            color: TripDetailTokens.routeRing,
          ),
        ],
      ),
    );
  }
}

class _RouteEndpoint extends StatelessWidget {
  const _RouteEndpoint({required this.label, required this.city});

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
            height: 1.5,
            letterSpacing: 1,
            color: TripDetailTokens.routeLabel,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          city,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_BOLD,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            height: 28 / 18,
            color: TripDetailTokens.bodyDark,
          ),
        ),
      ],
    );
  }
}

/// Schedule + vehicle meta — Figma section 2.
class TripDetailScheduleSection extends StatelessWidget {
  const TripDetailScheduleSection({
    super.key,
    required this.startDateTime,
    required this.endDateTime,
    required this.vehicleLabel,
    required this.vehicleNumber,
    required this.capacityLabel,
    required this.startDateLabel,
    required this.endDateLabel,
    required this.vehicleTypeLabel,
    required this.vehicleNumberLabel,
    required this.capacityTitle,
  });

  final DateTime startDateTime;
  final DateTime endDateTime;
  final String vehicleLabel;
  final String vehicleNumber;
  final String capacityLabel;
  final String startDateLabel;
  final String endDateLabel;
  final String vehicleTypeLabel;
  final String vehicleNumberLabel;
  final String capacityTitle;

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
          _ScheduleRow(
            label: startDateLabel,
            value: startDateTime.figmaTripDetailDateTime,
          ),
          SizedBox(height: 32.h),
          _ScheduleRow(
            label: endDateLabel,
            value: endDateTime.figmaTripDetailDateTime,
          ),
          SizedBox(height: 32.h),
          _ScheduleRow(label: vehicleTypeLabel, value: vehicleLabel, showIcon: false),
          SizedBox(height: 32.h),
          _ScheduleRow(
            label: vehicleNumberLabel,
            value: vehicleNumber,
            showIcon: false,
          ),
          SizedBox(height: 32.h),
          _ScheduleRow(
            label: capacityTitle,
            value: capacityLabel,
            showIcon: false,
          ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.label,
    required this.value,
    this.showIcon = true,
  });

  final String label;
  final String value;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10.4.sp,
            fontWeight: FontWeight.w500,
            height: 16 / 10.4,
            color: TripDetailTokens.scheduleLabel,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            if (showIcon) ...[
              Icon(
                Icons.calendar_today_outlined,
                size: 14.w,
                color: TripDetailTokens.scheduleLabel,
              ),
              SizedBox(width: 8.w),
            ],
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 12.48.sp,
                  fontWeight: FontWeight.w600,
                  height: 17 / 12.48,
                  color: TripDetailTokens.bodyDark,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Driver card — Figma section 3.
class TripDetailDriverCard extends StatelessWidget {
  const TripDetailDriverCard({
    super.key,
    required this.name,
    required this.subtitle,
    this.onTap,
  });

  final String name;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: TripDetailTokens.cardBg,
        borderRadius: BorderRadius.circular(TripDetailTokens.cardRadius.r),
      ),
      child: Row(
        children: [
          _DriverAvatar(name: name),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_BOLD,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    height: 20 / 14,
                    color: TripDetailTokens.bodyDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_MEDIUM,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: TripDetailTokens.subtitleGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: content);
  }

  /// Demo driver profile for assigned / interested drivers.
  static TripDetailDriverCard fromDummy({
    required String subtitle,
    VoidCallback? onTap,
  }) {
    const driver = DummyUser.driver;
    final displayName = driver.name.split(' ').take(2).join(' ');
    return TripDetailDriverCard(
      name: displayName,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}

class _DriverAvatar extends StatelessWidget {
  const _DriverAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56.w,
      height: 56.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: TripDetailTokens.primaryOrange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(24.r),
            ),
            alignment: Alignment.center,
            child: Text(
              name.initials,
              style: TextStyle(
                fontFamily: FontRes.MANROPE_BOLD,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: TripDetailTokens.primaryOrange,
              ),
            ),
          ),
          Positioned(
            right: -4.w,
            bottom: -4.h,
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: TripDetailTokens.routeRing,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: TripDetailTokens.cardBg, width: 2),
              ),
              child: Icon(Icons.verified, size: 12.w, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Estimated price — Figma section 4.
class TripDetailPriceSection extends StatelessWidget {
  const TripDetailPriceSection({
    super.key,
    required this.label,
    required this.priceText,
  });

  final String label;
  final String priceText;

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
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: FontRes.MANROPE_BOLD,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              height: 1.5,
              letterSpacing: 1,
              color: TripDetailTokens.routeLabel,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            priceText,
            style: TextStyle(
              fontFamily: FontRes.MANROPE_EXTRABOLD,
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              height: 32 / 24,
              color: TripDetailTokens.primaryOrange,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sticky footer with primary CTA — Figma footer.
class TripDetailRequestFooter extends StatelessWidget {
  const TripDetailRequestFooter({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: TripDetailTokens.screenBg.withValues(alpha: 0.9),
          border: const Border(
            top: BorderSide(color: TripDetailTokens.footerBorder),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Material(
              color: TripDetailTokens.primaryOrange,
              borderRadius:
                  BorderRadius.circular(TripDetailTokens.buttonRadius.r),
              elevation: 0,
              child: InkWell(
                onTap: onPressed,
                borderRadius:
                    BorderRadius.circular(TripDetailTokens.buttonRadius.r),
                child: Container(
                  width: double.infinity,
                  height: 60.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(TripDetailTokens.buttonRadius.r),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(159, 66, 0, 0.2),
                        blurRadius: 25,
                        offset: Offset(0, 20),
                      ),
                      BoxShadow(
                        color: Color.fromRGBO(159, 66, 0, 0.2),
                        blurRadius: 10,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_BOLD,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      height: 28 / 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
