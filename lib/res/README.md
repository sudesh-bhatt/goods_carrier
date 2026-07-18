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

After adding assets/fonts or if those files show red squiggles / duplicate `APP_ICON`, run:

```bash
dart run tool/generate_res.dart
# or auto-detect + fix:
dart run tool/fix_assets_res_if_broken.dart
```

**Tip:** Disable the iFlutter extension’s auto-regenerate for `lib/res`, or run the command above whenever it overwrites those files. Prefer `lib/generated/assets.dart` (`Assets.*`) in app code so builds do not depend on `AssetsRes`.
