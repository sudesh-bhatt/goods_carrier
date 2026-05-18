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

/// Figma profile screen tokens — [My Profile](https://www.figma.com/design/YxnNResvDQnbkcPhGejtxa/Mobile-App-UI--Developer-?node-id=1-1931).
abstract final class _ProfileTokens {
  static const heroShadow = BoxShadow(
    color: Color.fromRGBO(22, 28, 32, 0.04),
    blurRadius: 40,
    offset: Offset(0, 20),
  );
  static const overlayAccent = Color.fromRGBO(255, 109, 0, 0.05);
  static const avatarBorder = Color(0xFFEFF4FA);
  static const nameColor = Color(0xFF161C20);
  static const roleColor = Color.fromRGBO(89, 65, 54, 0.7);
  static const sectionLabelColor = Color.fromRGBO(89, 65, 54, 0.5);
  static const verifiedGreen = Color(0xFF4CAF50);
  static const logoutRed = Color(0xFFBA1A1A);
  static const logoutBorder = Color.fromRGBO(226, 191, 176, 0.3);
}

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
    final l10n = context.l10n;
    final user = ref.watch(authProvider).user!;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileHeroCard(user: user),
          SizedBox(height: 32.h), 
          _ProfileSection(
            label: l10n.customerAccountSettings,
            children: [
              CustomerProfileMenuRow(
                icon: Icons.person_outline_rounded,
                iconStyle: ProfileMenuIconStyle.accent,
                title: l10n.customerEditPersonalInfo,
                subtitle: l10n.customerEditPersonalInfoSub,
                onTap: () => context.push(AppRoutes.customerEditProfile),
              ),
              CustomerProfileMenuRow(
                icon: Icons.location_on_outlined,
                title: l10n.customerSavedAddresses,
                subtitle: l10n.customerSavedAddressesSub,
                onTap: () {},
              ),
              CustomerProfileMenuRow(
                icon: Icons.local_shipping_outlined,
                title: l10n.customerReportedTrips,
                subtitle: l10n.customerReportedTripsSub,
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: 32.h),
          _ProfileSection(
            label: l10n.customerActivity,
            children: [
              CustomerProfileMenuRow(
                icon: Icons.settings_outlined,
                iconSize: 24,
                title: l10n.settingsTitle,
                subtitle: l10n.customerSettingsSub,
                onTap: () {},
              ),
              CustomerProfileMenuRow(
                icon: Icons.help_outline_rounded,
                title: l10n.customerHelpSupport,
                subtitle: l10n.customerHelpSupportSub,
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: 32.h),
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
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.label,
    required this.children,
  });

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: FontRes.MANROPE_EXTRABOLD,
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              height: 16 / 12,
              letterSpacing: 2.4,
              color: _ProfileTokens.sectionLabelColor,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) SizedBox(height: 4.h),
              children[i],
            ],
          ],
        ),
      ],
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: Material(
        color: colors.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: const [_ProfileTokens.heroShadow],
          ),
          padding: EdgeInsets.all(24.w),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -64.w,
                top: -64.h,
                child: Container(
                  width: 128.w,
                  height: 128.w,
                  decoration: const BoxDecoration(
                    color: _ProfileTokens.overlayAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 96.w,
                        height: 96.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _ProfileTokens.avatarBorder,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 44.w,
                          backgroundColor: colors.primary.withValues(alpha: 0.12),
                          child: Text(
                            user.initials,
                            style: TextStyle(
                              fontFamily: FontRes.MANROPE_EXTRABOLD,
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w800,
                              color: colors.primaryDark,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 4.w,
                        bottom: 4.h,
                        child: Container(
                          width: 22.w,
                          height: 22.w,
                          decoration: BoxDecoration(
                            color: _ProfileTokens.verifiedGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.surface, width: 2),
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 12.w,
                            color: colors.surface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      user.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_EXTRABOLD,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        height: 32 / 24,
                        letterSpacing: -0.6,
                        color: _ProfileTokens.nameColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      l10n.customerRoleLabel.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_SEMIBOLD,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        height: 20 / 14,
                        letterSpacing: 1.4,
                        color: _ProfileTokens.roleColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: _ProfileTokens.avatarBorder,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 10.5.w,
                          color: colors.primaryDark,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          user.phone,
                          style: TextStyle(
                            fontFamily: FontRes.MANROPE_MEDIUM,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            height: 20 / 14,
                            color: _ProfileTokens.nameColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ),
            ],
          ),
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
    return SizedBox(
      width: double.infinity,
      height: 60.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _ProfileTokens.logoutRed,
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          side: const BorderSide(
            color: _ProfileTokens.logoutBorder,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.logout_rounded, size: 18.w, color: _ProfileTokens.logoutRed),
            SizedBox(width: 12.w),
            Text(
              context.l10n.settingsLogout,
              style: TextStyle(
                fontFamily: FontRes.MANROPE_BOLD,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                height: 24 / 16,
                color: _ProfileTokens.logoutRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
