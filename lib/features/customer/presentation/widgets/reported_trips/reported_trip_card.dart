import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/extensions/num_ext.dart';
import '../../../../../core/extensions/size_ext.dart';
import '../../../../../core/extensions/theme_ext.dart';
import '../../../../../res/font_res.dart';
import '../../../../../shared/domain/entities/reported_trip.dart';
import 'reported_trips_tokens.dart';

/// Reported trip card — Figma `1:6391`.
class ReportedTripCard extends StatelessWidget {
  const ReportedTripCard({
    super.key,
    required this.trip,
    required this.reportedByYouLabel,
    required this.estStartLabel,
    required this.estEndLabel,
    required this.vehicleLabel,
    required this.capacityLabel,
    required this.estimatedPriceLabel,
  });

  final ReportedTrip trip;
  final String reportedByYouLabel;
  final String estStartLabel;
  final String estEndLabel;
  final String vehicleLabel;
  final String capacityLabel;
  final String estimatedPriceLabel;

  String _pipeDateTime(DateTime dt) {
    final date = DateFormat('d MMMM yyyy').format(dt);
    final time =
        DateFormat('hh:mm a').format(dt).toUpperCase().replaceAll(' ', '');
    return '$date | $time';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(21.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.5.r),
        border: Border.all(color: ReportedTripsTokens.cardBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 12.5,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: ReportedTripsTokens.badgeRed,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              reportedByYouLabel,
              style: TextStyle(
                fontFamily: FontRes.MANROPE_BOLD,
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                height: 15 / 10,
                letterSpacing: -0.5,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 17.h),
          _RouteBlock(
            fromLabel: context.l10n.tripFrom,
            fromCity: trip.fromCity,
            toLabel: context.l10n.tripTo,
            toCity: trip.toCity,
          ),
          SizedBox(height: 17.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 18.h),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: ReportedTripsTokens.sectionDivider),
                bottom: BorderSide(color: ReportedTripsTokens.sectionDivider),
              ),
            ),
            child: Column(
              children: [
                if (trip.estimatedEndDate != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _MetaCell(
                          label: estStartLabel,
                          value: _pipeDateTime(trip.estimatedStartDate),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _MetaCell(
                          label: estEndLabel,
                          value: _pipeDateTime(trip.estimatedEndDate!),
                        ),
                      ),
                    ],
                  )
                else
                  _MetaCell(
                    label: estStartLabel,
                    value: _pipeDateTime(trip.estimatedStartDate),
                  ),
                SizedBox(height: 16.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _MetaCell(
                        label: vehicleLabel,
                        value: trip.vehicleType.label,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _MetaCell(
                        label: capacityLabel,
                        value: trip.capacityDisplay,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                estimatedPriceLabel.toUpperCase(),
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_MEDIUM,
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w500,
                  height: 16 / 10.5,
                  color: ReportedTripsTokens.labelGrey,
                ),
              ),
              Text(
                trip.estimatedPrice.inr,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_EXTRABOLD,
                  fontSize: 21.sp,
                  fontWeight: FontWeight.w800,
                  height: 29 / 21,
                  letterSpacing: -1,
                  color: ReportedTripsTokens.primaryOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RouteBlock extends StatelessWidget {
  const _RouteBlock({
    required this.fromLabel,
    required this.fromCity,
    required this.toLabel,
    required this.toCity,
  });

  final String fromLabel;
  final String fromCity;
  final String toLabel;
  final String toCity;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RouteRow(
          label: fromLabel,
          city: fromCity,
          icon: Icons.location_on_rounded,
          iconSize: Size(16.w, 20.h),
        ),
        SizedBox(height: 10.h),
        _RouteRow(
          label: toLabel,
          city: toCity,
          icon: Icons.navigation_rounded,
          iconSize: Size(18.w, 18.w),
        ),
      ],
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({
    required this.label,
    required this.city,
    required this.icon,
    required this.iconSize,
  });

  final String label;
  final String city;
  final IconData icon;
  final Size iconSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: FontRes.MANROPE_MEDIUM,
            fontSize: 10.5.sp,
            fontWeight: FontWeight.w500,
            height: 16 / 10.5,
            color: ReportedTripsTokens.labelGrey,
          ),
        ),
        SizedBox(height: 5.h),
        Row(
          children: [
            Icon(
              icon,
              size: iconSize.width,
              color: ReportedTripsTokens.primaryOrange,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                city,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_EXTRABOLD,
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w800,
                  height: 23 / 19,
                  color: ReportedTripsTokens.bodyDark,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetaCell extends StatelessWidget {
  const _MetaCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: FontRes.MANROPE_MEDIUM,
            fontSize: 10.5.sp,
            fontWeight: FontWeight.w500,
            height: 16 / 10.5,
            color: ReportedTripsTokens.labelGrey,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_SEMIBOLD,
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w600,
            height: 17 / 12.5,
            color: ReportedTripsTokens.bodyDark,
          ),
        ),
      ],
    );
  }
}
