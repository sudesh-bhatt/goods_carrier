import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../generated/assets.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

const _kLoginBannerAsset = 'assets/images/login_screen_banner.png';

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
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    safeSetState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authProvider.notifier).sendOtp(_phoneCtrl.text.trim());
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
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
                child: Transform.translate(
                  offset: Offset(0, -24.h),
                  child: Column(
                    children: [
                      _FormCard(
                        l10n: l10n,
                        colors: colors,
                        textTheme: textTheme,
                        appStyles: appStyles,
                        formKey: _formKey,
                        phoneCtrl: _phoneCtrl,
                        submitted: _submitted,
                        isLoading: isLoading,
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
                      height: 72.h,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      l10n.appName,
                      textAlign: TextAlign.center,
                      style: appStyles.sectionHeading.copyWith(
                        color: colors.textPrimary,
                        fontSize: 22.sp,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      l10n.authLoginBrandLine,
                      textAlign: TextAlign.center,
                      style: appStyles.caption.copyWith(
                        color: colors.textSecondary,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
    required this.onSendOtp,
  });

  final AppLocalizations l10n;
  final AppColorScheme colors;
  final TextTheme textTheme;
  final AppTextStyles appStyles;
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneCtrl;
  final bool submitted;
  final bool isLoading;
  final VoidCallback onSendOtp;

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
                color: colors.textPrimary,
                fontSize: 24.sp,
                height: 1.2,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.authLoginSubtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              l10n.authPhoneLabel.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                color: colors.textSecondary,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                height: 1.2,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CountryCodeChip(colors: colors, textTheme: textTheme, l10n: l10n),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextFormField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    autofocus: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: Validators.phone,
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
                      fillColor: colors.inputFill,
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
                            Assets.ctaRightArrow.svg(
                              width: 18.w,
                              height: 18.w,
                              colorFilter: ColorFilter.mode(
                                colors.onPrimary,
                                BlendMode.srcIn,
                              ),
                            ),
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

class _CountryCodeChip extends StatelessWidget {
  const _CountryCodeChip({
    required this.colors,
    required this.textTheme,
    required this.l10n,
  });

  final AppColorScheme colors;
  final TextTheme textTheme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: colors.inputFill,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.authCountryCodeInd,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.textPrimary,
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colors.textSecondary,
            size: 22.w,
          ),
        ],
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
