import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';

/// Orange warning strip displayed on shipment cards/details when goods are fragile.
///
/// ```dart
/// if (shipment.goods.isFragile) const FragileBanner()
/// ```
class FragileBanner extends StatelessWidget {
  const FragileBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.base.w,
        vertical: AppDimensions.xs.h,
      ),
      decoration: BoxDecoration(
        color: colors.warningBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm.r),
        border: Border.all(
          color: colors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: AppDimensions.iconSm.w,
            color: colors.primary,
          ),
          SizedBox(width: AppDimensions.xs.w),
          Text(
            context.l10n.shipmentFragileWarning,
            style: context.textTheme.labelSmall?.copyWith(
              color: colors.primaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
