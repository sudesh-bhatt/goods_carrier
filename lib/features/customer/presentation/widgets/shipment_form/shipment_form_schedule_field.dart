import 'package:flutter/material.dart';

import '../../../../../core/extensions/size_ext.dart';
import '../../../../../res/font_res.dart';
import 'shipment_form_card.dart';
import 'shipment_form_field.dart';
import 'shipment_form_tokens.dart';

/// Date or time picker row — shared by customer post shipment and driver add trip.
class ShipmentFormScheduleField extends StatelessWidget {
  const ShipmentFormScheduleField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.isPlaceholder = false,
    this.compact = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPlaceholder;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final fieldHeight = compact ? 44.h : 52.h;
    final iconSize = compact ? 14.w : 18.w;
    final fontSize = compact ? 14.sp : 16.sp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShipmentFormFieldLabel(text: label),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: fieldHeight,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: ShipmentFormTokens.fieldFill,
              borderRadius: BorderRadius.circular(compact ? 8.r : 12.r),
            ),
            child: Row(
              children: [
                if (!compact) ...[
                  Icon(icon, size: iconSize, color: ShipmentFormTokens.primary),
                  SizedBox(width: 12.w),
                ],
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_MEDIUM,
                      fontSize: fontSize,
                      fontWeight: compact ? FontWeight.w400 : FontWeight.w500,
                      color: isPlaceholder
                          ? ShipmentFormTokens.hint
                          : ShipmentFormTokens.heading,
                    ),
                  ),
                ),
                if (compact)
                  Icon(icon, size: iconSize, color: ShipmentFormTokens.label),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 2×2 schedule grid — driver add trip (`1:3634`).
class ShipmentFormScheduleGrid extends StatelessWidget {
  const ShipmentFormScheduleGrid({
    super.key,
    required this.sectionTitle,
    required this.sectionIcon,
    required this.startDateLabel,
    required this.startTimeLabel,
    required this.endDateLabel,
    required this.endTimeLabel,
    required this.startDateValue,
    required this.startTimeValue,
    required this.endDateValue,
    required this.endTimeValue,
    required this.onStartDateTap,
    required this.onStartTimeTap,
    required this.onEndDateTap,
    required this.onEndTimeTap,
    this.startDatePlaceholder = true,
    this.startTimePlaceholder = true,
    this.endDatePlaceholder = true,
    this.endTimePlaceholder = true,
    this.scheduleError,
  });

  final String sectionTitle;
  final IconData sectionIcon;
  final String startDateLabel;
  final String startTimeLabel;
  final String endDateLabel;
  final String endTimeLabel;
  final String startDateValue;
  final String startTimeValue;
  final String endDateValue;
  final String endTimeValue;
  final VoidCallback onStartDateTap;
  final VoidCallback onStartTimeTap;
  final VoidCallback onEndDateTap;
  final VoidCallback onEndTimeTap;
  final bool startDatePlaceholder;
  final bool startTimePlaceholder;
  final bool endDatePlaceholder;
  final bool endTimePlaceholder;
  final String? scheduleError;

  @override
  Widget build(BuildContext context) {
    return ShipmentFormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(sectionIcon, size: 18.w, color: ShipmentFormTokens.primary),
              SizedBox(width: 12.w),
              Text(
                sectionTitle,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_BOLD,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  height: 24 / 16,
                  color: ShipmentFormTokens.title,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ShipmentFormScheduleField(
                  label: startDateLabel,
                  value: startDateValue,
                  icon: Icons.calendar_today_outlined,
                  onTap: onStartDateTap,
                  isPlaceholder: startDatePlaceholder,
                  compact: true,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ShipmentFormScheduleField(
                  label: startTimeLabel,
                  value: startTimeValue,
                  icon: Icons.access_time_rounded,
                  onTap: onStartTimeTap,
                  isPlaceholder: startTimePlaceholder,
                  compact: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ShipmentFormScheduleField(
                  label: endDateLabel,
                  value: endDateValue,
                  icon: Icons.calendar_today_outlined,
                  onTap: onEndDateTap,
                  isPlaceholder: endDatePlaceholder,
                  compact: true,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ShipmentFormScheduleField(
                  label: endTimeLabel,
                  value: endTimeValue,
                  icon: Icons.access_time_rounded,
                  onTap: onEndTimeTap,
                  isPlaceholder: endTimePlaceholder,
                  compact: true,
                ),
              ),
            ],
          ),
          if (scheduleError != null) ...[
            SizedBox(height: 8.h),
            Text(
              scheduleError!,
              style: TextStyle(
                fontFamily: FontRes.MANROPE_REGULAR,
                fontSize: 12.sp,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
