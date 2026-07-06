import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/num_ext.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/string_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../models/customer_trip_request_success_args.dart';
import '../widgets/customer_light_chrome.dart';
import '../widgets/trip_detail/trip_detail_tokens.dart';

/// Request sent confirmation — Figma customer trip request success.
class CustomerTripRequestSuccessScreen extends StatelessWidget {
  const CustomerTripRequestSuccessScreen({super.key, required this.args});

  final CustomerTripRequestSuccessArgs args;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return CustomerLightChrome(
      child: Scaffold(
        backgroundColor: TripDetailTokens.screenBg,
        appBar: FlowScreenAppBar(
          title: l10n.driverConfirmationTitle,
          backgroundColor: Colors.white.withValues(alpha: 0.8),
          showBack: false,
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
                  child: Column(
                    children: [
                      const _SuccessIcon(),
                      SizedBox(height: 32.h),
                      Text(
                        l10n.customerTripRequestSentTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_EXTRABOLD,
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w800,
                          height: 36 / 30,
                          letterSpacing: -0.6,
                          color: TripDetailTokens.bodyDark,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 17.w),
                        child: Text(
                          l10n.customerTripRequestSentBody,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: FontRes.MANROPE_REGULAR,
                            fontSize: 16.sp,
                            height: 26 / 16,
                            color: const Color(0xFF595F64),
                          ),
                        ),
                      ),
                      SizedBox(height: 40.h),
                      _RequestSummaryCard(
                        fromCity: args.fromCity,
                        toCity: args.toCity,
                        dateLabel: args.pickupDateTime.displayDate,
                        priceText: args.estimatedPrice.inr,
                        fromLabel: l10n.tripFrom.toUpperCase(),
                        toLabel: l10n.tripTo.toUpperCase(),
                        dateFieldLabel: l10n.driverSummaryDate,
                        priceFieldLabel: l10n.driverSummaryTotalPrice,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(58.w, 0, 58.w, 24.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: Material(
                    color: TripDetailTokens.primaryOrange,
                    borderRadius: BorderRadius.circular(12.r),
                    child: InkWell(
                      onTap: () => context.go(AppRoutes.customerHome),
                      borderRadius: BorderRadius.circular(12.r),
                      child: Center(
                        child: Text(
                          l10n.shipmentPostBackToHome,
                          style: TextStyle(
                            fontFamily: FontRes.MANROPE_BOLD,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessIcon extends StatelessWidget {
  const _SuccessIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96.w,
      height: 96.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TripDetailTokens.successGreenStart,
            TripDetailTokens.successGreenEnd,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: TripDetailTokens.successGreenStart.withValues(alpha: 0.2),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(Icons.check_rounded, color: Colors.white, size: 40.w),
    );
  }
}

class _RequestSummaryCard extends StatelessWidget {
  const _RequestSummaryCard({
    required this.fromCity,
    required this.toCity,
    required this.dateLabel,
    required this.priceText,
    required this.fromLabel,
    required this.toLabel,
    required this.dateFieldLabel,
    required this.priceFieldLabel,
  });

  final String fromCity;
  final String toCity;
  final String dateLabel;
  final String priceText;
  final String fromLabel;
  final String toLabel;
  final String dateFieldLabel;
  final String priceFieldLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 48.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A161C20),
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RouteLabel(label: fromLabel, city: fromCity),
          SizedBox(height: 16.h),
          _RouteLabel(label: toLabel, city: toCity),
          SizedBox(height: 32.h),
          Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  label: dateFieldLabel,
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14.w,
                        color: TripDetailTokens.estimatedPayBrown,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          dateLabel,
                          style: TextStyle(
                            fontFamily: FontRes.MANROPE_BOLD,
                            fontSize: 14.sp,
                            color: TripDetailTokens.bodyDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _SummaryTile(
                  label: priceFieldLabel,
                  child: Text(
                    priceText,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_EXTRABOLD,
                      fontSize: 20.sp,
                      color: TripDetailTokens.primaryOrange,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RouteLabel extends StatelessWidget {
  const _RouteLabel({required this.label, required this.city});

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
            letterSpacing: 1,
            color: TripDetailTokens.routeLabel,
          ),
        ),
        Text(
          city,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_BOLD,
            fontSize: 16.sp,
            color: TripDetailTokens.bodyDark,
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: TripDetailTokens.cardBg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: FontRes.MANROPE_BOLD,
              fontSize: 10.sp,
              letterSpacing: 1,
              color: TripDetailTokens.routeLabel,
            ),
          ),
          SizedBox(height: 4.h),
          child,
        ],
      ),
    );
  }
}
