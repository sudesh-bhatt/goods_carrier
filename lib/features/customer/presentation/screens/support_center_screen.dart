import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../widgets/support/support_center_tokens.dart';
import '../widgets/support/support_channel_card.dart';
import '../widgets/support/support_faq_tile.dart';

/// Support Center — [Figma](https://www.figma.com/design/YxnNResvDQnbkcPhGejtxa/Mobile-App-UI--Developer-?node-id=1-3571).
class SupportCenterScreen extends ConsumerWidget {
  const SupportCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    final faqs = [
      (l10n.supportFaqTrackQuestion, l10n.supportFaqTrackAnswer),
      (l10n.supportFaqChargesQuestion, l10n.supportFaqChargesAnswer),
      (l10n.supportFaqCancelQuestion, l10n.supportFaqCancelAnswer),
      (l10n.supportFaqCustomsQuestion, l10n.supportFaqCustomsAnswer),
    ];

    return Scaffold(
      backgroundColor: SupportCenterTokens.screenBg,
      appBar: FlowScreenAppBar(
        title: l10n.supportCenterTitle,
        fallbackRoute: AppRoutes.customerHome,
      ),
      body: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1,
        child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 48.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FaqSection(faqs: faqs),
            SizedBox(height: 24.h),
            _DirectChannelsSection(
              emailTitle: l10n.supportEmailTitle,
              emailDisplay: l10n.supportEmailDisplay,
              callTitle: l10n.supportCallTitle,
              phoneDisplay: l10n.supportPhoneDisplay,
              onCopyEmail: () => _copyContact(
                context,
                l10n.supportEmailDisplay,
                l10n.supportEmailCopied,
              ),
              onCopyPhone: () => _copyContact(
                context,
                l10n.supportPhoneDisplay,
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

/// FAQ block — 32px title gap, 16px between items.
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

/// Direct Channels — compact cards, 16px heading gap, 12px between cards.
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
