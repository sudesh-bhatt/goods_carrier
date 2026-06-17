import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../res/font_res.dart';

/// Visual preset — login card vs compact profile forms.
enum AppPhoneFieldSize {
  login,
  compact,
}

/// Label treatment above the phone row.
enum AppPhoneFieldLabelStyle {
  none,
  profilePersonal,
  profileBusiness,
}

/// Country code picker + local number — shared by login and profile flows.
class AppPhoneField extends StatelessWidget {
  const AppPhoneField({
    super.key,
    required this.controller,
    required this.dialCode,
    required this.onDialCodeChanged,
    this.label,
    this.labelStyle = AppPhoneFieldLabelStyle.none,
    this.size = AppPhoneFieldSize.login,
    this.hint,
    this.validator,
    this.readOnly = false,
    this.showLockSuffix = false,
    this.fillColor,
    this.textColor,
    this.hintColor,
    this.borderColor,
    this.focusedBorderColor,
    this.fieldRadius,
    this.onFieldSubmitted,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String dialCode;
  final ValueChanged<CountryCode> onDialCodeChanged;
  final String? label;
  final AppPhoneFieldLabelStyle labelStyle;
  final AppPhoneFieldSize size;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final bool readOnly;
  final bool showLockSuffix;
  final Color? fillColor;
  final Color? textColor;
  final Color? hintColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double? fieldRadius;
  final ValueChanged<String>? onFieldSubmitted;
  final bool autofocus;

  static const _kLoginInputFill = Color(0xFFF0F2F5);
  static const _kProfileFill = Color(0xFFEFF4FA);
  static const _kProfileLabel = Color(0xFF594136);
  static const _kPhoneDigits = Color(0xFF333333);

  static String alpha3CountryCode(String? alpha2) {
    const map = {
      'IN': 'IND', 'US': 'USA', 'GB': 'GBR', 'CN': 'CHN', 'JP': 'JPN',
      'DE': 'DEU', 'FR': 'FRA', 'AU': 'AUS', 'CA': 'CAN', 'SG': 'SGP',
      'AE': 'ARE', 'SA': 'SAU', 'PK': 'PAK', 'BD': 'BGD', 'NP': 'NPL',
      'LK': 'LKA', 'MY': 'MYS', 'TH': 'THA', 'ID': 'IDN', 'PH': 'PHL',
      'ZA': 'ZAF', 'NG': 'NGA', 'KE': 'KEN', 'BR': 'BRA', 'MX': 'MEX',
      'RU': 'RUS', 'KR': 'KOR', 'IT': 'ITA', 'ES': 'ESP', 'NL': 'NLD',
      'NZ': 'NZL', 'QA': 'QAT', 'KW': 'KWT', 'BH': 'BHR', 'OM': 'OMN',
      'IR': 'IRN', 'IQ': 'IRQ', 'EG': 'EGY', 'ET': 'ETH', 'GH': 'GHA',
      'TZ': 'TZA', 'UG': 'UGA', 'MM': 'MMR', 'VN': 'VNM', 'TR': 'TUR',
    };
    final key = alpha2?.toUpperCase();
    return map[key] ?? (key ?? 'IND');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final isLogin = size == AppPhoneFieldSize.login;
    final rowHeight = isLogin ? 52.h : 44.h;
    final radius = fieldRadius ?? (isLogin ? AppDimensions.radiusMd.r : 12.r);
    final fill = fillColor ?? (isLogin ? _kLoginInputFill : _kProfileFill);
    final digitsColor = textColor ??
        (isLogin
            ? _kPhoneDigits
            : (readOnly ? _kProfileLabel : const Color(0xFF161C20)));
    final hintClr = hintColor ?? colors.textHint;
    final border = borderColor ?? colors.primary.withValues(alpha: 0.42);
    final focusedBorder = focusedBorderColor ?? colors.primary;
    final maxLen = PhoneUtils.maxLocalLength(dialCode);

    final field = FormField<String>(
      initialValue: controller.text,
      validator: (v) =>
          (validator ?? (value) => Validators.phoneForCountry(dialCode, value))(
        controller.text,
      ),
      builder: (fieldState) {
        final hasError = fieldState.hasError;
        final rowBorder = hasError ? colors.error : border;
        final rowBorderWidth = hasError ? 1.5 : 1.0;
        final outline = OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: rowBorder, width: rowBorderWidth),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: rowHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CountryCodeBox(
                    height: rowHeight,
                    radius: radius,
                    fillColor: fill,
                    borderColor: rowBorder,
                    borderWidth: rowBorderWidth,
                    dialCode: dialCode,
                    readOnly: readOnly,
                    compact: !isLogin,
                    onChanged: onDialCodeChanged,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    flex: isLogin ? 7 : 1,
                    child: TextField(
                      controller: controller,
                      readOnly: readOnly,
                      autofocus: autofocus,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      onSubmitted: onFieldSubmitted,
                      onChanged: fieldState.didChange,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(maxLen),
                      ],
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_REGULAR,
                        fontSize: isLogin ? 16.sp : 14.sp,
                        fontWeight: FontWeight.w400,
                        height: isLogin ? null : 20 / 14,
                        color: digitsColor,
                      ),
                      decoration: InputDecoration(
                        hintText: hint ?? l10n.authPhoneDigitsPlaceholder,
                        hintStyle: TextStyle(
                          fontFamily: FontRes.MANROPE_REGULAR,
                          fontSize: isLogin ? 16.sp : 14.sp,
                          fontWeight: FontWeight.w400,
                          height: isLogin ? null : 19 / 14,
                          color: hintClr,
                        ),
                        filled: true,
                        fillColor: fill,
                        suffixIcon: showLockSuffix
                            ? Icon(
                                Icons.lock_outline,
                                size: isLogin ? 18.w : 10.w,
                                color: _kProfileLabel,
                              )
                            : null,
                        border: outline,
                        enabledBorder: outline,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(radius),
                          borderSide: BorderSide(
                            color: hasError ? colors.error : focusedBorder,
                            width: hasError ? 1.5 : 1.5,
                          ),
                        ),
                        disabledBorder: outline,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isLogin ? 14.w : 16.w,
                          vertical: isLogin ? 14.h : 12.h,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (hasError && fieldState.errorText != null)
              Padding(
                padding: EdgeInsets.only(top: 6.h),
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

    if (labelStyle == AppPhoneFieldLabelStyle.none) {
      return field;
    }

    final labelGap = labelStyle == AppPhoneFieldLabelStyle.profileBusiness
        ? 6.h
        : 4.h;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: Text(
            labelStyle == AppPhoneFieldLabelStyle.profileBusiness
                ? (label ?? '')
                : (label ?? '').toUpperCase(),
            style: TextStyle(
              fontFamily: labelStyle == AppPhoneFieldLabelStyle.profileBusiness
                  ? FontRes.MANROPE_SEMIBOLD
                  : FontRes.MANROPE_BOLD,
              fontSize: labelStyle == AppPhoneFieldLabelStyle.profileBusiness
                  ? 12.sp
                  : 10.sp,
              fontWeight: labelStyle == AppPhoneFieldLabelStyle.profileBusiness
                  ? FontWeight.w600
                  : FontWeight.w700,
              height: labelStyle == AppPhoneFieldLabelStyle.profileBusiness
                  ? 16 / 12
                  : 15 / 10,
              color: _kProfileLabel,
            ),
          ),
        ),
        SizedBox(height: labelGap),
        field,
      ],
    );
  }
}

class _CountryCodeBox extends StatelessWidget {
  const _CountryCodeBox({
    required this.height,
    required this.radius,
    required this.fillColor,
    required this.borderColor,
    required this.borderWidth,
    required this.dialCode,
    required this.readOnly,
    required this.compact,
    required this.onChanged,
  });

