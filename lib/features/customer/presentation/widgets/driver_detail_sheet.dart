import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/dummy/dummy_user.dart';
import '../../../../shared/domain/entities/user.dart';
import '../../../../shared/presentation/widgets/sheets/app_bottom_sheet.dart';
import '../../../../shared/presentation/widgets/sheets/app_modal_bottom_sheet.dart';
import '../providers/customer_shipments_provider.dart';

/// Modal bottom sheet displaying driver detail + "Select Driver" CTA.
class DriverDetailSheet extends ConsumerWidget {
  const DriverDetailSheet._({
    required this.driverId,
    required this.shipmentId,
  });

  final String driverId;
  final String shipmentId;

  static Future<bool?> show(
    BuildContext context, {
    required String driverId,
    required String shipmentId,
  }) =>
      AppModalBottomSheet.show<bool>(
        context: context,
        builder: (_) => DriverDetailSheet._(
          driverId: driverId,
          shipmentId: shipmentId,
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const driver = DummyUser.driver;

    return AppBottomSheetContainer(
      maxHeight: MediaQuery.sizeOf(context).height *
          AppBottomSheetTokens.maxHeightFraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppBottomSheetTitle(text: driver.name),
          SizedBox(height: AppBottomSheetTokens.sectionGap.h),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DriverHeader(driver: driver),
                  SizedBox(height: AppDimensions.xl.h),
                  _StatsRow(driver: driver),
                  SizedBox(height: AppDimensions.xl.h),
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
                ],
              ),
            ),
          ),
          SizedBox(height: AppBottomSheetTokens.sectionGap.h),
          AppBottomSheetActionRow(
            secondaryLabel: context.l10n.actionNo,
            primaryLabel: context.l10n.shipmentSelectDriver,
            onSecondary: () => Navigator.of(context).pop(false),
            onPrimary: () {
              ref
                  .read(customerShipmentsProvider.notifier)
                  .selectDriver(shipmentId, driverId);
              Navigator.of(context).pop(true);
            },
          ),
        ],
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
                driver.phone,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: colors.success.withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull.r),
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
      const _Stat(label: 'Trips', value: '142'),
      const _Stat(label: 'Rating', value: '4.8 ★'),
      const _Stat(label: 'Years', value: '6+'),
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
                    color: colors.textHint,
                  ),
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
  final String title;
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
  final String label;
  final String value;

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
