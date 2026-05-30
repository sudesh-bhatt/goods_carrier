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
  });

  final TextEditingController controller;
  final String dialCode;
  final ValueChanged<CountryCode> onDialCodeChanged;
  final String? hint;
  final String? Function(String?)? validator;
  final double? height;

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
    final radius = 12.r;
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
                color: ShipmentFormTokens.fieldFill,
                borderRadius: BorderRadius.circular(radius),
                border: fieldState.hasError
                    ? Border.all(color: colors.error, width: 1.5)
                    : null,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16.w),
                    child: Icon(
                      Icons.phone_outlined,
                      size: 18.w,
                      color: ShipmentFormTokens.primary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  _CountryCodeChip(
                    dialCode: dialCode,
                    onChanged: onDialCodeChanged,
                  ),
                  Container(
                    width: 1,
                    height: 24.h,
                    color: ShipmentFormTokens.connector,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      keyboardType: TextInputType.phone,
                      onChanged: fieldState.didChange,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(maxLen),
                      ],
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_MEDIUM,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: ShipmentFormTokens.heading,
                      ),
                      cursorColor: colors.primary,
                      decoration: InputDecoration(
                        hintText: hint ?? '0000000000',
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
  });

  final String dialCode;
  final ValueChanged<CountryCode> onChanged;

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
                fontFamily: FontRes.MANROPE_MEDIUM,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: ShipmentFormTokens.heading,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16.w,
              color: ShipmentFormTokens.hint,
            ),
          ],
        ),
      ),
    );
  }
}
