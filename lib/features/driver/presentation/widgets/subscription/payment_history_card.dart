import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/extensions/size_ext.dart';
import '../../../../../res/font_res.dart';
import '../../../../../shared/domain/models/driver_payment_record.dart';
import 'subscription_tokens.dart';

/// Payment history row — Figma `1:5349`.
class PaymentHistoryCard extends StatelessWidget {
  const PaymentHistoryCard({
    super.key,
    required this.payment,
    required this.dateLabel,
    required this.invoiceLabel,
    required this.onInvoiceTap,
    this.isLoadingInvoice = false,
  });

  final DriverPaymentRecord payment;
  final String dateLabel;
  final String invoiceLabel;
  final VoidCallback onInvoiceTap;
  final bool isLoadingInvoice;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(22, 28, 32, 0.03),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.displayTransactionId,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_BOLD,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                        color: SubscriptionTokens.brownText.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      payment.planName.isNotEmpty
                          ? payment.planName
                          : 'Subscription',
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_BOLD,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        height: 22 / 15,
                        color: SubscriptionTokens.headingDark,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    payment.amountLabel,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_EXTRABOLD,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      height: 28 / 18,
                      letterSpacing: -0.45,
                      color: SubscriptionTokens.primaryOrange,
                    ),
                  ),
                  Text(
                    payment.displayStatus,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_SEMIBOLD,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      height: 15 / 10,
                      color: SubscriptionTokens.brownText.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.only(top: 12.h),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: const Color(0xFFE9EEF4).withValues(alpha: 0.3),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 13.5.w,
                  color: SubscriptionTokens.radioSelected,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    dateLabel,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_MEDIUM,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      height: 16 / 12,
                      color: SubscriptionTokens.brownText,
                    ),
                  ),
                ),
                Material(
                  color: SubscriptionTokens.receiptCardBg,
                  borderRadius: BorderRadius.circular(12.r),
                  child: InkWell(
                    onTap: isLoadingInvoice ? null : onInvoiceTap,
                    borderRadius: BorderRadius.circular(12.r),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(12.w, 5.h, 12.w, 6.25.h),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isLoadingInvoice)
                            SizedBox(
                              width: 10.67.w,
                              height: 10.67.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 1.5,
                              ),
                            )
                          else
                            Icon(
                              Icons.download_rounded,
                              size: 10.67.w,
                              color: SubscriptionTokens.headingDark,
                            ),
                          SizedBox(width: 6.w),
                          Text(
                            invoiceLabel,
                            style: TextStyle(
                              fontFamily: FontRes.MANROPE_BOLD,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              height: 16 / 11,
                              color: SubscriptionTokens.headingDark,
                            ),
                          ),
                        ],
                      ),
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

String formatPaymentHistoryDate(DateTime date, String locale) =>
    DateFormat('d MMM yyyy', locale).format(date);
