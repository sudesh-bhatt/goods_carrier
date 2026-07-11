import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/extensions/num_ext.dart';
import '../../../../../core/extensions/size_ext.dart';
import '../../../../../core/extensions/string_ext.dart';
import '../../../../../core/extensions/svg_gen_image_extension.dart';
import '../../../../../generated/assets.dart';
import '../../../../../res/font_res.dart';
import '../../../../../shared/presentation/widgets/profile/profile_image_content.dart';
import 'shipment_publish_tokens.dart';

/// Splits "Mumbai, MH" → ("Mumbai", "MH") or city-only.
(String, String) parseLocationLabel(String city) {
  final parts = city.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
  if (parts.length >= 2) {
    return (parts.first, parts.sublist(1).join(', '));
  }
  return (city, '');
}

/// White route + trip id card — Figma `1:2540` section 1.
class PublishRouteCard extends StatelessWidget {
  const PublishRouteCard({
    super.key,
    required this.tripIdLabel,
    required this.displayId,
    required this.publishLabel,
    required this.fromTitle,
    required this.fromSubtitle,
    required this.toTitle,
    required this.toSubtitle,
  });

  final String tripIdLabel;
  final String displayId;
  final String publishLabel;
  final String fromTitle;
  final String fromSubtitle;
  final String toTitle;
  final String toSubtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: ShipmentPublishTokens.cardWhite,
        borderRadius:
            BorderRadius.circular(ShipmentPublishTokens.cardRadius.r),
        boxShadow: const [ShipmentPublishTokens.routeCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tripIdLabel.toUpperCase(),
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_BOLD,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                        letterSpacing: 1,
                        color: ShipmentPublishTokens.labelBrown,
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
                        color: ShipmentPublishTokens.bodyDark,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: ShipmentPublishTokens.publishBg,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  publishLabel.toUpperCase(),
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_BOLD,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    height: 16 / 12,
                    letterSpacing: 0.6,
                    color: ShipmentPublishTokens.publishFg,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 32.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LocationTexts(
                  title: fromTitle,
                  subtitle: fromSubtitle,
                  alignEnd: false,
                ),
              ),
              Expanded(
                child: _LocationTexts(
                  title: toTitle,
                  subtitle: toSubtitle,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              const _RouteDot(isOrigin: true),
              Expanded(
                child: Container(
                  height: 2.h,
                  margin: EdgeInsets.symmetric(horizontal: 8.w),
                  color: ShipmentPublishTokens.routeLine,
                ),
              ),
              const _RouteDot(isOrigin: false),
            ],
          ),
        ],
      ),
    );
  }
}

class _RouteDot extends StatelessWidget {
  const _RouteDot({required this.isOrigin});

  final bool isOrigin;

  @override
  Widget build(BuildContext context) {
    if (isOrigin) {
      return Container(
        width: 8.w,
        height: 8.w,
        decoration: BoxDecoration(
          color: ShipmentPublishTokens.routeRing,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: ShipmentPublishTokens.ringGlow,
              spreadRadius: 4,
            ),
          ],
        ),
      );
    }
    return Container(
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(
        color: ShipmentPublishTokens.routeLine,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE2BFB0), width: 2),
      ),
    );
  }
}

class _LocationTexts extends StatelessWidget {
  const _LocationTexts({
    required this.title,
    required this.subtitle,
    required this.alignEnd,
  });

  final String title;
  final String subtitle;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_SEMIBOLD,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            height: 20 / 14,
            color: ShipmentPublishTokens.labelBrown,
          ),
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: FontRes.MANROPE_REGULAR,
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              height: 16 / 12,
              color: ShipmentPublishTokens.subtitleGrey,
            ),
          ),
      ],
    );
  }
}

/// Interested driver card — `#EFF4FA`, call + WhatsApp.
class PublishDriverInterestCard extends StatelessWidget {
  const PublishDriverInterestCard({
    super.key,
    required this.driverName,
    required this.expertLabel,
    required this.vehicleName,
    required this.vehicleNumber,
    required this.capacityLabel,
    required this.capacityValue,
    this.avatarUrl,
    this.statusLabel,
    this.onTap,
    this.onCall,
    this.onWhatsApp,
  });

  final String driverName;
  final String expertLabel;
  final String vehicleName;
  final String vehicleNumber;
  final String capacityLabel;
  final String capacityValue;
  final String? avatarUrl;
  /// e.g. "Accepted" for the assigned driver.
  final String? statusLabel;
  final VoidCallback? onTap;
  final VoidCallback? onCall;
  final VoidCallback? onWhatsApp;

