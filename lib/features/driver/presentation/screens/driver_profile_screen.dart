import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../shared/domain/entities/user.dart';
import '../../../../shared/presentation/widgets/buttons/app_button.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../../../../shared/presentation/widgets/navigation/confirmation_bottom_sheet.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../settings/presentation/providers/theme_provider.dart';
import '../providers/driver_trips_provider.dart';

/// Driver profile screen.
///
/// Shows personal info, vehicle details (from last active/completed trip),
/// a subscription tier badge, trip history tabs, and theme toggle.
class DriverProfileScreen extends ConsumerWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors    = context.colors;
    final user      = ref.watch(authProvider).user!;
    final tripsState = ref.watch(driverTripsProvider);
    final themeMode  = ref.watch(themeProvider);
    final allTrips   = tripsState.trips;
    final completed  = tripsState.completed;

    // Derive vehicle info from the most recent trip (placeholder for Session 7 profile API)
    final latestTrip = allTrips.isNotEmpty ? allTrips.first : null;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBarWidget(
        title: 'My Profile',
        actions: [
          AppBarAction(
            icon: Icons.edit_outlined,
            onTap: () {}, // Edit profile — Session 7
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPadding.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppDimensions.xl.h),

              // ── Avatar + name + tier badge ─────────────────────────────
              _DriverHeader(user: user),

              SizedBox(height: AppDimensions.xxl.h),

              // ── Stats row ─────────────────────────────────────────────
              _StatsRow(
                trips:    allTrips.length,
                completed: completed.length,
                rating:   '4.8',
              ),

              SizedBox(height: AppDimensions.xl.h),

              // ── Personal info ─────────────────────────────────────────
              const _SectionTitle(title: 'Personal Information'),
              SizedBox(height: AppDimensions.sm.h),
              _InfoCard(
                rows: [
                  _InfoRow(
                    icon: Icons.person_outline_rounded,
                    label: context.l10n.profileName,
                    value: user.name,
                  ),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: context.l10n.profilePhone,
                    value: user.phone,
                  ),
                  _InfoRow(
                    icon: Icons.email_outlined,
                    label: context.l10n.profileEmail,
                    value: user.email,
                  ),
                ],
              ),

              // ── Vehicle / business info ───────────────────────────────
              if (latestTrip != null) ...[
                SizedBox(height: AppDimensions.xl.h),
                const _SectionTitle(title: 'Vehicle Details'),
                SizedBox(height: AppDimensions.sm.h),
                _InfoCard(
                  rows: [
                    _InfoRow(
                      icon: Icons.local_shipping_outlined,
                      label: context.l10n.profileVehicleType,
                      value: latestTrip.vehicleCategory.label,
                    ),
                    _InfoRow(
                      icon: Icons.directions_car_outlined,
                      label: context.l10n.profileVehicleNumber,
                      value: latestTrip.vehicleNumber,
                    ),
                    _InfoRow(
                      icon: Icons.scale_outlined,
                      label: context.l10n.profileLoadCapacity,
                      value: '${latestTrip.loadCapacityTons} Ton',
                    ),
                  ],
                ),
              ],

              if (user.gstNumber != null || user.companyName != null) ...[
                SizedBox(height: AppDimensions.xl.h),
                const _SectionTitle(title: 'Business Details'),
                SizedBox(height: AppDimensions.sm.h),
                _InfoCard(
                  rows: [
                    if (user.companyName != null)
                      _InfoRow(
                        icon: Icons.business_outlined,
                        label: context.l10n.profileCompanyName,
                        value: user.companyName!,
                      ),
                    if (user.gstNumber != null)
                      _InfoRow(
                        icon: Icons.receipt_long_outlined,
                        label: context.l10n.profileGstNumber,
                        value: user.gstNumber!,
                      ),
                  ],
                ),
              ],

              SizedBox(height: AppDimensions.xl.h),

              // ── Theme toggle ──────────────────────────────────────────
              _SectionTitle(title: context.l10n.settingsTheme),
              SizedBox(height: AppDimensions.sm.h),
              _ThemeToggleCard(current: themeMode),

              SizedBox(height: AppDimensions.xxl.h),

              // ── Logout ────────────────────────────────────────────────
              AppButton(
                label: context.l10n.settingsLogout,
                variant: AppButtonVariant.secondary,
                onPressed: () async {
                  final confirmed = await ConfirmationBottomSheet.show(
                    context,
                    title:       context.l10n.settingsLogout,
                    body:        context.l10n.settingsLogoutConfirm,
                    confirmLabel: context.l10n.actionYes,
                    isDangerous:  true,
                  );
                  if (confirmed == true && context.mounted) {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go(AppRoutes.splash);
                  }
                },
              ),

              SizedBox(height: AppDimensions.xl.h),
              Center(
                child: Text(
                  context.l10n.settingsVersion('1.0.0'),
                  style: context.textTheme.bodySmall
                      ?.copyWith(color: colors.textHint),
                ),
              ),
              SizedBox(height: AppDimensions.xl.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Driver header ─────────────────────────────────────────────────────────────

class _DriverHeader extends StatelessWidget {
  const _DriverHeader({required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 88.w,
                height: 88.w,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user.initials,
                    style: context.textTheme.headlineMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.surface, width: 2),
                  ),
                  child: Icon(Icons.camera_alt_outlined,
                      size: 14.w, color: colors.onPrimary),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.sm.h),
          Text(
            user.name,
            style: context.textTheme.titleLarge?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4.h),
          // Subscription tier badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.base.w,
              vertical: 4.h,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.ratingBannerGradientStart,
                  colors.ratingBannerGradientEnd,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusFull.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium_rounded,
                    size: 14.w, color: colors.onPrimary),
                SizedBox(width: 4.w),
                Text(
                  'Gold Member',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
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

// ─── Stats row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.trips,
    required this.completed,
    required this.rating,
  });

  final int    trips;
  final int    completed;
  final String rating;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final stats = [
      _Stat('Total Trips',  trips.toString()),
      _Stat('Completed',    completed.toString()),
      _Stat('Rating',       '$rating ★'),
    ];

    return Row(
      children: stats.map((s) {
        return Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: AppDimensions.base.h),
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusMd.r),
              boxShadow: context.cardShadow,
            ),
            child: Column(
              children: [
                Text(
                  s.value,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  s.label,
                  style: context.textTheme.bodySmall
                      ?.copyWith(color: colors.textHint),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Stat {
  const _Stat(this.label, this.value);
  final String label;
  final String value;
}

// ─── Theme toggle (same pattern as CustomerProfileScreen) ─────────────────────

class _ThemeToggleCard extends ConsumerWidget {
  const _ThemeToggleCard({required this.current});
  final ThemeMode current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final options = [
      (ThemeMode.light,  context.l10n.settingsThemeLight,  Icons.light_mode_outlined),
      (ThemeMode.dark,   context.l10n.settingsThemeDark,   Icons.dark_mode_outlined),
      (ThemeMode.system, context.l10n.settingsThemeSystem, Icons.brightness_auto_outlined),
    ];

    return Container(
      padding: EdgeInsets.all(AppDimensions.sm.w),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
        boxShadow: context.cardShadow,
      ),
      child: Row(
        children: options.map((opt) {
          final (mode, label, icon) = opt;
          final isSelected = current == mode;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(themeProvider.notifier).setMode(mode);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                    vertical: AppDimensions.sm.h, horizontal: 4.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primary.withOpacity(0.10)
                      : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSm.r),
                  border: Border.all(
                    color: isSelected ? colors.primary : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon,
                        size: AppDimensions.iconBase.w,
                        color: isSelected
                            ? colors.primary
                            : colors.textHint),
                    SizedBox(height: 4.h),
                    Text(
                      label,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? colors.primary
                            : colors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: context.textTheme.titleSmall?.copyWith(
          color: context.colors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.all(AppDimensions.base.w),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        children: rows
            .asMap()
            .entries
            .map(
              (e) => Column(
                children: [
                  e.value,
                  if (e.key < rows.length - 1)
                    Divider(
                        height: AppDimensions.xl.h, color: colors.divider),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String   label;
  final String   value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppDimensions.iconMd.w, color: colors.textHint),
        SizedBox(width: AppDimensions.sm.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: context.textTheme.bodySmall
                      ?.copyWith(color: colors.textHint)),
              SizedBox(height: 2.h),
              Text(
                value,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
