import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';

// ─── Variant enum ─────────────────────────────────────────────────────────────

enum AppButtonVariant { primary, secondary, ghost }

// ─── AppButton ────────────────────────────────────────────────────────────────

/// Design-system button with three variants, loading state, and haptic feedback.
///
/// ```dart
/// // Primary — orange fill, white text
/// AppButton(label: context.l10n.actionSave, onPressed: _save);
///
/// // Secondary — orange border, no fill
/// AppButton(label: context.l10n.actionCancel, onPressed: _cancel,
///           variant: AppButtonVariant.secondary);
///
/// // Ghost — no border, no fill, orange text
/// AppButton(label: context.l10n.actionSkip, onPressed: _skip,
///           variant: AppButtonVariant.ghost);
///
/// // Loading state — disables tap and shows spinner
/// AppButton(label: context.l10n.authSendOtp, onPressed: null,
///           isLoading: true);
/// ```
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.height,
    this.borderRadius,
    this.textStyle,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;

  /// Optional icon shown left of the label (16 dp recommended).
  final Widget? leadingIcon;

  final double? height;
  final double? borderRadius;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveRadius =
        BorderRadius.circular((borderRadius ?? AppDimensions.radiusMd).r);
    final effectiveHeight = (height ?? AppDimensions.buttonHeight).h;
    final bool disabled = onPressed == null && !isLoading;

    void handleTap() {
      HapticFeedback.lightImpact();
      onPressed?.call();
    }

    final child = _ButtonContent(
      label: label,
      isLoading: isLoading,
      leadingIcon: leadingIcon,
      variant: variant,
      colors: colors,
      textStyle: textStyle,
    );

    Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
        button = ElevatedButton(
          onPressed: (disabled || isLoading) ? null : handleTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            disabledBackgroundColor: colors.primary.withOpacity(0.4),
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: effectiveRadius),
            minimumSize: Size(0, effectiveHeight),
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.base.w),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: child,
        );

      case AppButtonVariant.secondary:
        button = OutlinedButton(
          onPressed: (disabled || isLoading) ? null : handleTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.primary,
            disabledForegroundColor: colors.primary.withOpacity(0.4),
            side: BorderSide(
              color: disabled ? colors.primary.withOpacity(0.4) : colors.primary,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(borderRadius: effectiveRadius),
            minimumSize: Size(0, effectiveHeight),
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.base.w),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: child,
        );

      case AppButtonVariant.ghost:
        button = TextButton(
          onPressed: (disabled || isLoading) ? null : handleTap,
          style: TextButton.styleFrom(
            foregroundColor: colors.primary,
            disabledForegroundColor: colors.primary.withOpacity(0.4),
            shape: RoundedRectangleBorder(borderRadius: effectiveRadius),
            minimumSize: Size(0, effectiveHeight),
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.base.w),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: child,
        );
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: effectiveHeight,
      child: button,
    );
  }
}

// ─── Internal child ───────────────────────────────────────────────────────────

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.isLoading,
    required this.leadingIcon,
    required this.variant,
    required this.colors,
    required this.textStyle,
  });

  final String label;
  final bool isLoading;
  final Widget? leadingIcon;
  final AppButtonVariant variant;
  final dynamic colors;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final Color spinnerColor = variant == AppButtonVariant.primary
        ? Colors.white
        : context.colors.primary;

    if (isLoading) {
      return SizedBox(
        width: 22.w,
        height: 22.h,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
        ),
      );
    }

    final labelStyle = (textStyle ??
            context.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ))!
        .copyWith(
          color: variant == AppButtonVariant.primary
              ? Colors.white
              : context.colors.primary,
        );

    if (leadingIcon == null) {
      return Text(label, style: labelStyle);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        leadingIcon!,
        SizedBox(width: AppDimensions.sm.w),
        Text(label, style: labelStyle),
      ],
    );
  }
}
