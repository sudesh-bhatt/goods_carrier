import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/svg_gen_image_extension.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../generated/assets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../res/font_res.dart';
import '../providers/auth_provider.dart';

const _kLoginBannerAsset = 'assets/images/login_screen_banner.png';

/// Figma Login card headline fill (node 2013-1652).
const _kLoginHeadlineColor = Color(0xFF1A1C1E);

/// Figma login input field fill (lighter than global [AppColorScheme.inputFill]).
const _kLoginInputFill = Color(0xFFF0F2F5);

/// Login screen — phone capture + OTP request ([Figma Login](https://www.figma.com/design/wT5NdNeg7YVPPcq1nY9D2P/Goods-Carrier--Copy-?node-id=2013-1639)).
///
/// Top: warehouse banner + logo + app name. No back button (entry from terms flow).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SafeSetStateMixin {
  final _formKey   = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  bool   _submitted = false;
  String _dialCode  = '+91';   // updated when user picks a country

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    safeSetState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // Full E.164-style number sent to the backend: e.g. +919876543210
    final fullNumber = '$_dialCode${_phoneCtrl.text.trim()}';
    await ref.read(authProvider.notifier).sendOtp(fullNumber);
    if (mounted) context.push(AppRoutes.otpVerification);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final textTheme = context.textTheme;
    final appStyles = context.appTextStyles;
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: colors.background,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LoginHeroBanner(
              colors: colors,
              l10n: l10n,
              appStyles: appStyles,
            ),
            SizedBox(height: 30.h),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(25.w, 0, 25.w, 32.h),
                child: Transform.translate(
                  offset: Offset(0, -24.h),
                  child: Column(
                    children: [
                      _FormCard(
                        l10n:      l10n,
                        colors:    colors,
                        textTheme: textTheme,
                        appStyles: appStyles,
                        formKey:   _formKey,
                        phoneCtrl: _phoneCtrl,
                        submitted: _submitted,
                        isLoading: isLoading,
                        dialCode:  _dialCode,
                        onCountryChanged: (code) => safeSetState(
                          () => _dialCode = code.dialCode ?? '+91',
                        ),
                        onSendOtp: _sendOtp,
                      ),
                      SizedBox(height: 20.h),
                      _FeatureRow(
                        colors: colors,
                        appStyles: appStyles,
                        l10n: l10n,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero: banner + logo + title (no back) ────────────────────────────────────

class _LoginHeroBanner extends StatelessWidget {
  const _LoginHeroBanner({
    required this.colors,
    required this.l10n,
    required this.appStyles,
  });

  final AppColorScheme colors;
  final AppLocalizations l10n;
  final AppTextStyles appStyles;

  @override
  Widget build(BuildContext context) {
    final h = 232.h;
    return SizedBox(
      height: h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            _kLoginBannerAsset,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 72.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.background.withValues(alpha: 0),
                    colors.background,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Assets.appLogo.image(
                      height: 150.h,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 10.h),

                  ],
                ),
              ),
            ),
          ),
        ]
      ),
    );
  }
}

