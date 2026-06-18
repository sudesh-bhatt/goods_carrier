import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/utils/validators.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/presentation/widgets/inputs/app_phone_field.dart';

/// Figma driver profile setup screen background (node 1-661).
const kDriverProfileBackground = Color(0xFFF5FAFF);

/// Figma driver profile input fill.
const kDriverProfileFieldFill = Color(0xFFEFF4FA);

const _kLabelColor = Color(0xFF594136);
const _kPlaceholderColor = Color(0x66594136);
const _kInputTextColor = Color(0xFF594136);

/// Section header — personal details variant (12px uppercase).
class DriverProfilePersonalSectionHeader extends StatelessWidget {
  const DriverProfilePersonalSectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Row(
        children: [
          Icon(Icons.person_outline_rounded, size: 16.w, color: context.colors.primary),
          SizedBox(width: 8.w),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontFamily: FontRes.MANROPE_BOLD,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              height: 16 / 12,
              color: _kLabelColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header — business details variant (14px uppercase).
class DriverProfileBusinessSectionHeader extends StatelessWidget {
  const DriverProfileBusinessSectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.business_outlined, size: 12.w, color: const Color(0xFF9F4200)),
        SizedBox(width: 8.w),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontFamily: FontRes.MANROPE_BOLD,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
            height: 20 / 14,
            color: _kLabelColor,
          ),
        ),
      ],
    );
  }
}

/// White card wrapper for a form section.
class DriverProfileSectionCard extends StatelessWidget {
  const DriverProfileSectionCard({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.gap = 16,
    this.useBusinessShadow = false,
  });

  final Widget child;
  final double borderRadius;
  final double gap;
  final bool useBusinessShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius.r),
        boxShadow: [
          BoxShadow(
            color: useBusinessShadow
                ? const Color(0x0A161C20)
                : const Color(0x0D000000),
            blurRadius: useBusinessShadow ? 40 : 2,
            offset: useBusinessShadow ? const Offset(0, 20) : const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Personal-details text field — 10px label, 44px input, 12px radius.
class DriverProfilePersonalField extends StatelessWidget {
  const DriverProfilePersonalField({
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
    this.suffix,
    this.inputFormatters,
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
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: FontRes.MANROPE_BOLD,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              height: 15 / 10,
              color: _kLabelColor,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          textInputAction: textInputAction,
          autofocus: autofocus,
          readOnly: readOnly,
          inputFormatters: inputFormatters,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_REGULAR,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            height: 20 / 14,
            color: readOnly ? _kInputTextColor : const Color(0xFF161C20),
          ),
          decoration: _inputDecoration(hint: hint, suffix: suffix),
        ),
      ],
    );
  }
}

/// Business-details text field — 12px semibold label.
class DriverProfileBusinessField extends StatelessWidget {
  const DriverProfileBusinessField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
  });

  final String label;
  final String? hint;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;

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
              fontFamily: FontRes.MANROPE_SEMIBOLD,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              height: 16 / 12,
              color: _kLabelColor,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_REGULAR,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            height: 19 / 14,
            color: const Color(0xFF161C20),
          ),
          decoration: _inputDecoration(hint: hint),
        ),
      ],
    );
  }
}

/// Multiline address field for personal details.
class DriverProfileAddressField extends StatelessWidget {
  const DriverProfileAddressField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.textInputAction = TextInputAction.next,
  });

  final String label;
  final String? hint;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: FontRes.MANROPE_BOLD,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              height: 15 / 10,
              color: _kLabelColor,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        TextFormField(
          controller: controller,
          validator: validator,
          textInputAction: textInputAction,
          keyboardType: TextInputType.multiline,
          minLines: 3,
          maxLines: 3,
          textAlignVertical: TextAlignVertical.top,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_REGULAR,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            height: 20 / 14,
            color: const Color(0xFF161C20),
          ),
          decoration: _inputDecoration(hint: hint, minHeight: 64),
        ),
      ],
    );
  }
}

/// Business phone — country code + local number via [AppPhoneField].
class DriverProfileBusinessPhoneField extends StatelessWidget {
  const DriverProfileBusinessPhoneField({
    super.key,
    required this.label,
    required this.controller,
    required this.dialCode,
    required this.onDialCodeChanged,
    this.hint,
    this.validator,
  });

  final String label;
  final String? hint;
  final TextEditingController controller;
  final String dialCode;
  final ValueChanged<CountryCode> onDialCodeChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return AppPhoneField(
      label: label,
      labelStyle: AppPhoneFieldLabelStyle.profileBusiness,
      size: AppPhoneFieldSize.compact,
      controller: controller,
      dialCode: dialCode,
      onDialCodeChanged: onDialCodeChanged,
      hint: hint,
      validator: validator ??
          (v) {
            if (v == null || v.trim().isEmpty) return null;
            return Validators.phoneForCountry(dialCode, v);
          },
    );
  }
}

InputDecoration _inputDecoration({
  String? hint,
  Widget? suffix,
  double minHeight = 44,
}) {
  final radius = BorderRadius.circular(12.r);
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      fontFamily: FontRes.MANROPE_REGULAR,
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      height: 19 / 14,
      color: _kPlaceholderColor,
    ),
    filled: true,
    fillColor: kDriverProfileFieldFill,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    constraints: BoxConstraints(minHeight: minHeight.h),
    errorMaxLines: 2,
    errorStyle: TextStyle(
      fontFamily: FontRes.MANROPE_REGULAR,
      fontSize: 12.sp,
      height: 16 / 12,
      color: const Color(0xFFD32F2F),
    ),
    suffixIcon: suffix,
    suffixIconConstraints: BoxConstraints(minWidth: 24.w, minHeight: 24.h),
    border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(color: Color(0xFFFF6D00), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
    ),
  );
}
