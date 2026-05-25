import 'package:flutter/material.dart';

import '../../../../../core/extensions/size_ext.dart';
import '../../../../../res/font_res.dart';
import '../../../../../shared/domain/enums/saved_address_label.dart';
import 'saved_address_tokens.dart';

class AddAddressSectionLabel extends StatelessWidget {
  const AddAddressSectionLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: FontRes.MANROPE_EXTRABOLD,
        fontSize: 14.sp,
        fontWeight: FontWeight.w800,
        height: 20 / 14,
        letterSpacing: 1.4,
        color: SavedAddressTokens.labelBrown,
      ),
    );
  }
}

class AddressLabelChipRow extends StatelessWidget {
  const AddressLabelChipRow({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.homeLabel,
    required this.officeLabel,
    required this.otherLabel,
  });

  final SavedAddressLabel selected;
  final ValueChanged<SavedAddressLabel> onSelected;
  final String homeLabel;
  final String officeLabel;
  final String otherLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _LabelChip(
            label: homeLabel,
            icon: SavedAddressLabel.home.icon,
            selected: selected == SavedAddressLabel.home,
            onTap: () => onSelected(SavedAddressLabel.home),
          ),
        ),
        SizedBox(width: 5.w),
        Expanded(
          child: _LabelChip(
            label: officeLabel,
            icon: SavedAddressLabel.office.icon,
            selected: selected == SavedAddressLabel.office,
            onTap: () => onSelected(SavedAddressLabel.office),
          ),
        ),
        SizedBox(width: 5.w),
        Expanded(
          child: _LabelChip(
            label: otherLabel,
            icon: SavedAddressLabel.other.icon,
            selected: selected == SavedAddressLabel.other,
            onTap: () => onSelected(SavedAddressLabel.other),
          ),
        ),
      ],
    );
  }
}

class _LabelChip extends StatelessWidget {
  const _LabelChip({
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
    return Material(
      color: selected ? SavedAddressTokens.chipSelected : SavedAddressTokens.fieldFill,
      borderRadius: BorderRadius.circular(24.r),
      elevation: selected ? 2 : 0,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.r),
        child: SizedBox(
          height: 48.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14.w,
                color: selected ? Colors.white : SavedAddressTokens.chipUnselectedText,
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_BOLD,
                  fontSize: 16.sp,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? Colors.white : SavedAddressTokens.chipUnselectedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddAddressTextField extends StatelessWidget {
  const AddAddressTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.validator,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: FontRes.MANROPE_BOLD,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              height: 16 / 12,
              color: SavedAddressTokens.labelBrown,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_MEDIUM,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: SavedAddressTokens.cardTitle,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: FontRes.MANROPE_MEDIUM,
              fontSize: 16.sp,
              color: SavedAddressTokens.hintGrey,
            ),
            filled: true,
            fillColor: SavedAddressTokens.fieldFill,
            contentPadding: EdgeInsets.fromLTRB(48.w, 17.h, 16.w, 17.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.r),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 16.w, right: 8.w),
              child: Icon(icon, size: 18.w, color: SavedAddressTokens.hintGrey),
            ),
            prefixIconConstraints: BoxConstraints(minWidth: 42.w),
          ),
        ),
      ],
    );
  }
}

class AddressLandmarkHintCard extends StatelessWidget {
  const AddressLandmarkHintCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: SavedAddressTokens.hintCardBg,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: SavedAddressTokens.hintCardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20.w,
            color: SavedAddressTokens.hintCardIcon,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: FontRes.MANROPE_REGULAR,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                height: 23 / 14,
                color: SavedAddressTokens.hintCardText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
