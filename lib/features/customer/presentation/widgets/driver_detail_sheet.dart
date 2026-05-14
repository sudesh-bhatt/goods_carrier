import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/dummy/dummy_user.dart';
import '../../../../shared/domain/entities/user.dart';
import '../../../../shared/presentation/widgets/buttons/app_button.dart';
import '../providers/customer_shipments_provider.dart';

/// Modal bottom sheet displaying driver detail + "Select Driver" CTA.
///
/// Shows dummy [DummyUser.driver] data (real driver lookup comes in Session 7).
/// On "Select Driver" → calls [CustomerShipmentsNotifier.selectDriver] and pops.
class DriverDetailSheet extends ConsumerWidget {
  const DriverDetailSheet._({
    required this.driverId,
    required this.shipmentId,
  });

  final String driverId;
  final String shipmentId;

  /// Show the sheet and return whether a driver was selected.
  static Future<bool?> show(
    BuildContext context, {
    required String driverId,
    required String shipmentId,
  }) =>
      showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => DriverDetailSheet._(
          driverId:   driverId,
          shipmentId: shipmentId,
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    // In Session 7 this will do a real driver lookup by driverId.
    // For now, map everything to DummyUser.driver.
    const driver = DummyUser.driver;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize:     0.5,
      maxChildSize:     0.92,
      builder: (context, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusLg.r),
          ),
        ),
        child: Column(
          children: [
            // Drag handle
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppDimensions.sm.h),
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull.r),
                ),
              ),
            ),

            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.screenPadding.w),
                children: [
                  // ── Driver header ─────────────────────────────────────
                  _DriverHeader(driver: driver),

                  SizedBox(height: AppDimensions.xl.h),

                  // ── Stats row ────────────────────────────────────────
                  _StatsRow(driver: driver),

                  SizedBox(height: AppDimensions.xl.h),

                  // ── Vehicle details ──────────────────────────────────
                  _InfoCard(
                    title: 'Vehicle Info',
                    rows: [
                      _InfoRow(
                        icon: Icons.local_shipping_outlined,
                        label: 'Company',
                        value: driver.companyName ?? '—',
                      ),
                      _InfoRow(
                        icon: Icons.badge_outlined,
                        label: 'GST Number',
                        value: driver.gstNumber ?? '—',
                      ),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Business Phone',
                        value: driver.businessPhone ?? driver.phone,
                      ),
                    ],
                  ),

                  SizedBox(height: AppDimensions.xl.h),

                  // ── Select CTA ────────────────────────────────────────
                  AppButton(
                    label: context.l10n.shipmentSelectDriver,
                    onPressed: () {
                      ref
                          .read(customerShipmentsProvider.notifier)
                          .selectDriver(shipmentId, driverId);
                      Navigator.of(context).pop(true);
                    },
                  ),

                  SizedBox(height: AppDimensions.xl.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Driver header ────────────────────────────────────────────────────────────

class _DriverHeader extends StatelessWidget {
  const _DriverHeader({required this.driver});
  final User driver;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        // Avatar initials
        Container(
          width: 64.w,
          height: 64.w,
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              driver.initials,
              style: context.textTheme.titleLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        SizedBox(width: AppDimensions.base.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                driver.name,
                style: context.textTheme.titleMedium?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                driver.phone,
                style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: colors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
                ),
                child: Text(
                  'Verified Driver',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: colors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Stats row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.driver});
  final User driver;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final stats = [
      const _Stat(label: 'Trips',  value: '142'),
      const _Stat(label: 'Rating', value: '4.8 ★'),
      const _Stat(label: 'Years',  value: '6+'),
    ];
    return Row(
      children: stats.map((s) {
        return Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: AppDimensions.base.h),
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
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
                  style: context.textTheme.bodySmall?.copyWith(
                      color: colors.textHint),
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
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;
}

// ─── Info card ────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.rows});
  final String         title;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.labelMedium?.copyWith(
              color: colors.textHint,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppDimensions.sm.h),
          ...rows.map((r) => Padding(
                padding: EdgeInsets.only(bottom: AppDimensions.sm.h),
                child: r,
              )),
        ],
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
      children: [
        Icon(icon, size: AppDimensions.iconMd.w, color: colors.textHint),
        SizedBox(width: AppDimensions.sm.w),
        Text(
          '$label: ',
          style: context.textTheme.bodySmall?.copyWith(color: colors.textHint),
        ),
        Expanded(
          child: Text(
            value,
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
