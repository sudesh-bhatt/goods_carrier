import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/domain/enums/session_phase.dart';
import '../../../../shared/domain/models/legal_page.dart';
import '../../../../shared/presentation/widgets/buttons/app_button.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../providers/auth_provider.dart';

/// Which legal / CMS document to display (Settings vs onboarding).
enum LegalDocument {
  terms,
  privacy,
  about;

  /// CMS slug for `GET /api/pages/{slug}`.
  String get apiSlug => switch (this) {
        LegalDocument.privacy => 'privacy_policy',
        LegalDocument.terms => 'terms_and_conditions',
        LegalDocument.about => 'about_good_carrier',
      };

  /// Alternate slugs if the primary one 404s.
  List<String> get apiSlugFallbacks => switch (this) {
        LegalDocument.privacy => const ['privacy-policy', 'privacy'],
        LegalDocument.terms => const [
            'terms-and-conditions',
            'terms_conditions',
            'terms',
          ],
        LegalDocument.about => const [
            'about-good-carrier',
            'about',
            'about_us',
            'about-us',
          ],
      };
}

final legalPageProvider =
    FutureProvider.family<LegalPage?, LegalDocument>((ref, document) async {
  final client = ref.read(legalPageApiClientProvider);
  final slugs = [document.apiSlug, ...document.apiSlugFallbacks];
  for (final slug in slugs) {
    try {
      final page = await client.fetchPage(slug);
      if (page.hasContent) return page;
    } catch (_) {
      // Try next slug / fall back to local copy.
    }
  }
  return null;
});

/// Scrollable Terms / Privacy screen. Loads CMS HTML from the API when available
/// and falls back to the built-in copy if the request fails.
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

    final pageAsync = ref.watch(legalPageProvider(widget.document));

    final title = switch (widget.document) {
      LegalDocument.privacy => l10n.authPrivacyPolicy,
      LegalDocument.terms => l10n.authTermsLink,
      LegalDocument.about => l10n.customerSettingsAboutApp,
    };

    return Scaffold(
      backgroundColor: colors.background,
      appBar: FlowScreenAppBar(title: title),
      body: Column(
        children: [
          Expanded(
            child: pageAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _LegalScrollBody(
                errorMessage: ApiExceptionMapper.userMessage(e),
                child: _FallbackLegalBody(document: widget.document),
              ),
              data: (page) {
                if (page != null && page.hasContent) {
                  return _LegalScrollBody(
                    child: _LegalHtmlBody(content: page.content),
                  );
                }
                return _LegalScrollBody(
                  child: _FallbackLegalBody(document: widget.document),
                );
              },
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

class _LegalScrollBody extends StatelessWidget {
  const _LegalScrollBody({
    required this.child,
    this.errorMessage,
  });

  final Widget child;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppDimensions.base.h),
          if (errorMessage != null) ...[
            Text(
              errorMessage!,
              style: TextStyle(
                fontFamily: FontRes.MANROPE_REGULAR,
                fontSize: 12.sp,
                color: context.colors.error,
              ),
            ),
            SizedBox(height: AppDimensions.sm.h),
          ],
          child,
          SizedBox(height: AppDimensions.xl.h),
        ],
      ),
    );
  }
}

