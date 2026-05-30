import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../res/font_res.dart';

/// Driver main tabs — shared bottom shell with customer (`1:406`).
enum DriverMainTab { home, myTrips, notifications, profile }

class DriverBottomNavBar extends StatelessWidget {
  const DriverBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  final DriverMainTab currentTab;
  final ValueChanged<DriverMainTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
            color: colors.shadowCard,
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(8.w, 12.h, 8.w, 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DriverTab(
                label: l10n.customerNavHome,
                icon: Icons.home_rounded,
                selected: currentTab == DriverMainTab.home,
                onTap: () => _select(DriverMainTab.home),
              ),
              _DriverTab(
                label: l10n.driverNavMyTrip,
                icon: Icons.local_shipping_outlined,
                selected: currentTab == DriverMainTab.myTrips,
                onTap: () => _select(DriverMainTab.myTrips),
              ),
              _DriverTab(
                label: l10n.customerNavNotifications,
                icon: Icons.notifications_none_rounded,
                selected: currentTab == DriverMainTab.notifications,
                onTap: () => _select(DriverMainTab.notifications),
              ),
              _DriverTab(
                label: l10n.customerNavProfile,
                icon: Icons.person_outline_rounded,
                selected: currentTab == DriverMainTab.profile,
                onTap: () => _select(DriverMainTab.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _select(DriverMainTab tab) {
    HapticFeedback.selectionClick();
    onTabSelected(tab);
  }
}

class _DriverTab extends StatelessWidget {
  const _DriverTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
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
                  Icon(
                    icon,
                    size: 18.w,
                    color: selected ? colors.onPrimary : colors.textSecondary,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_SEMIBOLD,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: selected ? colors.onPrimary : colors.textSecondary,
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
}
