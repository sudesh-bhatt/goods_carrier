import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../shared/presentation/widgets/buttons/app_button.dart';
import '../../../../shared/presentation/widgets/inputs/app_otp_field.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../providers/auth_provider.dart';

/// 4-digit OTP verification screen with a 60-second resend countdown.
///
/// On successful verification the [AuthNotifier] sets status to
/// [AuthStatus.profileSetupPending] and GoRouter's redirect takes the user
/// to the correct profile-setup screen automatically.
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends ConsumerState<OtpVerificationScreen> {
  static const _totalSeconds = 60;
  int _remaining = _totalSeconds;
  Timer? _timer;
  bool _hasError = false;

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
    setState(() => _remaining = _totalSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 0) {
        t.cancel();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  Future<void> _resendOtp() async {
    final phone = ref.read(authProvider).phoneNumber ?? '';
    await ref.read(authProvider.notifier).sendOtp(phone);
    setState(() => _hasError = false);
    _startTimer();
  }

  Future<void> _verify(String otp) async {
    setState(() => _hasError = false);
    await ref.read(authProvider.notifier).verifyOtp(otp);

    if (!mounted) return;
    final state = ref.read(authProvider);

    if (state.error != null) {
      setState(() => _hasError = true);
    }
    // GoRouter redirect handles navigation if verification succeeds.
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final authState = ref.watch(authProvider);
    final phone = authState.phoneNumber ?? '';
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const AppBarWidget(title: ''),
      body: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: AppDimensions.xl.h),

              // ── Icon ───────────────────────────────────────────────────
              Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_outline_rounded,
                    size: AppDimensions.iconLg.w, color: colors.primary),
              ),

              SizedBox(height: AppDimensions.xl.h),

              // ── Heading ────────────────────────────────────────────────
              Text(
                context.l10n.authVerifyOtp,
                style: context.textTheme.headlineSmall?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),

              SizedBox(height: AppDimensions.sm.h),

              Text(
                context.l10n.authOtpSentTo('+91 $phone'),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppDimensions.xxl.h),

              // ── 4-box OTP field ────────────────────────────────────────
              AppOtpField(
                onCompleted: isLoading ? (_) {} : _verify,
                hasError: _hasError,
                enabled: !isLoading,
              ),

              // Error message
              if (authState.error != null) ...[
                SizedBox(height: AppDimensions.sm.h),
                Text(
                  authState.error!,
                  style: context.textTheme.bodySmall
                      ?.copyWith(color: colors.error),
                  textAlign: TextAlign.center,
                ),
              ],

              SizedBox(height: AppDimensions.xl.h),

              // ── Resend section ─────────────────────────────────────────
              if (_remaining > 0)
                Text(
                  context.l10n.authResendIn(_remaining),
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                )
              else
                AppButton(
                  label: context.l10n.authResendOtp,
                  onPressed: isLoading ? null : _resendOtp,
                  variant: AppButtonVariant.ghost,
                  isFullWidth: false,
                  height: 40,
                ),

              const Spacer(),

              // ── Loading indicator ──────────────────────────────────────
              if (isLoading) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.primary,
                      ),
                    ),
                    SizedBox(width: AppDimensions.sm.w),
                    Text(
                      'Verifying...',
                      style: context.textTheme.bodySmall
                          ?.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.xl.h),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