  final double height;
  final double radius;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final String dialCode;
  final bool readOnly;
  final bool compact;
  final ValueChanged<CountryCode> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final picker = Localizations.override(
      context: context,
      locale: const Locale('en'),
      child: Theme(
        data: Theme.of(context).copyWith(
          listTileTheme: ListTileThemeData(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
            minVerticalPadding: 12.h,
            dense: false,
            titleTextStyle: TextStyle(
              fontFamily: FontRes.MANROPE_MEDIUM,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: colors.textPrimary,
              height: 1.4,
            ),
          ),
          dividerColor: Colors.transparent,
        ),
        child: CountryCodePicker(
          onChanged: readOnly ? (_) {} : onChanged,
          initialSelection: 'IN',
          favorite: const ['IN'],
          showCountryOnly: false,
          showOnlyCountryWhenClosed: false,
          alignLeft: false,
          showDropDownButton: false,
          hideMainText: true,
          showFlagMain: false,
          showFlag: !readOnly,
          flagWidth: compact ? 18.w : 22.w,
          padding: EdgeInsets.zero,
          builder: (CountryCode? code) => Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 8.w : 10.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    '${AppPhoneField.alpha3CountryCode(code?.code)}  ${code?.dialCode ?? dialCode}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_REGULAR,
                      fontSize: compact ? 14.sp : 13.sp,
                      fontWeight: FontWeight.w500,
                      color: compact
                          ? const Color(0xFF161C20)
                          : const Color(0xFF333333),
                      height: compact ? 20 / 14 : 20 / 13,
                    ),
                  ),
                ),
                if (!readOnly) ...[
                  SizedBox(width: 2.w),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16.w,
                    color: colors.textSecondary,
                  ),
                ],
              ],
            ),
          ),
          dialogTextStyle: TextStyle(
            fontFamily: FontRes.MANROPE_MEDIUM,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: colors.textPrimary,
            height: 1.4,
          ),
        ),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: readOnly ? IgnorePointer(child: picker) : picker,
      ),
    );
  }
}
