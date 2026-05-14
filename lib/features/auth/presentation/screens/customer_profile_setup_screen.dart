import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/presentation/widgets/buttons/app_button.dart';
import '../../../../shared/presentation/widgets/inputs/app_text_field.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../providers/auth_provider.dart';

/// Profile setup for new Customer accounts.
///
/// Required: name, email.
/// Optional: company name, GST number.
///
/// On submit → [AuthNotifier.submitCustomerProfile] → auth status becomes
/// [AuthStatus.authenticated] → GoRouter redirects to customerHome.
class CustomerProfileSetupScreen extends ConsumerStatefulWidget {
  const CustomerProfileSetupScreen({super.key});

  @override
  ConsumerState<CustomerProfileSetupScreen> createState() =>
      _CustomerProfileSetupScreenState();
}

class _CustomerProfileSetupScreenState
    extends ConsumerState<CustomerProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _gstCtrl     = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _companyCtrl.dispose();
    _gstCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    await ref.read(authProvider.notifier).submitCustomerProfile(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      companyName: _companyCtrl.text.trim().isEmpty
          ? null
          : _companyCtrl.text.trim(),
      gstNumber: _gstCtrl.text.trim().isEmpty
          ? null
          : _gstCtrl.text.trim(),
    );
    // GoRouter redirect fires automatically on auth status change.
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBarWidget(
        title: context.l10n.profileSetupTitle,
        leadingType: AppBarLeadingType.none,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Form(
            key: _formKey,
            autovalidateMode: _submitted
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenPadding.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppDimensions.xl.h),

                  // ── Subtitle ─────────────────────────────────────────────
                  Text(
                    context.l10n.profileSetupSubtitle,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),

                  SizedBox(height: AppDimensions.xl.h),

                  // ── Avatar placeholder ────────────────────────────────────
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 80.w,
                          height: 80.w,
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.10),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.person_outline_rounded,
                              size: 40.w, color: colors.primary),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 28.w,
                            height: 28.w,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: colors.surface,
                                  width: 2),
                            ),
                            child: Icon(Icons.camera_alt_outlined,
                                size: 14.w, color: colors.onPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppDimensions.xl.h),

                  // ── Required fields ───────────────────────────────────────
                  AppTextField(
                    label: context.l10n.profileName,
                    hint: 'Arjun Sharma',
                    controller: _nameCtrl,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofocus: true,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    validator: (v) => Validators.required(
                        v, context.l10n.profileName),
                  ),

                  SizedBox(height: AppDimensions.base.h),

                  AppTextField(
                    label: context.l10n.profileEmail,
                    hint: 'arjun@email.com',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: Validators.email,
                  ),

                  SizedBox(height: AppDimensions.xl.h),

                  // ── Optional section header ───────────────────────────────
                  Row(children: [
                    Expanded(child: Divider(color: colors.divider)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.sm.w),
                      child: Text(
                        context.l10n.labelOptional,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: colors.textHint,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: colors.divider)),
                  ]),

                  SizedBox(height: AppDimensions.base.h),

                  AppTextField(
                    label: context.l10n.profileCompanyName,
                    hint: 'Sharma Enterprises Pvt. Ltd.',
                    controller: _companyCtrl,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.business_outlined),
                  ),

                  SizedBox(height: AppDimensions.base.h),

                  AppTextField(
                    label: context.l10n.profileGstNumber,
                    hint: context.l10n.profileGstNumberHint,
                    controller: _gstCtrl,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.done,
                    prefixIcon: const Icon(Icons.receipt_long_outlined),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      return Validators.gstNumber(v);
                    },
                  ),

                  SizedBox(height: AppDimensions.xxxl.h),

                  AppButton(
                    label: context.l10n.actionContinue,
                    onPressed: isLoading ? null : _submit,
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
