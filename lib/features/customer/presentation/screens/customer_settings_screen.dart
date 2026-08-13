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
import '../../../../core/providers/vehicle_masters_provider.dart';
import '../../../../shared/data/api/settings/settings_api_client.dart';
import '../../../../shared/domain/enums/user_role.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../providers/customer_dashboard_provider.dart';
import '../providers/customer_notifications_provider.dart';
import '../providers/customer_shipments_provider.dart';
import '../../../driver/presentation/providers/driver_shipment_requests_provider.dart';
import '../../../driver/presentation/providers/driver_trips_provider.dart';
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

  /// Role-specific settings client so drivers hit `/api/driver/settings/*`.
  SettingsApiClient get _settingsApi {
    final role = ref.read(authProvider).user?.role ?? UserRole.customer;
    return ref.read(settingsApiClientProvider(role));
  }

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
      final settings = await _settingsApi.fetchSettings();
      if (!mounted) return;
      await ref
          .read(pushNotificationsProvider.notifier)
          .setEnabled(settings.pushNotificationsEnabled);
      final locale = Locale(settings.languageCode);
      final previous = ref.read(localeProvider);
      if (supportedAppLocales.contains(locale) &&
          locale.languageCode != previous.languageCode) {
        await ref.read(localeProvider.notifier).setLocale(locale);
        _refreshLocalizedFeeds();
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

  /// Re-fetch feeds so backend-translated fields match the new Accept-Language.
  void _refreshLocalizedFeeds() {
    final role = ref.read(authProvider).user?.role ?? UserRole.customer;
    switch (role) {
      case UserRole.customer:
        ref
            .read(customerDashboardProvider.notifier)
            .refresh(showLoadingIndicator: false);
        ref.read(customerShipmentsProvider.notifier).refresh();
        ref
            .read(customerNotificationsProvider.notifier)
            .refresh(showLoadingIndicator: false);
      case UserRole.driver:
        ref.read(driverShipmentRequestsProvider.notifier).refresh();
        ref.read(driverTripsProvider.notifier).refresh();
        ref
            .read(driverNotificationsProvider.notifier)
            .refresh(showLoadingIndicator: false);
        ref.invalidate(vehicleMastersProvider);
    }
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

    if (selected == null || !context.mounted) return;

    final previous = ref.read(localeProvider);
    if (selected.languageCode == previous.languageCode) return;

    await ref.read(localeProvider.notifier).setLocale(selected);
    if (EnvConfig.useRemoteApi) {
      try {
        await _settingsApi.updateLanguage(selected.languageCode);
      } catch (_) {}
    }
    _refreshLocalizedFeeds();
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
                  await _settingsApi.updatePushNotification(v);
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
                  onTap: () => context.push(
                    AppRoutes.terms,
                    extra: LegalDocument.about,
                  ),
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
