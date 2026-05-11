import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:goods_carrier/core/theme/app_color_scheme.dart';
import 'package:goods_carrier/generated/assets.dart';

import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/domain/enums/user_role.dart';
import '../providers/auth_provider.dart';

// ─── Role data model ──────────────────────────────────────────────────────────

class _RoleOption {
  const _RoleOption({
    required this.role,
    required this.title,
    required this.description,
    required this.icon,
  });

  final UserRole role;
  final String   title;
  final String   description;
  final SvgGenImage icon;

}

const _kRoles = [
  _RoleOption(
    role:        UserRole.customer,
    title:       'Customer / Send Goods',
    description: 'Find transport easily. Ship anything from small parcels to '
                 'full containers globally.',
    icon:        Assets.icRoleCustomer,
  ),
  _RoleOption(
    role:        UserRole.driver,
    title:       'Driver / Transporter',
    description: 'List trips and earn. Connect with businesses needing reliable '
                 'transport solutions.',
    icon:        Assets.icRoleDriver,
  ),
];

/// Role selection screen — matches the Figma design:
///
///   - "Choose Your Role" + descriptive subtitle
///   - Two selectable cards with animated radio-button indicator
///     • Selected  → `primary`-tinted background, `primary` border, filled
///                   orange icon box, filled checkmark circle
///     • Unselected → `cardBackground`, `divider` border, `inputFill` icon
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
    extends ConsumerState<RoleSelectionScreen> {

  // Customer is pre-selected, matching the Figma default state.
  UserRole _selected = UserRole.customer;

  void _onContinue() {
    HapticFeedback.lightImpact();
    ref.read(authProvider.notifier).selectRole(_selected);
    context.go(AppRoutes.languageSelection);
  }

  @override
  Widget build(BuildContext context) {
    final colors    = context.colors;
    final textTheme = context.textTheme;

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
              // headlineMedium (textPrimary, w700) + w800 override
              Text(
                'Choose Your Role',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              SizedBox(height: 10.h),

              // bodyMedium (textSecondary) with line-height adjustment
              Text(
                'Select how you\'d like to use the Goods Carrier platform '
                'to manage your logistics.',
                style: textTheme.bodyMedium?.copyWith(fontSize: 12,),
              ),

              SizedBox(height: 32.h),

              // ── Role cards ────────────────────────────────────────────
              ..._kRoles.map((option) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: _RoleCard(
                  option:     option,
                  isSelected: _selected == option.role,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selected = option.role);
                  },
                ),
              )),

              const Spacer(),

              // ── Continue button ───────────────────────────────────────
              // Uses global ElevatedButtonTheme (primary bg, white fg)
              // with shape overridden to stadium (pill) per Figma.
              SizedBox(
                width:  double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
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
    required this.isSelected,
    required this.onTap,
  });

  final _RoleOption  option;
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
                  child: option.icon.svg(
                    colorFilter: ColorFilter.mode( isSelected ? Colors.white : colors.disableColor, BlendMode.srcIn),
                  )

                ),

                SizedBox(width: 14.w),

                // Title — expands to push radio to the right
                Expanded(
                  child: Text(
                    option.title,
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
              option.description,
              style: textTheme.bodyLarge?.copyWith(
                color:  colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