// ─── Form card ────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.l10n,
    required this.colors,
    required this.textTheme,
    required this.appStyles,
    required this.formKey,
    required this.phoneCtrl,
    required this.submitted,
    required this.isLoading,
    required this.dialCode,
    required this.onCountryChanged,
    required this.onSendOtp,
  });

  final AppLocalizations     l10n;
  final AppColorScheme       colors;
  final TextTheme            textTheme;
  final AppTextStyles        appStyles;
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneCtrl;
  final bool                 submitted;
  final bool                 isLoading;
  final String               dialCode;
  final ValueChanged<CountryCode> onCountryChanged;
  final VoidCallback         onSendOtp;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppDimensions.radiusLoginCard.r);
    final fieldRadius = BorderRadius.circular(AppDimensions.radiusMd.r);
    const phoneDigitsColor = Color(0xFF333333);
    final orangeFieldBorder = BorderSide(
      color: colors.primary.withValues(alpha: 0.42),
      width: 1,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: colors.shadowCard,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        autovalidateMode: submitted
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.authLoginHeadline,
              style: appStyles.sectionHeading.copyWith(
                fontFamily: FontRes.MANROPE_EXTRABOLD,
                color: _kLoginHeadlineColor,
                fontSize: 24.sp,
                fontWeight: FontWeight.w400,
                height: 1.25,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.authLoginSubtitle,
              style: appStyles.label.copyWith(
                color: colors.textSecondary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                height: 20 / 14,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              l10n.authPhoneLabel.toUpperCase(),
              style: appStyles.caption.copyWith(
                fontFamily: FontRes.MANROPE_SEMIBOLD,
                color: colors.textSecondary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.8,
                height: 16 / 12,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 30 % — country code picker ────────────────────────
                Expanded(
                  flex: 3,
                  child: _CountryBox(
                    colors:    colors,
                    textTheme: textTheme,
                    l10n:      l10n,
                    onChanged: onCountryChanged,
                  ),
                ),
                SizedBox(width: 8.w),
                // ── 70 % — phone number input ─────────────────────────
                Expanded(
                  flex: 7,
                  child: TextFormField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    autofocus: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      // India: 10 digits; ITU-T E.164 max for all others: 15.
                      LengthLimitingTextInputFormatter(
                        dialCode == '+91' ? 10 : 15,
                      ),
                    ],
                    validator: (v) => Validators.phoneForCountry(dialCode, v),
                    onFieldSubmitted: (_) => onSendOtp(),
                    style: textTheme.bodyLarge?.copyWith(
                      color: phoneDigitsColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.authPhoneDigitsPlaceholder,
                      hintStyle: textTheme.bodyMedium?.copyWith(
                        color: colors.textHint,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      filled: true,
                      fillColor: _kLoginInputFill,
                      border: OutlineInputBorder(
                        borderRadius: fieldRadius,
                        borderSide: orangeFieldBorder,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: fieldRadius,
                        borderSide: orangeFieldBorder,
                      ),
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
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 14.h,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg.r),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.28),
                    blurRadius: 14,
                    offset: Offset(0, 6.h),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onSendOtp,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusLg.r),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 22.w,
                          height: 22.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: colors.onPrimary,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.authSendOtp,
                              style: textTheme.labelLarge?.copyWith(
                                color: colors.onPrimary,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.arrow_forward,
                              size: 18.w,
                              color: colors.onPrimary,
                            )
                          ],
                        ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LinkButton(
                  label: l10n.authPrivacyPolicy.toUpperCase(),
                  textTheme: textTheme,
                  colors: colors,
                  onTap: () {},
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Text(
                    '•',
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.textHint,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                _LinkButton(
                  label: l10n.authHelpCenter.toUpperCase(),
                  textTheme: textTheme,
                  colors: colors,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryBox extends StatelessWidget {
  const _CountryBox({
    required this.colors,
    required this.textTheme,
    required this.l10n,
    required this.onChanged,
  });

  final AppColorScheme            colors;
  final TextTheme                 textTheme;
  final AppLocalizations          l10n;
  final ValueChanged<CountryCode> onChanged;

  /// ISO 3166-1 alpha-3 lookup — covers countries most relevant to an India-
  /// focused logistics app. Unmapped codes fall back to the alpha-2 value.
  static String _alpha3(String? alpha2) {
    const _map = {
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
    return _map[key] ?? (key ?? 'IND');
  }

  @override
  Widget build(BuildContext context) {
    // Force English country names in the dialog right now.
    // TODO: swap `const Locale('en')` → `Localizations.localeOf(context)`
    // once the app's locale switcher is wired through the ancestor tree.
    return Localizations.override(
      context: context,
      locale: const Locale('en'),
      child: SizedBox(
        height: 52.h,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _kLoginInputFill,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.42),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
            // Theme override propagates into the picker's internal ListTiles,
            // giving us control over dialog item spacing and divider visibility.
            child: Theme(
              data: Theme.of(context).copyWith(
                listTileTheme: ListTileThemeData(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical:   2.h,
                  ),
                  minVerticalPadding: 12.h,
                  dense: false,
                  titleTextStyle: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize:   14.sp,
                    fontWeight: FontWeight.w500,
                    color:      colors.textPrimary,
                    height:     1.4,
                  ),
                ),
                // Remove the hairline dividers between rows — cleaner look.
                dividerColor: Colors.transparent,
              ),
              child: CountryCodePicker(
                onChanged: onChanged,
                initialSelection:          'IN',
                favorite:                  const ['IN'],
                showCountryOnly:           false,
                showOnlyCountryWhenClosed: false,
                alignLeft:                 false,
                showDropDownButton:        false,
                hideMainText:              true,
                showFlagMain:              false,
                showFlag:                  true,   // flags shown in the dialog list
                flagWidth:                 22.w,
                padding:                   EdgeInsets.zero,

                // ── Closed-state: "IND  +91  ▾" ─────────────────────────────
                builder: (CountryCode? code) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          '${_alpha3(code?.code)}  ${code?.dialCode ?? '+91'}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: FontRes.MANROPE_REGULAR,
                            fontSize:   13.sp,
                            fontWeight: FontWeight.w500,
                            color:      const Color(0xFF333333),
                            height:     20 / 13,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size:  16.w,
                        color: colors.textSecondary,
                      ),
                    ],
                  ),
                ),

                // ── Dialog row text ───────────────────────────────────────────
                // Fallback style; primary control is via listTileTheme above.
                dialogTextStyle: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize:   14.sp,
                  fontWeight: FontWeight.w500,
                  color:      colors.textPrimary,
                  height:     1.4,
                ),

                // ── Dialog chrome ─────────────────────────────────────────────
                dialogBackgroundColor: colors.surface,
                barrierColor:          Colors.black.withOpacity(0.45),
                closeIcon: Icon(
                  Icons.close_rounded,
                  size:  22.w,
                  color: colors.textPrimary,
                ),

                // ── Search field ──────────────────────────────────────────────
                searchStyle: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize:   14.sp,
                  fontWeight: FontWeight.w400,
                  color:      colors.textPrimary,
                ),
                searchDecoration: InputDecoration(
                  hintText: l10n.actionSearch,
                  hintStyle: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize:   14.sp,
                    fontWeight: FontWeight.w400,
                    color:      colors.textHint,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colors.textSecondary,
                    size:  20.w,
                  ),
                  filled:    true,
                  fillColor: _kLoginInputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    borderSide:   BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    borderSide:   BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    borderSide:   BorderSide(color: colors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical:   12,
                  ),
                ),

                dialogSize: Size(
                  MediaQuery.of(context).size.width * 0.90,
                  600.h,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  const _LinkButton({
    required this.label,
    required this.textTheme,
    required this.colors,
    required this.onTap,
  });

  final String label;
  final TextTheme textTheme;
  final AppColorScheme colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: colors.textHint,
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.9,
        ),
      ),
    );
  }
}

