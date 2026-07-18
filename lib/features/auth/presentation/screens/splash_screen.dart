import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/providers/app_config_provider.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/app_update_service.dart';
import '../../../../core/utils/app_version_utils.dart';
import '../../../../generated/assets.dart';
import '../../../../shared/data/api/app/app_config_api_client.dart';
import '../../../../shared/domain/enums/session_phase.dart';
import '../../../settings/presentation/providers/push_notifications_provider.dart';
import '../providers/auth_provider.dart';

const _kStepAnimDuration = Duration(milliseconds: 400);
const _kNavigateHold = Duration(milliseconds: 350);

/// Splash progress milestones driven by real init work (not a fixed timer).
const _kProgressStart = 0.08;
const _kProgressAfterFcm = 0.40;
const _kProgressAfterConfig = 0.72;
const _kProgressAfterSession = 1.0;

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

/// Splash — FCM token → app config → session, with step-based progress.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  var _navigated = false;

  @override
  void initState() {
    super.initState();
    // Manual step animation — do not auto-forward on a fixed timer.
    _ctrl = AnimationController(vsync: this, value: _kProgressStart);
    Future.microtask(_runSplashFlow);
  }

  Future<void> _animateProgressTo(double value) async {
    if (!mounted) return;
    await _ctrl.animateTo(
      value.clamp(0.0, 1.0),
      duration: _kStepAnimDuration,
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _runSplashFlow() async {
    // 1) FCM token first — HeadersInterceptor needs X-FCM-Token on config.
    await _ensureFcmToken();
    if (!mounted) return;
    await _animateProgressTo(_kProgressAfterFcm);

    // 2) App config API
    final appConfigNotifier = ref.read(appConfigProvider.notifier);
    if (EnvConfig.useRemoteApi) {
      await appConfigNotifier.load();
    } else {
      await appConfigNotifier.hydrateFromPrefsOnly();
    }
    if (!mounted) return;
    await _animateProgressTo(_kProgressAfterConfig);

    final config = ref.read(appConfigProvider).config;
    final gateRedirect = splashGateRedirectForConfig(config);
    if (gateRedirect != null) {
      await _animateProgressTo(_kProgressAfterSession);
      if (!mounted) return;
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

    // 3) Session restore
    await ref.read(authProvider.notifier).restoreSession();
    if (!mounted) return;
    await _animateProgressTo(_kProgressAfterSession);
    if (!mounted) return;

    await Future<void>.delayed(_kNavigateHold);
    _navigateNext();
  }

  Future<void> _ensureFcmToken() async {
    final pushEnabled = ref.read(pushNotificationsProvider);
    if (!pushEnabled) {
      if (kDebugMode) {
        debugPrint('[Splash] Push disabled — skipping FCM token fetch');
      }
      return;
    }

    try {
      final fcm = ref.read(fcmServiceProvider);
      await fcm.initialize(requestPermission: true);
      if (kDebugMode) {
        debugPrint(
          '[Splash] FCM ready — token present=${fcm.currentToken != null}',
        );
      }
    } catch (e, st) {
      // Splash must continue even if push permission / token fails.
      if (kDebugMode) {
        debugPrint('[Splash] FCM init failed: $e\n$st');
      }
    }
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
                animation: _ctrl,
                builder: (context, _) {
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: _ctrl.value,
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
