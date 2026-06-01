# `lib/res` — path constants (legacy)

| File | Purpose |
|------|---------|
| `font_res.dart` | Manrope family name constants (used across the app) |
| `assets_res.dart` | String paths for assets (optional; prefer `lib/generated/assets.dart`) |
| `default_res.dart` | `.env` path constant |

## Regeneration

**Do not rely on the iFlutter plugin** for `assets_res.dart`, `default_res.dart`, or `font_res.dart`. It generates invalid Dart when:

- The same basename exists in two folders (e.g. `app_icon.png` and `app_icon.svg` → duplicate `APP_ICON`)
- A dotfile is listed (`.env` → `static const String = '.env'`)

If `font_res.dart` loses `MANROPE_*` constants, the whole app will show hundreds of analyzer errors — run the generator immediately.

After adding assets/fonts or if those files show red squiggles, run:

```bash
dart run tool/generate_res.dart
```

This is also run automatically by `dart run tool/sync_env.dart`.
