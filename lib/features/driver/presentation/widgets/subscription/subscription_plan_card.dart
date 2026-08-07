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
    this.isFcfoActive = false,
    this.activeNowLabel = 'Active now',
    this.unavailablePurchaseLabel = 'Trips in use',
    this.tripLimitLabel,
    this.forcePrimaryCta = false,
  });

  final SubscriptionPlan plan;
  final List<String> features;
  final String choosePlanLabel;
  final String subscribeNowLabel;
  final String recommendedLabel;
  final String perMonthLabel;
  final VoidCallback onChoose;

  /// True when this plan is the FCFO plan currently consuming trips.
  final bool isFcfoActive;
  final String activeNowLabel;

  /// CTA when [SubscriptionPlan.canPurchase] is false.
  final String unavailablePurchaseLabel;

  /// Optional e.g. "5 trips included".
  final String? tripLimitLabel;

  /// Orange primary CTA for purchasable plans (e.g. while another plan is owned).
  final bool forcePrimaryCta;

  @override
  Widget build(BuildContext context) {
    final canPurchase = plan.canPurchase;
    final isRecommended = plan.isRecommended && canPurchase;
    final emphasize = canPurchase && (isRecommended || forcePrimaryCta);
    final displayFeatures = features.isNotEmpty ? features : plan.features;
    final ctaLabel = canPurchase
        ? (isRecommended ? subscribeNowLabel : choosePlanLabel)
        : unavailablePurchaseLabel;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 280),
      opacity: canPurchase ? 1 : 0.72,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: emphasize
                  ? Border.all(
                      color: SubscriptionTokens.primaryOrange,
                      width: 2,
                    )
                  : !canPurchase
                      ? Border.all(
                          color: SubscriptionTokens.secondaryButtonBg,
                          width: 1.5,
                        )
                      : null,
              boxShadow: [
                emphasize
                    ? SubscriptionTokens.recommendedCardShadow
                    : SubscriptionTokens.planCardShadow,
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        plan.name,
                        style: TextStyle(
                          fontFamily: emphasize
                              ? FontRes.MANROPE_EXTRABOLD
                              : FontRes.MANROPE_BOLD,
                          fontSize: 24.sp,
                          fontWeight:
                              emphasize ? FontWeight.w800 : FontWeight.w700,
                          height: 32 / 24,
                          color: SubscriptionTokens.titleDark,
                        ),
                      ),
                    ),
                    if (isFcfoActive || !canPurchase)
                      Container(
                        margin: EdgeInsets.only(left: 8.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: isFcfoActive
                              ? SubscriptionTokens.successGreenStart
                                  .withValues(alpha: 0.12)
                              : SubscriptionTokens.upiIconBg,
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Text(
                          isFcfoActive
                              ? activeNowLabel
                              : unavailablePurchaseLabel,
                          style: TextStyle(
                            fontFamily: FontRes.MANROPE_BOLD,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: isFcfoActive
                                ? SubscriptionTokens.successGreenStart
                                : SubscriptionTokens.upiIcon,
                          ),
                        ),
                      ),
                  ],
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
                if (tripLimitLabel != null && tripLimitLabel!.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(
                    tripLimitLabel!,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_SEMIBOLD,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: SubscriptionTokens.primaryOrange,
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
                        fontSize: (emphasize ? 48 : 36).sp,
                        fontWeight: FontWeight.w800,
                        height: 1,
                        color: emphasize
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
                      emphasized: emphasize,
                    ),
                  ),
                ),
                SizedBox(height: 28.h),
                _PlanCtaButton(
                  label: ctaLabel,
                  isPrimary: emphasize,
                  enabled: canPurchase,
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
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
      ),
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
    this.enabled = true,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bg = !enabled
        ? SubscriptionTokens.secondaryButtonBg
        : isPrimary
            ? SubscriptionTokens.primaryOrange
            : SubscriptionTokens.secondaryButtonBg;
    final fg = !enabled
        ? SubscriptionTokens.mutedBrown
        : isPrimary
            ? Colors.white
            : SubscriptionTokens.titleDark;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(8.r),
      elevation: 0,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          width: double.infinity,
          height: 56.h,
          alignment: Alignment.center,
          decoration: isPrimary && enabled
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: const [SubscriptionTokens.payButtonShadow],
                )
              : null,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: isPrimary && enabled
                  ? FontRes.MANROPE_EXTRABOLD
                  : FontRes.MANROPE_BOLD,
              fontSize: 16.sp,
              fontWeight:
                  isPrimary && enabled ? FontWeight.w900 : FontWeight.w700,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
