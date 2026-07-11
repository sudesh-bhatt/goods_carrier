import 'package:flutter/material.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../shared/presentation/widgets/sheets/app_bottom_sheet.dart';
import '../../../../shared/presentation/widgets/sheets/app_modal_bottom_sheet.dart';

/// Confirm interest bottom sheet — Figma `1:5846`.
class ConfirmRequestBottomSheet extends StatelessWidget {
  const ConfirmRequestBottomSheet._({
    required this.title,
    required this.body,
    required this.secondaryLabel,
    required this.primaryLabel,
  });

  final String title;
  final String body;
  final String secondaryLabel;
  final String primaryLabel;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String body,
    required String secondaryLabel,
    required String primaryLabel,
  }) =>
      AppModalBottomSheet.show<bool>(
        context: context,
        builder: (_) => ConfirmRequestBottomSheet._(
          title: title,
          body: body,
          secondaryLabel: secondaryLabel,
          primaryLabel: primaryLabel,
        ),
      ).then((value) => value ?? false);

  @override
  Widget build(BuildContext context) {
    return AppBottomSheetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppBottomSheetHeaderIcon(icon: Icons.local_shipping_outlined),
          SizedBox(height: AppBottomSheetTokens.sectionGap.h),
          AppBottomSheetTitle(text: title),
          SizedBox(height: 8.h),
          AppBottomSheetBody(text: body),
          SizedBox(height: AppBottomSheetTokens.sectionGap.h),
          AppBottomSheetActionRow(
            secondaryLabel: secondaryLabel,
            primaryLabel: primaryLabel,
            onSecondary: () => Navigator.of(context).pop(false),
            onPrimary: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}
