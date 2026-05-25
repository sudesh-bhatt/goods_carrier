import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import 'saved_addresses/saved_address_tokens.dart';

/// Blurred top bar — Figma saved/add address (`1:3130`, `1:3201`).
class CustomerFlowHeader extends StatelessWidget implements PreferredSizeWidget {
  const CustomerFlowHeader({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Size get preferredSize => Size.fromHeight(64.h);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 0.8),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(255, 109, 0, 0.05),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 64.h,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  children: [
                    FigmaFlowBackButton(
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.customerHome);
                        }
                      },
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_BOLD,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        height: 28 / 18,
                        letterSpacing: -0.45,
                        color: SavedAddressTokens.titleDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
