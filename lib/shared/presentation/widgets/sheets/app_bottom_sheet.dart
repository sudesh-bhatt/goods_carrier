import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../res/font_res.dart';

/// Figma bottom sheet tokens — node `1:2310`.
abstract final class AppBottomSheetTokens {
  static const background = Color(0xFFFFFFFF);
  static const handleColor = Color(0xFFDDE3E9);
  static const titleColor = Color(0xFF161C20);
  static const bodyColor = Color(0xFF594136);
  static const primaryOrange = Color(0xFFFF6D00);
  static const secondaryBorder = Color(0xFFDDE3E9);

  static const topRadius = 24.0;
  static const handleWidth = 48.0;
  static const handleHeight = 6.0;
  static const contentPaddingH = 24.0;
  static const contentPaddingTop = 24.0;
  static const contentPaddingBottom = 40.0;
  static const sectionGap = 16.0;
  static const buttonHeight = 60.0;
  static const buttonRadius = 16.0;
  static const headerIconSize = 64.0;

  /// Default cap for scrollable sheets (filter, picker, etc.).
  static const maxHeightFraction = 0.8;
}

/// Full-width bottom sheet shell — Figma `1:2310`.
class AppBottomSheetContainer extends StatelessWidget {
  const AppBottomSheetContainer({
    super.key,
    required this.child,
    this.backgroundColor = AppBottomSheetTokens.background,
    this.showHandle = true,
    this.maxHeight,
  });

  final Widget child;
  final Color backgroundColor;
  final bool showHandle;
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    // Prefer viewPadding — MediaQuery.padding.bottom can be 0 on Android
    // edge-to-edge even when a 3-button nav bar is present.
    final systemBottom = keyboardInset > 0
        ? 0.0
        : MediaQuery.viewPaddingOf(context).bottom;
    final isBounded = maxHeight != null;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppBottomSheetTokens.topRadius.r),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(22, 28, 32, 0.12),
              blurRadius: 40,
              offset: Offset(0, -20),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: systemBottom),
          child: ConstrainedBox(
            constraints: isBounded
                ? BoxConstraints(maxHeight: maxHeight!)
                : const BoxConstraints(),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppBottomSheetTokens.contentPaddingH.w,
                AppBottomSheetTokens.contentPaddingTop.h,
                AppBottomSheetTokens.contentPaddingH.w,
                AppBottomSheetTokens.contentPaddingBottom.h,
              ),
              child: Column(
                mainAxisSize:
                    isBounded ? MainAxisSize.max : MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showHandle) ...[
                    const Center(child: AppBottomSheetHandle()),
                    SizedBox(height: AppBottomSheetTokens.sectionGap.h),
                  ],
                  if (isBounded) Expanded(child: child) else child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Drag handle — 48×6, `#DDE3E9`.
class AppBottomSheetHandle extends StatelessWidget {
  const AppBottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppBottomSheetTokens.handleWidth.w,
      height: AppBottomSheetTokens.handleHeight.h,
      decoration: BoxDecoration(
        color: AppBottomSheetTokens.handleColor,
        borderRadius: BorderRadius.circular(9999),
      ),
    );
  }
}

/// Orange circular header icon with white border + glow.
class AppBottomSheetHeaderIcon extends StatelessWidget {
  const AppBottomSheetHeaderIcon({
    super.key,
    required this.icon,
    this.iconSize = 28,
  });

  final IconData icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: AppBottomSheetTokens.headerIconSize.w,
        height: AppBottomSheetTokens.headerIconSize.w,
        decoration: BoxDecoration(
          color: AppBottomSheetTokens.primaryOrange,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: AppBottomSheetTokens.primaryOrange.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: iconSize.w,
        ),
      ),
    );
  }
}

/// Sheet title — Manrope ExtraBold 24, `#161C20`.
class AppBottomSheetTitle extends StatelessWidget {
  const AppBottomSheetTitle({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: FontRes.MANROPE_EXTRABOLD,
        fontSize: 24.sp,
        fontWeight: FontWeight.w800,
        height: 30 / 24,
        letterSpacing: -0.6,
        color: AppBottomSheetTokens.titleColor,
      ),
    );
  }
}

/// Sheet body — Manrope Regular 15, `#594136`.
class AppBottomSheetBody extends StatelessWidget {
  const AppBottomSheetBody({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: FontRes.MANROPE_REGULAR,
          fontSize: 15.sp,
          fontWeight: FontWeight.w400,
          height: 24 / 15,
          color: AppBottomSheetTokens.bodyColor,
        ),
      ),
    );
  }
}

/// Side-by-side secondary + primary CTAs — Figma `1:2310`.
class AppBottomSheetActionRow extends StatelessWidget {
  const AppBottomSheetActionRow({
    super.key,
    required this.secondaryLabel,
    required this.primaryLabel,
    required this.onSecondary,
    required this.onPrimary,
    this.isPrimaryLoading = false,
    this.isPrimaryEnabled = true,
  });

  final String secondaryLabel;
  final String primaryLabel;
  final VoidCallback? onSecondary;
  final VoidCallback? onPrimary;
  final bool isPrimaryLoading;
  final bool isPrimaryEnabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppBottomSheetSecondaryButton(
            label: secondaryLabel,
            onPressed: onSecondary,
          ),
        ),
        SizedBox(width: AppBottomSheetTokens.sectionGap.w),
        Expanded(
          child: AppBottomSheetPrimaryButton(
            label: primaryLabel,
            onPressed: isPrimaryEnabled && !isPrimaryLoading ? onPrimary : null,
            isLoading: isPrimaryLoading,
          ),
        ),
      ],
    );
  }
}

/// Outlined secondary CTA — 2px `#DDE3E9` border, `#594136` text.
class AppBottomSheetSecondaryButton extends StatelessWidget {
  const AppBottomSheetSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed!();
              },
        borderRadius:
            BorderRadius.circular(AppBottomSheetTokens.buttonRadius.r),
        child: Ink(
          height: AppBottomSheetTokens.buttonHeight.h,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppBottomSheetTokens.secondaryBorder,
              width: 2,
            ),
            borderRadius:
                BorderRadius.circular(AppBottomSheetTokens.buttonRadius.r),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: FontRes.MANROPE_BOLD,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                height: 24 / 16,
                letterSpacing: -0.4,
                color: AppBottomSheetTokens.bodyColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Filled primary CTA — `#FF6D00` with orange shadow, white text.
class AppBottomSheetPrimaryButton extends StatelessWidget {
  const AppBottomSheetPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(AppBottomSheetTokens.buttonRadius.r),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: AppBottomSheetTokens.primaryOrange
                      .withValues(alpha: 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ]
            : null,
      ),
      child: Material(
        color: enabled
            ? AppBottomSheetTokens.primaryOrange
            : AppBottomSheetTokens.primaryOrange.withValues(alpha: 0.4),
        borderRadius:
            BorderRadius.circular(AppBottomSheetTokens.buttonRadius.r),
        child: InkWell(
          onTap: enabled
              ? () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                }
              : null,
          borderRadius:
              BorderRadius.circular(AppBottomSheetTokens.buttonRadius.r),
          child: SizedBox(
            height: AppBottomSheetTokens.buttonHeight.h,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_BOLD,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        height: 24 / 16,
                        letterSpacing: -0.4,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