  @override
  Widget build(BuildContext context) {
    final isTappable = onTap != null;
    final trimmedStatus = statusLabel?.trim();
    final hasStatus = trimmedStatus != null && trimmedStatus.isNotEmpty;

    return Material(
      color: ShipmentPublishTokens.cardDriver,
      borderRadius:
          BorderRadius.circular(ShipmentPublishTokens.cardRadius.r),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(ShipmentPublishTokens.cardRadius.r),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _DriverAvatar(name: driverName, avatarUrl: avatarUrl),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driverName,
                                style: TextStyle(
                                  fontFamily: FontRes.MANROPE_BOLD,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  height: 20 / 14,
                                  color: ShipmentPublishTokens.bodyDark,
                                ),
                              ),
                              if (expertLabel.trim().isNotEmpty)
                                Text(
                                  expertLabel,
                                  style: TextStyle(
                                    fontFamily: FontRes.MANROPE_MEDIUM,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                    color: ShipmentPublishTokens.subtitleGrey,
                                  ),
                                ),
                              if (hasStatus) ...[
                                SizedBox(height: 2.h),
                                _StatusBadge(label: trimmedStatus),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _VehicleMeta(
                            title: vehicleName,
                            subtitle: vehicleNumber,
                          ),
                        ),
                        SizedBox(width: 34.w),
                        Expanded(
                          child: _VehicleMeta(
                            title: capacityLabel,
                            subtitle: capacityValue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                children: [
                  _ContactButton(
                    icon: Icons.phone_outlined,
                    onTap: onCall,
                  ),
                  SizedBox(height: 12.h),
                  _ContactButton(
                    leading: Assets.icWhatsapp.svgTint(
                      width: 18.w,
                      height: 18.w,
                      color: Colors.black,
                    ),
                    onTap: onWhatsApp,
                  ),
                  if (isTappable) ...[
                    SizedBox(height: 12.h),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 22.w,
                      color: ShipmentPublishTokens.subtitleGrey,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: ShipmentPublishTokens.publishBg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: FontRes.MANROPE_SEMIBOLD,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          height: 14 / 10,
          color: ShipmentPublishTokens.publishFg,
        ),
      ),
    );
  }
}

class _DriverAvatar extends StatelessWidget {
  const _DriverAvatar({required this.name, this.avatarUrl});

  final String name;
  final String? avatarUrl;

  Widget _initialsPlaceholder() {
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
              placeholder: _initialsPlaceholder(),
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
                border: Border.all(
                  color: ShipmentPublishTokens.cardDriver,
                  width: 2,
                ),
              ),
              child: Icon(Icons.verified, size: 12.w, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleMeta extends StatelessWidget {
  const _VehicleMeta({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_BOLD,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            height: 20 / 14,
            color: ShipmentPublishTokens.bodyDark,
          ),
        ),
        Text(
          subtitle,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_REGULAR,
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            height: 16 / 12,
            letterSpacing: 0.6,
            color: ShipmentPublishTokens.subtitleGrey,
          ),
        ),
      ],
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({this.icon, this.leading, this.onTap})
      : assert(icon != null || leading != null);

  final IconData? icon;
  final Widget? leading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(ShipmentPublishTokens.actionRadius.r),
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onTap!();
              },
        borderRadius:
            BorderRadius.circular(ShipmentPublishTokens.actionRadius.r),
        child: SizedBox(
          width: 42.w,
          height: 42.w,
          child: Center(
            child: leading ?? Icon(icon, size: 18.w, color: Colors.black),
          ),
        ),
      ),
    );
  }
}

/// Payment summary — `#E9EEF4`.
class PublishPaymentSummaryCard extends StatelessWidget {
  const PublishPaymentSummaryCard({
    super.key,
    required this.headerLabel,
    required this.baseFareLabel,
    required this.totalLabel,
    required this.amount,
    this.baseFare,
  });

  final String headerLabel;
  final String baseFareLabel;
  final String totalLabel;
  final double amount;
  final double? baseFare;

  @override
  Widget build(BuildContext context) {
    final baseAmount = baseFare ?? amount;
    final baseFormatted = baseAmount.inrDetailed;
    final totalFormatted = amount.inrDetailed;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ShipmentPublishTokens.paymentCard,
        borderRadius:
            BorderRadius.circular(ShipmentPublishTokens.cardRadius.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            decoration: const BoxDecoration(
              color: ShipmentPublishTokens.paymentHeader,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Text(
              headerLabel.toUpperCase(),
              style: TextStyle(
                fontFamily: FontRes.MANROPE_EXTRABOLD,
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
                height: 1.5,
                letterSpacing: 1,
                color: ShipmentPublishTokens.labelBrown,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      baseFareLabel,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_REGULAR,
                        fontSize: 14.sp,
                        color: ShipmentPublishTokens.subtitleGrey,
                      ),
                    ),
                    Text(
                      baseFormatted,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_SEMIBOLD,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: ShipmentPublishTokens.bodyDark,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16.h),
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: ShipmentPublishTokens.dividerTan),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            totalLabel,
                            style: TextStyle(
                              fontFamily: FontRes.MANROPE_BOLD,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: ShipmentPublishTokens.bodyDark,
                            ),
                          ),
                          Text(
                            totalFormatted,
                            style: TextStyle(
                              fontFamily: FontRes.MANROPE_EXTRABOLD,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                              color: ShipmentPublishTokens.priceBrown,
                            ),
                          ),
                        ],
                      ),
                    ),
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
