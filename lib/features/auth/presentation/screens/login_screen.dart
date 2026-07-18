import 'dart:ui';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../../generated/assets.dart';
import '../../../../shared/presentation/widgets/inputs/app_phone_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../res/font_res.dart';
import '../providers/auth_provider.dart';
import 'terms_screen.dart';

const _kLoginBannerAsset = 'assets/images/login_screen_banner.png';

/// Figma Login card headline fill (node 2013-1652).
const _kLoginHeadlineColor = Color(0xFF1A1C1E);

/// Figma social-proof tiles (node 1-837).
const _kFeatureTileHeight = 122.4;
const _kFeatureTileTitleColor = Color(0xFF323539);
const _kFeatureTileBodyColor = Color(0xFF44474E);

/// Login screen — phone capture + OTP request
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
    final fullNumber =
        PhoneUtils.buildE164(_dialCode, _phoneCtrl.text.trim());
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
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Align(
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        height: 150.h,
                        child: Assets.appLogo.image(
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
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
            AppPhoneField(
              controller: phoneCtrl,
              dialCode: dialCode,
              onDialCodeChanged: onCountryChanged,
              size: AppPhoneFieldSize.login,
              autofocus: true,
              onFieldSubmitted: (_) => onSendOtp(),
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
                  onTap: () => context.push(
                    AppRoutes.terms,
                    extra: LegalDocument.privacy,
                  ),
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
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _FeatureTile(
              colors: colors,
              appStyles: appStyles,
              leading: Assets.icVerifiedCarriers.svg(
                height: 21.h,
                width: 22.w,
              ),
              title: l10n.authFeatureVerifiedTitle,
              desc: l10n.authFeatureVerifiedDesc,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: _FeatureTile(
              colors: colors,
              appStyles: appStyles,
              leading: Assets.icSecurePayment.svg(
                height: 20.h,
                width: 16.w,
              ),
              title: l10n.authFeatureSecureTitle,
              desc: l10n.authFeatureSecureDesc,
            ),
          ),
        ],
      ),
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
    final radius = BorderRadius.circular(AppDimensions.radiusLg.r);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          height: _kFeatureTileHeight.h,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: radius,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 22.h,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: leading,
                ),
              ),
              SizedBox(height: 3.4.h),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: appStyles.cardTitle.copyWith(
                  color: _kFeatureTileTitleColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  height: 20 / 14,
                ),
              ),
              SizedBox(height: 3.4.h),
              SizedBox(
                height: 36.h,
                child: Text(
                  desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: appStyles.caption.copyWith(
                    color: _kFeatureTileBodyColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    height: 18 / 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
