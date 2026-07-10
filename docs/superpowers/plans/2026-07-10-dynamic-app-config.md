# Dynamic App Config Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bootstrap the app from `GET /api/app/config`, persist config, override API base URL from `app_url`, gate splash on maintenance / platform min-version (optional or force update), and expose remote app name/tagline with l10n fallbacks.

**Architecture:** Extend the existing splash `appConfigProvider` path. Add a runtime base-URL holder initialized from SharedPreferences (else `.env`), expand `AppConfigData` to the live API shape, persist via `AppConfigPreferencesStore`, then run maintenance / update gates before auth routing. Splash logo and launcher icon stay bundled.

**Tech Stack:** Flutter, Riverpod, Dio, SharedPreferences, `package_info_plus`, `in_app_update` (Android), `url_launcher` (iOS / Play fallback), existing l10n ARB.

**Spec:** `docs/superpowers/specs/2026-07-10-dynamic-app-config-design.md`

## Global Constraints

- First install always bootstraps API base URL from `.env` / `EnvConfig.apiBaseUrl`.
- Relative media paths (`/storage/...`) are stored as returned; resolve with **effective** base URL when used (same idea as `ProfileImageUtils.resolveNetworkUrl`).
- Do **not** download or change launcher/splash icons this pass.
- Version check is **platform-specific only** (Android ↔ `minimum_android_version`, iOS ↔ `minimum_ios_version`).
- `force_update` missing → `false` (Later allowed). `force_update: true` → no skip.
- `maintenance_mode: true` → hard-block maintenance screen.
- API failure / null fields → keep last prefs or current defaults; never crash splash.
- Prefer smallest diffs; follow existing store/provider patterns (`AuthPreferencesStore`, `appConfigProvider`).
- Use `safeSetState` instead of `setState` where local widget state is updated.
- App bar on new screens: `FlowScreenAppBar` from `lib/shared/presentation/widgets/navigation/app_bar_widget.dart`.

## File map

| File | Responsibility |
|------|----------------|
| `lib/core/config/runtime_api_base_url.dart` | Mutable effective API base URL |
| `lib/core/network/api_constants.dart` | `baseUrl` reads runtime holder |
| `lib/core/utils/profile_image_utils.dart` | Resolve relative URLs via effective base |
| `lib/core/utils/app_version_utils.dart` | Dotted version compare |
| `lib/shared/data/api/app/app_config_api_client.dart` | Live API model + parse |
| `lib/shared/data/local/app_config_preferences_store.dart` | Persist/load config JSON |
| `lib/core/providers/app_config_provider.dart` | Load → save → apply base URL |
| `lib/core/providers/repository_providers.dart` | Prefs store provider if needed |
| `lib/main.dart` | Init runtime base URL from prefs before `runApp` |
| `lib/core/network/dio_client.dart` | Ensure Dio uses `ApiConstants.baseUrl`; allow refresh after config |
| `lib/core/branding/app_branding.dart` | Remote-or-l10n name/tagline |
| `lib/features/auth/presentation/screens/splash_screen.dart` | Gates after config |
| `lib/features/auth/presentation/screens/maintenance_screen.dart` | Hard-block UI |
| `lib/core/services/app_update_service.dart` | In-app update / store open |
| `lib/core/router/app_routes.dart` + `app_router.dart` | Maintenance route + redirect guard |
| `lib/l10n/app_en.arb` (+ hi/gu) | Maintenance + update copy |
| `pubspec.yaml` / `.env.example` | `package_info_plus`, `in_app_update`, optional iOS store URL |
| `test/core/utils/app_version_utils_test.dart` | Version compare |
| `test/shared/data/api/app/app_config_data_test.dart` | Parsing |
| `test/shared/data/local/app_config_preferences_store_test.dart` | Prefs round-trip |

---

### Task 1: Runtime API base URL

**Files:**
- Create: `lib/core/config/runtime_api_base_url.dart`
- Modify: `lib/core/network/api_constants.dart`
- Modify: `lib/core/utils/profile_image_utils.dart`
- Modify: `lib/main.dart`
- Test: `test/core/config/runtime_api_base_url_test.dart`

