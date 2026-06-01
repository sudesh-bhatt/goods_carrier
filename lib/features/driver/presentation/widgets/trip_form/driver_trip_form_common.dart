import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/extensions/size_ext.dart';
import '../../../../../core/extensions/theme_ext.dart';
import '../../../../../res/font_res.dart';
import 'driver_trip_form_tokens.dart';

class DriverTripFormCard extends StatelessWidget {
  const DriverTripFormCard({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: DriverTripFormTokens.cardFill,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: const [DriverTripFormTokens.cardShadow],
      ),
      child: child,
    );
  }
}

class DriverTripFormFieldLabel extends StatelessWidget {
  const DriverTripFormFieldLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: FontRes.MANROPE_SEMIBOLD,
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        letterSpacing: 0.6,
        color: DriverTripFormTokens.label,
      ),
    );
  }
}

class DriverTripFormSectionHeader extends StatelessWidget {
  const DriverTripFormSectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.leading,
  }) : assert(icon != null || leading != null);

  final String title;
  final IconData? icon;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        leading ??
            Icon(icon!, size: 18.w, color: DriverTripFormTokens.primary),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_BOLD,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            height: 24 / 16,
            color: DriverTripFormTokens.heading,
          ),
        ),
      ],
    );
  }
}

/// Grey filled field — Figma 44px height, 8px radius.
///
/// Text inputs use [TextFormField] directly (parent [Form] validates).
/// Pickers use [FormField] only — never nest [TextFormField] inside [FormField].
class DriverTripFormField extends StatelessWidget {
  const DriverTripFormField({
    super.key,
    this.controller,
    this.hint,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.suffix,
    this.prefix,
    this.textAlign,
    this.style,
    this.value,
  });

  final TextEditingController? controller;
  final String? hint;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Widget? suffix;
  final Widget? prefix;
  final TextAlign? textAlign;
  final TextStyle? style;
  final String? value;

  bool get _isPicker => readOnly && onTap != null && controller == null;

  @override
  Widget build(BuildContext context) {
    if (_isPicker) {
      return _DriverTripFormPickerField(
        hint: hint,
        value: value,
        onTap: onTap!,
        suffix: suffix,
        prefix: prefix,
        textAlign: textAlign,
        style: style,
        validator: validator,
      );
    }

    return _DriverTripFormTextField(
      controller: controller!,
      hint: hint,
      readOnly: readOnly,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      suffix: suffix,
      prefix: prefix,
      textAlign: textAlign,
      style: style,
    );
  }
}

class _DriverTripFormTextField extends StatelessWidget {
  const _DriverTripFormTextField({
    required this.controller,
    this.hint,
    this.readOnly = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.suffix,
    this.prefix,
    this.textAlign,
    this.style,
  });

  final TextEditingController controller;
  final String? hint;
  final bool readOnly;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Widget? suffix;
  final Widget? prefix;
  final TextAlign? textAlign;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final textStyle = style ??
        TextStyle(
          fontFamily: FontRes.MANROPE_REGULAR,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          height: 19 / 14,
          color: DriverTripFormTokens.heading,
        );

    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      textAlign: textAlign ?? TextAlign.start,
      style: textStyle,
      cursorColor: DriverTripFormTokens.primary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: textStyle.copyWith(color: DriverTripFormTokens.hint),
        filled: true,
        fillColor: DriverTripFormTokens.fieldFill,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        prefixIcon: prefix == null
            ? null
            : Padding(
                padding: EdgeInsets.only(left: 16.w, right: 8.w),
                child: prefix,
              ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffix == null
            ? null
            : Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: suffix,
              ),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: context.colors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: context.colors.error, width: 1.5),
        ),
        isDense: true,
        errorStyle: TextStyle(
          fontFamily: FontRes.MANROPE_REGULAR,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}

class _DriverTripFormPickerField extends StatelessWidget {
  const _DriverTripFormPickerField({
    required this.onTap,
    this.hint,
    this.value,
    this.suffix,
    this.prefix,
    this.textAlign,
    this.style,
    this.validator,
  });

  final VoidCallback onTap;
  final String? hint;
  final String? value;
  final Widget? suffix;
  final Widget? prefix;
  final TextAlign? textAlign;
  final TextStyle? style;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyle = style ??
        TextStyle(
          fontFamily: FontRes.MANROPE_REGULAR,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          height: 19 / 14,
          color: DriverTripFormTokens.heading,
        );

    final display = (value != null && value!.isNotEmpty) ? value! : (hint ?? '');

    return FormField<String>(
      key: ValueKey<String>('picker_${hint}_$value'),
      initialValue: value ?? '',
      validator: validator,
      builder: (fieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                    height: 44.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: DriverTripFormTokens.fieldFill,
                      borderRadius: BorderRadius.circular(8.r),
                      border: fieldState.hasError
                          ? Border.all(color: colors.error, width: 1.5)
                          : null,
                    ),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        if (prefix != null) ...[prefix!, SizedBox(width: 8.w)],
                        Expanded(
                          child: Text(
                            display,
                            textAlign: textAlign ?? TextAlign.start,
                            style: textStyle.copyWith(
                              color: (value != null && value!.isNotEmpty)
                                  ? textStyle.color
                                  : DriverTripFormTokens.hint,
                            ),
                          ),
                        ),
                        if (suffix != null) suffix!,
                      ],
                    ),
                  ),
                ),
              ),
            if (fieldState.hasError && fieldState.errorText != null)
              Padding(
                padding: EdgeInsets.only(top: 6.h),
                child: Text(
                  fieldState.errorText!,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_REGULAR,
                    fontSize: 12.sp,
                    color: colors.error,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class DriverTripFormPickerSuffix extends StatelessWidget {
  const DriverTripFormPickerSuffix({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.keyboard_arrow_down_rounded,
      size: 20.w,
      color: DriverTripFormTokens.hint,
    );
  }
}
