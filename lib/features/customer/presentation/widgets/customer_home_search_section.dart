import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/domain/enums/vehicle_type.dart';

/// Search + filter row on the customer home tab.
class CustomerHomeSearchRow extends StatelessWidget {
  const CustomerHomeSearchRow({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onFilterTap,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;

  static BoxDecoration _whiteBoxDecoration(AppColorScheme colors) =>
      BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: colors.shadowCard,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fieldHeight = AppDimensions.inputHeight.h;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            height: fieldHeight,
            decoration: _whiteBoxDecoration(colors),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            alignment: Alignment.center,
            child: Row(
              children: [
                Icon(Icons.search_rounded, size: 20.w, color: colors.textHint),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_REGULAR,
                      fontSize: 14.sp,
                      height: 1.25,
                      color: colors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(
                        fontFamily: FontRes.MANROPE_REGULAR,
                        fontSize: 14.sp,
                        color: colors.textHint,
                      ),
                      filled: true,
                      fillColor: colors.surface,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onFilterTap,
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              width: fieldHeight,
              height: fieldHeight,
              decoration: _whiteBoxDecoration(colors),
              alignment: Alignment.center,
              child: Icon(
                Icons.tune_rounded,
                size: 20.w,
                color: colors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Vehicle filter chips on the customer home tab.
class CustomerHomeVehicleChips extends StatelessWidget {
  const CustomerHomeVehicleChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final VehicleType? selected;
  final ValueChanged<VehicleType> onSelected;

  static const _chips = [
    (VehicleType.mini, 'Mini', Icons.local_shipping_outlined),
    (VehicleType.pickupTruck, 'Pickup', Icons.fire_truck_outlined),
    (VehicleType.truck, 'Truck', Icons.local_shipping_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: Row(
        children: [
          for (var i = 0; i < _chips.length; i++) ...[
            if (i > 0) SizedBox(width: 10.w),
            Expanded(
              child: _VehicleChip(
                label: _chips[i].$2,
                icon: _chips[i].$3,
                selected: selected == _chips[i].$1,
                onTap: () => onSelected(_chips[i].$1),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VehicleChip extends StatelessWidget {
  const _VehicleChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = selected ? colors.onPrimary : colors.textPrimary;
    final bg = selected ? colors.primary : const Color(0xFFF0F2F5);

    return Material(
      color: bg,
      elevation: selected ? 4 : 0,
      shadowColor: colors.primary.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(22.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.r),
        child: SizedBox(
          height: 44.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16.w, color: fg),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_SEMIBOLD,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
