import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/data/api/app/app_config_api_client.dart';
import '../providers/app_config_provider.dart';

String resolveAppName(AppConfigData? config, AppLocalizations l10n) {
  final remote = config?.appName?.trim();
  if (remote != null && remote.isNotEmpty) return remote;
  return l10n.appName;
}

String resolveAppTagline(AppConfigData? config, AppLocalizations l10n) {
  final remote = config?.appTagline?.trim();
  if (remote != null && remote.isNotEmpty) return remote;
  return l10n.appTagline;
}

class AppBranding {
  const AppBranding(this._config);

  final AppConfigData? _config;

  String appName(AppLocalizations l10n) => resolveAppName(_config, l10n);

  String appTagline(AppLocalizations l10n) => resolveAppTagline(_config, l10n);

  static AppBranding of(WidgetRef ref) =>
      AppBranding(ref.watch(appConfigProvider).config);
}

final appBrandingProvider = Provider<AppBranding>((ref) {
  final config = ref.watch(appConfigProvider).config;
  return AppBranding(config);
});
