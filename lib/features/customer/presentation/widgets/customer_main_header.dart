import 'package:flutter/material.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../res/font_res.dart';

/// Shared app bar for the customer main shell — title + optional trailing.
class CustomerMainHeader extends StatelessWidget {
  const CustomerMainHeader({
    super.key,
    required this.title,
    required this.unreadCount,
    this.userName,
    this.trailing,
    this.onNotifications,
    this.onProfile,
  });

  final String title;
  final int unreadCount;
  final String? userName;
  final Widget? trailing;
  final VoidCallback? onNotifications;
  final VoidCallback? onProfile;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial = (userName?.trim().isNotEmpty == true)
        ? userName!.trim()[0].toUpperCase()
        : '?';

    return ColoredBox(
      color: colors.surface,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 56.h,
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: Text(
                      title,
                      key: ValueKey<String>(title),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_EXTRABOLD,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              if (trailing != null) ...[
                trailing!,
                SizedBox(width: 4.w),
              ],
              if (onNotifications != null)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints:
                      BoxConstraints(minWidth: 40.w, minHeight: 40.w),
                  onPressed: onNotifications,
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 24.w,
                        color: colors.primary,
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.surface,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              if (onProfile != null) ...[
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: onProfile,
                  child: CircleAvatar(
                    radius: 17.w,
                    backgroundColor:
                        colors.primary.withValues(alpha: 0.12),
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_BOLD,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: colors.primaryDark,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