**Interfaces:**
- Produces: `RuntimeApiBaseUrl.current` (`String`), `RuntimeApiBaseUrl.initFromPrefs(SharedPreferences)`, `RuntimeApiBaseUrl.set(String?)`, `RuntimeApiBaseUrl.normalize(String)`
- Consumes: `EnvConfig.apiBaseUrl`, SharedPreferences key `app_config_v1` only for reading nested `app_url` **or** a dedicated key `api_base_url_v1` written by the prefs store in Task 3 — prefer reading via a thin helper that Task 3 will own; for Task 1 use dedicated key `runtime_api_base_url_v1` set only when config applies, and `initFromPrefs` reads that key else `EnvConfig`.

- [ ] **Step 1: Write the failing test**

```dart
// test/core/config/runtime_api_base_url_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:goods_carrier/core/config/runtime_api_base_url.dart';

void main() {
  setUp(() {
    RuntimeApiBaseUrl.resetForTest(EnvConfigFallback: 'https://bootstrap.example');
  });

  test('normalize strips trailing slashes', () {
    expect(
      RuntimeApiBaseUrl.normalize('https://a.example/'),
      'https://a.example',
    );
  });

  test('set updates current; null/empty ignored', () {
    RuntimeApiBaseUrl.set('https://api.example/');
    expect(RuntimeApiBaseUrl.current, 'https://api.example');
    RuntimeApiBaseUrl.set('  ');
    expect(RuntimeApiBaseUrl.current, 'https://api.example');
  });
}
```

Note: implement `resetForTest` only for tests (or `@visibleForTesting`). If importing `EnvConfig` in tests is awkward without dotenv, pass bootstrap URL into `resetForTest`.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/config/runtime_api_base_url_test.dart`

Expected: FAIL (library/file not found)

- [ ] **Step 3: Implement runtime holder + wire ApiConstants / ProfileImageUtils / main**

```dart
// lib/core/config/runtime_api_base_url.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'env_config.dart';

abstract final class RuntimeApiBaseUrl {
  static const prefsKey = 'runtime_api_base_url_v1';

  static String _current = '';

  static String get current {
    if (_current.isNotEmpty) return _current;
    return EnvConfig.apiBaseUrl;
  }

  static String normalize(String raw) =>
      raw.trim().replaceAll(RegExp(r'/+$'), '');

  static void initFromPrefs(SharedPreferences prefs) {
    final saved = prefs.getString(prefsKey)?.trim();
    if (saved != null && saved.isNotEmpty) {
      _current = normalize(saved);
    } else {
      _current = EnvConfig.apiBaseUrl;
    }
  }

  static Future<void> set(String? url, {SharedPreferences? prefs}) async {
    final trimmed = url?.trim() ?? '';
    if (trimmed.isEmpty) return;
    _current = normalize(trimmed);
    if (prefs != null) {
      await prefs.setString(prefsKey, _current);
    }
  }

  @visibleForTesting
  static void resetForTest({required String bootstrap}) {
    _current = normalize(bootstrap);
  }
}
```

```dart
// api_constants.dart — change baseUrl getter only:
static String get baseUrl => RuntimeApiBaseUrl.current;
```

```dart
// profile_image_utils.dart — in resolveNetworkUrl:
return '${RuntimeApiBaseUrl.current}$trimmed';
```

```dart
// main.dart — after prefs load, before runApp:
RuntimeApiBaseUrl.initFromPrefs(prefs);
```

Also update Dio creation: it already uses `ApiConstants.baseUrl` at construction time — after `RuntimeApiBaseUrl.set`, update the live Dio instance:

```dart
// In AppConfigNotifier after set — Task 4 will call:
ref.read(dioProvider).options.baseUrl = RuntimeApiBaseUrl.current;
```

Document that Task 4 must refresh Dio `options.baseUrl` after apply.

- [ ] **Step 4: Run tests**

Run: `flutter test test/core/config/runtime_api_base_url_test.dart`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/config/runtime_api_base_url.dart \
  lib/core/network/api_constants.dart \
  lib/core/utils/profile_image_utils.dart \
  lib/main.dart \
  test/core/config/runtime_api_base_url_test.dart
git commit -m "$(cat <<'EOF'
Add runtime API base URL holder bootstrapped from prefs.

EOF
)"
```

---

### Task 2: AppConfigData model + API parse

**Files:**
- Modify: `lib/shared/data/api/app/app_config_api_client.dart`
- Test: `test/shared/data/api/app/app_config_data_test.dart`

**Interfaces:**
- Produces: `AppConfigData` with fields below; `AppConfigData.fromJson(Map<String, dynamic>)`; `Map<String, dynamic> toJson()`; `AppConfigApiClient.fetchConfig()` returns new shape
- Consumes: `ApiEnvelope.parseData`

