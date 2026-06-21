import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/extensions/size_ext.dart';
import '../../../../../core/extensions/svg_gen_image_extension.dart';
import '../../../../../core/extensions/theme_ext.dart';
import '../../../../../generated/assets.dart';
import '../../../../../res/font_res.dart';
import 'driver_my_trip_tokens.dart';

/// Interested customer row — Figma Trip Details `1:4180`.
class DriverTripInterestCustomerCard extends StatelessWidget {
  const DriverTripInterestCustomerCard({
    super.key,
    required this.name,
    this.phone,
    this.onWhatsApp,
    this.onCall,
    this.showActions = false,
    this.isBusy = false,
    this.onAccept,
    this.onReject,
  });

  final String name;
  final String? phone;
  final VoidCallback? onWhatsApp;
  final VoidCallback? onCall;
  final bool showActions;
  final bool isBusy;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: DriverMyTripTokens.customerCardFill,
        border: Border.all(color: DriverMyTripTokens.customerCardBorder),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor:
                    DriverMyTripTokens.primary.withValues(alpha: 0.15),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_BOLD,
                    fontSize: 18.sp,
                    color: DriverMyTripTokens.primary,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_BOLD,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    height: 24 / 16,
                    color: DriverMyTripTokens.heading,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (showActions) ...[
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: l10n.driverTripRequestAccept,
                    foreground: Colors.white,
                    background: DriverMyTripTokens.primary,
                    isBusy: isBusy,
                    onTap: onAccept,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _ActionButton(
                    label: l10n.driverTripRequestReject,
                    foreground: DriverMyTripTokens.heading,
                    background: Colors.white,
                    borderColor: DriverMyTripTokens.customerCardBorder,
                    isBusy: isBusy,
                    onTap: onReject,
                  ),
                ),
              ],
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: _ContactButton(
                    leading: Assets.icWhatsapp.svgTint(
                      width: 18.w,
                      height: 18.w,
                      color: DriverMyTripTokens.heading,
                    ),
                    label: 'WHATSAPP',
                    onTap: onWhatsApp,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _ContactButton(
                    icon: Icons.phone_outlined,
                    label: 'CALL',
                    onTap: onCall,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.foreground,
    required this.background,
    this.borderColor,
    this.isBusy = false,
    this.onTap,
  });

  final String label;
  final Color foreground;
  final Color background;
  final Color? borderColor;
  final bool isBusy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: isBusy || onTap == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onTap!();
              },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          height: 40.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: borderColor == null
                ? null
                : Border.all(color: borderColor!),
          ),
          child: isBusy
              ? SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: foreground,
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_BOLD,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
                ),
        ),
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.label,
    this.onTap,
    this.icon,
    this.leading,
  }) : assert(icon != null || leading != null);

  final IconData? icon;
  final Widget? leading;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onTap!();
              },
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          height: 36.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              leading ??
                  Icon(
                    icon,
                    size: 18.w,
                    color: DriverMyTripTokens.heading,
                  ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_BOLD,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: DriverMyTripTokens.heading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
