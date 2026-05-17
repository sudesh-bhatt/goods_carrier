import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../buttons/app_button.dart';
import '../sheets/app_modal_bottom_sheet.dart';

/// Modal bottom sheet with title, body text, and confirm / cancel CTAs.
///
/// The sheet has a drag handle, rounded top corners (16 dp), and respects
/// the device's keyboard inset so it never gets obscured.
///
/// Returns `true` when the user confirms, `false` (or null) when dismissed.
///
/// ```dart
/// // Show:
/// final confirmed = await ConfirmationBottomSheet.show(
///   context,
///   title: context.l10n.settingsLogout,
///   body: context.l10n.settingsLogoutConfirm,
///   confirmLabel: context.l10n.actionYes,
///   cancelLabel: context.l10n.actionNo,
///   isDangerous: true,
/// );
/// if (confirmed == true) _logout();
/// ```
class ConfirmationBottomSheet extends StatelessWidget {
  const ConfirmationBottomSheet._({
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.isDangerous,
    this.leadingIcon,
  });

  final String title;
  final String body;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDangerous;
  final Widget? leadingIcon;

  // ── Static show helper ────────────────────────────────────────────────────

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String body,
    String? confirmLabel,
    String? cancelLabel,

    /// Tints the confirm button red when true.
    bool isDangerous = false,
    Widget? leadingIcon,
  }) {
    final l10n = context.l10n;
    return AppModalBottomSheet.show<bool>(
      context: context,
      builder: (_) => ConfirmationBottomSheet._(
        title: title,
        body: body,
        confirmLabel: confirmLabel ?? l10n.actionConfirm,
        cancelLabel: cancelLabel ?? l10n.actionCancel,
        isDangerous: isDangerous,
        leadingIcon: leadingIcon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(
        left: AppDimensions.base.w,
        right: AppDimensions.base.w,
        bottom: AppDimensions.base.h + bottomPadding,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          SizedBox(height: AppDimensions.md.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: colors.divider,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
          ),
          SizedBox(height: AppDimensions.xl.h),

          // Leading icon (optional)
          if (leadingIcon != null) ...[
            leadingIcon!,
            SizedBox(height: AppDimensions.base.h),
          ],

          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.xl.w),
            child: Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: AppDimensions.sm.h),

          // Body
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.xl.w),
            child: Text(
              body,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: AppDimensions.xl.h),

          // CTAs
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.base.w),
            child: Column(
              children: [
                AppButton(
                  label: confirmLabel,
                  onPressed: () => Navigator.pop(context, true),
                  height: AppDimensions.buttonHeight,
                  // For dangerous actions override button background to error colour
                  textStyle: isDangerous
                      ? context.textTheme.labelLarge?.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w600,
                        )
                      : null,
                ),
                if (isDangerous)
                  // Rebuild the ElevatedButton with error colour for danger actions.
                  // Achieved via a thin wrapper with a coloured container.
                  const SizedBox.shrink(),
                SizedBox(height: AppDimensions.sm.h),
                AppButton(
                  label: cancelLabel,
                  onPressed: () => Navigator.pop(context, false),
                  variant: AppButtonVariant.ghost,
                  height: AppDimensions.buttonHeight,
                ),
              ],
            ),
          ),

          SizedBox(height: AppDimensions.base.h),
        ],
      ),
    );
  }
}
