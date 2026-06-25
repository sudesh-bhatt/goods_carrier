import 'package:flutter/material.dart';

import '../../../../../core/extensions/size_ext.dart';
import '../../../../../res/font_res.dart';
import 'subscription_tokens.dart';

enum SubscriptionPaymentMethod {
  upi('upi'),
  card('card'),
  netbanking('netbanking'),
  wallet('wallet');

  const SubscriptionPaymentMethod(this.apiValue);

  final String apiValue;
}

class SubscriptionPaymentOptionTile extends StatelessWidget {
  const SubscriptionPaymentOptionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBackground,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBackground;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.03),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: const [SubscriptionTokens.paymentOptionShadow],
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Row(
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(icon, color: SubscriptionTokens.headingDark),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_BOLD,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          height: 28 / 18,
                          color: SubscriptionTokens.headingDark,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_REGULAR,
                          fontSize: 14.sp,
                          height: 20 / 14,
                          color: SubscriptionTokens.brownText,
                        ),
                      ),
                    ],
                  ),
                ),
                _RadioIndicator(selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioIndicator extends StatelessWidget {
  const _RadioIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? SubscriptionTokens.radioSelected
              : SubscriptionTokens.radioUnselected,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 12.w,
              height: 12.w,
              decoration: const BoxDecoration(
                color: SubscriptionTokens.radioSelected,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}
