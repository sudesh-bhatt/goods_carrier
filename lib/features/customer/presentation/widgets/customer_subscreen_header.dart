import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../res/font_res.dart';
/// Figma sub-screen app bar — back control + title (`2013:2534`, `2013:3535`).
class CustomerSubscreenHeader extends StatelessWidget implements PreferredSizeWidget {
  const CustomerSubscreenHeader({
    super.key,
    required this.title,
    this.showBack = true,
    this.trailing,
  });

  final String title;
  final bool showBack;
  final Widget? trailing;

  @override
  Size get preferredSize => Size.fromHeight(64.h);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ColoredBox(
      color: colors.surface,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                if (showBack)
                  _BackButton(onTap: () {
                    HapticFeedback.lightImpact();
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.customerHome);
                    }
                  })
                else
                  SizedBox(width: 32.w),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_EXTRABOLD,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                if (trailing != null) trailing! else SizedBox(width: 32.w),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: colors.inputFill,
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: SizedBox(
          width: 32.w,
          height: 32.w,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16.w,
            color: colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