// ─── Feature highlights ───────────────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.colors,
    required this.appStyles,
    required this.l10n,
  });

  final AppColorScheme colors;
  final AppTextStyles appStyles;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _FeatureTile(
            colors: colors,
            appStyles: appStyles,
            leading: SizedBox(
              height: 28.h,
              child: Assets.icVerifiedCarriers.svg(),
            ),
            title: l10n.authFeatureVerifiedTitle,
            desc: l10n.authFeatureVerifiedDesc,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _FeatureTile(
            colors: colors,
            appStyles: appStyles,
            leading: SizedBox(
              height: 28.h,
              child: Assets.icSecurePayment.svg(),
            ),
            title: l10n.authFeatureSecureTitle,
            desc: l10n.authFeatureSecureDesc,
          ),
        ),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.colors,
    required this.appStyles,
    required this.leading,
    required this.title,
    required this.desc,
  });

  final AppColorScheme colors;
  final AppTextStyles appStyles;
  final Widget leading;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg.r),
        boxShadow: [
          BoxShadow(
            color: colors.languageTileShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leading,
          SizedBox(height: 8.h),
          Text(
            title,
            style: appStyles.cardTitle.copyWith(
              color: colors.textPrimary,
              fontSize: 15.sp,
              height: 1.3,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            desc,
            style: appStyles.caption.copyWith(
              color: colors.textSecondary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
