import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../res/font_res.dart';

/// Figma flow screens — 32×32 tap target, 16px orange chevron (`1:3130`, `1:3201`).
class FigmaFlowBackButton extends StatelessWidget {
  const FigmaFlowBackButton({
    super.key,
    this.onTap,
    this.color = const Color(0xFFFF6D00),
  });

  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          if (onTap != null) {
            onTap!();
          } else if (context.canPop()) {
            context.pop();
          } else {
            Navigator.maybePop(context);
          }
        },
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 32.w,
          height: 32.w,
          child: Icon(
            Icons.arrow_back,
            size: 16.w,
            color: color,
          ),
        ),
      ),
    );
  }
}

/// Standard app bar for almost all screens — back + left title (+ optional actions).
///
/// Use this instead of raw [AppBar], [AppBarWidget], or custom `_FooAppBar` widgets.
/// Matches Figma Post Shipment: semi-transparent white bar, orange back, 18px bold title.
class FlowScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FlowScreenAppBar({
    super.key,
    required this.title,
    this.onBackTap,
    this.fallbackRoute,
    this.trailing,
    this.actions = const [],
    this.backgroundColor,
    this.showShadow = true,
    this.showBack = true,
  });

  static const titleColor = Color(0xFF191C1D);

  final String title;
  final VoidCallback? onBackTap;

  /// When [onBackTap] is null and the route cannot pop, navigates here.
  final String? fallbackRoute;
  final Widget? trailing;
  final List<AppBarAction> actions;
  final Color? backgroundColor;
  final bool showShadow;
  final bool showBack;

  @override
  Size get preferredSize => Size.fromHeight(64.h);

  void _handleBack(BuildContext context) {
    if (onBackTap != null) {
      onBackTap!();
      return;
    }
    if (context.canPop()) {
      context.pop();
      return;
    }
    if (fallbackRoute != null) {
      context.go(fallbackRoute!);
      return;
    }
    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withValues(alpha: 0.8),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                if (showBack)
                  AppBarBackButton(onTap: () => _handleBack(context))
                else
                  SizedBox(width: 48.w),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_BOLD,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      height: 28 / 18,
                      letterSpacing: -0.45,
                      color: titleColor,
                    ),
                  ),
                ),
                ...actions.map((a) => _ActionButton(action: a)),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Standard back control — orange left arrow used on all app bars.
class AppBarBackButton extends StatelessWidget {
  const AppBarBackButton({
    super.key,
    this.onTap,
    this.size,
    this.color,
  });

  final VoidCallback? onTap;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return IconButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        if (onTap != null) {
          onTap!();
        } else if (context.canPop()) {
          context.pop();
        } else {
          Navigator.maybePop(context);
        }
      },
      icon: Icon(
        Icons.arrow_back,
        size: size ?? 24.w,
        color: color ?? colors.primary,
      ),
      tooltip: context.l10n.actionBack,
    );
  }
}

/// Legacy centered [AppBar] wrapper — prefer [FlowScreenAppBar] for new screens.
///
/// Only use when you need [AppBarLeadingType.menu], centered title, or [bottom] slot.
enum AppBarLeadingType { back, menu, none }

class AppBarAction {
  const AppBarAction({
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
    this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback onTap;

  /// When > 0, shows an orange badge dot over the icon.
  final int badgeCount;
  final String? semanticLabel;
}

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingType = AppBarLeadingType.back,
    this.onLeadingTap,
    this.actions = const [],
    this.centerTitle = true,
    this.backgroundColor,
    this.titleStyle,
    this.elevation = 0,
    this.bottom,
  });

  final String title;
  final String? subtitle;
  final AppBarLeadingType leadingType;
  final VoidCallback? onLeadingTap;
  final List<AppBarAction> actions;
  final bool centerTitle;
  final Color? backgroundColor;
  final TextStyle? titleStyle;
  final double elevation;

  /// Optional [PreferredSizeWidget] placed below the title (e.g. [TabBar]).
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(
        AppDimensions.appBarHeight.h +
            (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;

    void handleLeadingTap() {
      HapticFeedback.lightImpact();
      if (onLeadingTap != null) {
        onLeadingTap!();
      } else if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }

    Widget? leadingWidget;
    switch (leadingType) {
      case AppBarLeadingType.back:
        leadingWidget = AppBarBackButton(onTap: handleLeadingTap);
      case AppBarLeadingType.menu:
        leadingWidget = IconButton(
          icon: Icon(
            Icons.menu_rounded,
            size: AppDimensions.iconBase.w,
            color: colors.textPrimary,
          ),
          onPressed: handleLeadingTap,
        );
      case AppBarLeadingType.none:
        leadingWidget = null;
    }

    final titleWidget = subtitle != null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: (titleStyle ??
                        context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ))!,
              ),
              Text(
                subtitle!,
                style: context.textTheme.labelSmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          )
        : Text(
            title,
            style: titleStyle ??
                context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
          );

    return AppBar(
      backgroundColor: backgroundColor ?? colors.surface,
      elevation: elevation,
      scrolledUnderElevation: 0.5,
      shadowColor: colors.divider,
      surfaceTintColor: Colors.transparent,
      leading: leadingWidget,
      automaticallyImplyLeading: false,
      centerTitle: centerTitle,
      title: titleWidget,
      bottom: bottom,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness:
            isDark ? Brightness.dark : Brightness.light,
        statusBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      actions: [
        ...actions.map(
          (a) => _ActionButton(action: a),
        ),
        if (actions.isNotEmpty) SizedBox(width: AppDimensions.xs.w),
      ],
    );
  }
}

// ─── Action icon button with optional badge ───────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action});
  final AppBarAction action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            action.icon,
            size: AppDimensions.iconBase.w,
            color: colors.textPrimary,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            action.onTap();
          },
          tooltip: action.semanticLabel,
        ),
        if (action.badgeCount > 0)
          Positioned(
            top: 8.h,
            right: 8.w,
            child: Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: colors.surface, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}