```dart
class AppConfigLanguage {
  const AppConfigLanguage({required this.code, required this.name});
  final String code;
  final String name;
  Map<String, dynamic> toJson() => {'code': code, 'name': name};
  factory AppConfigLanguage.fromJson(Map<String, dynamic> json) =>
      AppConfigLanguage(
        code: json['code']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
      );
}

class AppConfigData {
  const AppConfigData({
    this.appName,
    this.appTagline,
    this.logoUrl,
    this.supportedLanguages = const [],
    this.defaultLanguage,
    this.minimumAndroidVersion,
    this.minimumIosVersion,
    this.forceUpdate = false,
    this.maintenanceMode = false,
    this.appUrl,
    this.appIcon,
    this.appIconUrl,
  });

  final String? appName;
  final String? appTagline;
  final String? logoUrl;
  final List<AppConfigLanguage> supportedLanguages;
  final String? defaultLanguage;
  final String? minimumAndroidVersion;
  final String? minimumIosVersion;
  final bool forceUpdate;
  final bool maintenanceMode;
  final String? appUrl;
  final String? appIcon;
  final String? appIconUrl;

  factory AppConfigData.fromJson(Map<String, dynamic> data) { /* map keys */ }
  Map<String, dynamic> toJson() { /* inverse */ }
}
```

Parse keys exactly: `app_name`, `app_tagline`, `logo_url`, `supported_languages`, `default_language`, `minimum_android_version`, `minimum_ios_version`, `force_update` (default false), `maintenance_mode` (default false), `app_url`, `app_icon`, `app_icon_url`.

Remove obsolete fields: `minAppVersion`, `termsUrl`, `privacyUrl`.

- [ ] **Step 1: Write failing parse tests**

```dart
test('parses live payload and defaults force_update', () {
  final data = AppConfigData.fromJson({
    'app_name': 'Goods Carrier',
    'app_tagline': 'Your logistics partner',
    'logo_url': null,
    'supported_languages': [
      {'code': 'en', 'name': 'English'},
    ],
    'default_language': 'en',
    'minimum_android_version': null,
    'minimum_ios_version': '1.2.0',
    'maintenance_mode': true,
    'app_url': 'https://goodscarrier.ajonetech.com',
    'app_icon': 'app_settings/x.png',
    'app_icon_url': '/storage/app_settings/x.png',
  });
  expect(data.appName, 'Goods Carrier');
  expect(data.forceUpdate, isFalse);
  expect(data.maintenanceMode, isTrue);
  expect(data.appIconUrl, '/storage/app_settings/x.png');
  expect(data.supportedLanguages.single.code, 'en');
});
```

- [ ] **Step 2: Run test — expect FAIL**

Run: `flutter test test/shared/data/api/app/app_config_data_test.dart`

- [ ] **Step 3: Implement model + update `fetchConfig` to use `fromJson`**

- [ ] **Step 4: Run test — expect PASS**

- [ ] **Step 5: Commit**

```bash
git add lib/shared/data/api/app/app_config_api_client.dart \
  test/shared/data/api/app/app_config_data_test.dart
git commit -m "$(cat <<'EOF'
Expand AppConfigData to match live /api/app/config payload.

EOF
)"
```

---

### Task 3: AppConfigPreferencesStore

**Files:**
- Create: `lib/shared/data/local/app_config_preferences_store.dart`
- Modify: `lib/core/providers/repository_providers.dart` (or `app_config_provider.dart`) to expose store provider
- Test: `test/shared/data/local/app_config_preferences_store_test.dart`

**Interfaces:**
- Produces: `AppConfigPreferencesStore.load() → AppConfigData?`, `save(AppConfigData)`, `clear()`
- Prefs key: `app_config_json_v1` (full `toJson` string)
- Also on `save`: if `appUrl` non-null, call `RuntimeApiBaseUrl.set(appUrl, prefs: _prefs)` **or** leave apply to notifier — prefer notifier owns apply; store only persists JSON.

- [ ] **Step 1: Failing round-trip test** with `SharedPreferences.setMockInitialValues({})`

- [ ] **Step 2: Run — FAIL**

- [ ] **Step 3: Implement store mirroring `AuthPreferencesStore` style**

