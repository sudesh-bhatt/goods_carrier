import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../res/font_res.dart';

/// Profile settings row — Figma bento list (`2013:1958`).
class CustomerProfileMenuRow extends StatelessWidget {
  const CustomerProfileMenuRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: colors.cardBackground,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, size: 18.w, color: colors.primary),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_BOLD,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_REGULAR,
                        fontSize: 12.sp,
                        color: colors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20.w,
                color: colors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
