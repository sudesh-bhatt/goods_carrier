import 'package:flutter/material.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/presentation/widgets/profile/profile_image_content.dart';

/// Shared app bar for the customer main shell — title + optional trailing.
class CustomerMainHeader extends StatelessWidget {
  const CustomerMainHeader({
    super.key,
    required this.title,
    this.userInitials = '?',
    this.profileImageUrl,
    this.trailing,
    this.onProfile,
  });

  final String title;
  final String userInitials;
  final String? profileImageUrl;
  final Widget? trailing;
  final VoidCallback? onProfile;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final avatarSize = 34.w;

    return ColoredBox(
      color: colors.surface,
      child: SafeArea(
        child: Container(
          height: 56.h,
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: Row(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  layoutBuilder: (currentChild, previousChildren) {
                    return Stack(
                      alignment: Alignment.centerLeft,
                      clipBehavior: Clip.none,
                      children: [
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    );
                  },
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
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
              if (trailing != null) ...[
                trailing!,
                SizedBox(width: 4.w),
              ],
              if (onProfile != null) ...[
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: onProfile,
                  child: ClipOval(
                    child: SizedBox(
                      width: avatarSize,
                      height: avatarSize,
                      child: ProfileImageContent(
                        imageReference: profileImageUrl,
                        placeholder: ColoredBox(
                          color: colors.primary.withValues(alpha: 0.12),
                          child: Center(
                            child: Text(
                              userInitials,
                              style: TextStyle(
                                fontFamily: FontRes.MANROPE_BOLD,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: colors.primaryDark,
                              ),
                            ),
                          ),
                        ),
                        fit: BoxFit.cover,
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
