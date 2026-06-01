import 'package:flutter/material.dart';

import '../../../../../core/extensions/size_ext.dart';
import '../../../../../res/font_res.dart';
import 'driver_trip_form_common.dart';
import 'driver_trip_form_tokens.dart';

/// Schedule 2×2 grid — Figma `1:3634`.
class DriverTripFormScheduleCard extends StatelessWidget {
  const DriverTripFormScheduleCard({
    super.key,
    required this.sectionTitle,
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
    return DriverTripFormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DriverTripFormSectionHeader(
            title: sectionTitle,
            icon: Icons.calendar_today_outlined,
          ),
          SizedBox(height: 24.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ScheduleTile(
                  label: startDateLabel,
                  value: startDateValue,
                  icon: Icons.calendar_today_outlined,
                  onTap: onStartDateTap,
                  isPlaceholder: startDatePlaceholder,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _ScheduleTile(
                  label: startTimeLabel,
                  value: startTimeValue,
                  icon: Icons.access_time_rounded,
                  onTap: onStartTimeTap,
                  isPlaceholder: startTimePlaceholder,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ScheduleTile(
                  label: endDateLabel,
                  value: endDateValue,
                  icon: Icons.calendar_today_outlined,
                  onTap: onEndDateTap,
                  isPlaceholder: endDatePlaceholder,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _ScheduleTile(
                  label: endTimeLabel,
                  value: endTimeValue,
                  icon: Icons.access_time_rounded,
                  onTap: onEndTimeTap,
                  isPlaceholder: endTimePlaceholder,
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

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    required this.isPlaceholder,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DriverTripFormFieldLabel(text: label),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 44.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: DriverTripFormTokens.fieldFill,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_REGULAR,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      height: 20 / 14,
                      color: isPlaceholder
                          ? DriverTripFormTokens.hint
                          : DriverTripFormTokens.heading,
                    ),
                  ),
                ),
                Icon(icon, size: 14.w, color: DriverTripFormTokens.hint),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