```dart
class AppConfigPreferencesStore {
  AppConfigPreferencesStore(this._prefs);
  static const _kConfigKey = 'app_config_json_v1';
  final SharedPreferences _prefs;

  AppConfigData? load() { /* decode or null */ }

  Future<void> save(AppConfigData config) async {
    await _prefs.setString(_kConfigKey, jsonEncode(config.toJson()));
  }
}
```

- [ ] **Step 4: Run — PASS**

- [ ] **Step 5: Commit**

```bash
git add lib/shared/data/local/app_config_preferences_store.dart \
  lib/core/providers/repository_providers.dart \
  test/shared/data/local/app_config_preferences_store_test.dart
git commit -m "$(cat <<'EOF'
Persist app config JSON in SharedPreferences.

EOF
)"
```

---

### Task 4: AppConfigNotifier — load, persist, apply base URL

**Files:**
- Modify: `lib/core/providers/app_config_provider.dart`
- Modify: `lib/core/providers/repository_providers.dart` if store provider lives there

**Interfaces:**
- Consumes: `AppConfigApiClient`, `AppConfigPreferencesStore`, `RuntimeApiBaseUrl`, `dioProvider`
- Produces: `AppConfigState { config, isLoading, loadFailed }`; `load()` merges: start from `store.load()` as seed; on remote success `store.save` + `RuntimeApiBaseUrl.set` + `dio.options.baseUrl = RuntimeApiBaseUrl.current`; on failure keep seed / empty without clearing prefs

```dart
Future<void> load() async {
  if (state.isLoading) return;
  final cached = _store.load();
  state = AppConfigState(config: cached, isLoading: true);
  try {
    final remote = await _client.fetchConfig();
    await _store.save(remote);
    await RuntimeApiBaseUrl.set(remote.appUrl, prefs: _prefs);
    _dio.options.baseUrl = RuntimeApiBaseUrl.current;
    state = AppConfigState(config: remote);
  } catch (_) {
    state = AppConfigState(config: cached, loadFailed: true);
  }
}
```

Wire constructor with store + dio + prefs via providers.

- [ ] **Step 1: Manually verify compile** — `dart analyze lib/core/providers/app_config_provider.dart` (no dedicated widget test required if analyze clean; optional unit test with fake client)

- [ ] **Step 2: Optional fake-client unit test** asserting save + base URL apply on success and prefs retained on failure

- [ ] **Step 3: Implement notifier changes**

- [ ] **Step 4: `dart analyze` on touched files — no issues**

- [ ] **Step 5: Commit**

```bash
git commit -m "$(cat <<'EOF'
Wire app config load to persist and apply API base URL.

EOF
)"
```

---

### Task 5: Version compare utility

**Files:**
- Create: `lib/core/utils/app_version_utils.dart`
- Test: `test/core/utils/app_version_utils_test.dart`

**Interfaces:**
- Produces: `AppVersionUtils.isBelowMinimum({required String installed, required String? minimum}) → bool`
- Rules: null/empty minimum → `false` (not below). Compare dotted numeric segments left-to-right (`1.2.0` vs `1.10.0`). Non-numeric junk stripped per segment; missing segment = 0.

- [ ] **Step 1: Write tests**

```dart
expect(AppVersionUtils.isBelowMinimum(installed: '1.0.0', minimum: null), false);
expect(AppVersionUtils.isBelowMinimum(installed: '1.0.0', minimum: '1.0.0'), false);
expect(AppVersionUtils.isBelowMinimum(installed: '1.0.0', minimum: '1.0.1'), true);
expect(AppVersionUtils.isBelowMinimum(installed: '1.10.0', minimum: '1.2.0'), false);
expect(AppVersionUtils.isBelowMinimum(installed: '1.2.0', minimum: '1.10.0'), true);
```

- [ ] **Step 2: Run — FAIL**

- [ ] **Step 3: Implement**

- [ ] **Step 4: Run — PASS**

- [ ] **Step 5: Commit**

```bash
git commit -m "$(cat <<'EOF'
Add dotted app version comparison helper.

EOF
)"
```

---

### Task 6: Branding helper

**Files:**
- Create: `lib/core/branding/app_branding.dart`
- Modify: `lib/core/extensions/theme_ext.dart` (optional convenience on `BuildContext`)

**Interfaces:**
- Produces: `AppBranding.of(WidgetRef/BuildContext)` or provider `appBrandingProvider` returning `{String appName(AppLocalizations l10n), String appTagline(...)}` reading `appConfigProvider.state.config`

