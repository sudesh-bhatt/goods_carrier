import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/app_update_service.dart';
import '../../../../core/utils/app_version_utils.dart';
import '../../../../generated/assets.dart';
import '../../../../shared/domain/enums/session_phase.dart';
import '../../../../shared/data/api/app/app_config_api_client.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/providers/app_config_provider.dart';
import '../providers/auth_provider.dart';

const _kProgressDuration = Duration(milliseconds: 1800);
const _kNavigateDelay = Duration(milliseconds: 2600);

@visibleForTesting
String? splashGateRedirectForConfig(AppConfigData? config) {
  if (config?.maintenanceMode == true) return AppRoutes.maintenance;
  return null;
}

@visibleForTesting
bool shouldPromptUpdate({required bool isBelowPlatformMinimum}) {
  return isBelowPlatformMinimum;
}

@visibleForTesting
bool updateDialogAllowsLater({required bool force}) => !force;

@visibleForTesting
bool shouldRepeatUpdateDialog({
  required bool force,
  required bool updateStarted,
}) {
  return force && updateStarted;
}

@visibleForTesting
Widget buildUpdateDialogContent({
  required BuildContext context,
  required bool force,
  required VoidCallback onLater,
  required Future<void> Function() onUpdate,
}) {
  final l10n = context.l10n;
  return PopScope(
    canPop: updateDialogAllowsLater(force: force),
    child: AlertDialog(
      title: Text(l10n.updateAvailableTitle),
      content: Text(l10n.updateAvailableBody),
      actions: [
        if (updateDialogAllowsLater(force: force))
          TextButton(
            onPressed: onLater,
            child: Text(l10n.updateActionLater),
          ),
        FilledButton(
          onPressed: onUpdate,
          child: Text(l10n.updateActionUpdate),
        ),
      ],
    ),
  );
}

@visibleForTesting
String? minimumVersionForCurrentPlatform(
  AppConfigData? config, {
  bool? isAndroid,
  bool? isIOS,
}) {
  final android = isAndroid ?? Platform.isAndroid;
  final ios = isIOS ?? Platform.isIOS;

  if (android) return config?.minimumAndroidVersion;
  if (ios) return config?.minimumIosVersion;
  return null;
}

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

    Future.microtask(_runSplashFlow);
  }

  Future<void> _runSplashFlow() async {
    final appConfigNotifier = ref.read(appConfigProvider.notifier);
    if (EnvConfig.useRemoteApi) {
      await appConfigNotifier.load();
    } else {
      await appConfigNotifier.hydrateFromPrefsOnly();
    }
    if (!mounted) return;

    final config = ref.read(appConfigProvider).config;
    final gateRedirect = splashGateRedirectForConfig(config);
    if (gateRedirect != null) {
      context.go(gateRedirect);
      return;
    }

    final isBelowPlatformMinimum = await _isBelowPlatformMinimum(config);
    if (shouldPromptUpdate(isBelowPlatformMinimum: isBelowPlatformMinimum)) {
      if (!mounted) return;
      final proceed = await _showUpdateDialog(
        force: config?.forceUpdate ?? false,
      );
      if (!mounted) return;
      if (!proceed) return;
    }

    await ref.read(authProvider.notifier).restoreSession();
    if (!mounted) return;
    Future.delayed(_kNavigateDelay, _navigateNext);
  }

  Future<bool> _isBelowPlatformMinimum(AppConfigData? config) async {
    final minimum = minimumVersionForCurrentPlatform(config);
    if (minimum == null || minimum.trim().isEmpty) return false;

    final packageInfo = await PackageInfo.fromPlatform();
    return AppVersionUtils.isBelowMinimum(
      installed: packageInfo.version,
      minimum: minimum,
    );
  }

  Future<bool> _showUpdateDialog({required bool force}) async {
    do {
      var updateStarted = false;
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: updateDialogAllowsLater(force: force),
        builder: (context) {
          return buildUpdateDialogContent(
            context: context,
            force: force,
            onLater: () => Navigator.of(context).pop(true),
            onUpdate: () async {
              await AppUpdateService().startUpdate();
              updateStarted = true;
              if (context.mounted) Navigator.of(context).pop(false);
            },
          );
        },
      );

      if (!force) return result ?? true;
      if (shouldRepeatUpdateDialog(
          force: force, updateStarted: updateStarted)) {
        continue;
      }
      return false;
    } while (mounted);

    return false;
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
