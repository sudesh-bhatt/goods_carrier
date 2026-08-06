import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../models/subscription_flow_args.dart';
import '../providers/driver_subscription_provider.dart';
import '../widgets/subscription/subscription_tokens.dart';

/// Payment success / failure receipt — Figma `1:5178`.
class DriverSubscriptionPaymentResultScreen extends ConsumerWidget {
  const DriverSubscriptionPaymentResultScreen({
    super.key,
    required this.args,
  });

  final SubscriptionPaymentResultArgs args;

  void _leave(BuildContext context, WidgetRef ref) {
    ref.read(driverSubscriptionProvider.notifier).clearCheckoutFlow();
    context.go(AppRoutes.driverHome);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = args.paidAt != null
        ? DateFormat('dd MMMM yyyy', locale).format(args.paidAt!)
        : '—';
    final expiryLabel = args.expiresAt != null
        ? l10n.driverSubscriptionTillDate(
            DateFormat('dd MMMM yyyy', locale).format(args.expiresAt!),
          )
        : null;

    return Scaffold(
      backgroundColor: SubscriptionTokens.paymentScreenBg,
      appBar: FlowScreenAppBar(
        title: l10n.driverSubscriptionReceiptTitle,
        onBackTap: () => _leave(context, ref),
        showBack: true,
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
                    _StatusIcon(isSuccess: args.isSuccess),
                    SizedBox(height: 32.h),
                    Text(
                      args.isSuccess
                          ? l10n.driverSubscriptionPaymentSuccessTitle
                          : l10n.driverSubscriptionPaymentFailedTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_EXTRABOLD,
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w800,
                        height: 36 / 30,
                        letterSpacing: -0.75,
                        color: SubscriptionTokens.headingDark,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      args.isSuccess
                          ? l10n.driverSubscriptionPaymentSuccessBody
                          : (args.failureMessage ??
                              l10n.driverSubscriptionPaymentFailedBody),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_MEDIUM,
                        fontSize: 16.sp,
                        height: 26 / 16,
                        color: SubscriptionTokens.brownText,
                      ),
                    ),
                    SizedBox(height: 32.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: SubscriptionTokens.receiptCardBg,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.driverSubscriptionAmountLabel,
                            style: TextStyle(
                              fontFamily: FontRes.MANROPE_BOLD,
                              fontSize: 12.sp,
                              letterSpacing: 1.2,
                              color: SubscriptionTokens.brownText
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '₹${args.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontFamily: FontRes.MANROPE_EXTRABOLD,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w800,
                              color: SubscriptionTokens.headingDark,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Row(
                            children: [
                              Expanded(
                                child: _ReceiptField(
                                  label:
                                      l10n.driverSubscriptionTransactionIdLabel,
                                  value: args.transactionId ?? '—',
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: _ReceiptField(
                                  label: l10n.driverSubscriptionDateLabel,
                                  value: dateLabel,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24.h),
                          Divider(
                            color: SubscriptionTokens.divider.withValues(
                              alpha: 0.2,
                            ),
                            height: 1,
                          ),
                          SizedBox(height: 24.h),
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40.w,
                                  height: 40.w,
                                  decoration: BoxDecoration(
                                    color: SubscriptionTokens.bankIconBg,
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Icon(
                                    Icons.card_membership_outlined,
                                    size: 22.w,
                                    color: SubscriptionTokens.mutedBrown,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        args.planName,
                                        style: TextStyle(
                                          fontFamily: FontRes.MANROPE_BOLD,
                                          fontSize: 12.sp,
                                          color: SubscriptionTokens.headingDark,
                                        ),
                                      ),
                                      if (expiryLabel != null)
                                        Text(
                                          expiryLabel,
                                          style: TextStyle(
                                            fontFamily: FontRes.MANROPE_REGULAR,
                                            fontSize: 10.sp,
                                            color: SubscriptionTokens.brownText,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
                  color: SubscriptionTokens.primaryOrange,
                  borderRadius: BorderRadius.circular(12.r),
                  child: InkWell(
                    onTap: () => _leave(context, ref),
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
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.isSuccess});

  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96.w,
      height: 96.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSuccess
              ? [
                  SubscriptionTokens.successGreenStart,
                  SubscriptionTokens.successGreenEnd,
                ]
              : [
                  SubscriptionTokens.failureRedStart,
                  SubscriptionTokens.failureRedEnd,
                ],
        ),
        boxShadow: [
          if (isSuccess) SubscriptionTokens.successIconShadow,
        ],
      ),
      child: Icon(
        isSuccess ? Icons.check_rounded : Icons.close_rounded,
        size: 40.w,
        color: Colors.white,
      ),
    );
  }
}

class _ReceiptField extends StatelessWidget {
  const _ReceiptField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

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
            color: SubscriptionTokens.brownText.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_SEMIBOLD,
            fontSize: 14.sp,
            color: SubscriptionTokens.headingDark,
          ),
        ),
      ],
    );
  }
}
