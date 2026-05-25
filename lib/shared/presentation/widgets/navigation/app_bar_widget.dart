import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';

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

/// Consistent [PreferredSizeWidget] AppBar used across all screens.
///
/// Features:
/// - Transparent background with surface colour fallback
/// - Haptic feedback on back / menu tap
/// - Supports back chevron OR hamburger menu as leading
/// - Up to two action icon slots on the right
/// - Optional subtitle below title
///
/// ```dart
/// // Standard back-nav screen
/// Scaffold(
///   appBar: AppBarWidget(title: context.l10n.shipmentGoods),
/// );
///
/// // Driver home — hamburger + bell + avatar
/// Scaffold(
///   appBar: AppBarWidget(
///     title: context.l10n.appName,
///     leadingType: AppBarLeadingType.menu,
///     onLeadingTap: () => _openDrawer(),
///     actions: [
///       AppBarAction(icon: Icons.notifications_outlined, onTap: _openNotifs),
///     ],
///   ),
/// );
/// ```
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
