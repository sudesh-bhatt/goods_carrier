import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:goods_carrier/core/theme/app_color_scheme.dart';
import 'package:goods_carrier/generated/assets.dart';

import '../../../../core/extensions/svg_gen_image_extension.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../shared/domain/enums/user_role.dart';
import '../providers/auth_provider.dart';

// ─── Role data model ──────────────────────────────────────────────────────────
// title & description are intentionally excluded — they are locale-dependent
// and resolved via context.l10n at build time.

class _RoleOption {
  const _RoleOption({
    required this.role,
    required this.icon,
  });

  final UserRole    role;
  final SvgGenImage icon;
}

const _kRoles = [
  _RoleOption(role: UserRole.customer, icon: Assets.icRoleCustomer),
  _RoleOption(role: UserRole.driver,   icon: Assets.icRoleDriver),
];

/// Role selection screen — matches the Figma design:
///
///   - "Choose Your Role" + descriptive subtitle
///   - Two selectable cards with animated radio-button indicator
///     • Selected  → `primary`-tinted background, `primary` border, filled
///                   orange icon box, filled checkmark circle
///     • Unselected → `cardBackground`, `borderColor` (muted outline), `inputFill` icon
///                   box, empty circle
///   - "Continue →" pill button at bottom (no immediate navigation on tap)
///
/// The screen is intentionally stateful — selection state lives here, and
/// [AuthNotifier.selectRole] is only called when the user taps Continue.
class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState
    extends ConsumerState<RoleSelectionScreen> with SafeSetStateMixin {

  // Customer is pre-selected, matching the Figma default state.
  UserRole _selected = UserRole.customer;

  Future<void> _onContinue() async {
    HapticFeedback.lightImpact();
    final route =
        await ref.read(authProvider.notifier).submitOnboardingRole(_selected);
    if (!mounted) return;
    if (route != null) context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final l10n      = context.l10n;
    final colors    = context.colors;
    final textTheme = context.textTheme;

    // Resolve locale-dependent card strings here — _RoleOption is const
    // and cannot hold l10n references.
    final cardData = [
      (option: _kRoles[0], title: l10n.roleCustomerTitle, description: l10n.roleCustomerDescription),
      (option: _kRoles[1], title: l10n.roleDriverTitle,   description: l10n.roleDriverDescription),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 48.h),

              // ── Header ────────────────────────────────────────────────
              Text(
                l10n.roleSelectionTitle,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              SizedBox(height: 10.h),

              Text(
                l10n.roleSelectionSubtitle,
                style: textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),

              SizedBox(height: 32.h),

              // ── Role cards ────────────────────────────────────────────
              ...cardData.map((data) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: _RoleCard(
                  option:      data.option,
                  title:       data.title,
                  description: data.description,
                  isSelected:  _selected == data.option.role,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    safeSetState(() => _selected = data.option.role);
                  },
                ),
              )),

              const Spacer(),

              // ── Continue button ───────────────────────────────────────
              SizedBox(
                width:  double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  // shape falls through to theme — radius 12 from ElevatedButtonTheme
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.actionContinue,
                        style: textTheme.labelLarge?.copyWith(
                          color: colors.onPrimary,
                        ),
                      ),
                      SizedBox(width: 8.w),
                     Icon(
                        Icons.arrow_forward,
                        size: 18.w,
                        color: colors.onPrimary,
                     )
                    ],
                  ),
                ),
              ),

              SizedBox(height: 28.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Role card ────────────────────────────────────────────────────────────────

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.option,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final _RoleOption  option;
  final String       title;
  final String       description;
  final bool         isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors    = context.colors;
    final textTheme = context.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve:    Curves.easeInOut,
        padding:  EdgeInsets.all(34.w),
        decoration: BoxDecoration(
          // Selected: orange wash. Unselected: themed card background.
          color:        isSelected
              ? colors.primary.setOpacity(0.07)
              : colors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? colors.primary : colors.borderColor,
            width: isSelected ? 2.0 : 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: icon  +  title  +  radio ────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon box
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width:  64.w,
                  height: 64.w,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color:        isSelected ? colors.primary : colors.inputFill,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: option.icon.svgTint(
                    color: isSelected
                        ? colors.onPrimary
                        : colors.disableColor,
                  ),

                ),

                SizedBox(width: 14.w),

                // Title — expands to push radio to the right
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.titleLarge?.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),

                SizedBox(width: 10.w),

                // Radio indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width:  22.w,
                  height: 22.w,
                  /*decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? colors.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? colors.primary : colors.divider,
                      width: 2.0,
                    ),
                  ),*/
                  child: isSelected
                      ? Assets.icRadioSelected.svg()
                      : Assets.icRadioUnselected.svg(),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            // ── Description — full width, starts below the icon ──────
            Text(
              description,
              style: textTheme.bodyLarge?.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
