import 'package:flutter/material.dart';

import '../../../../../core/extensions/size_ext.dart';
import '../../../../../core/extensions/theme_ext.dart';
import '../../../../../res/font_res.dart';
import '../../../../../shared/domain/entities/driver_trip.dart';
import '../../models/driver_trip_list_badge.dart';
import 'driver_my_trip_card.dart';
import 'driver_my_trip_tokens.dart';

/// Trip summary card on Trip Details — Figma `1:4180`.
class DriverTripDetailCard extends StatelessWidget {
  const DriverTripDetailCard({super.key, required this.trip});

  final DriverTrip trip;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final badge = listBadgeFor(trip);
    final badgeLabel = switch (badge) {
      DriverTripListBadge.published => l10n.driverTripBadgePublish,
      DriverTripListBadge.expired => l10n.driverTripBadgeExpired,
      DriverTripListBadge.draft => l10n.driverTripBadgeDraft,
    };

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.8.w, 20.8.h, 20.8.w, 24.h),
      decoration: BoxDecoration(
        color: DriverMyTripTokens.cardFill,
        borderRadius: BorderRadius.circular(12.48.r),
        border: Border.all(color: DriverMyTripTokens.cardBorder, width: 1.04),
        boxShadow: const [DriverMyTripTokens.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RouteLabel(text: l10n.driverTripPickupLabel),
                    SizedBox(height: 5.h),
                    _RouteValue(
                      city: trip.fromCity,
                      icon: Icons.location_on_outlined,
                    ),
                    SizedBox(height: 10.h),
                    _RouteLabel(text: l10n.driverTripDropLabel),
                    SizedBox(height: 5.h),
                    _RouteValue(
                      city: trip.toCity,
                      icon: Icons.near_me_outlined,
                    ),
                  ],
                ),
              ),
              _StatusPill(label: badgeLabel, badge: badge),
            ],
          ),
          SizedBox(height: 24.h),
          DriverMyTripDetailsGrid(
            trip: trip,
            includeVehicleNumber: true,
          ),
          SizedBox(height: 24.h),
          _DriverInfoRow(
            name: trip.driverName,
            subtitle: l10n.driverExpertDriverLabel,
          ),
          SizedBox(height: 24.h),
          DriverMyTripPriceBlock(price: trip.estimatedPrice),
        ],
      ),
    );
  }
}

class _RouteLabel extends StatelessWidget {
  const _RouteLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: FontRes.MANROPE_MEDIUM,
        fontSize: 10.4.sp,
        fontWeight: FontWeight.w500,
        height: 16 / 10.4,
        color: DriverMyTripTokens.labelGrey,
      ),
    );
  }
}

class _RouteValue extends StatelessWidget {
  const _RouteValue({required this.city, required this.icon});

  final String city;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18.w, color: DriverMyTripTokens.primary),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            city,
            style: TextStyle(
              fontFamily: FontRes.MANROPE_EXTRABOLD,
              fontSize: 18.72.sp,
              fontWeight: FontWeight.w800,
              height: 23 / 18.72,
              color: DriverMyTripTokens.heading,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.badge});

  final String label;
  final DriverTripListBadge badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: badge.background,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: FontRes.MANROPE_BOLD,
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: badge.foreground,
        ),
      ),
    );
  }
}

class _DriverInfoRow extends StatelessWidget {
  const _DriverInfoRow({required this.name, required this.subtitle});

  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 28.r,
              backgroundColor:
                  DriverMyTripTokens.primary.withValues(alpha: 0.12),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_BOLD,
                  fontSize: 20.sp,
                  color: DriverMyTripTokens.primary,
                ),
              ),
            ),
            Positioned(
              right: -4.w,
              bottom: -4.h,
              child: Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: DriverMyTripTokens.badgeExpert,
                  border:
                      Border.all(color: DriverMyTripTokens.actionFill, width: 2),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child:
                    Icon(Icons.verified_rounded, size: 12.w, color: Colors.white),
              ),
            ),
          ],
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_BOLD,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: DriverMyTripTokens.heading,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_MEDIUM,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: DriverMyTripTokens.expertDriver,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
