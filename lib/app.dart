import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/providers/connectivity_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/firebase_messaging_bootstrap.dart';
import 'features/settings/presentation/providers/locale_provider.dart';
import 'features/settings/presentation/providers/theme_provider.dart';
import 'l10n/app_localizations.dart';
import 'shared/presentation/widgets/feedback/connectivity_banner.dart';
import 'shared/presentation/widgets/layout/app_system_bottom_inset.dart';

// ─── Scroll behaviour ─────────────────────────────────────────────────────────

/// Removes the Android stretch/glow overscroll indicator and uses platform-
/// appropriate physics:
///   iOS / macOS → BouncingScrollPhysics (rubber-band feel)
///   Android / other → ClampingScrollPhysics (hard stop, no bounce)
///
/// Applied globally via [MaterialApp.scrollBehavior].
class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      switch (getPlatform(context)) {
        TargetPlatform.iOS ||
        TargetPlatform.macOS =>
          const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
        _ => const ClampingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
      };

  /// Suppress the Material stretch / glow overscroll indicator on Android.
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      child;
}

/// Root widget of the Goods Carrier app.
///
/// Responsibilities:
///  - Initialise flutter_screenutil (390×844 = iPhone 14 / Galaxy A54 baseline).
///  - Wire [ThemeMode] and [Locale] from their respective providers.
///  - Wire [GoRouter] from [appRouterProvider] (role-based redirect).
///  - Register all localisation delegates (EN / HI / GU).
///  - Clamp textScaler to [0.85 – 1.20] for consistent Indian-market rendering.
class GoodsCarrierApp extends ConsumerWidget {
  const GoodsCarrierApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeProvider);
    final locale    = ref.watch(localeProvider);
    final router    = ref.watch(appRouterProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return FirebaseMessagingBootstrap(
          child: MaterialApp.router(
          title: 'Goods Carrier',
          debugShowCheckedModeBanner: false,

          // ── Router ─────────────────────────────────────────────────────────
          routerConfig: router,

          // ── Localisation ───────────────────────────────────────────────────
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: supportedAppLocales,

          // ── Theme ──────────────────────────────────────────────────────────
          theme: AppTheme.light(),
          // darkTheme: AppTheme.dark(),
          // themeMode: themeMode,

          // ── Global scroll behaviour ────────────────────────────────────────
          scrollBehavior: const _AppScrollBehavior(),

          // ── Text scale clamp + tablet guard + connectivity banner ─────────
          // • Clamps text scale to [0.85 – 1.20] — prevents illegible text on
          //   Android accessibility settings or tiny Tier-2/3 handsets.
          // • On tablets (shortestSide ≥ 600) the content is centred in a
          //   480 px column so the UI isn't stretched across a wide canvas.
          // • [ConnectivityBanner] slides in from the top whenever the device
          //   loses internet access, pushing content down — no overlay.
          builder: (context, routerChild) {
            final mq       = MediaQuery.of(context);
            final isTablet = mq.size.shortestSide >= 600;
            final isOnline = ref.watch(isOnlineProvider);

            // Clamp text scale first (preserves system viewPadding), then apply
            // the universal bottom inset so nested MediaQueries cannot restore
            // a stale padding.bottom and undo the guard.
            Widget content = MediaQuery(
              data: mq.copyWith(
                textScaler: TextScaler.linear(
                  mq.textScaler.scale(1.0).clamp(0.85, 1.20),
                ),
              ),
              child: AppSystemBottomInset(child: routerChild!),
            );

            if (isTablet) {
              content = Material(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Center(
                  child: SizedBox(width: 480, child: content),
                ),
              );
            }

            return ConnectivityBanner(isOnline: isOnline, child: content);
          },
        ),
        );
      },
    );
  }
}