```dart
String resolveAppName(AppConfigData? config, AppLocalizations l10n) {
  final remote = config?.appName?.trim();
  if (remote != null && remote.isNotEmpty) return remote;
  return l10n.appName;
}
```

Same for tagline. Add `context.appName(ref)` only if it fits existing extension style; otherwise a top-level function + Riverpod read at call sites is enough.

There are currently **no UI call sites** using `l10n.appName` / `appTagline` outside generated l10n — still ship the helper so future/current screens can use it. If any screen should show branding soon (e.g. login header), wire one obvious call site if it already displays a hard-coded product name; otherwise helper-only is OK for this task.

- [ ] **Step 1: Unit test resolve helpers**

- [ ] **Step 2: Implement**

- [ ] **Step 3: Commit**

```bash
git commit -m "$(cat <<'EOF'
Add app branding resolver with remote-or-l10n fallback.

EOF
)"
```

---

### Task 7: Dependencies + AppUpdateService

**Files:**
- Modify: `pubspec.yaml` — add `package_info_plus`, `in_app_update`
- Modify: `.env.example` — add `IOS_APP_STORE_URL=` (full App Store URL when known)
- Modify: `lib/core/config/env_config.dart` — `iosAppStoreUrl` getter
- Create: `lib/core/services/app_update_service.dart`

**Interfaces:**
- Produces: `AppUpdateService.promptUpdate()` → Android tries `InAppUpdate.checkForUpdate` / `performImmediateUpdate` when immediate allowed; on failure open Play Store `https://play.google.com/store/apps/details?id=${packageName}`; iOS opens `EnvConfig.iosAppStoreUrl` if non-empty else no-op with debug log
- Consumes: `package_info_plus`, `url_launcher`, `in_app_update`, `dart:io` Platform

- [ ] **Step 1: Add deps**

```bash
flutter pub add package_info_plus in_app_update
```

(`url_launcher` already present)

- [ ] **Step 2: Implement `AppUpdateService`**

```dart
class AppUpdateService {
  Future<void> startUpdate() async {
    if (Platform.isAndroid) {
      try {
        final info = await InAppUpdate.checkForUpdate();
        if (info.updateAvailability == UpdateAvailability.updateAvailable) {
          await InAppUpdate.performImmediateUpdate();
          return;
        }
      } catch (_) {/* fall through */}
      final packageInfo = await PackageInfo.fromPlatform();
      final uri = Uri.parse(
        'https://play.google.com/store/apps/details?id=${packageInfo.packageName}',
      );
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (Platform.isIOS) {
      final url = EnvConfig.iosAppStoreUrl;
      if (url.isEmpty) return;
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}
```

- [ ] **Step 3: `flutter pub get` + analyze service file**

- [ ] **Step 4: Commit**

```bash
git commit -m "$(cat <<'EOF'
Add in-app update service with store fallbacks.

EOF
)"
```

---

### Task 8: Maintenance screen + routes

**Files:**
- Create: `lib/features/auth/presentation/screens/maintenance_screen.dart`
- Modify: `lib/core/router/app_routes.dart` — `static const maintenance = '/maintenance';`
- Modify: `lib/core/router/app_router.dart` — register route; in `redirect`, if config `maintenanceMode` and loc != maintenance && loc != splash → `AppRoutes.maintenance`; allow staying on maintenance
- Modify: `lib/l10n/app_en.arb`, `app_hi.arb`, `app_gu.arb` — strings below
- Run: `flutter gen-l10n` (or project’s usual l10n generation)

**Copy (EN):**
- `maintenanceTitle`: `Under maintenance`
- `maintenanceBody`: `We're performing scheduled maintenance. Please try again later.`
- `updateAvailableTitle`: `Update available`
- `updateAvailableBody`: `A new update is available. Please update the app.`
- `updateActionUpdate`: `Update`
- `updateActionLater`: `Later`

**Maintenance UI:** `Scaffold` + `FlowScreenAppBar(title: ..., showBack: false)` + centered message. No navigation actions that escape the gate (router redirect enforces).

- [ ] **Step 1: Add ARB keys + gen-l10n**

- [ ] **Step 2: Implement screen + routes + redirect**

Redirect must read persisted/config state carefully — prefer `ref.read(appConfigProvider).config?.maintenanceMode == true` inside redirect via `ref` from `GoRouter` refreshListenable / `Provider` pattern already used in `app_router.dart`. If redirect cannot easily read Riverpod, splash-only navigation to maintenance is acceptable **and** redirect blocks leaving maintenance while flag true.

