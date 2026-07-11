import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/data/local/app_config_preferences_store.dart';
import '../config/runtime_api_base_url.dart';
import '../network/dio_client.dart';
import '../../shared/data/api/app/app_config_api_client.dart';
import 'repository_providers.dart';
import 'shared_preferences_provider.dart';

class AppConfigState {
  const AppConfigState({
    this.config,
    this.isLoading = false,
    this.loadFailed = false,
  });

  final AppConfigData? config;
  final bool isLoading;
  final bool loadFailed;
}

class AppConfigNotifier extends StateNotifier<AppConfigState> {
  AppConfigNotifier(this._client, this._store, this._prefs, this._dio)
      : super(const AppConfigState());

  final AppConfigApiClient _client;
  final AppConfigPreferencesStore _store;
  final SharedPreferences _prefs;
  final Dio _dio;

  Future<void> load() async {
    if (state.isLoading) return;
    final cached = _store.load();
    state = AppConfigState(config: cached, isLoading: true);
    try {
      final config = await _client.fetchConfig();
      await _store.save(config);
      await RuntimeApiBaseUrl.set(config.appUrl, prefs: _prefs);
      _dio.options.baseUrl = RuntimeApiBaseUrl.current;
      state = AppConfigState(config: config);
    } catch (_) {
      state = AppConfigState(config: cached, loadFailed: true);
    }
  }
}

final appConfigProvider =
    StateNotifierProvider<AppConfigNotifier, AppConfigState>((ref) {
  return AppConfigNotifier(
    ref.read(appConfigApiClientProvider),
    ref.read(appConfigPreferencesStoreProvider),
    ref.read(sharedPreferencesProvider),
    ref.read(dioProvider),
  );
});
