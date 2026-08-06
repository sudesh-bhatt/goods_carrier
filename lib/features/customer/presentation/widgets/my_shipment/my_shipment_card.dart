import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/extensions/num_ext.dart';
import '../../../../../core/extensions/size_ext.dart';
import '../../../../../core/extensions/string_ext.dart';
import '../../../../../core/extensions/theme_ext.dart';
import '../../../../../res/font_res.dart';
import '../../../../../shared/domain/entities/shipment.dart';
import '../../../../../shared/domain/enums/shipment_status.dart';
import '../../models/customer_shipment_status_badge.dart';
import 'my_shipment_card_tokens.dart';

/// My Shipment tab list card — Figma `1:2327` / `1:2328`.
class MyShipmentListCard extends StatelessWidget {
  const MyShipmentListCard({
    super.key,
    required this.shipment,
    required this.shipmentIdLabel,
    required this.estimatedPayLabel,
    required this.fromLabel,
    required this.toLabel,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    this.onEdit,
    this.onDelete,
    this.showEditDelete = true,
  });

  final Shipment shipment;
  final String shipmentIdLabel;
  final String estimatedPayLabel;
  final String fromLabel;
  final String toLabel;
  final String primaryActionLabel;
  final VoidCallback onPrimaryAction;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showEditDelete;

  String get _displayId =>
      shipment.id.startsWith('#') ? shipment.id : '#${shipment.id}';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MyShipmentCardTokens.cardBg,
        borderRadius:
            BorderRadius.circular(MyShipmentCardTokens.cardRadius.r),
        boxShadow: const [MyShipmentCardTokens.cardShadow],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderRow(
            shipmentIdLabel: shipmentIdLabel,
            displayId: _displayId,
            status: shipment.status,
            allottedStatus: shipment.allottedStatus,
          ),
          SizedBox(height: 24.h),
          _PriceBlock(
            priceText: shipment.estimatedPrice.inr,
            label: estimatedPayLabel,
          ),
          SizedBox(height: 24.h),
          _CompactRouteRow(
            fromLabel: fromLabel,
            toLabel: toLabel,
            fromCity: shipment.pickup.displayLabel,
            toCity: shipment.drop.displayLabel,
          ),
          SizedBox(height: 24.h),
          _MetaDividerRow(
            dateLine: shipment.pickupDateTime.displayDate,
            timeLine: shipment.pickupDateTime.displayTime,
            vehicleLine: shipment.vehicleType.label,
            capacityLine: shipment.loadCapacityLabel,
          ),
          SizedBox(height: 24.h),
          _ActionRow(
            primaryLabel: primaryActionLabel,
            onPrimary: onPrimaryAction,
            onEdit: onEdit,
            onDelete: onDelete,
            showEditDelete: showEditDelete,
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.shipmentIdLabel,
    required this.displayId,
    required this.status,
    this.allottedStatus,
  });

  final String shipmentIdLabel;
  final String displayId;
  final ShipmentStatus status;
  final String? allottedStatus;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                shipmentIdLabel.toUpperCase(),
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_BOLD,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  letterSpacing: 1,
                  color: MyShipmentCardTokens.labelBrown,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                displayId,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_EXTRABOLD,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  height: 28 / 20,
                  color: MyShipmentCardTokens.bodyDark,
                ),
              ),
            ],
          ),
        ),
        _StatusBadge(status: status, allottedStatus: allottedStatus),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, this.allottedStatus});

  final ShipmentStatus status;
  final String? allottedStatus;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = customerShipmentStatusBadgeLabel(
      l10n,
      status,
      allottedStatus: allottedStatus,
    );
    final hasAllotted =
        allottedStatus != null && allottedStatus!.trim().isNotEmpty;
    final (bg, fg) = switch (status) {
      ShipmentStatus.cancelled when !hasAllotted => (
          MyShipmentCardTokens.expiredBg,
          MyShipmentCardTokens.expiredFg,
        ),
      _ => (
          MyShipmentCardTokens.publishedBg,
          MyShipmentCardTokens.publishedFg,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: FontRes.MANROPE_BOLD,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          height: 1.5,
          letterSpacing: -0.5,
          color: fg,
        ),
      ),
    );
  }
}

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({required this.priceText, required this.label});

  final String priceText;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          priceText,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_EXTRABOLD,
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            height: 28 / 18,
            color: MyShipmentCardTokens.priceBrown,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_MEDIUM,
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            height: 1.5,
            color: MyShipmentCardTokens.labelBrown,
          ),
        ),
      ],
    );
  }
}

