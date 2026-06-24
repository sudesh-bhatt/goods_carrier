import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/data/api/customer/customer_support_api_client.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../widgets/support/support_center_tokens.dart';
import '../widgets/support/support_channel_card.dart';
import '../widgets/support/support_faq_tile.dart';

/// Support Center — remote `GET /api/customer/support` with l10n fallback.
class SupportCenterScreen extends ConsumerStatefulWidget {
  const SupportCenterScreen({super.key});

  @override
  ConsumerState<SupportCenterScreen> createState() =>
      _SupportCenterScreenState();
}

class _SupportCenterScreenState extends ConsumerState<SupportCenterScreen>
    with SafeSetStateMixin {
  SupportCenterData? _remote;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (EnvConfig.useRemoteApi) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }
  }

  Future<void> _load() async {
    safeSetState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data =
          await ref.read(customerSupportApiClientProvider).fetchSupport();
      if (!mounted) return;
      safeSetState(() {
        _remote = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      safeSetState(() {
        _loading = false;
        _error = ApiExceptionMapper.userMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final fallbackFaqs = [
      (l10n.supportFaqTrackQuestion, l10n.supportFaqTrackAnswer),
      (l10n.supportFaqChargesQuestion, l10n.supportFaqChargesAnswer),
      (l10n.supportFaqCancelQuestion, l10n.supportFaqCancelAnswer),
      (l10n.supportFaqCustomsQuestion, l10n.supportFaqCustomsAnswer),
    ];

    final faqs = _remote?.faqs.isNotEmpty == true
        ? _remote!.faqs.map((f) => (f.question, f.answer)).toList()
        : fallbackFaqs;

    final email = _remote?.contact.email.isNotEmpty == true
        ? _remote!.contact.email
        : l10n.supportEmailDisplay;
    final phone = _remote?.contact.phone.isNotEmpty == true
        ? _remote!.contact.phone
        : l10n.supportPhoneDisplay;

    return Scaffold(
      backgroundColor: SupportCenterTokens.screenBg,
      appBar: FlowScreenAppBar(
        title: l10n.supportCenterTitle,
        fallbackRoute: AppRoutes.customerHome,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 48.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_error != null) ...[
                      Text(
                        _error!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: SupportCenterTokens.subtitle,
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                    _FaqSection(faqs: faqs),
                    SizedBox(height: 24.h),
                    _DirectChannelsSection(
                      emailTitle: l10n.supportEmailTitle,
                      emailDisplay: email,
                      callTitle: l10n.supportCallTitle,
                      phoneDisplay: phone,
                      onCopyEmail: () => _copyContact(
                        context,
                        email,
                        l10n.supportEmailCopied,
                      ),
                      onCopyPhone: () => _copyContact(
                        context,
                        phone,
                        l10n.supportPhoneCopied,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _copyContact(BuildContext context, String value, String message) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _FaqSection extends StatelessWidget {
  const _FaqSection({required this.faqs});

  final List<(String, String)> faqs;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.supportFaqSectionTitle,
          style: SupportCenterTokens.sectionTitle(),
        ),
        SizedBox(height: 32.h),
        for (var i = 0; i < faqs.length; i++) ...[
          SupportFaqTile(
            question: faqs[i].$1,
            answer: faqs[i].$2,
          ),
          if (i < faqs.length - 1) SizedBox(height: 16.h),
        ],
      ],
    );
  }
}

class _DirectChannelsSection extends StatelessWidget {
  const _DirectChannelsSection({
    required this.emailTitle,
    required this.emailDisplay,
    required this.callTitle,
    required this.phoneDisplay,
    required this.onCopyEmail,
    required this.onCopyPhone,
  });

  final String emailTitle;
  final String emailDisplay;
  final String callTitle;
  final String phoneDisplay;
  final VoidCallback onCopyEmail;
  final VoidCallback onCopyPhone;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.supportDirectChannelsTitle,
          style: SupportCenterTokens.sectionTitle(),
        ),
        SizedBox(height: 16.h),
        SupportChannelCard(
          title: emailTitle,
          subtitle: emailDisplay,
          icon: Icons.alternate_email_rounded,
          iconBackground: SupportCenterTokens.emailIconBg,
          iconColor: SupportCenterTokens.emailIconFg,
          iconSize: 18.w,
          onTap: onCopyEmail,
        ),
        SizedBox(height: 12.h),
        SupportChannelCard(
          title: callTitle,
          subtitle: phoneDisplay,
          icon: Icons.phone_outlined,
          iconBackground: SupportCenterTokens.callIconBg,
          iconColor: SupportCenterTokens.callIconFg,
          iconSize: 16.w,
          onTap: onCopyPhone,
        ),
      ],
    );
  }
}
