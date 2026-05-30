import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../models/report_trip_confirmation_args.dart';
import '../widgets/customer_light_chrome.dart';
import '../widgets/report_trip/report_trip_tokens.dart';

/// Report submitted success — Figma `1:6123`.
class ReportTripSuccessScreen extends StatelessWidget {
  const ReportTripSuccessScreen({super.key, required this.args});

  final ReportTripConfirmationArgs args;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = DateFormat('d MMMM yyyy', locale).format(args.submittedAt);
    final displayId = args.reportId.startsWith('#')
        ? args.reportId
        : '#${args.reportId}';

    return CustomerLightChrome(
      child: Scaffold(
        backgroundColor: ReportTripTokens.screenBg,
        appBar: FlowScreenAppBar(
          title: l10n.reportTripStatusTitle,
          backgroundColor: Colors.white.withValues(alpha: 0.8),
          onBackTap: () => context.go(AppRoutes.customerHome),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(32.w, 48.h, 32.w, 24.h),
                  child: Column(
                    children: [
                      const _ReportSuccessIcon(),
                      SizedBox(height: 32.h),
                      Text(
                        l10n.reportTripSuccessTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_EXTRABOLD,
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w800,
                          height: 36 / 30,
                          letterSpacing: -0.75,
                          color: ReportTripTokens.bodyDark,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        l10n.reportTripSuccessBody,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_MEDIUM,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          height: 26 / 16,
                          color: ReportTripTokens.bodyGrey,
                        ),
                      ),
                      SizedBox(height: 40.h),
                      _ReportSummaryCard(
                        reportId: displayId,
                        dateLabel: dateLabel,
                        reportIdLabel: l10n.reportIdLabel,
                        dateFieldLabel: l10n.reportDateLabel,
                        reviewInfo: l10n.reportReviewTimeInfo,
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
                    color: ReportTripTokens.primaryOrange,
                    borderRadius:
                        BorderRadius.circular(ReportTripTokens.buttonRadius.r),
                    elevation: 0,
                    shadowColor:
                        ReportTripTokens.primaryOrange.withValues(alpha: 0.3),
                    child: InkWell(
                      onTap: () => context.go(AppRoutes.customerHome),
                      borderRadius: BorderRadius.circular(
                        ReportTripTokens.buttonRadius.r,
                      ),
                      child: Center(
                        child: Text(
                          l10n.shipmentPostBackToHome,
                          style: TextStyle(
                            fontFamily: FontRes.MANROPE_BOLD,
                            fontSize: 16.sp,
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

class _ReportSuccessIcon extends StatelessWidget {
  const _ReportSuccessIcon();

  static const _accentBlue = Color(0xFF00A0FC);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128.w,
      height: 128.w,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: 128.w,
            height: 128.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ReportTripTokens.primaryOrange,
              boxShadow: [
                BoxShadow(
                  color: ReportTripTokens.primaryOrange.withValues(alpha: 0.15),
                  blurRadius: 50,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Container(
              width: 50.w,
              height: 50.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.check_rounded,
                color: ReportTripTokens.primaryOrange,
                size: 28.w,
              ),
            ),
          ),
          Positioned(
            right: -8.w,
            top: -8.h,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: _accentBlue.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportSummaryCard extends StatelessWidget {
  const _ReportSummaryCard({
    required this.reportId,
    required this.dateLabel,
    required this.reportIdLabel,
    required this.dateFieldLabel,
    required this.reviewInfo,
  });

  final String reportId;
  final String dateLabel;
  final String reportIdLabel;
  final String dateFieldLabel;
  final String reviewInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(ReportTripTokens.summaryRadius.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A161C20),
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          _SummaryRow(label: reportIdLabel, value: reportId, valueIsBrown: true),
          SizedBox(height: 16.h),
          Container(height: 1, color: ReportTripTokens.divider),
          SizedBox(height: 16.h),
          _SummaryRow(label: dateFieldLabel, value: dateLabel),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: ReportTripTokens.cardFill,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 12.w,
                  color: ReportTripTokens.infoBlue,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    reviewInfo,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_REGULAR,
                      fontSize: 12.sp,
                      height: 16 / 12,
                      color: ReportTripTokens.bodyGrey,
                    ),
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueIsBrown = false,
  });

  final String label;
  final String value;
  final bool valueIsBrown;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_BOLD,
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: ReportTripTokens.labelBrown,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_BOLD,
            fontSize: 16.sp,
            fontWeight: valueIsBrown ? FontWeight.w700 : FontWeight.w600,
            color: valueIsBrown
                ? ReportTripTokens.priceBrown
                : ReportTripTokens.bodyDark,
          ),
        ),
      ],
    );
  }
}
