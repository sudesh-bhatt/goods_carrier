# Dynamic App Config Design

**Date:** 2026-07-10  
**Status:** Approved for implementation planning  
**API:** `GET /api/app/config` (public, no auth)

## Goal

Make app branding, API base URL, maintenance, and minimum-version behavior configurable from the backend. Persist config locally. On API failure or null fields, keep current defaults so the app continues to work as it does today.

## Current state

- Splash already calls `GET /api/app/config` via `appConfigProvider` when `USE_REMOTE_API` is true.
- `AppConfigData` only maps stale fields (`min_app_version`, `maintenance_mode`, `terms_url`, `privacy_url`) and does **not** match the live response.
- Config is **not** persisted.
- API base URL comes only from `EnvConfig` / `.env`.
- App name / tagline live in l10n ARB files; splash logo is a bundled asset.
- Launcher icon is build-time via `flutter_launcher_icons` (`assets/images/app_icon.png`).

## Decisions (locked)

| Topic | Decision |
|-------|----------|
| Approach | Extend existing splash config path (Approach 1) |
| `app_url` | Override Dio/API base URL after successful fetch; persist for next cold start |
| First install bootstrap | Always from `.env` / compile-time default |
| Launcher / splash icon | **Skip** dynamic icon download; splash keeps bundled logo |
| Relative media paths | Store as returned; when used, prepend effective base URL (same pattern as `ProfileImageUtils.resolveNetworkUrl`) |
| Maintenance | Hard block → dedicated maintenance screen |
| Version gate | Platform-specific only (Android ↔ `minimum_android_version`, iOS ↔ `minimum_ios_version`) |
| Update UX | Optional by default (Update + Later); if `force_update == true`, no skip |
| Update mechanism | Android: Play in-app update; iOS: open App Store via `url_launcher` |
| Branding | Prefer remote `app_name` / `app_tagline` everywhere those concepts are shown; else l10n |

## API shape (expected)

```json
{
  "success": true,
  "message": "App config fetched successfully",
  "data": {
    "app_name": "Goods Carrier",
    "app_tagline": "Your logistics partner",
    "logo_url": null,
    "supported_languages": [
      { "code": "en", "name": "English" },
      { "code": "hi", "name": "Hindi" },
      { "code": "gu", "name": "Gujarati" }
    ],
    "default_language": "en",
    "minimum_android_version": null,
    "minimum_ios_version": null,
    "force_update": false,
    "maintenance_mode": false,
    "app_url": "https://goodscarrier.ajonetech.com",
    "app_icon": "app_settings/....png",
    "app_icon_url": "/storage/app_settings/....png"
  }
}
```

Notes:

- `force_update` may be absent today → treat as `false`.
- `logo_url` / `app_icon` / `app_icon_url` are persisted for future use; this pass does not change splash or launcher icons.
- Paths under `/storage/...` (or other relative paths) are half-paths; resolve with effective base URL when displaying.

## Architecture

```
.env bootstrap URL
        │
        ▼
SharedPreferences (last app_url / full config JSON)
        │
        ▼
RuntimeBaseUrl (effective) ──► ApiConstants / Dio.baseUrl
        │
        ▼
Splash: GET /api/app/config
        │
        ├─ success → merge nulls with defaults → save prefs → apply app_url
        └─ failure → keep last prefs / defaults
        │
        ▼
Gates: maintenance? → MaintenanceScreen
       version below min? → Update dialog (force or optional)
       else → existing session restore routing
```

### Components

1. **`AppConfigData`** — typed model matching the live API (nullable strings, bool defaults).
2. **`AppConfigApiClient`** — parse envelope `data` into `AppConfigData`.
3. **`AppConfigPreferencesStore`** — persist/load full config JSON (same style as `AuthPreferencesStore`).
4. **`RuntimeApiBaseUrl`** (or equivalent) — holds effective base URL; initialized from prefs or `EnvConfig`; updated after fetch.
5. **`AppConfigNotifier`** — load remote → save → apply base URL; expose config for UI/gates.
6. **`AppBranding`** — `appName` / `appTagline` with remote-or-l10n fallback.
7. **Maintenance screen** — hard block UI.
8. **Update prompt + in-app update helper** — platform-aware.

## Bootstrap & base URL

1. On app start (before or as Dio is first configured): read prefs.
2. Effective base URL = prefs `app_url` if non-empty, else `EnvConfig.apiBaseUrl`.
3. First install has no prefs → always `.env` / default (`https://goodscarrier.ajonetech.com` today).
4. Splash fetches config with that base URL.
5. On success with non-null `app_url`: normalize (trim, strip trailing `/`), save, set Dio `BaseOptions.baseUrl` / runtime holder for the rest of the session.
6. Subsequent API calls use the updated base URL.
7. Relative media resolution must use the **effective** base URL, not a hardcoded host.

## Splash gates

Order after config load (and session restore may run in parallel or after gates — gates that block must win before navigating to login/home):

1. **Maintenance** if `maintenance_mode == true` → `MaintenanceScreen` only.
2. **Version check** (skip if platform min is null/empty):
   - Read installed version via `package_info_plus`.
   - Compare only the current platform’s minimum field.
   - If installed &lt; minimum:
     - Show “New update is available. Please update the app.”
     - **Update** → Android in-app update; iOS App Store link.
     - If `force_update` → non-dismissible (no Later).
     - Else → Later continues to normal auth routing.
3. Else → existing splash navigation (authenticated home / onboarding / login).

Splash **visuals unchanged** (bundled `Assets.splashScreenLogo`).

## Branding

- Central helper prefers remote non-empty `app_name` / `app_tagline`, else `context.l10n.appName` / `appTagline`.
- Call sites that display app name/tagline use the helper (ARB remains the fallback source of truth).

## Fallbacks

| Concern | Fallback chain |
|---------|----------------|
| Base URL | Last prefs `app_url` → `.env` / `EnvConfig` default |
| Name / tagline | Remote → l10n |
| Maintenance | `false` |
| Force update | `false` |
| Min versions | null → skip check |
| Languages | Persist; do not force locale change in this pass |
| Icon / logo URLs | Persist only; unused for UI this pass |

## Out of scope

- Writing files into Flutter `assets/` or changing the store launcher icon at runtime.
- Changing the splash logo asset.
- Forcing `default_language` on the device locale (store for future).
- Backend changes (client tolerates missing `force_update`).

## Verification

1. Fresh install: config fetch uses `.env` base URL; prefs empty beforehand.
2. Successful fetch with `app_url`: prefs saved; later Dio calls hit that host; next cold start uses saved `app_url`.
3. API failure: app still opens with last prefs or defaults; no crash.
4. Null `app_name` / `app_tagline`: UI shows l10n strings.
5. `maintenance_mode: true`: cannot reach login/home; maintenance screen shown.
6. Android below `minimum_android_version`, `force_update: false`: dialog with Later works; iOS min ignored.
7. iOS below `minimum_ios_version`, `force_update: true`: cannot skip; Android min ignored.
8. Relative `app_icon_url` stored as-is; if ever displayed, resolves to `{effectiveBase}{path}`.

## Risks

- Mutable Dio base URL: ensure a single Dio instance / options update so interceptors keep working.
- Version string compare: use a small semver-aware or dotted-numeric compare; document assumption (e.g. `1.2.3`).
- In-app update only works on Play-distributed Android builds; debug/sideload may need store fallback.
- Stale prefs `app_url` pointing at a dead host: user may need reinstall or a future “reset base URL” escape; first-fetch failure should not wipe last-known-good config unless explicitly desired (this design: keep last good).
