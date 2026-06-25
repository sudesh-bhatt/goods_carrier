import 'package:flutter/material.dart';

import '../../../../../core/extensions/size_ext.dart';
import '../../../../../res/font_res.dart';
import '../../../../../shared/domain/models/subscription_plan.dart';
import 'subscription_tokens.dart';

class SubscriptionPlanCard extends StatelessWidget {
  const SubscriptionPlanCard({
    super.key,
    required this.plan,
    required this.choosePlanLabel,
    required this.subscribeNowLabel,
    required this.recommendedLabel,
    required this.perMonthLabel,
    required this.onChoose,
    this.features = const [],
  });

  final SubscriptionPlan plan;
  final List<String> features;
  final String choosePlanLabel;
  final String subscribeNowLabel;
  final String recommendedLabel;
  final String perMonthLabel;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    final isRecommended = plan.isRecommended;
    final displayFeatures = features.isNotEmpty ? features : plan.features;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(32.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: isRecommended
                ? Border.all(color: SubscriptionTokens.primaryOrange, width: 2)
                : null,
            boxShadow: [
              isRecommended
                  ? SubscriptionTokens.recommendedCardShadow
                  : SubscriptionTokens.planCardShadow,
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.name,
                style: TextStyle(
                  fontFamily: isRecommended
                      ? FontRes.MANROPE_EXTRABOLD
                      : FontRes.MANROPE_BOLD,
                  fontSize: 24.sp,
                  fontWeight: isRecommended ? FontWeight.w800 : FontWeight.w700,
                  height: 32 / 24,
                  color: SubscriptionTokens.titleDark,
                ),
              ),
              if (plan.displayTagline.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  plan.displayTagline,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_MEDIUM,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    height: 20 / 14,
                    color: SubscriptionTokens.bodyGrey,
                  ),
                ),
              ],
              SizedBox(height: 32.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    plan.priceLabel,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_EXTRABOLD,
                      fontSize: (isRecommended ? 48 : 36).sp,
                      fontWeight: FontWeight.w800,
                      height: 1,
                      color: isRecommended
                          ? SubscriptionTokens.primaryOrange
                          : SubscriptionTokens.titleDark,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    perMonthLabel,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_MEDIUM,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      height: 24 / 16,
                      color: SubscriptionTokens.bodyGrey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),
              ...displayFeatures.map(
                (feature) => Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: _FeatureRow(
                    label: feature,
                    emphasized: isRecommended,
                  ),
                ),
              ),
              SizedBox(height: 28.h),
              _PlanCtaButton(
                label: isRecommended ? subscribeNowLabel : choosePlanLabel,
                isPrimary: isRecommended,
                onTap: onChoose,
              ),
            ],
          ),
        ),
        if (isRecommended)
          Positioned(
            top: -14.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: SubscriptionTokens.primaryOrange,
                  borderRadius: BorderRadius.circular(9999.r),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.1),
                      blurRadius: 15,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Text(
                  recommendedLabel,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_EXTRABOLD,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.label,
    required this.emphasized,
  });

  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.check_circle,
          size: (emphasized ? 18 : 16.67).w,
          color: SubscriptionTokens.primaryOrange,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: emphasized
                  ? FontRes.MANROPE_SEMIBOLD
                  : FontRes.MANROPE_MEDIUM,
              fontSize: 14.sp,
              fontWeight: emphasized ? FontWeight.w600 : FontWeight.w500,
              height: 20 / 14,
              color: emphasized
                  ? SubscriptionTokens.titleDark
                  : SubscriptionTokens.bodyGrey,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlanCtaButton extends StatelessWidget {
  const _PlanCtaButton({
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary
          ? SubscriptionTokens.primaryOrange
          : SubscriptionTokens.secondaryButtonBg,
      borderRadius: BorderRadius.circular(8.r),
      elevation: 0,
      shadowColor: SubscriptionTokens.primaryOrange.withValues(alpha: 0.25),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          width: double.infinity,
          height: 56.h,
          alignment: Alignment.center,
          decoration: isPrimary
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: const [SubscriptionTokens.payButtonShadow],
                )
              : null,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: isPrimary
                  ? FontRes.MANROPE_EXTRABOLD
                  : FontRes.MANROPE_BOLD,
              fontSize: 16.sp,
              fontWeight: isPrimary ? FontWeight.w900 : FontWeight.w700,
              color: isPrimary ? Colors.white : SubscriptionTokens.titleDark,
            ),
          ),
        ),
      ),
    );
  }
}
