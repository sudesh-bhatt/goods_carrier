import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';

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
        leadingWidget = IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: AppDimensions.iconMd.w,
            color: colors.textPrimary,
          ),
          onPressed: handleLeadingTap,
          tooltip: context.l10n.actionBack,
        );
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
