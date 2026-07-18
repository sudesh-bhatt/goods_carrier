import 'package:flutter/material.dart';
import 'package:goods_carrier/generated/assets.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/svg_gen_image_extension.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/theme/app_color_scheme.dart';

import '../../../../res/font_res.dart';
import '../../../../shared/domain/entities/shipment_masters.dart';
import '../../../../shared/presentation/widgets/network/dio_network_icon.dart';

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

/// Vehicle filter chips — "All" + labels/ids from dashboard `vehicle_types` API.
class CustomerHomeVehicleChips extends StatelessWidget {
  const CustomerHomeVehicleChips({
    super.key,
    required this.vehicleTypes,
    required this.selectedVehicleTypeId,
    required this.onSelected,
    required this.allLabel,
  });

  final List<ShipmentMasterOption> vehicleTypes;
  final int? selectedVehicleTypeId;
  final ValueChanged<int?> onSelected;
  final String allLabel;

  @override
  Widget build(BuildContext context) {
    if (vehicleTypes.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 44.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: vehicleTypes.length + 1,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _VehicleChip(
              label: allLabel,
              materialIcon: Icons.apps_rounded,
              selected: selectedVehicleTypeId == null,
              onTap: () => onSelected(null),
            );
          }
          final option = vehicleTypes[index - 1];
          return _VehicleChip(
            label: option.name,
            iconUrl: option.iconUrl,
            assetIcon: _assetForOption(option),
            selected: selectedVehicleTypeId == option.id,
            onTap: () => onSelected(option.id),
          );
        },
      ),
    );
  }

  static SvgGenImage _assetForOption(ShipmentMasterOption option) {
    final slug = (option.slug ?? option.name).toLowerCase();
    if (slug.contains('pickup')) return Assets.pickupVehicle;
    if (slug.contains('truck')) return Assets.truckVehicle;
    return Assets.miniVehicle;
  }
}

class _VehicleChip extends StatelessWidget {
  const _VehicleChip({
    required this.label,
    this.iconUrl,
    this.assetIcon,
    this.materialIcon,
    required this.selected,
    required this.onTap,
  }) : assert(assetIcon != null || materialIcon != null || iconUrl != null);

  final String label;
  final String? iconUrl;
  final SvgGenImage? assetIcon;
  final IconData? materialIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = selected ? colors.onPrimary : colors.textPrimary;
    final bg = selected ? colors.primary : const Color(0xFFF0F2F5);

    Widget fallback;
    if (assetIcon != null) {
      fallback = assetIcon!.svgTint(width: 16.w, height: 16.w, color: fg);
    } else {
      fallback = Icon(materialIcon, size: 16.w, color: fg);
    }

    return Material(
      color: bg,
      elevation: selected ? 4 : 0,
      shadowColor: colors.primary.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(22.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: SizedBox(
            height: 44.h,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                VehicleTypeNetworkIcon(
                  iconUrl: iconUrl,
                  color: fg,
                  size: 16.w,
                  fallback: fallback,
                ),
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
      ),
    );
  }
}