class _CompactRouteRow extends StatelessWidget {
  const _CompactRouteRow({
    required this.fromLabel,
    required this.toLabel,
    required this.fromCity,
    required this.toCity,
  });

  final String fromLabel;
  final String toLabel;
  final String fromCity;
  final String toCity;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 12.w,
            child: Column(
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: MyShipmentCardTokens.routeRing,
                      width: 2,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Center(
                      child: Container(
                        width: 2.w,
                        height: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF8D7164), Color(0x008D7164)],
                            stops: [0.33, 0.33],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: const BoxDecoration(
                    color: MyShipmentCardTokens.routeRing,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RouteStop(label: fromLabel, city: fromCity),
                _RouteStop(label: toLabel, city: toCity),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteStop extends StatelessWidget {
  const _RouteStop({required this.label, required this.city});

  final String label;
  final String city;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_BOLD,
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            height: 1.5,
            letterSpacing: 1,
            color: MyShipmentCardTokens.labelBrown,
          ),
        ),
        Text(
          city,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_BOLD,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            height: 24 / 16,
            color: MyShipmentCardTokens.bodyDark,
          ),
        ),
      ],
    );
  }
}

class _MetaDividerRow extends StatelessWidget {
  const _MetaDividerRow({
    required this.dateLine,
    required this.timeLine,
    required this.vehicleLine,
    required this.capacityLine,
  });

  final String dateLine;
  final String timeLine;
  final String vehicleLine;
  final String capacityLine;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 17.h),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: MyShipmentCardTokens.metaDivider),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _MetaColumn(
              icon: Icons.calendar_today_outlined,
              line1: dateLine,
              line2: timeLine,
            ),
          ),
          Expanded(
            child: _MetaColumn(
              icon: Icons.local_shipping_outlined,
              line1: vehicleLine,
              line2: capacityLine,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaColumn extends StatelessWidget {
  const _MetaColumn({
    required this.icon,
    required this.line1,
    required this.line2,
  });

  final IconData icon;
  final String line1;
  final String line2;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14.w, color: MyShipmentCardTokens.labelBrown),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line1,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_BOLD,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  height: 14 / 11,
                  color: MyShipmentCardTokens.bodyDark,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                line2,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_REGULAR,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                  height: 14 / 11,
                  color: MyShipmentCardTokens.labelBrown,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.primaryLabel,
    required this.onPrimary,
    this.onEdit,
    this.onDelete,
    required this.showEditDelete,
  });

  final String primaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showEditDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: MyShipmentCardTokens.primaryOrange,
            borderRadius:
                BorderRadius.circular(MyShipmentCardTokens.actionRadius.r),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onPrimary();
              },
              borderRadius:
                  BorderRadius.circular(MyShipmentCardTokens.actionRadius.r),
              child: SizedBox(
                height: 40.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      size: 13.w,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      primaryLabel,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_BOLD,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        height: 16 / 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (showEditDelete && onEdit != null) ...[
          SizedBox(width: 8.w),
          _IconActionButton(
            icon: Icons.edit_outlined,
            iconColor: MyShipmentCardTokens.bodyDark,
            onTap: onEdit!,
          ),
        ],
        if (showEditDelete && onDelete != null) ...[
          SizedBox(width: 8.w),
          _IconActionButton(
            icon: Icons.delete_outline,
            iconColor: MyShipmentCardTokens.deleteRed,
            onTap: onDelete!,
          ),
        ],
      ],
    );
  }
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MyShipmentCardTokens.actionSecondaryBg,
      borderRadius:
          BorderRadius.circular(MyShipmentCardTokens.actionRadius.r),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius:
            BorderRadius.circular(MyShipmentCardTokens.actionRadius.r),
        child: SizedBox(
          width: 40.w,
          height: 40.w,
          child: Icon(icon, size: 14.w, color: iconColor),
        ),
      ),
    );
  }
}
