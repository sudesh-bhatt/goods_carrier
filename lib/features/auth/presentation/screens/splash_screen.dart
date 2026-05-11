import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../generated/assets.dart';

// ─── Timing constants ─────────────────────────────────────────────────────────

const _kProgressDuration = Duration(milliseconds: 1800);
const _kNavigateDelay    = Duration(milliseconds: 2600);

/// Splash screen — matches the Figma design:
///
///   - Theme-aware background (`colors.background`)
///   - Brand logo from `assets/images/splash_screen_logo.png`
///   - "Goods Carrier" using `headlineLarge` from the global text theme
///   - "YOUR LOGISTICS PARTNER" using `labelSmall` with wider tracking
///   - Animated progress bar at the bottom (SYSTEM INITIALIZING … 100 %)
///
/// GoRouter's redirect short-circuits this screen for already-authenticated
/// users (they jump straight to their home screen).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late final AnimationController _ctrl;

  /// [0.15 – 1.0] → progress bar fills left-to-right
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(vsync: this, duration: _kProgressDuration);

    _progress = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.15, 1.0, curve: Curves.easeInOut),
    );

    _ctrl.forward();

    Future.delayed(_kNavigateDelay, () {
      if (mounted) context.go(AppRoutes.roleSelection);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors    = context.colors;
    final textTheme = context.textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Logo — vertically centred (wordmark is baked into the image)
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Assets.splashScreenLogo.image(),
                ),
              ),
            ),

            // ── Bottom progress section ───────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 36.h),
              child: AnimatedBuilder(
                animation: _progress,
                builder: (_, __) {
                  final pct = (_progress.value * 100).round();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress track — uses divider token for the unfilled
                      // portion so it adapts correctly in dark mode
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2.r),
                        child: LinearProgressIndicator(
                          value:           _progress.value,
                          minHeight:       3.5.h,
                          backgroundColor: colors.divider,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colors.primary,
                          ),
                        ),
                      ),

                      SizedBox(height: 10.h),

                      // Labels
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // "SYSTEM INITIALIZING" — bodySmall (textHint) +
                          // wider tracking
                          Text(
                            'SYSTEM INITIALIZING',
                            style: textTheme.bodySmall?.copyWith(
                              letterSpacing: 1.5,
                              fontWeight:    FontWeight.w600,
                            ),
                          ),

                          // Percentage — same size, accent colour
                          Text(
                            '$pct%',
                            style: textTheme.bodySmall?.copyWith(
                              color:      colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

