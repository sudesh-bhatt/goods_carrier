import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/extensions/size_ext.dart';
import '../../../../../core/extensions/theme_ext.dart';
import '../../../../../res/font_res.dart';
import 'shipment_form_tokens.dart';

class ShipmentFormFieldLabel extends StatelessWidget {
  const ShipmentFormFieldLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: FontRes.MANROPE_MEDIUM,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        height: 16 / 14,
        letterSpacing: 1.1,
        color: ShipmentFormTokens.label,
      ),
    );
  }
}

class ShipmentFormInputRow extends StatelessWidget {
  const ShipmentFormInputRow({
    super.key,
    this.icon,
    this.leading,
    this.controller,
    this.hint,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
    this.inputFormatters,
    this.suffix,
    this.validator,
    this.textAlign,
    this.height,
    this.fieldRadius,
    this.value,
  }) : assert(icon != null || leading != null);

  final IconData? icon;
  final Widget? leading;
  final TextEditingController? controller;
  final String? hint;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final TextAlign? textAlign;
  final double? height;
  final double? fieldRadius;
  final String? value;

  String get _currentValue => controller?.text ?? value ?? '';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fieldHeight = height ?? 54.h;
    final radius = (fieldRadius ?? 12).r;

    return FormField<String>(
      initialValue: _currentValue,
      validator: (_) => validator?.call(_currentValue),
      builder: (fieldState) {
        final container = Container(
          height: fieldHeight,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: ShipmentFormTokens.fieldFill,
            borderRadius: BorderRadius.circular(radius),
            border: fieldState.hasError
                ? Border.all(color: colors.error, width: 1.5)
                : null,
          ),
          child: Row(
            children: [
              leading ??
                  Icon(icon, size: 18.w, color: ShipmentFormTokens.primary),
              SizedBox(width: 12.w),
              Expanded(
                child: readOnly && (onTap != null || value != null)
                    ? Align(
                        alignment: textAlign == TextAlign.center
                            ? Alignment.center
                            : Alignment.centerLeft,
                        child: Text(
                          _displayText,
                          style: TextStyle(
                            fontFamily: FontRes.MANROPE_MEDIUM,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: _displayText.isNotEmpty
                                ? ShipmentFormTokens.heading
                                : ShipmentFormTokens.hint,
                          ),
                        ),
                      )
                    : TextFormField(
                        controller: controller,
                        readOnly: readOnly,
                        onTap: onTap,
                        keyboardType: keyboardType,
                        inputFormatters: inputFormatters,
                        onChanged: fieldState.didChange,
                        textAlign: textAlign ?? TextAlign.start,
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_MEDIUM,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: ShipmentFormTokens.heading,
                        ),
                        cursorColor: colors.primary,
                        decoration: InputDecoration(
                          hintText: hint,
                          hintStyle: TextStyle(
                            fontFamily: FontRes.MANROPE_REGULAR,
                            fontSize: 16.sp,
                            color: ShipmentFormTokens.hint,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          errorStyle: const TextStyle(height: 0, fontSize: 0),
                        ),
                      ),
              ),
              if (suffix != null) suffix!,
            ],
          ),
        );

        Widget field = container;
        if (onTap != null) {
          field = GestureDetector(
            onTap: () {
              onTap!();
              fieldState.didChange(_currentValue);
            },
            behavior: HitTestBehavior.opaque,
            child: container,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            field,
            if (fieldState.hasError && fieldState.errorText != null)
              Padding(
                padding: EdgeInsets.only(top: 6.h, left: 2.w),
                child: Text(
                  fieldState.errorText!,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_REGULAR,
                    fontSize: 12.sp,
                    height: 16 / 12,
                    color: colors.error,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  String get _displayText {
    if (value != null && value!.isNotEmpty) return value!;
    if (controller?.text.isNotEmpty == true) return controller!.text;
    return hint ?? '';
  }
}

/// Multiline additional-comments field — white fill per Figma.
class ShipmentFormCommentsField extends StatelessWidget {
  const ShipmentFormCommentsField({
    super.key,
    required this.controller,
    required this.hint,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FormField<String>(
      initialValue: controller.text,
      validator: (_) => validator?.call(controller.text),
      builder: (fieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: ShipmentFormTokens.commentsFieldFill,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: fieldState.hasError
                      ? Border.all(color: colors.error, width: 1.5)
                      : null,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                  child: TextFormField(
                    controller: controller,
                    maxLines: 4,
                    minLines: 4,
                    onChanged: fieldState.didChange,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_REGULAR,
                      fontSize: 16.sp,
                      height: 24 / 16,
                      color: ShipmentFormTokens.heading,
                    ),
                    cursorColor: ShipmentFormTokens.primary,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(
                        fontFamily: FontRes.MANROPE_REGULAR,
                        fontSize: 16.sp,
                        height: 24 / 16,
                        color: ShipmentFormTokens.hintMuted,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      filled: false,
                      fillColor: Colors.transparent,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.zero,
                      errorStyle: const TextStyle(height: 0, fontSize: 0),
                    ),
                  ),
                ),
              ),
            ),
            if (fieldState.hasError && fieldState.errorText != null)
              Padding(
                padding: EdgeInsets.only(top: 6.h, left: 2.w),
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

class ShipmentFormSection extends StatelessWidget {
  const ShipmentFormSection({
    super.key,
    required this.label,
    required this.child,
    this.labelStyle,
  });

  final String label;
  final Widget child;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: labelStyle ??
              TextStyle(
                fontFamily: FontRes.MANROPE_BOLD,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                height: 16 / 12,
                letterSpacing: 1.1,
                color: ShipmentFormTokens.label,
              ),
        ),
        SizedBox(height: 12.h),
        child,
      ],
    );
  }
}
