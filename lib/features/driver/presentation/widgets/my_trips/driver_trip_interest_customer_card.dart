import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/extensions/size_ext.dart';
import '../../../../../core/extensions/string_ext.dart';
import '../../../../../core/extensions/svg_gen_image_extension.dart';
import '../../../../../generated/assets.dart';
import '../../../../../res/font_res.dart';
import '../../../../../shared/presentation/widgets/profile/profile_image_content.dart';
import 'driver_my_trip_tokens.dart';

/// Interested customer row — Figma Trip Details `1:4180`.
class DriverTripInterestCustomerCard extends StatelessWidget {
  const DriverTripInterestCustomerCard({
    super.key,
    required this.name,
    this.avatarUrl,
    this.phone,
    this.onWhatsApp,
    this.onCall,
  });

  final String name;
  final String? avatarUrl;
  final String? phone;
  final VoidCallback? onWhatsApp;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
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
              _CustomerAvatar(name: name, avatarUrl: avatarUrl),
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
          Row(
            children: [
              Expanded(
                child: _ContactButton(
                  leading: Assets.icWhatsapp.svgTint(
                    width: 20.w,
                    height: 20.w,
                    color: DriverMyTripTokens.heading,
                  ),
                  label: 'WHATSAPP',
                  onTap: phone != null && phone!.isNotEmpty ? onWhatsApp : null,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _ContactButton(
                  icon: Icons.phone_outlined,
                  label: 'CALL',
                  onTap: phone != null && phone!.isNotEmpty ? onCall : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomerAvatar extends StatelessWidget {
  const _CustomerAvatar({required this.name, this.avatarUrl});

  final String name;
  final String? avatarUrl;

  Widget _placeholder() {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: DriverMyTripTokens.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        name.initials,
        style: TextStyle(
          fontFamily: FontRes.MANROPE_BOLD,
          fontSize: 18.sp,
          color: DriverMyTripTokens.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 48.w,
        height: 48.w,
        child: ProfileImageContent(
          imageReference: avatarUrl,
          placeholder: _placeholder(),
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
                    size: 16.w,
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
