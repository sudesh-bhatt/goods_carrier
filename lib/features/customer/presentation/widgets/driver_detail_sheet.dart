import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/num_ext.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/string_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/utils/external_launcher.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/domain/models/customer_shipment_detail.dart';
import '../../../../shared/presentation/widgets/profile/profile_image_content.dart';
import '../../../../shared/presentation/widgets/sheets/app_bottom_sheet.dart';
import '../../../../shared/presentation/widgets/sheets/app_modal_bottom_sheet.dart';
import '../providers/customer_shipments_provider.dart';
import 'shipment_publish/shipment_publish_tokens.dart';

/// Modal bottom sheet displaying driver detail + "Select Driver" CTA.
class DriverDetailSheet extends ConsumerWidget {
  const DriverDetailSheet._({
    required this.driverId,
    required this.shipmentId,
    required this.driver,
    required this.isAssigned,
  });

  final String driverId;
  final String shipmentId;
  final ShipmentInterestedDriver driver;
  final bool isAssigned;

  static Future<ShipmentAssignmentResult?> show(
    BuildContext context, {
    required String driverId,
    required String shipmentId,
    ShipmentInterestedDriver? driver,
    bool isAssigned = false,
  }) =>
      AppModalBottomSheet.show<ShipmentAssignmentResult>(
        context: context,
        builder: (_) => DriverDetailSheet._(
          driverId: driverId,
          shipmentId: shipmentId,
          isAssigned: isAssigned,
          driver: driver ??
              ShipmentInterestedDriver(
                driverId: driverId,
                name: 'Driver',
              ),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return AppBottomSheetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DriverHeader(
            driver: driver,
            expertLabel: l10n.customerExpertDriver,
            statusLabel: isAssigned ? l10n.customerDriverAccepted : null,
          ),
          SizedBox(height: 20.h),
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
                  value: driver.vehicleNumber.toUpperCase(),
                ),
              if (driver.capacityLabel.isNotEmpty)
                _InfoRow(
                  icon: Icons.scale_outlined,
                  label: 'Capacity',
                  value: driver.capacityLabel.toUpperCase(),
                ),
              if (driver.phone != null && driver.phone!.isNotEmpty)
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: driver.phone!,
                ),
            ],
          ),
          if (driver.offeredPrice != null ||
              (driver.note != null && driver.note!.isNotEmpty)) ...[
            SizedBox(height: 12.h),
            _RequestDetailsCard(
              offeredPriceLabel: l10n.driverOfferedPrice,
              noteLabel: l10n.driverRequestNote,
              offeredPrice: driver.offeredPrice,
              note: driver.note,
            ),
          ],
          if (!isAssigned) ...[
            SizedBox(height: AppBottomSheetTokens.sectionGap.h),
            AppBottomSheetActionRow(
              secondaryLabel: l10n.actionNo,
              primaryLabel: l10n.shipmentSelectDriver,
              onSecondary: () => Navigator.of(context).pop(),
              onPrimary: () async {
                final apiShipmentId = ref
                    .read(customerShipmentsProvider.notifier)
                    .apiResourceIdFor(shipmentId);
                final result = await ref
                    .read(customerShipmentsProvider.notifier)
                    .selectDriver(apiShipmentId, driverId);
                if (!context.mounted) return;
                if (result == null) {
                  final error = ref.read(customerShipmentsProvider).error;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error ?? context.l10n.errorGeneric),
                    ),
                  );
                  return;
                }
                Navigator.of(context).pop(result);
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _DriverHeader extends StatelessWidget {
  const _DriverHeader({
    required this.driver,
    required this.expertLabel,
    this.statusLabel,
  });

  final ShipmentInterestedDriver driver;
  final String expertLabel;
  final String? statusLabel;

  @override
  Widget build(BuildContext context) {
    final subtitle = driver.subtitle?.trim();
    final hasPhone = driver.phone != null && driver.phone!.isNotEmpty;
    final badgeLabel = statusLabel?.trim().isNotEmpty == true
        ? statusLabel!.trim()
        : 'Verified Driver';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _DriverAvatar(name: driver.name, avatarUrl: driver.avatarUrl),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                driver.name,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_BOLD,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  height: 24 / 18,
                  color: ShipmentPublishTokens.bodyDark,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle != null && subtitle.isNotEmpty
                    ? subtitle
                    : expertLabel,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_MEDIUM,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  height: 16 / 12,
                  color: ShipmentPublishTokens.subtitleGrey,
                ),
              ),
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: ShipmentPublishTokens.publishBg,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  badgeLabel.toUpperCase(),
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_SEMIBOLD,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    height: 14 / 10,
                    color: ShipmentPublishTokens.publishFg,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasPhone) ...[
          SizedBox(width: 8.w),
          _HeaderCallButton(
            onTap: () {
              final phone = driver.phone!.trim();
              final dialCode = driver.countryCode.isNotEmpty
                  ? driver.countryCode
                  : PhoneUtils.splitE164(phone).dialCode;
              final localNumber = phone.startsWith('+')
                  ? PhoneUtils.splitE164(phone).localNumber
                  : phone.replaceAll(RegExp(r'\D'), '');
              ExternalLauncher.dialPhone(
                dialCode: dialCode,
                localNumber: localNumber,
              );
            },
          ),
        ],
      ],
    );
  }
}

