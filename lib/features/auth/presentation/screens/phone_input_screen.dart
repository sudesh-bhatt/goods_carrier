import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../generated/assets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/widgets/inputs/app_text_field.dart';
import '../providers/auth_provider.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

class PhoneInputScreen extends ConsumerStatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  ConsumerState<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends ConsumerState<PhoneInputScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  bool _submitted  = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    setState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authProvider.notifier).sendOtp(_phoneCtrl.text.trim());
    if (mounted) context.push(AppRoutes.otpVerification);
  }

  @override
  Widget build(BuildContext context) {
    final l10n      = context.l10n;
    final colors    = context.colors;
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

            // ── Hero section ──────────────────────────────────────────
            _HeroSection(colors: colors),

            // ── Scrollable body ───────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    SizedBox(height: 24.h),

                    // ── Form card ─────────────────────────────────────
                    _FormCard(
                      l10n:      l10n,
                      colors:    colors,
                      textTheme: textTheme,
                      appStyles: appStyles,
                      formKey:   _formKey,
                      phoneCtrl: _phoneCtrl,
                      submitted: _submitted,
                      isLoading: isLoading,
                      onSendOtp: _sendOtp,
                    ),

                    SizedBox(height: 20.h),

                    // ── Feature highlights ────────────────────────────
                    _FeatureRow(colors: colors, textTheme: textTheme, l10n: l10n),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero section ─────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.colors});
  final dynamic colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colors.primary,
      child: Stack(
        children: [
          // ── Floating back button (top-left) ───────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(left: 4.w, top: 4.h),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20.w,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.pop();
                },
                tooltip: context.l10n.actionBack,
              ),
            ),
          ),

          // ── Logo (centred) ────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(top: 12.h, bottom: 24.h),
              child: Center(
                child: Assets.splashScreenLogo.image(
                  height: 80.h,
                  fit: BoxFit.contain,
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

  final AppLocalizations     l10n;
  final dynamic              colors;
  final TextTheme            textTheme;
  final dynamic              appStyles;
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneCtrl;
  final bool                 submitted;
  final bool                 isLoading;
  final VoidCallback         onSendOtp;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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

            // ── Welcome heading ───────────────────────────────────────
            Text(
              l10n.authWelcome,
              style: appStyles.sectionHeading.copyWith(
                color: colors.textPrimary,
              ),
            ),

            SizedBox(height: 8.h),

            // ── Subtitle ──────────────────────────────────────────────
            Text(
              l10n.authLoginSubtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.brownText,
                height: 1.5,
              ),
            ),

            SizedBox(height: 20.h),

            // ── PHONE NUMBER label ────────────────────────────────────
            Text(
              l10n.authPhoneLabel.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),

            SizedBox(height: 8.h),

            // ── Phone field ───────────────────────────────────────────
            AppTextField(
              label: l10n.authPhoneLabel,
              hint: '98765 43210',
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              autofocus: true,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: Validators.phone,
              onSubmitted: (_) => onSendOtp(),
              prefixIcon: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🇮🇳', style: TextStyle(fontSize: 18.sp)),
                    SizedBox(width: 4.w),
                    Text(
                      '+91',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Container(width: 1, height: 20.h, color: colors.divider),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // ── Send OTP button ───────────────────────────────────────
            SizedBox(
              width:  double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: isLoading ? null : onSendOtp,
                child: isLoading
                    ? SizedBox(
                        width:  22.w,
                        height: 22.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        l10n.authSendOtp,
                        style: textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 16.h),

            // ── PRIVACY POLICY • HELP CENTER ──────────────────────────
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
                    style: textTheme.labelSmall?.copyWith(color: colors.textHint),
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

// ─── Link button (no padding/target inflation) ────────────────────────────────

class _LinkButton extends StatelessWidget {
  const _LinkButton({
    required this.label,
    required this.textTheme,
    required this.colors,
    required this.onTap,
  });

  final String    label;
  final TextTheme textTheme;
  final dynamic   colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: colors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─── Feature highlights row ───────────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.colors,
    required this.textTheme,
    required this.l10n,
  });

  final dynamic          colors;
  final TextTheme        textTheme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _FeatureTile(
            colors:    colors,
            textTheme: textTheme,
            icon:      Icons.verified_rounded,
            title:     l10n.authFeatureVerifiedTitle,
            desc:      l10n.authFeatureVerifiedDesc,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _FeatureTile(
            colors:    colors,
            textTheme: textTheme,
            icon:      Icons.shield_rounded,
            title:     l10n.authFeatureSecureTitle,
            desc:      l10n.authFeatureSecureDesc,
          ),
        ),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.colors,
    required this.textTheme,
    required this.icon,
    required this.title,
    required this.desc,
  });

  final dynamic   colors;
  final TextTheme textTheme;
  final IconData  icon;
  final String    title;
  final String    desc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.primary, size: 24.w),
          SizedBox(height: 8.h),
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            desc,
            style: textTheme.bodySmall?.copyWith(
              color: colors.brownText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
