import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/extensions/size_ext.dart';
import '../../../../../res/font_res.dart';
import '../../../../../shared/domain/models/current_subscription.dart';
import 'subscription_tokens.dart';

/// Hero card for the driver's currently active subscription.
class SubscriptionActivePlanCard extends StatelessWidget {
  const SubscriptionActivePlanCard({
    super.key,
    required this.subscription,
    required this.activeLabel,
    required this.changePlanLabel,
    required this.perMonthLabel,
    required this.validTillLabel,
    required this.tripsUsageLabel,
    required this.onChangePlan,
  });

  final CurrentSubscription subscription;
  final String activeLabel;
  final String changePlanLabel;
  final String perMonthLabel;
  final String validTillLabel;
  final String tripsUsageLabel;
  final VoidCallback onChangePlan;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: SubscriptionTokens.primaryOrange, width: 2),
        boxShadow: const [SubscriptionTokens.recommendedCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  subscription.planName,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_EXTRABOLD,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    height: 34 / 28,
                    color: SubscriptionTokens.titleDark,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: SubscriptionTokens.successGreenStart
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  activeLabel,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_BOLD,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: SubscriptionTokens.successGreenStart,
                  ),
                ),
              ),
            ],
          ),
          if (subscription.priceLabel.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  subscription.priceLabel,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_EXTRABOLD,
                    fontSize: 40.sp,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    color: SubscriptionTokens.primaryOrange,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  perMonthLabel,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_MEDIUM,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: SubscriptionTokens.bodyGrey,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 20.h),
          _MetaRow(
            icon: Icons.event_available_rounded,
            label: validTillLabel,
          ),
          if (tripsUsageLabel.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _MetaRow(
              icon: Icons.local_shipping_outlined,
              label: tripsUsageLabel,
            ),
          ],
          SizedBox(height: 28.h),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            child: InkWell(
              onTap: onChangePlan,
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                width: double.infinity,
                height: 52.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: SubscriptionTokens.primaryOrange,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  changePlanLabel,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_EXTRABOLD,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: SubscriptionTokens.primaryOrange,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String formatValidTill(DateTime endDate, String locale) {
    return DateFormat('dd MMM yyyy', locale).format(endDate.toLocal());
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18.w, color: SubscriptionTokens.bodyGrey),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: FontRes.MANROPE_MEDIUM,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              height: 20 / 14,
              color: SubscriptionTokens.bodyGrey,
            ),
          ),
        ),
      ],
    );
  }
}
