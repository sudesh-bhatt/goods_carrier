import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/domain/entities/user.dart';
import '../../../../shared/presentation/widgets/navigation/confirmation_bottom_sheet.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/customer_profile_menu_row.dart';

/// Profile tab body.
class CustomerProfileTab extends ConsumerStatefulWidget {
  const CustomerProfileTab({super.key});

  @override
  ConsumerState<CustomerProfileTab> createState() => _CustomerProfileTabState();
}

class _CustomerProfileTabState extends ConsumerState<CustomerProfileTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.colors;
    final l10n = context.l10n;
    final user = ref.watch(authProvider).user!;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileHeroCard(user: user),
          SizedBox(height: 28.h),
          _SectionLabel(text: l10n.customerAccountSettings),
          SizedBox(height: 12.h),
          CustomerProfileMenuRow(
            icon: Icons.person_outline_rounded,
            title: l10n.customerEditPersonalInfo,
            subtitle: l10n.customerEditPersonalInfoSub,
            onTap: () {},
          ),
          SizedBox(height: 8.h),
          CustomerProfileMenuRow(
            icon: Icons.location_on_outlined,
            title: l10n.customerSavedAddresses,
            subtitle: l10n.customerSavedAddressesSub,
            onTap: () {},
          ),
          SizedBox(height: 8.h),
          CustomerProfileMenuRow(
            icon: Icons.flag_outlined,
            title: l10n.customerReportedTrips,
            subtitle: l10n.customerReportedTripsSub,
            onTap: () {},
          ),
          SizedBox(height: 28.h),
          _SectionLabel(text: l10n.customerActivity),
          SizedBox(height: 12.h),
          CustomerProfileMenuRow(
            icon: Icons.settings_outlined,
            title: l10n.settingsTitle,
            subtitle: l10n.customerEditPersonalInfoSub,
            onTap: () {},
          ),
          SizedBox(height: 8.h),
          CustomerProfileMenuRow(
            icon: Icons.help_outline_rounded,
            title: l10n.customerHelpSupport,
            subtitle: l10n.customerHelpSupportSub,
            onTap: () {},
          ),
          SizedBox(height: 28.h),
          _LogoutButton(
            onPressed: () async {
              final confirmed = await ConfirmationBottomSheet.show(
                context,
                title: l10n.settingsLogout,
                body: l10n.settingsLogoutConfirm,
                confirmLabel: l10n.actionYes,
                isDangerous: true,
              );
              if (confirmed == true && context.mounted) {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go(AppRoutes.splash);
              }
            },
          ),
          SizedBox(height: 16.h),
          Center(
            child: Text(
              l10n.settingsVersion('1.0.0'),
              style: TextStyle(
                fontFamily: FontRes.MANROPE_REGULAR,
                fontSize: 12.sp,
                color: colors.textHint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 48.w,
                backgroundColor: colors.primary.withValues(alpha: 0.12),
                child: Text(
                  user.initials,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_EXTRABOLD,
                    fontSize: 28.sp,
                    color: colors.primaryDark,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.surface, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 14.w,
                    color: colors.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            user.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: FontRes.MANROPE_EXTRABOLD,
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            l10n.customerRoleLabel,
            style: TextStyle(
              fontFamily: FontRes.MANROPE_SEMIBOLD,
              fontSize: 14.sp,
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: colors.inputFill,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone_outlined, size: 16.w, color: colors.primary),
                SizedBox(width: 8.w),
                Text(
                  user.phone,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_SEMIBOLD,
                    fontSize: 14.sp,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: FontRes.MANROPE_SEMIBOLD,
          fontSize: 11.sp,
          letterSpacing: 0.8,
          color: context.colors.textHint,
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.error,
          side: BorderSide(color: colors.error.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        icon: Icon(Icons.logout_rounded, size: 20.w),
        label: Text(
          context.l10n.settingsLogout,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_BOLD,
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