class _LegalHtmlBody extends StatelessWidget {
  const _LegalHtmlBody({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final html = _normalizeContent(content);

    return Html(
      data: html,
      style: {
        'body': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontFamily: FontRes.MANROPE_REGULAR,
          fontSize: FontSize(13.sp),
          lineHeight: const LineHeight(1.6),
          color: colors.textSecondary,
        ),
        'h1': Style(
          fontFamily: FontRes.MANROPE_BOLD,
          fontSize: FontSize(18.sp),
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
          margin: Margins.only(top: 16, bottom: 8),
        ),
        'h2': Style(
          fontFamily: FontRes.MANROPE_BOLD,
          fontSize: FontSize(15.sp),
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
          margin: Margins.only(top: 16, bottom: 6),
        ),
        'h3': Style(
          fontFamily: FontRes.MANROPE_BOLD,
          fontSize: FontSize(14.sp),
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
          margin: Margins.only(top: 12, bottom: 4),
        ),
        'p': Style(
          margin: Margins.only(bottom: 10),
          fontFamily: FontRes.MANROPE_REGULAR,
          fontSize: FontSize(13.sp),
          lineHeight: const LineHeight(1.6),
          color: colors.textSecondary,
        ),
        'li': Style(
          margin: Margins.only(bottom: 4),
          fontFamily: FontRes.MANROPE_REGULAR,
          fontSize: FontSize(13.sp),
          lineHeight: const LineHeight(1.55),
          color: colors.textSecondary,
        ),
        'strong': Style(
          fontFamily: FontRes.MANROPE_BOLD,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
        'ul': Style(margin: Margins.only(bottom: 10, left: 8)),
        'ol': Style(margin: Margins.only(bottom: 10, left: 8)),
      },
    );
  }

  /// WYSIWYG may store HTML or plain text with newlines.
  static String _normalizeContent(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    final looksLikeHtml = RegExp(r'<[a-zA-Z][^>]*>').hasMatch(trimmed);
    if (looksLikeHtml) return trimmed;

    final blocks = trimmed
        .split(RegExp(r'\n\s*\n'))
        .map((b) => b.trim())
        .where((b) => b.isNotEmpty);
    final buffer = StringBuffer();
    for (final block in blocks) {
      final singleLine = block.replaceAll(RegExp(r'\n+'), ' ').trim();
      final isHeading = RegExp(r'^\d+\.\s+.+').hasMatch(singleLine) &&
          singleLine.length < 80;
      if (isHeading) {
        buffer.writeln('<h2>${_escape(singleLine)}</h2>');
      } else {
        buffer.writeln('<p>${_escape(singleLine)}</p>');
      }
    }
    return buffer.toString();
  }

  static String _escape(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}

class _FallbackLegalBody extends StatelessWidget {
  const _FallbackLegalBody({required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    final sections = switch (document) {
      LegalDocument.privacy => _privacyFallback,
      LegalDocument.terms => _termsFallback,
      LegalDocument.about => _aboutFallback,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final section in sections) ...[
          _SectionTitle(section.$1),
          _Para(section.$2),
        ],
      ],
    );
  }
}

const _termsFallback = <(String, String)>[
  (
    '1. Acceptance of Terms',
    'By using the Goods Carrier application, you agree to these Terms and Conditions. If you do not agree, please do not use the application. These terms apply to all users, including Customers and Drivers.',
  ),
  (
    '2. Services',
    'Goods Carrier is a logistics marketplace that connects Customers (shippers) with Drivers (transporters). We do not directly provide transportation services. Drivers operate as independent service providers.',
  ),
  (
    '3. User Accounts',
    'You must provide accurate and complete information during registration. You are responsible for maintaining the confidentiality of your account credentials and for all activities under your account.',
  ),
  (
    '4. Customer Responsibilities',
    'Customers must provide accurate pickup and delivery details, declare goods correctly (including fragile or hazardous materials), and be available for pickup and delivery. Misdeclaration of goods may result in account suspension.',
  ),
  (
    '5. Driver Responsibilities',
    'Drivers must hold valid commercial vehicle permits, maintain adequate insurance, handle goods with care, and complete deliveries within the agreed timeline. Drivers must comply with all applicable traffic and transport laws.',
  ),
  (
    '6. Payments',
    'Payment terms are agreed between Customer and Driver. Goods Carrier may facilitate payments via the in-app payment gateway. Platform fees may apply. All transactions are subject to applicable taxes.',
  ),
  (
    '7. Liability',
    'Goods Carrier is not liable for loss or damage to goods during transit. We recommend Customers obtain appropriate cargo insurance for high-value shipments.',
  ),
  (
    '8. Privacy',
    'Your data is processed in accordance with our Privacy Policy. By using this app, you consent to the collection and use of your information as described therein.',
  ),
  (
    '9. Dispute Resolution',
    'Any disputes shall first be resolved through our in-app dispute resolution process. Unresolved disputes shall be subject to arbitration under the laws of the Republic of India, with jurisdiction in Mumbai.',
  ),
  (
    '10. Changes to Terms',
    'We reserve the right to modify these terms at any time. Continued use of the app after changes constitutes acceptance of the revised terms.',
  ),
];

const _privacyFallback = <(String, String)>[
  (
    '1. Introduction',
    'Goods Carrier respects your privacy and is committed to protecting your personal information. This Privacy Policy explains how we collect, use, store, and share information when you use the Goods Carrier mobile application and related services. By using the application, you agree to the practices described in this Privacy Policy.',
  ),
  (
    '2. Information We Collect',
    'We may collect account information (name, email, phone, profile photo, role), business and address details, location data for pickup and delivery, Driver vehicle and document data, shipment and trip details, device and usage data, and communication or support messages.',
  ),
  (
    '3. How We Use Your Information',
    'We use your information to create and manage accounts, connect Customers with Drivers, process shipments and payments, verify Driver profiles where required, send service notifications, improve app performance and support, and comply with legal obligations.',
  ),
  (
    '4. How We Share Information',
    'We do not sell your personal information. We may share limited information with other users as needed to complete a shipment or trip, with service providers such as payment and notification partners, and with authorities when required by law.',
  ),
  (
    '5. Data Retention',
    'We retain your information for as long as your account is active and as needed to provide services, resolve disputes, enforce agreements, and meet legal requirements. You may request account deletion subject to applicable retention obligations.',
  ),
  (
    '6. Data Security',
    'We use reasonable technical and organizational measures to protect your information. However, no method of transmission or storage is completely secure, and we cannot guarantee absolute security.',
  ),
  (
    '7. Your Rights',
    'Depending on applicable law, you may request access, correction, or deletion of your personal information, or withdraw certain consents. You can manage some preferences in the app settings or contact support for assistance.',
  ),
  (
    '8. Children\'s Privacy',
    'Goods Carrier is intended for adults and business users. We do not knowingly collect personal information from children.',
  ),
  (
    '9. Changes to This Policy',
    'We may update this Privacy Policy from time to time. Continued use of the application after changes means you accept the updated policy. The latest version will be available in the app and on our platform.',
  ),
  (
    '10. Contact Us',
    'If you have questions about this Privacy Policy or your personal data, please contact Goods Carrier support through the application or the support channels published by the platform administrator.',
  ),
];

const _aboutFallback = <(String, String)>[
  (
    '1. Who We Are',
    'Good Carrier is a logistics marketplace that connects Customers who need to move goods with Drivers who have the right vehicles for the job. Our goal is simple: make goods transport across India more reliable, transparent, and easy to manage from your phone.',
  ),
  (
    '2. What We Do',
    'We help Customers post shipment requirements, discover available trips, and coordinate with transporters. Drivers can publish trips, manage vehicles, receive shipment requests, and grow their business through the platform.',
  ),
  (
    '3. For Customers',
    'Customers can create shipment requests, filter by vehicle type and capacity, compare options, and stay updated through in-app notifications. Good Carrier helps you find suitable logistics partners without calling around manually.',
  ),
  (
    '4. For Drivers',
    'Drivers can list vehicles, publish available trips, receive customer requests, and manage day-to-day operations from the app. The platform is built to support independent transporters and fleet operators alike.',
  ),
  (
    '5. Our Commitment',
    'We are committed to a safe, fair marketplace experience for both Customers and Drivers. We continuously improve the product based on real logistics workflows, clear communication, and dependable support.',
  ),
  (
    '6. Contact & Support',
    'If you need help with your account, a shipment, or a trip, please use Help & Support in the app. Our team is here to assist Customers and Drivers with onboarding, account issues, and service questions.',
  ),
];

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
