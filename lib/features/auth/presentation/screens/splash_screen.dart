import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../generated/assets.dart';
import '../../../../shared/domain/enums/user_role.dart';
import '../providers/auth_provider.dart';

// ─── Timing constants ─────────────────────────────────────────────────────────

const _kProgressDuration = Duration(milliseconds: 1800);
const _kNavigateDelay = Duration(milliseconds: 2600);

/// Splash screen — matches the Figma design.
///
/// Navigates to home when a profile is saved in preferences; otherwise
/// continues the onboarding flow at role selection.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
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

    Future.delayed(_kNavigateDelay, _navigateNext);
  }

  void _navigateNext() {
    if (!mounted) return;

    final auth = ref.read(authProvider);
    if (auth.isAuthenticated && auth.user != null) {
      final home = auth.user!.role == UserRole.customer
          ? AppRoutes.customerHome
          : AppRoutes.driverHome;
      context.go(home);
      return;
    }

    context.go(AppRoutes.roleSelection);
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
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Assets.splashScreenLogo.image(),
                ),
              ),
            ),
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2.r),
                        child: LinearProgressIndicator(
                          value: _progress.value,
                          minHeight: 3.5.h,
                          backgroundColor: colors.divider,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colors.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.splashInitializing,
                            style: textTheme.bodySmall?.copyWith(
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$pct%',
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.primary,
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
