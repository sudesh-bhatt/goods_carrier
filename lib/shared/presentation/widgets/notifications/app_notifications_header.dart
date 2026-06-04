import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../res/font_res.dart';
import 'app_notification_tokens.dart';

/// Shared notifications app bar — Figma TopAppBar (customer & driver).
class AppNotificationsHeader extends StatelessWidget {
  const AppNotificationsHeader({
    super.key,
    required this.title,
    this.onMarkAllRead,
    this.showMarkAllRead = false,
  });

  final String title;
  final VoidCallback? onMarkAllRead;
  final bool showMarkAllRead;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0xCCFFFFFF),
            border: Border(
              bottom: BorderSide(color: AppNotificationTokens.headerBorder),
            ),
          ),
          child: SafeArea(
            child: SizedBox(
              height: 64.h,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_BOLD,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          height: 28 / 18,
                          letterSpacing: -0.45,
                          color: AppNotificationTokens.heading,
                        ),
                      ),
                    ),
                    if (showMarkAllRead && onMarkAllRead != null)
                      IconButton(
                        onPressed: onMarkAllRead,
                        padding: EdgeInsets.all(8.w),
                        constraints: BoxConstraints(
                          minWidth: 32.w,
                          minHeight: 32.w,
                        ),
                        icon: Icon(
                          Icons.done_all_rounded,
                          size: 14.w,
                          color: AppNotificationTokens.markAllReadIcon,
                        ),
                        tooltip: context.l10n.notificationMarkAllRead,
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
