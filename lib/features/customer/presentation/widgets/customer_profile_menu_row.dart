import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../res/font_res.dart';

/// Icon treatment for profile bento rows — Figma `1:1931`.
enum ProfileMenuIconStyle {
  /// Orange wash (#FFDBCB) + dark orange icon (#9F4200).
  accent,

  /// Grey wash (#E3E9EE) + slate icon (#5F656A).
  neutral,
}

/// Profile settings row — Figma bento list.
class CustomerProfileMenuRow extends StatelessWidget {
  const CustomerProfileMenuRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconStyle = ProfileMenuIconStyle.neutral,
    this.iconSize,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final ProfileMenuIconStyle iconStyle;

  /// Figma icon size — default 20px; Settings uses 24px.
  final double? iconSize;

  static const double _kDefaultIconSize = 20;
  static const double _kIconBoxSize = 40;

  static const _kAccentIconBg = Color(0xFFFFDBCB);
  static const _kNeutralIconBg = Color(0xFFE3E9EE);
  static const _kNeutralIcon = Color(0xFF5F656A);
  static const _kChevron = Color(0x66594136);
  static const _kTitle = Color(0xFF161C20);
  static const _kSubtitle = Color(0xFF594136);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final iconBg = iconStyle == ProfileMenuIconStyle.accent
        ? _kAccentIconBg
        : _kNeutralIconBg;
    final iconColor =
        iconStyle == ProfileMenuIconStyle.accent ? colors.primaryDark : _kNeutralIcon;
    final resolvedIconSize = (iconSize ?? _kDefaultIconSize).w;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(24.r),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(24.r),
        child: SizedBox(
          height: 72.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Container(
                  width: _kIconBoxSize.w,
                  height: _kIconBoxSize.w,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: resolvedIconSize, color: iconColor),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_BOLD,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          height: 20 / 14,
                          color: _kTitle,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_REGULAR,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          height: 16 / 12,
                          color: _kSubtitle,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 12.w,
                  color: _kChevron,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
