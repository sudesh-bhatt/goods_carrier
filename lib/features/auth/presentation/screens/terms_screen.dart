import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../shared/domain/enums/session_phase.dart';
import '../../../../shared/presentation/widgets/buttons/app_button.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../providers/auth_provider.dart';

/// Which legal document to display (Settings vs onboarding).
enum LegalDocument { terms, privacy }

/// Scrollable Terms & Conditions screen. The "Accept & Continue" CTA is only
/// enabled after the user checks the agreement checkbox (onboarding only).
class TermsScreen extends ConsumerStatefulWidget {
  const TermsScreen({super.key, this.document = LegalDocument.terms});

  final LegalDocument document;

  @override
  ConsumerState<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends ConsumerState<TermsScreen>
    with SafeSetStateMixin {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final auth = ref.watch(authProvider);
    final showOnboardingFooter =
        auth.sessionPhase == SessionPhase.onboarding &&
            widget.document == LegalDocument.terms;

    final title = switch (widget.document) {
      LegalDocument.privacy => l10n.authPrivacyPolicy,
      LegalDocument.terms => l10n.authTermsLink,
    };

    return Scaffold(
      backgroundColor: colors.background,
      appBar: FlowScreenAppBar(title: title),
      body: Column(
        children: [
          // ── Scrollable T&C body ────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding:
                  EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppDimensions.base.h),
                  const _SectionTitle('1. Acceptance of Terms'),
                  const _Para(
                    'By using the Goods Carrier application, you agree to these '
                    'Terms and Conditions. If you do not agree, please do not use '
                    'the application. These terms apply to all users, including '
                    'Customers and Drivers.',
                  ),
                  const _SectionTitle('2. Services'),
                  const _Para(
                    'Goods Carrier is a logistics marketplace that connects '
                    'Customers (shippers) with Drivers (transporters). We do not '
                    'directly provide transportation services. Drivers operate as '
                    'independent service providers.',
                  ),
                  const _SectionTitle('3. User Accounts'),
                  const _Para(
                    'You must provide accurate and complete information during '
                    'registration. You are responsible for maintaining the '
                    'confidentiality of your account credentials and for all '
                    'activities under your account.',
                  ),
                  const _SectionTitle('4. Customer Responsibilities'),
                  const _Para(
                    'Customers must provide accurate pickup and delivery details, '
                    'declare goods correctly (including fragile or hazardous '
                    'materials), and be available for pickup and delivery. '
                    'Misdeclaration of goods may result in account suspension.',
                  ),
                  const _SectionTitle('5. Driver Responsibilities'),
                  const _Para(
                    'Drivers must hold valid commercial vehicle permits, '
                    'maintain adequate insurance, handle goods with care, and '
                    'complete deliveries within the agreed timeline. Drivers '
                    'must comply with all applicable traffic and transport laws.',
                  ),
                  const _SectionTitle('6. Payments'),
                  const _Para(
                    'Payment terms are agreed between Customer and Driver. '
                    'Goods Carrier may facilitate payments via the in-app '
                    'payment gateway. Platform fees may apply. All transactions '
                    'are subject to applicable taxes.',
                  ),
                  const _SectionTitle('7. Liability'),
                  const _Para(
                    'Goods Carrier is not liable for loss or damage to goods '
                    'during transit. We recommend Customers obtain appropriate '
                    'cargo insurance for high-value shipments.',
                  ),
                  const _SectionTitle('8. Privacy'),
                  const _Para(
                    'Your data is processed in accordance with our Privacy Policy. '
                    'By using this app, you consent to the collection and use of '
                    'your information as described therein.',
                  ),
                  const _SectionTitle('9. Dispute Resolution'),
                  const _Para(
                    'Any disputes shall first be resolved through our in-app '
                    'dispute resolution process. Unresolved disputes shall be '
                    'subject to arbitration under the laws of the Republic of '
                    'India, with jurisdiction in Mumbai.',
                  ),
                  const _SectionTitle('10. Changes to Terms'),
                  const _Para(
                    'We reserve the right to modify these terms at any time. '
                    'Continued use of the app after changes constitutes '
                    'acceptance of the revised terms.',
                  ),
                  SizedBox(height: AppDimensions.xl.h),
                ],
              ),
            ),
          ),

          if (showOnboardingFooter)
            Container(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.screenPadding.w,
                AppDimensions.base.h,
                AppDimensions.screenPadding.w,
                AppDimensions.xl.h,
              ),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.divider)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      safeSetState(() => _accepted = !_accepted);
                    },
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 22.w,
                          height: 22.w,
                          decoration: BoxDecoration(
                            color: _accepted
                                ? colors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(
                              color: _accepted
                                  ? colors.primary
                                  : colors.divider,
                              width: 1.5,
                            ),
                          ),
                          child: _accepted
                              ? Icon(
                                  Icons.check,
                                  color: colors.onPrimary,
                                  size: 14.w,
                                )
                              : null,
                        ),
                        SizedBox(width: AppDimensions.sm.w),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: context.textTheme.bodySmall?.copyWith(
                                color: colors.textSecondary,
                              ),
                              children: [
                                TextSpan(text: l10n.authTermsPrefix),
                                TextSpan(
                                  text: l10n.authTermsLink,
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppDimensions.base.h),
                  AppButton(
                    label: l10n.actionContinue,
                    isLoading: auth.isLoading,
                    onPressed: _accepted && !auth.isLoading
                        ? () async {
                            final route = await ref
                                .read(authProvider.notifier)
                                .acceptOnboardingAgreement();
                            if (!context.mounted) return;
                            if (route != null) context.go(route);
                          }
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: AppDimensions.base.h, bottom: AppDimensions.xs.h),
      child: Text(
        text,
        style: context.textTheme.titleSmall?.copyWith(
          color: context.colors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Para extends StatelessWidget {
  const _Para(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.sm.h),
      child: Text(
        text,
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colors.textSecondary,
          height: 1.6,
        ),
      ),
    );
  }
}
