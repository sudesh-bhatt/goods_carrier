import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/svg_gen_image_extension.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../generated/assets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../res/font_res.dart';
import '../../../domain/enums/user_role.dart';
import 'app_main_tab.dart';

/// Figma bottom nav inactive label/icon — `1:4690`.
const _navInactive = Color(0xFF64748B);

/// Shared bottom nav for customer and driver main shells (`1:406` / `1:4690`).
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.role,
    required this.currentTab,
    required this.onTabSelected,
  });

  final UserRole role;
  final AppMainTab currentTab;
  final ValueChanged<AppMainTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final listingsLabel = _listingsLabel(l10n);

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xCCFFFFFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            boxShadow: [
              BoxShadow(
                color: const Color(0x0F161C20),
                blurRadius: 40,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(8.w, 12.h, 8.w, 8.h),
              child: Row(
                children: [
                  _NavTab(
                    label: l10n.customerNavHome,
                    svgIcon: Assets.navHome,
                    selected: currentTab == AppMainTab.home,
                    onTap: () => _select(AppMainTab.home),
                  ),
                  _NavTab(
                    label: listingsLabel,
                    icon: Icons.local_shipping_outlined,
                    selected: currentTab == AppMainTab.listings,
                    onTap: () => _select(AppMainTab.listings),
                  ),
                  _NavTab(
                    label: l10n.customerNavNotifications,
                    icon: Icons.notifications_none_rounded,
                    selected: currentTab == AppMainTab.notifications,
                    onTap: () => _select(AppMainTab.notifications),
                  ),
                  _NavTab(
                    label: l10n.customerNavProfile,
                    icon: Icons.person_outline_rounded,
                    selected: currentTab == AppMainTab.profile,
                    onTap: () => _select(AppMainTab.profile),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _listingsLabel(AppLocalizations l10n) => switch (role) {
        UserRole.customer => l10n.customerNavShipments,
        UserRole.driver => l10n.driverNavMyTrip,
      };

  void _select(AppMainTab tab) {
    HapticFeedback.selectionClick();
    onTabSelected(tab);
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.svgIcon,
  }) : assert(icon != null || svgIcon != null);

  final String label;
  final IconData? icon;
  final SvgGenImage? svgIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: selected ? 12.w : 8.w,
                vertical: 8.h,
              ),
              decoration: selected
                  ? BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    )
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIcon(
                    selected ? colors.onPrimary : _navInactive,
                  ),
                  SizedBox(height: 4.h),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_SEMIBOLD,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        height: 16 / 11,
                        color: selected ? colors.onPrimary : _navInactive,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color color) {
    if (svgIcon != null) {
      return svgIcon!.svgTint(width: 18.w, height: 18.w, color: color);
    }
    return Icon(icon, size: 18.w, color: color);
  }
}
