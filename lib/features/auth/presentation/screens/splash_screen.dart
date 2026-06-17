import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../generated/assets.dart';
import '../../../../shared/domain/enums/session_phase.dart';
import '../providers/auth_provider.dart';

const _kProgressDuration = Duration(milliseconds: 1800);
const _kNavigateDelay = Duration(milliseconds: 2600);

/// Splash — restores session via API, then routes to login or onboarding/home.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _progress;
  var _navigated = false;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(vsync: this, duration: _kProgressDuration);
    _progress = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.15, 1.0, curve: Curves.easeInOut),
    );
    _ctrl.forward();

    Future.microtask(() async {
      await ref.read(authProvider.notifier).restoreSession();
      Future.delayed(_kNavigateDelay, _navigateNext);
    });
  }

  void _navigateNext() {
    if (!mounted || _navigated) return;
    _navigated = true;

    final auth = ref.read(authProvider);
    if (auth.sessionPhase == SessionPhase.authenticated) {
      final home = auth.user?.isCustomer == true
          ? AppRoutes.customerHome
          : AppRoutes.driverHome;
      context.go(home);
      return;
    }

    final onboardingRoute = auth.routeForCurrentStep;
    if (auth.sessionPhase == SessionPhase.onboarding &&
        onboardingRoute != null) {
      context.go(onboardingRoute);
      return;
    }

    context.go(AppRoutes.loginScreen);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.w),
              child: Assets.splashScreenLogo.image(),
            ),
            const Spacer(flex: 3),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.w),
              child: AnimatedBuilder(
                animation: _progress,
                builder: (context, _) {
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: _progress.value,
                          minHeight: 4.h,
                          backgroundColor: colors.borderColor,
                          color: colors.primary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        l10n.splashInitializing,
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.textHint,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 48.h),
          ],
        ),
      ),
    );
  }
}
