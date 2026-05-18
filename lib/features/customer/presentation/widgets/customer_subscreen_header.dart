import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
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
                  AppBarBackButton(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRoutes.customerHome);
                      }
                    },
                  )
                else
                  SizedBox(width: 48.w),
                SizedBox(width: 8.w),
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
                if (trailing != null) trailing! else SizedBox(width: 48.w),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
