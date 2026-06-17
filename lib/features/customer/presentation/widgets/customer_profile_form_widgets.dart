import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../generated/assets.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/presentation/widgets/profile/profile_image_content.dart';

/// Shared profile form field fill — create & edit profile screens.
const kCustomerProfileFieldFill = Color(0xFFF0F2F5);

/// Profile avatar with camera affordance — matches [CustomerProfileSetupScreen].
class CustomerProfileAvatar extends StatelessWidget {
  const CustomerProfileAvatar({
    super.key,
    required this.colors,
    required this.onTap,
    this.image,
    this.savedImagePath,
  });

  final AppColorScheme colors;
  final VoidCallback onTap;
  final XFile? image;

  /// Local path or remote URL from [User.profileImageUrl] (edit flows).
  final String? savedImagePath;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: colors.primary.withValues(alpha: 0.12),
      child: Icon(
        Icons.person_outline_rounded,
        size: 44.w,
        color: colors.primary,
      ),
    );

    return SizedBox(
      width: 104.w,
      height: 104.w,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 96.w,
              height: 96.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surface,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF000000).withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: EdgeInsets.all(4.w),
              child: ClipOval(
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: ProfileImageContent(
                    pickedPath: image?.path,
                    imageReference: savedImagePath,
                    placeholder: placeholder,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 2.w,
            bottom: 2.w,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: colors.primaryDark,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.surface, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF000000).withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Assets.icProfileCamera.svg(
                  width: 12.w,
                  height: 12.w,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Caps label + pill field — matches [CustomerProfileSetupScreen].
class CustomerProfileFormField extends StatelessWidget {
  const CustomerProfileFormField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.next,
    this.autofocus = false,
    this.readOnly = false,
    this.suffixIcon,
    this.fillColor = kCustomerProfileFieldFill,
  });

  final String label;
  final String? hint;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final bool autofocus;
  final bool readOnly;
  final IconData? suffixIcon;
  final Color fillColor;

  static const _kSuffixIconColor = Color(0x4D594136);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fieldRadius = BorderRadius.circular(24.r);
    const noBorder = BorderSide(color: Colors.transparent, width: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: FontRes.MANROPE_BOLD,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              height: 16 / 12,
              color: colors.brownText,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          textInputAction: textInputAction,
          autofocus: autofocus,
          readOnly: readOnly,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_SEMIBOLD,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            height: 24 / 16,
            color: const Color(0xFF161C20),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: FontRes.MANROPE_REGULAR,
              color: colors.textHint,
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: fillColor,
            contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 17.h),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: _kSuffixIconColor, size: 20.w)
                : null,
            border: OutlineInputBorder(borderRadius: fieldRadius, borderSide: noBorder),
            enabledBorder:
                OutlineInputBorder(borderRadius: fieldRadius, borderSide: noBorder),
            focusedBorder: OutlineInputBorder(
              borderRadius: fieldRadius,
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: fieldRadius,
              borderSide: BorderSide(color: colors.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: fieldRadius,
              borderSide: BorderSide(color: colors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
