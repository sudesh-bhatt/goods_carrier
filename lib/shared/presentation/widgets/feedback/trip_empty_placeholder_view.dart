import 'package:flutter/material.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../generated/assets.dart';
import '../../../../res/font_res.dart';

/// Figma trip empty placeholder — warehouse illustration + CTA.
///
/// Used on driver My Trip (`1:3425`) and customer shipments empty (`1:3367`).
class TripEmptyPlaceholderView extends StatelessWidget {
  const TripEmptyPlaceholderView({
    super.key,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.showActionIcon = true,
    this.scrollable = true,
  });

  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showActionIcon;
  final bool scrollable;

  static const _kTitleColor = Color(0xFF161C20);
  static const _kBodyColor = Color(0xFF594136);
  static const _kAccentBg = Color(0xFFFFDBCB);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final content = Padding(
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 32.h),
      child: Column(
        children: [
          _IllustrationSection(colors: colors),
          SizedBox(height: 32.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: FontRes.MANROPE_BOLD,
              fontSize: 30.sp,
              fontWeight: FontWeight.w700,
              height: 36 / 30,
              letterSpacing: -0.75,
              color: _kTitleColor,
            ),
          ),
          SizedBox(height: 15.25.h),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: FontRes.MANROPE_REGULAR,
              fontSize: 18.sp,
              fontWeight: FontWeight.w400,
              height: 24 / 18,
              color: _kBodyColor,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: 48.h),
            _PrimaryCtaButton(
              label: actionLabel!,
              onPressed: onAction!,
              colors: colors,
              showIcon: showActionIcon,
            ),
          ],
        ],
      ),
    );

    if (!scrollable) return content;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: content,
    );
  }
}

class _IllustrationSection extends StatelessWidget {
  const _IllustrationSection({required this.colors});

  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final size = 320.w;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(22, 28, 32, 0.06),
                  blurRadius: 40,
                  offset: Offset(0, 20),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: Image.asset(
                Assets.emptyTripPlaceholder.path,
                width: size,
                height: size,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            right: 12.w,
            top: 12.h,
            child: Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: TripEmptyPlaceholderView._kAccentBg,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.local_shipping_outlined,
                size: 22.w,
                color: colors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryCtaButton extends StatelessWidget {
  const _PrimaryCtaButton({
    required this.label,
    required this.onPressed,
    required this.colors,
    required this.showIcon,
  });

  final String label;
  final VoidCallback onPressed;
  final AppColorScheme colors;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24.r),
        child: Ink(
          width: double.infinity,
          height: 68.h,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showIcon) ...[
                Icon(
                  Icons.add_circle_outline,
                  size: 20.w,
                  color: colors.onPrimary,
                ),
                SizedBox(width: 12.w),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_BOLD,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  height: 30 / 18,
                  color: colors.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
