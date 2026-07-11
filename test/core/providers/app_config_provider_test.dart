import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goods_carrier/core/config/runtime_api_base_url.dart';
import 'package:goods_carrier/core/providers/app_config_provider.dart';
import 'package:goods_carrier/shared/data/api/app/app_config_api_client.dart';
import 'package:goods_carrier/shared/data/local/app_config_preferences_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    RuntimeApiBaseUrl.resetForTest(bootstrap: 'https://bootstrap.example');
  });

  test('load seeds cached config then saves remote config and applies base URL',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = AppConfigPreferencesStore(prefs);
    const cached = AppConfigData(appUrl: 'https://cached.example');
    const remote = AppConfigData(appUrl: 'https://remote.example/api/');
    await store.save(cached);

    final remoteFetch = Completer<AppConfigData>();
    final dio = Dio(BaseOptions(baseUrl: RuntimeApiBaseUrl.current));
    final notifier = AppConfigNotifier(
      _FakeAppConfigApiClient(() => remoteFetch.future),
      store,
      prefs,
      dio,
    );

    final loadFuture = notifier.load();

    expect(notifier.state.config?.appUrl, cached.appUrl);
    expect(notifier.state.isLoading, isTrue);
    expect(notifier.state.loadFailed, isFalse);

    remoteFetch.complete(remote);
    await loadFuture;

    expect(store.load()?.appUrl, remote.appUrl);
    expect(RuntimeApiBaseUrl.current, 'https://remote.example/api');
    expect(dio.options.baseUrl, RuntimeApiBaseUrl.current);
    expect(notifier.state.config?.appUrl, remote.appUrl);
    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.loadFailed, isFalse);
  });

  test('load keeps cached config and prefs when remote fetch fails', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = AppConfigPreferencesStore(prefs);
    const cached = AppConfigData(appUrl: 'https://cached.example');
    await store.save(cached);

    final dio = Dio(BaseOptions(baseUrl: RuntimeApiBaseUrl.current));
    final notifier = AppConfigNotifier(
      _FakeAppConfigApiClient(() => Future.error(StateError('offline'))),
      store,
      prefs,
      dio,
    );

    await notifier.load();

    expect(store.load()?.appUrl, cached.appUrl);
    expect(notifier.state.config?.appUrl, cached.appUrl);
    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.loadFailed, isTrue);
  });
}

class _FakeAppConfigApiClient implements AppConfigApiClient {
  _FakeAppConfigApiClient(this._fetchConfig);

  final Future<AppConfigData> Function() _fetchConfig;

  @override
  Future<AppConfigData> fetchConfig() => _fetchConfig();
}
