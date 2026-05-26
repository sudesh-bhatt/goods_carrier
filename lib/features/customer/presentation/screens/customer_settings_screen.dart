import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/presentation/providers/locale_provider.dart';
import '../../../settings/presentation/providers/push_notifications_provider.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../widgets/settings/customer_settings_tokens.dart';
import '../widgets/settings/customer_settings_widgets.dart';
import '../../../../shared/presentation/widgets/sheets/app_picker_bottom_sheet.dart';
import '../../../auth/presentation/screens/terms_screen.dart';

/// Customer settings — [Figma](https://www.figma.com/design/YxnNResvDQnbkcPhGejtxa/Mobile-App-UI--Developer-?node-id=1-3296).
class CustomerSettingsScreen extends ConsumerWidget {
  const CustomerSettingsScreen({super.key});

  String _languageLabel(Locale locale, AppLocalizations l10n) {
    return switch (locale.languageCode) {
      'hi' => l10n.settingsLanguageHindi,
      'gu' => l10n.settingsLanguageGujarati,
      _ => l10n.settingsLanguageEnglish,
    };
  }

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;

    final selected = await AppPickerBottomSheet.show<Locale>(
      context: context,
      title: l10n.customerSettingsChooseLanguage,
      items: [
        AppPickerItem(
          value: const Locale('en'),
          label: l10n.settingsLanguageEnglish,
        ),
        AppPickerItem(
          value: const Locale('hi'),
          label: l10n.settingsLanguageHindi,
        ),
        AppPickerItem(
          value: const Locale('gu'),
          label: l10n.settingsLanguageGujarati,
        ),
      ],
    );

    if (selected != null && context.mounted) {
      await ref.read(localeProvider.notifier).setLocale(selected);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final pushEnabled = ref.watch(pushNotificationsProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: CustomerSettingsTokens.screenBg,
      appBar: FlowScreenAppBar(
        title: l10n.settingsTitle,
        fallbackRoute: AppRoutes.customerHome,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 48.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsSectionHeader(
              label: l10n.customerSettingsNotificationsSection,
            ),
            SizedBox(height: 24.h),
            SettingsToggleCard(
              icon: Icons.notifications_none_outlined,
              title: l10n.customerSettingsPushNotifications,
              subtitle: l10n.customerSettingsPushNotificationsSub,
              value: pushEnabled,
              onChanged: (v) =>
                  ref.read(pushNotificationsProvider.notifier).setEnabled(v),
            ),
            SizedBox(height: 48.h),
            SettingsSectionHeader(
              label: l10n.customerSettingsLanguageSection,
            ),
            SizedBox(height: 24.h),
            SettingsLanguageCard(
              title: l10n.customerSettingsChooseLanguage,
              languageLabel: _languageLabel(locale, l10n),
              onTap: () => _pickLanguage(context, ref),
            ),
            SizedBox(height: 48.h),
            SettingsSectionHeader(label: l10n.customerSettingsLegalSection),
            SizedBox(height: 24.h),
            SettingsLegalCard(
              items: [
                SettingsLegalRow(
                  label: l10n.authPrivacyPolicy,
                  onTap: () => context.push(
                    AppRoutes.terms,
                    extra: LegalDocument.privacy,
                  ),
                ),
                SettingsLegalRow(
                  label: l10n.authTermsLink,
                  onTap: () => context.push(
                    AppRoutes.terms,
                    extra: LegalDocument.terms,
                  ),
                ),
                SettingsLegalRow(
                  label: l10n.customerSettingsAboutApp,
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Good Carrier',
                      applicationVersion: '4.2.0',
                      applicationIcon: Icon(
                        Icons.local_shipping_rounded,
                        size: 48.w,
                        color: CustomerSettingsTokens.primaryOrange,
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 48.h),
            SettingsVersionFooter(label: l10n.customerSettingsVersionFooter),
          ],
        ),
      ),
    );
  }
}
