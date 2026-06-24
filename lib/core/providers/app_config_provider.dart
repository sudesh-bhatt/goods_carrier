import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/data/api/app/app_config_api_client.dart';
import 'repository_providers.dart';

class AppConfigState {
  const AppConfigState({
    this.config,
    this.isLoading = false,
  });

  final AppConfigData? config;
  final bool isLoading;
}

class AppConfigNotifier extends StateNotifier<AppConfigState> {
  AppConfigNotifier(this._client) : super(const AppConfigState());

  final AppConfigApiClient _client;

  Future<void> load() async {
    if (state.isLoading) return;
    state = const AppConfigState(isLoading: true);
    try {
      final config = await _client.fetchConfig();
      state = AppConfigState(config: config);
    } catch (_) {
      state = const AppConfigState();
    }
  }
}

final appConfigProvider =
    StateNotifierProvider<AppConfigNotifier, AppConfigState>((ref) {
  return AppConfigNotifier(ref.read(appConfigApiClientProvider));
});