class _DriverAvatar extends StatelessWidget {
  const _DriverAvatar({required this.name, this.avatarUrl});

  final String name;
  final String? avatarUrl;

  Widget _placeholder() {
    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        color: ShipmentPublishTokens.routeRing.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24.r),
      ),
      alignment: Alignment.center,
      child: Text(
        name.initials,
        style: TextStyle(
          fontFamily: FontRes.MANROPE_BOLD,
          fontSize: 18.sp,
          color: ShipmentPublishTokens.routeRing,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56.w,
      height: 56.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: ProfileImageContent(
              imageReference: avatarUrl,
              placeholder: _placeholder(),
            ),
          ),
          Positioned(
            right: -4.w,
            bottom: -4.h,
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: ShipmentPublishTokens.routeRing,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(Icons.verified, size: 12.w, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCallButton extends StatelessWidget {
  const _HeaderCallButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ShipmentPublishTokens.cardDriver,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          width: 42.w,
          height: 42.w,
          child: Icon(
            Icons.phone_outlined,
            size: 18.w,
            color: ShipmentPublishTokens.bodyDark,
          ),
        ),
      ),
    );
  }
}

class _RequestDetailsCard extends StatelessWidget {
  const _RequestDetailsCard({
    required this.offeredPriceLabel,
    required this.noteLabel,
    this.offeredPrice,
    this.note,
  });

  final String offeredPriceLabel;
  final String noteLabel;
  final double? offeredPrice;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final hasPrice = offeredPrice != null && offeredPrice! > 0;
    final trimmedNote = note?.trim();
    final hasNote = trimmedNote != null && trimmedNote.isNotEmpty;
    if (!hasPrice && !hasNote) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.base.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: ShipmentPublishTokens.routeLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasPrice) ...[
            Row(
              children: [
                Icon(
                  Icons.payments_outlined,
                  size: 18.w,
                  color: ShipmentPublishTokens.subtitleGrey,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    offeredPriceLabel,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_REGULAR,
                      fontSize: 14.sp,
                      height: 20 / 14,
                      color: ShipmentPublishTokens.subtitleGrey,
                    ),
                  ),
                ),
                Text(
                  offeredPrice!.inrDetailed,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_EXTRABOLD,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    height: 24 / 18,
                    color: ShipmentPublishTokens.priceBrown,
                  ),
                ),
              ],
            ),
          ],
          if (hasPrice && hasNote) SizedBox(height: 12.h),
          if (hasNote)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.sticky_note_2_outlined,
                  size: 18.w,
                  color: ShipmentPublishTokens.subtitleGrey,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        noteLabel,
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_REGULAR,
                          fontSize: 14.sp,
                          height: 20 / 14,
                          color: ShipmentPublishTokens.subtitleGrey,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        trimmedNote,
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_SEMIBOLD,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          height: 20 / 14,
                          color: ShipmentPublishTokens.bodyDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
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
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.base.w),
      decoration: BoxDecoration(
        color: ShipmentPublishTokens.cardDriver,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: FontRes.MANROPE_SEMIBOLD,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: colors.textHint,
            ),
          ),
          SizedBox(height: 12.h),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) SizedBox(height: 10.h),
            rows[i],
          ],
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18.w,
          color: ShipmentPublishTokens.subtitleGrey,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: FontRes.MANROPE_REGULAR,
                fontSize: 14.sp,
                height: 20 / 14,
                color: ShipmentPublishTokens.subtitleGrey,
              ),
              children: [
                TextSpan(text: '$label: '),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontFamily: FontRes.MANROPE_SEMIBOLD,
                    fontWeight: FontWeight.w600,
                    color: ShipmentPublishTokens.bodyDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
