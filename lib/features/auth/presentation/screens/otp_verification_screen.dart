import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/svg_gen_image_extension.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../generated/assets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/presentation/widgets/inputs/app_otp_field.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../providers/auth_provider.dart';

/// Figma OTP input fill — matches Login screen fields.
const _kOtpBoxFill = Color(0xFFF0F2F5);

/// Figma headline color (node 2013-1700).
const _kOtpHeadlineColor = Color(0xFF1A1C1E);

/// Horizontal inset for the Verify CTA (~72% of content width per Figma).
const _kVerifyButtonHorizontalInset = 48.0;

/// 4-digit OTP verification — [Figma OTP screen](https://www.figma.com/design/wT5NdNeg7YVPPcq1nY9D2P/Goods-Carrier--Copy-?node-id=2013-1700).
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen>
    with SafeSetStateMixin {
  static const _totalSeconds = 60;

  int _remaining = _totalSeconds;
  Timer? _timer;
  bool _hasError = false;
  String _otp = '';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    safeSetState(() => _remaining = _totalSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 0) {
        t.cancel();
      } else {
        safeSetState(() => _remaining--);
      }
    });
  }

  Future<void> _resendOtp() async {
    if (_remaining > 0) return;
    final phone = ref.read(authProvider).phoneNumber ?? '';
    await ref.read(authProvider.notifier).sendOtp(phone);
    safeSetState(() => _hasError = false);
    _startTimer();
  }

  Future<void> _verify() async {
    if (_otp.length != 4) return;
    safeSetState(() => _hasError = false);
    await ref.read(authProvider.notifier).verifyOtp(_otp);

    if (!mounted) return;
    if (ref.read(authProvider).error != null) {
      safeSetState(() => _hasError = true);
    }
  }

  String _formatPhoneDisplay(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 10 && digits.startsWith('91')) {
      final local = digits.substring(2);
      if (local.length == 10) {
        return '+91 $local';
      }
    }
    if (raw.startsWith('+')) return raw;
    return '+91 $raw';
  }

  String _formatCountdown(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final textTheme = context.textTheme;
    final appStyles = context.appTextStyles;
    final authState = ref.watch(authProvider);
    final phoneDisplay = _formatPhoneDisplay(authState.phoneNumber);
    final isLoading = authState.isLoading;
    final canVerify = _otp.length == 4 && !isLoading;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: FlowScreenAppBar(title: l10n.authVerifyNumberTitle),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      SizedBox(height: 24.h),
                      _OtpHeroIcon(colors: colors),
                      SizedBox(height: 24.h),
                      Text(
                        l10n.authEnterOtp,
                        textAlign: TextAlign.center,
                        style: appStyles.sectionHeading.copyWith(
                          fontFamily: FontRes.MANROPE_EXTRABOLD,
                          color: _kOtpHeadlineColor,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w400,
                          height: 1.25,
                          letterSpacing: 0,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        l10n.authOtpCodeSentPrefix,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          fontFamily: FontRes.MANROPE_REGULAR,
                          color: colors.textSecondary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          height: 20 / 14,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        phoneDisplay,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(
                          fontFamily: FontRes.MANROPE_SEMIBOLD,
                          color: colors.textPrimary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          height: 24 / 16,
                        ),
                      ),
                      SizedBox(height: 32.h),
                      AppOtpField(
                        boxFillColor: _kOtpBoxFill,
                        autoSubmitOnComplete: false,
                        onChanged: (value) => safeSetState(() => _otp = value),
                        onCompleted: (_) {},
                        hasError: _hasError,
                        enabled: !isLoading,
                      ),
                      if (authState.error != null) ...[
                        SizedBox(height: 12.h),
                        Text(
                          authState.error!,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      // Figma: resend capsule → encryption centered in remaining space.
                      Expanded(
                        child: Center(
                          child: _OtpActionBlock(
                            l10n: l10n,
                            colors: colors,
                            textTheme: textTheme,
                            remaining: _remaining,
                            isLoading: isLoading,
                            canVerify: canVerify,
                            countdown: _formatCountdown(_remaining),
                            onResend: _resendOtp,
                            onVerify: _verify,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Resend + CTA + footers (centered below OTP per Figma) ───────────────────

class _OtpActionBlock extends StatelessWidget {
  const _OtpActionBlock({
    required this.l10n,
    required this.colors,
    required this.textTheme,
    required this.remaining,
    required this.isLoading,
    required this.canVerify,
    required this.countdown,
    required this.onResend,
    required this.onVerify,
  });

  final AppLocalizations l10n;
  final AppColorScheme colors;
  final TextTheme textTheme;
  final int remaining;
  final bool isLoading;
  final bool canVerify;
  final String countdown;
  final VoidCallback onResend;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (remaining > 0) ...[
          _ResendTimerPill(
            colors: colors,
            label: l10n.authResendCodeIn,
            countdown: countdown,
          ),
          SizedBox(height: 10.h),
        ],
        GestureDetector(
          onTap: remaining > 0 || isLoading ? null : onResend,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Text(
              l10n.authResendSms,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: remaining > 0
                    ? colors.textHint
                    : colors.textSecondary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _kVerifyButtonHorizontalInset.w,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusLg.r),
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
                onPressed: canVerify ? onVerify : null,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  disabledBackgroundColor:
                      colors.primary.withValues(alpha: 0.45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusLg.r,
                    ),
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
                            l10n.authVerifyAndContinue,
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
        ),
        SizedBox(height: 14.h),
        _HelpFooter(
          l10n: l10n,
          colors: colors,
          textTheme: textTheme,
        ),
        SizedBox(height: 8.h),
        _EncryptionFooter(
          l10n: l10n,
          colors: colors,
          textTheme: textTheme,
        ),
      ],
    );
  }
}

// ─── Hero lock icon ───────────────────────────────────────────────────────────

class _OtpHeroIcon extends StatelessWidget {
  const _OtpHeroIcon({required this.colors});

  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88.w,
      height: 88.w,
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Assets.icOtpLock.svg(
        width: 24.w,
        height: 24.w,
      ),
    );
  }
}

// ─── Resend timer pill ────────────────────────────────────────────────────────

class _ResendTimerPill extends StatelessWidget {
  const _ResendTimerPill({
    required this.colors,
    required this.label,
    required this.countdown,
  });

  final AppColorScheme colors;
  final String label;
  final String countdown;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: _kOtpBoxFill,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule_rounded,
              size: 18.w,
              color: colors.textSecondary,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                fontFamily: FontRes.MANROPE_REGULAR,
                color: colors.textSecondary,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              countdown,
              style: textTheme.bodySmall?.copyWith(
                fontFamily: FontRes.MANROPE_BOLD,
                color: colors.primary,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Footers ──────────────────────────────────────────────────────────────────

class _HelpFooter extends StatelessWidget {
  const _HelpFooter({
    required this.l10n,
    required this.colors,
    required this.textTheme,
  });

  final AppLocalizations l10n;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: textTheme.bodyMedium?.copyWith(
          color: colors.textSecondary,
          fontSize: 14.sp,
        ),
        children: [
          TextSpan(text: l10n.authHavingTrouble),
          TextSpan(
            text: l10n.authNeedHelp,
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EncryptionFooter extends StatelessWidget {
  const _EncryptionFooter({
    required this.l10n,
    required this.colors,
    required this.textTheme,
  });

  final AppLocalizations l10n;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.security_outlined,
          size: 14.w,
          color: colors.textHint,
        ),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            l10n.authEncryptedVerification,
            textAlign: TextAlign.center,
            style: textTheme.labelSmall?.copyWith(
              color: colors.textHint,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }
}
