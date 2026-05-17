import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../res/font_res.dart';

/// Customer main tabs — Figma bottom shell (`2013:1553`).
enum CustomerMainTab { home, shipments, notifications, profile }

class CustomerBottomNavBar extends StatelessWidget {
  const CustomerBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  final CustomerMainTab currentTab;
  final ValueChanged<CustomerMainTab> onTabSelected;

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
              _FigmaTab(
                label: l10n.customerNavHome,
                icon: Icons.home_rounded,
                selected: currentTab == CustomerMainTab.home,
                onTap: () => _select(CustomerMainTab.home),
              ),
              _FigmaTab(
                label: l10n.customerNavShipments,
                icon: Icons.inventory_2_outlined,
                selected: currentTab == CustomerMainTab.shipments,
                onTap: () => _select(CustomerMainTab.shipments),
              ),
              _FigmaTab(
                label: l10n.customerNavNotifications,
                icon: Icons.notifications_none_rounded,
                selected: currentTab == CustomerMainTab.notifications,
                onTap: () => _select(CustomerMainTab.notifications),
              ),
              _FigmaTab(
                label: l10n.customerNavProfile,
                icon: Icons.person_outline_rounded,
                selected: currentTab == CustomerMainTab.profile,
                onTap: () => _select(CustomerMainTab.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _select(CustomerMainTab tab) {
    HapticFeedback.selectionClick();
    onTabSelected(tab);
  }
}

class _FigmaTab extends StatelessWidget {
  const _FigmaTab({
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

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedScale(
          scale: selected ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutBack,
          child: Icon(
            icon,
            size: 18.w,
            color: selected ? colors.onPrimary : colors.textSecondary,
          ),
        ),
        SizedBox(height: 4.h),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_SEMIBOLD,
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: selected ? colors.onPrimary : colors.textSecondary,
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

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
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
