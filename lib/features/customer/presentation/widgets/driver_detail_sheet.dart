import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/utils/external_launcher.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../../shared/domain/models/customer_shipment_detail.dart';
import '../../../../shared/presentation/widgets/sheets/app_bottom_sheet.dart';
import '../../../../shared/presentation/widgets/sheets/app_modal_bottom_sheet.dart';
import '../providers/customer_shipments_provider.dart';

/// Modal bottom sheet displaying driver detail + "Select Driver" CTA.
class DriverDetailSheet extends ConsumerWidget {
  const DriverDetailSheet._({
    required this.driverId,
    required this.shipmentId,
    required this.driver,
  });

  final String driverId;
  final String shipmentId;
  final ShipmentInterestedDriver driver;

  static Future<bool?> show(
    BuildContext context, {
    required String driverId,
    required String shipmentId,
    ShipmentInterestedDriver? driver,
  }) =>
      AppModalBottomSheet.show<bool>(
        context: context,
        builder: (_) => DriverDetailSheet._(
          driverId: driverId,
          shipmentId: shipmentId,
          driver: driver ??
              ShipmentInterestedDriver(
                driverId: driverId,
                name: 'Driver',
              ),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  _InfoCard(
                    title: 'Vehicle Info',
                    rows: [
                      if (driver.vehicleName.isNotEmpty)
                        _InfoRow(
                          icon: Icons.local_shipping_outlined,
                          label: 'Vehicle',
                          value: driver.vehicleName,
                        ),
                      if (driver.vehicleNumber.isNotEmpty)
                        _InfoRow(
                          icon: Icons.confirmation_number_outlined,
                          label: 'Number',
                          value: driver.vehicleNumber,
                        ),
                      if (driver.capacityLabel.isNotEmpty)
                        _InfoRow(
                          icon: Icons.scale_outlined,
                          label: 'Capacity',
                          value: driver.capacityLabel,
                        ),
                      if (driver.phone != null && driver.phone!.isNotEmpty)
                        _InfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Phone',
                          value: driver.phone!,
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
            onPrimary: () async {
              final apiShipmentId = ref
                  .read(customerShipmentsProvider.notifier)
                  .apiResourceIdFor(shipmentId);
              await ref
                  .read(customerShipmentsProvider.notifier)
                  .selectDriver(apiShipmentId, driverId);
              if (context.mounted) Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );
  }
}

class _DriverHeader extends StatelessWidget {
  const _DriverHeader({required this.driver});
  final ShipmentInterestedDriver driver;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initials = driver.name.trim().isNotEmpty
        ? driver.name.trim().split(' ').take(2).map((p) => p[0]).join()
        : 'D';

    return Row(
      children: [
        Container(
          width: 64.w,
          height: 64.w,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initials.toUpperCase(),
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
              if (driver.subtitle != null && driver.subtitle!.isNotEmpty)
                Text(
                  driver.subtitle!,
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
                  color: colors.success.withValues(alpha: 0.12),
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
        if (driver.phone != null && driver.phone!.isNotEmpty) ...[
          IconButton(
            onPressed: () {
              final parts = PhoneUtils.splitE164(driver.phone!);
              ExternalLauncher.dialPhone(
                dialCode: parts.dialCode,
                localNumber: parts.localNumber,
              );
            },
            icon: const Icon(Icons.phone_outlined),
          ),
        ],
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.rows});
  final String title;
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (rows.isEmpty) return const SizedBox.shrink();

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
