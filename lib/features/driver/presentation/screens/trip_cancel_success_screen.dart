import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../res/font_res.dart';
import '../../../customer/presentation/widgets/cancel_shipment/cancel_shipment_tokens.dart';
import '../../../customer/presentation/widgets/customer_light_chrome.dart';
import '../../../customer/presentation/widgets/shipment_form/shipment_form_tokens.dart';
import '../models/trip_cancel_confirmation_args.dart';
import '../providers/driver_trips_provider.dart';

/// Trip cancelled success — Figma `1:5028`.
class TripCancelSuccessScreen extends ConsumerWidget {
  const TripCancelSuccessScreen({super.key, required this.args});

  final TripCancelConfirmationArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = DateFormat('d MMMM yyyy', locale).format(args.startDate);
    final priceLabel = '₹${args.totalPrice.toStringAsFixed(0)}';

    return CustomerLightChrome(
      child: Scaffold(
        backgroundColor: CancelShipmentTokens.screenBg,
        appBar: AppBar(
          backgroundColor: Colors.white.withValues(alpha: 0.8),
          elevation: 0,
          shadowColor: ShipmentFormTokens.primary.withValues(alpha: 0.05),
          title: Text(
            l10n.driverCancelTrip,
            style: TextStyle(
              fontFamily: FontRes.MANROPE_BOLD,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.45,
              color: const Color(0xFF191C1D),
            ),
          ),
          automaticallyImplyLeading: false,
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
                      const _CancelSuccessIcon(),
                      SizedBox(height: 32.h),
                      Text(
                        l10n.tripCancelSuccessTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_EXTRABOLD,
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w800,
                          height: 36 / 30,
                          letterSpacing: -0.6,
                          color: CancelShipmentTokens.bodyDark,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        l10n.tripCancelSuccessBody(args.tripId),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_REGULAR,
                          fontSize: 16.sp,
                          height: 26 / 16,
                          color: const Color(0xFF595F64),
                        ),
                      ),
                      SizedBox(height: 32.h),
                      _CancelSummaryCard(
                        fromCity: args.fromCity,
                        toCity: args.toCity,
                        dateLabel: dateLabel,
                        priceLabel: priceLabel,
                        fromLabel: l10n.tripFrom.toUpperCase(),
                        toLabel: l10n.tripTo.toUpperCase(),
                        dateFieldLabel: l10n.shipmentPostDateLabel,
                        priceFieldLabel: l10n.shipmentPostTotalPriceLabel,
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
                    color: CancelShipmentTokens.primaryOrange,
                    borderRadius: BorderRadius.circular(12.r),
                    elevation: 0,
                    shadowColor:
                        CancelShipmentTokens.primaryOrange.withValues(alpha: 0.3),
                    child: InkWell(
                      onTap: () {
                        ref.read(driverTripsProvider.notifier).refresh();
                        context.go(AppRoutes.driverHome);
                      },
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

class _CancelSuccessIcon extends StatelessWidget {
  const _CancelSuccessIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96.w,
      height: 96.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: CancelShipmentTokens.cancelRed,
        boxShadow: [
          BoxShadow(
            color: CancelShipmentTokens.cancelRed.withValues(alpha: 0.2),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(Icons.close_rounded, color: Colors.white, size: 40.w),
    );
  }
}

class _CancelSummaryCard extends StatelessWidget {
  const _CancelSummaryCard({
    required this.fromCity,
    required this.toCity,
    required this.dateLabel,
    required this.priceLabel,
    required this.fromLabel,
    required this.toLabel,
    required this.dateFieldLabel,
    required this.priceFieldLabel,
  });

  final String fromCity;
  final String toCity;
  final String dateLabel;
  final String priceLabel;
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Column(
                  children: [
                    _TimelineDot(
                      fill: const Color(0xFF9F4200),
                      halo: const Color(0xFFFFDBCB),
                    ),
                    Container(
                      width: 2.w,
                      height: 40.h,
                      color: const Color(0xFFDDE3E9),
                    ),
                    const _TimelineDot(
                      fill: Color(0xFF00629E),
                      halo: Color(0xFFCFE5FF),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RouteStop(label: fromLabel, city: fromCity),
                    SizedBox(height: 24.h),
                    _RouteStop(label: toLabel, city: toCity),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 32.h),
          Row(
            children: [
              Expanded(
                child: _MetaTile(
                  label: dateFieldLabel,
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14.w,
                        color: const Color(0xFF9F4200),
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          dateLabel,
                          style: TextStyle(
                            fontFamily: FontRes.MANROPE_BOLD,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: CancelShipmentTokens.bodyDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: _MetaTile(
                  label: priceFieldLabel,
                  child: Text(
                    priceLabel,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_EXTRABOLD,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: CancelShipmentTokens.primaryOrange,
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

class _TimelineDot extends StatelessWidget {
  const _TimelineDot({required this.fill, required this.halo});

  final Color fill;
  final Color halo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12.w,
      height: 12.w,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: halo, blurRadius: 0, spreadRadius: 4)],
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
            color: CancelShipmentTokens.labelBrown,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          city,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_BOLD,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: CancelShipmentTokens.bodyDark,
          ),
        ),
      ],
    );
  }
}

class _MetaTile extends StatelessWidget {
  const _MetaTile({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: CancelShipmentTokens.cardFill,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: FontRes.MANROPE_BOLD,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: CancelShipmentTokens.labelBrown,
            ),
          ),
          SizedBox(height: 4.h),
          child,
        ],
      ),
    );
  }
}