- [ ] **Step 3: Hot smoke — navigate to `/maintenance` in debug**

- [ ] **Step 4: Commit**

```bash
git commit -m "$(cat <<'EOF'
Add maintenance screen and route guard.

EOF
)"
```

---

### Task 9: Splash gates (maintenance + update)

**Files:**
- Modify: `lib/features/auth/presentation/screens/splash_screen.dart`
- Possibly create: `lib/features/auth/presentation/widgets/app_update_dialog.dart`

**Flow (replace/extend current microtask):**

```dart
Future.microtask(() async {
  if (EnvConfig.useRemoteApi) {
    await ref.read(appConfigProvider.notifier).load();
  } else {
    // still hydrate from prefs if present
    // optional: notifier.hydrateFromPrefsOnly()
  }

  final config = ref.read(appConfigProvider).config;

  if (config?.maintenanceMode == true) {
    if (!mounted) return;
    context.go(AppRoutes.maintenance);
    return;
  }

  final needsUpdate = await _isBelowPlatformMinimum(config);
  if (needsUpdate) {
    final force = config?.forceUpdate ?? false;
    final proceed = await _showUpdateDialog(force: force);
    if (!proceed) {
      // force path: dialog only has Update; startUpdate and stay
      return;
    }
    // Later → fall through
  }

  await ref.read(authProvider.notifier).restoreSession();
  Future.delayed(_kNavigateDelay, _navigateNext);
});
```

`_isBelowPlatformMinimum`:
- `PackageInfo.fromPlatform()` → `version`
- if `Platform.isAndroid` use `config?.minimumAndroidVersion`
- if `Platform.isIOS` use `config?.minimumIosVersion`
- else false
- `AppVersionUtils.isBelowMinimum(...)`

Update dialog:
- barrierDismissible: `!force`
- actions: Update always; Later only if `!force`
- Update calls `AppUpdateService().startUpdate()`
- For force: after Update, do not call `_navigateNext` (user must update). Optionally re-show dialog if they return without updating.
- For optional Later: return `true` to continue.

Keep splash **logo** as `Assets.splashScreenLogo` unchanged.

Use `safeSetState` if any local flags are set.

- [ ] **Step 1: Implement helpers + dialog + splash wiring**

- [ ] **Step 2: `dart analyze` on splash + dialog**

- [ ] **Step 3: Manual checklist** (device/simulator):
  1. Normal config → login/home as today
  2. Mock/prefs `maintenance_mode: true` → maintenance screen
  3. Set min version above installed, `force_update: false` → Later works
  4. Same with `force_update: true` → no Later

- [ ] **Step 4: Commit**

```bash
git commit -m "$(cat <<'EOF'
Gate splash on maintenance mode and platform min version.

EOF
)"
```

---

### Task 10: Final verification + docs touch-up

**Files:**
- Modify (optional): `docs/API_INTEGRATION_STATUS.md` — note expanded config usage
- Do not change splash asset or launcher icon pipeline

- [ ] **Step 1: Run unit tests**

```bash
flutter test test/core/config/runtime_api_base_url_test.dart \
  test/shared/data/api/app/app_config_data_test.dart \
  test/shared/data/local/app_config_preferences_store_test.dart \
  test/core/utils/app_version_utils_test.dart
```

Expected: all PASS

- [ ] **Step 2: Run** `flutter analyze` on changed paths — no new errors

- [ ] **Step 3: Manual verification against spec checklist** (fresh install base URL, prefs persist, API fail soft, branding fallback, platform-specific version)

- [ ] **Step 4: Commit any doc/status fixes**

```bash
git commit -m "$(cat <<'EOF'
Verify dynamic app config integration and update status notes.

EOF
)"
```

---

## Spec coverage (self-review)

| Spec requirement | Task |
|------------------|------|
| Expand model to live API | 2 |
| Persist prefs | 3 |
| Bootstrap `.env` first install; override `app_url` | 1, 4, main |
| Relative URL resolve via effective base | 1 (`ProfileImageUtils`) |
| Skip launcher/splash icon change | Global + Task 9 |
| Maintenance hard block | 8, 9 |
| Platform-specific min version | 5, 9 |
| Optional vs `force_update` | 9 |
| In-app update + store | 7 |
| Branding remote-or-l10n | 6 |
| API fail / null fallbacks | 4, 6, 9 |
| Store languages / icon fields for future | 2, 3 |

No intentional placeholders left in task steps.
