import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../shared/domain/entities/shipment.dart';
import '../../../../shared/presentation/widgets/sheets/app_bottom_sheet.dart';
import '../../../../shared/presentation/widgets/sheets/app_modal_bottom_sheet.dart';

/// Confirm interest bottom sheet — Figma `1:5846`.
class ConfirmRequestBottomSheet extends ConsumerStatefulWidget {
  const ConfirmRequestBottomSheet._({required this.shipment});

  final Shipment shipment;

  static Future<bool> show(
    BuildContext context, {
    required Shipment shipment,
  }) =>
      AppModalBottomSheet.show<bool>(
        context: context,
        builder: (_) => ConfirmRequestBottomSheet._(shipment: shipment),
      ).then((value) => value ?? false);

  @override
  ConsumerState<ConfirmRequestBottomSheet> createState() =>
      _ConfirmRequestBottomSheetState();
}

class _ConfirmRequestBottomSheetState
    extends ConsumerState<ConfirmRequestBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppBottomSheetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppBottomSheetHeaderIcon(icon: Icons.local_shipping_outlined),
          SizedBox(height: AppBottomSheetTokens.sectionGap.h),
          AppBottomSheetTitle(text: l10n.driverConfirmRequestTitle),
          SizedBox(height: 8.h),
          AppBottomSheetBody(text: l10n.driverConfirmRequestBody),
          SizedBox(height: AppBottomSheetTokens.sectionGap.h),
          AppBottomSheetActionRow(
            secondaryLabel: l10n.actionNo,
            primaryLabel: l10n.driverConfirmYesContinue,
            onSecondary: () => Navigator.of(context).pop(false),
            onPrimary: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}
