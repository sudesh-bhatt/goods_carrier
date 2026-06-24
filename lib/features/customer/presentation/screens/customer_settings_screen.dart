import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/presentation/providers/locale_provider.dart';
import '../../../settings/presentation/providers/push_notifications_provider.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../widgets/settings/customer_settings_tokens.dart';
import '../widgets/settings/customer_settings_widgets.dart';
import '../../../../shared/presentation/widgets/sheets/app_picker_bottom_sheet.dart';
import '../../../auth/presentation/screens/terms_screen.dart';

/// Customer settings — [Figma](https://www.figma.com/design/YxnNResvDQnbkcPhGejtxa/Mobile-App-UI--Developer-?node-id=1-3296).
class CustomerSettingsScreen extends ConsumerStatefulWidget {
  const CustomerSettingsScreen({super.key});

  @override
  ConsumerState<CustomerSettingsScreen> createState() =>
      _CustomerSettingsScreenState();
}

class _CustomerSettingsScreenState extends ConsumerState<CustomerSettingsScreen>
    with SafeSetStateMixin {
  var _syncingRemote = false;

  @override
  void initState() {
    super.initState();
    if (EnvConfig.useRemoteApi) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncFromRemote());
    }
  }

  Future<void> _syncFromRemote() async {
    safeSetState(() => _syncingRemote = true);
    try {
      final settings =
          await ref.read(customerSettingsApiClientProvider).fetchSettings();
      if (!mounted) return;
      await ref
          .read(pushNotificationsProvider.notifier)
          .setEnabled(settings.pushNotificationsEnabled);
      final locale = Locale(settings.languageCode);
      if (supportedAppLocales.contains(locale)) {
        await ref.read(localeProvider.notifier).setLocale(locale);
      }
    } catch (_) {
    } finally {
      if (mounted) safeSetState(() => _syncingRemote = false);
    }
  }

  String _languageLabel(Locale locale, AppLocalizations l10n) {
    return switch (locale.languageCode) {
      'hi' => l10n.settingsLanguageHindi,
      'gu' => l10n.settingsLanguageGujarati,
      _ => l10n.settingsLanguageEnglish,
    };
  }

  Future<void> _pickLanguage(BuildContext context) async {
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
      if (EnvConfig.useRemoteApi) {
        try {
          await ref
              .read(customerSettingsApiClientProvider)
              .updateLanguage(selected.languageCode);
        } catch (_) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pushEnabled = ref.watch(pushNotificationsProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: CustomerSettingsTokens.screenBg,
      appBar: FlowScreenAppBar(
        title: l10n.settingsTitle,
        fallbackRoute: AppRoutes.customerHome,
      ),
      body: _syncingRemote
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
              onChanged: (v) async {
                await ref.read(pushNotificationsProvider.notifier).setEnabled(v);
                if (!EnvConfig.useRemoteApi) return;
                try {
                  await ref
                      .read(customerSettingsApiClientProvider)
                      .updatePushNotification(v);
                } catch (_) {}
              },
            ),
            SizedBox(height: 48.h),
            SettingsSectionHeader(
              label: l10n.customerSettingsLanguageSection,
            ),
            SizedBox(height: 24.h),
            SettingsLanguageCard(
              title: l10n.customerSettingsChooseLanguage,
              languageLabel: _languageLabel(locale, l10n),
              onTap: () => _pickLanguage(context),
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
