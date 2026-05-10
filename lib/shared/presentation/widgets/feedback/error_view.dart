import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../buttons/app_button.dart';

/// Full-page or inline error state with icon, message, and optional retry CTA.
///
/// ```dart
/// // Full-page network error
/// ErrorView(
///   message: context.l10n.errorNetwork,
///   subtitle: context.l10n.errorNetworkSubtitle,
///   onRetry: () => ref.refresh(shipmentsProvider),
/// );
///
/// // Inline (no expand)
/// ErrorView.inline(message: context.l10n.errorGeneric);
/// ```
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.subtitle,
    this.onRetry,
    this.isFullPage = true,
  });

  /// Convenience constructor for inline non-full-page usage.
  const ErrorView.inline({
    super.key,
    required this.message,
    this.subtitle,
    this.onRetry,
  }) : isFullPage = false;

  final String message;
  final String? subtitle;
  final VoidCallback? onRetry;
  final bool isFullPage;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final content = Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.xxl.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: colors.error.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: AppDimensions.iconLg.w,
              color: colors.error,
            ),
          ),

          SizedBox(height: AppDimensions.base.h),

          Text(
            message,
            style: context.textTheme.titleMedium?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          if (subtitle != null) ...[
            SizedBox(height: AppDimensions.xs.h),
            Text(
              subtitle!,
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          if (onRetry != null) ...[
            SizedBox(height: AppDimensions.xl.h),
            AppButton(
              label: context.l10n.actionRetry,
              onPressed: onRetry,
              isFullWidth: false,
              height: 44,
              borderRadius: AppDimensions.radiusFull,
            ),
          ],
        ],
      ),
    );

    return isFullPage
        ? Center(child: content)
        : content;
  }
}
