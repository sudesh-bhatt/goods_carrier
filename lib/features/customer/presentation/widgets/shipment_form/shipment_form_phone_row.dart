import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/extensions/size_ext.dart';
import '../../../../../core/extensions/theme_ext.dart';
import '../../../../../core/utils/phone_utils.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../res/font_res.dart';
import 'shipment_form_tokens.dart';

/// Phone input with country code picker — matches [ShipmentFormInputRow] styling.
class ShipmentFormPhoneRow extends StatelessWidget {
  const ShipmentFormPhoneRow({
    super.key,
    required this.controller,
    required this.dialCode,
    required this.onDialCodeChanged,
    this.hint,
    this.validator,
    this.height,
    this.fieldFillColor,
    this.fieldHintColor,
    this.fieldTextColor,
    this.dividerColor,
    this.fieldRadius,
    this.showLeadingIcon = true,
  });

  final TextEditingController controller;
  final String dialCode;
  final ValueChanged<CountryCode> onDialCodeChanged;
  final String? hint;
  final String? Function(String?)? validator;
  final double? height;
  final Color? fieldFillColor;
  final Color? fieldHintColor;
  final Color? fieldTextColor;
  final Color? dividerColor;
  final double? fieldRadius;
  final bool showLeadingIcon;

  static String _alpha3(String? alpha2) {
    const map = {
      'IN': 'IND', 'US': 'USA', 'GB': 'GBR', 'CN': 'CHN', 'JP': 'JPN',
      'DE': 'DEU', 'FR': 'FRA', 'AU': 'AUS', 'CA': 'CAN', 'SG': 'SGP',
      'AE': 'ARE', 'SA': 'SAU', 'PK': 'PAK', 'BD': 'BGD', 'NP': 'NPL',
      'LK': 'LKA', 'MY': 'MYS', 'TH': 'THA', 'ID': 'IDN', 'PH': 'PHL',
    };
    final key = alpha2?.toUpperCase();
    return map[key] ?? (key ?? 'IND');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fieldHeight = height ?? 54.h;
    final radius = fieldRadius ?? 12.r;
    final fill = fieldFillColor ?? ShipmentFormTokens.fieldFill;
    final hintColor = fieldHintColor ?? ShipmentFormTokens.hint;
    final textColor = fieldTextColor ?? ShipmentFormTokens.heading;
    final separatorColor = dividerColor ?? ShipmentFormTokens.connector;
    final compact = height != null && height! < 50;
    final maxLen = PhoneUtils.maxLocalLength(dialCode);

    return FormField<String>(
      initialValue: controller.text,
      validator: (_) =>
          (validator ?? (v) => Validators.phoneForCountry(dialCode, v))(
            controller.text,
          ),
      builder: (fieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: fieldHeight,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(radius),
                border: fieldState.hasError
                    ? Border.all(color: colors.error, width: 1.5)
                    : null,
              ),
              child: Row(
                children: [
                  if (showLeadingIcon) ...[
                    Padding(
                      padding: EdgeInsets.only(left: 16.w),
                      child: Icon(
                        Icons.phone_outlined,
                        size: 18.w,
                        color: ShipmentFormTokens.primary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ] else
                    SizedBox(width: 16.w),
                  _CountryCodeChip(
                    dialCode: dialCode,
                    onChanged: onDialCodeChanged,
                    textColor: textColor,
                    hintColor: hintColor,
                    compact: compact,
                  ),
                  Container(
                    width: 1,
                    height: 24.h,
                    color: separatorColor,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.phone,
                      onChanged: fieldState.didChange,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(maxLen),
                      ],
                      style: TextStyle(
                        fontFamily: compact
                            ? FontRes.MANROPE_REGULAR
                            : FontRes.MANROPE_MEDIUM,
                        fontSize: compact ? 14.sp : 16.sp,
                        fontWeight:
                            compact ? FontWeight.w400 : FontWeight.w500,
                        height: compact ? 19 / 14 : null,
                        color: textColor,
                      ),
                      cursorColor: colors.primary,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: fill,
                        hintText: hint ?? '0000000000',
                        hintStyle: TextStyle(
                          fontFamily: FontRes.MANROPE_REGULAR,
                          fontSize: compact ? 14.sp : 16.sp,
                          height: compact ? 19 / 14 : null,
                          color: hintColor,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                ],
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
}

class _CountryCodeChip extends StatelessWidget {
  const _CountryCodeChip({
    required this.dialCode,
    required this.onChanged,
    required this.textColor,
    required this.hintColor,
    required this.compact,
  });

  final String dialCode;
  final ValueChanged<CountryCode> onChanged;
  final Color textColor;
  final Color hintColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      locale: const Locale('en'),
      child: CountryCodePicker(
        onChanged: onChanged,
        initialSelection: 'IN',
        favorite: const ['IN'],
        showCountryOnly: false,
        showOnlyCountryWhenClosed: false,
        alignLeft: false,
        showDropDownButton: false,
        hideMainText: true,
        showFlagMain: false,
        showFlag: true,
        flagWidth: 18.w,
        padding: EdgeInsets.zero,
        builder: (CountryCode? code) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${ShipmentFormPhoneRow._alpha3(code?.code)}  ${code?.dialCode ?? dialCode}',
              style: TextStyle(
                fontFamily: compact
                    ? FontRes.MANROPE_REGULAR
                    : FontRes.MANROPE_MEDIUM,
                fontSize: compact ? 14.sp : 14.sp,
                fontWeight:
                    compact ? FontWeight.w400 : FontWeight.w500,
                height: compact ? 19 / 14 : null,
                color: textColor,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16.w,
              color: hintColor,
            ),
          ],
        ),
      ),
    );
  }
}
