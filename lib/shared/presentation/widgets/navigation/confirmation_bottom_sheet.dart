import 'package:flutter/material.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../sheets/app_bottom_sheet.dart';
import '../sheets/app_modal_bottom_sheet.dart';

/// Confirmation bottom sheet — Figma `1:2310`.
///
/// Full-width sheet with optional header icon, title, body, and side-by-side
/// secondary / primary CTAs. Returns `true` on confirm, `false` on cancel.
class ConfirmationBottomSheet extends StatelessWidget {
  const ConfirmationBottomSheet._({
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.cancelLabel,
    this.headerIcon,
  });

  final String title;
  final String body;
  final String confirmLabel;
  final String cancelLabel;
  final IconData? headerIcon;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String body,
    String? confirmLabel,
    String? cancelLabel,
    IconData? headerIcon,

    /// Kept for API compatibility — styling follows Figma primary orange.
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
        cancelLabel: cancelLabel ?? l10n.actionNo,
        headerIcon: headerIcon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (headerIcon != null) ...[
            AppBottomSheetHeaderIcon(icon: headerIcon!),
            SizedBox(height: AppBottomSheetTokens.sectionGap.h),
          ],
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppBottomSheetTitle(text: title),
                SizedBox(height: 10.88.h),
                AppBottomSheetBody(text: body),
              ],
            ),
          ),
          SizedBox(height: AppBottomSheetTokens.sectionGap.h),
          AppBottomSheetActionRow(
            secondaryLabel: cancelLabel,
            primaryLabel: confirmLabel,
            onSecondary: () => Navigator.pop(context, false),
            onPrimary: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }
}
