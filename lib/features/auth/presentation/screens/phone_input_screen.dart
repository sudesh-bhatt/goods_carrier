import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/presentation/widgets/buttons/app_button.dart';
import '../../../../shared/presentation/widgets/inputs/app_text_field.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../providers/auth_provider.dart';

/// Phone number entry screen. Validates a 10-digit Indian mobile number and
/// calls [AuthNotifier.sendOtp] before navigating to [OtpVerificationScreen].
class PhoneInputScreen extends ConsumerStatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  ConsumerState<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends ConsumerState<PhoneInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  bool _submitted = false;

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
    final colors = context.colors;
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBarWidget(title: ''),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPadding.w),
            child: Form(
              key: _formKey,
              autovalidateMode: _submitted
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppDimensions.xl.h),

                  // ── Heading ─────────────────────────────────────────────
                  Text(
                    context.l10n.authPhoneLabel,
                    style: context.textTheme.headlineSmall?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  SizedBox(height: AppDimensions.sm.h),

                  Text(
                    'We\'ll send a 4-digit OTP to verify your number',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),

                  SizedBox(height: AppDimensions.xxl.h),

                  // ── Phone field ─────────────────────────────────────────
                  AppTextField(
                    label: context.l10n.authPhoneLabel,
                    hint: '98765 43210',
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    autofocus: true,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: Validators.phone,
                    onSubmitted: (_) => _sendOtp(),
                    prefixIcon: Container(
                      padding: EdgeInsets.symmetric(horizontal: AppDimensions.sm.w),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '🇮🇳',
                            style: TextStyle(fontSize: 18.sp),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '+91',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: AppDimensions.sm.w),
                          Container(width: 1, height: 20.h,
                              color: colors.divider),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // ── CTA ─────────────────────────────────────────────────
                  AppButton(
                    label: context.l10n.authSendOtp,
                    onPressed: isLoading ? null : _sendOtp,
                    isLoading: isLoading,
                  ),

                  SizedBox(height: AppDimensions.xl.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
