import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../res/font_res.dart';
import '../../../domain/enums/vehicle_type.dart';
import '../../../domain/models/shipment_filter.dart';
import '../buttons/app_button.dart';

/// Figma filter bottom sheet (`2013:1268` / Filter Search).
const _kSheetBackground = Color(0xFFF8F9FA);
const _kFieldFill = Color(0xFFF3F4F5);
const _kChipInactive = Color(0xFFE7E8E9);
const _kSectionLabel = Color(0xFF434655);
const _kTitleColor = Color(0xFF191C1D);
const _kScrim = Color(0x660F172A);

/// Global filter dialog — route, date, vehicle class, load capacity.
///
/// ```dart
/// final result = await FilterSearchSheet.show(context, initial: currentFilter);
/// if (result != null) applyFilter(result);
/// ```
class FilterSearchSheet extends StatefulWidget {
  const FilterSearchSheet({super.key, required this.initial});

  final ShipmentFilter initial;

  /// Presents the sheet and returns applied filters, or `null` if dismissed.
  static Future<ShipmentFilter?> show(
    BuildContext context, {
    ShipmentFilter initial = const ShipmentFilter(),
  }) {
    return showModalBottomSheet<ShipmentFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: _kScrim,
      builder: (_) => FilterSearchSheet(initial: initial),
    );
  }

  @override
  State<FilterSearchSheet> createState() => _FilterSearchSheetState();
}

class _FilterSearchSheetState extends State<FilterSearchSheet>
    with SafeSetStateMixin {
  late ShipmentFilter _filter;
  late final TextEditingController _fromCtrl;
  late final TextEditingController _toCtrl;
  bool _isCalendarExpanded = false;
  late DateTime _calendarMonth;

  @override
  void initState() {
    super.initState();
    _filter = _withDefaultPickupDate(widget.initial);
    _fromCtrl = TextEditingController(text: widget.initial.fromCity ?? '');
    _toCtrl = TextEditingController(text: widget.initial.toCity ?? '');
    final seed = _filter.pickupDate ?? _today;
    _calendarMonth = DateTime(seed.year, seed.month);
  }

  ShipmentFilter _withDefaultPickupDate(ShipmentFilter source) {
    if (source.pickupDate != null) return source;
    return source.copyWith(pickupDate: _today);
  }

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    super.dispose();
  }

  void _clearAll() {
    HapticFeedback.lightImpact();
    safeSetState(() {
      _filter = const ShipmentFilter().copyWith(pickupDate: _today);
      _fromCtrl.clear();
      _toCtrl.clear();
      _isCalendarExpanded = false;
      _calendarMonth = DateTime(_today.year, _today.month);
    });
  }

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  void _toggleCalendar() {
    HapticFeedback.selectionClick();
    safeSetState(() {
      _isCalendarExpanded = !_isCalendarExpanded;
      if (_isCalendarExpanded) {
        final ref = _filter.pickupDate ?? _today;
        _calendarMonth = DateTime(ref.year, ref.month);
      }
    });
  }

  void _selectPickupDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    safeSetState(() {
      _filter = _filter.copyWith(pickupDate: normalized);
      _calendarMonth = DateTime(normalized.year, normalized.month);
      _isCalendarExpanded = false;
    });
  }

  void _togglePickupDateChip(DateTime date) {
    final selected =
        _filter.pickupDate != null && _isSameDay(_filter.pickupDate!, date);
    safeSetState(() {
      _filter = selected
          ? _filter.copyWith(pickupDate: _today)
          : _filter.copyWith(pickupDate: date);
    });
  }

  void _apply() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop(
      _filter.copyWith(
        fromCity: _fromCtrl.text.trim().isEmpty ? null : _fromCtrl.text.trim(),
        toCity: _toCtrl.text.trim().isEmpty ? null : _toCtrl.text.trim(),
      ),
    );
  }

  /// Mon–Sun of the current week by default; switches week when a date outside it is picked.
  List<DateTime> get _weekDateOptions {
    final ref = _filter.pickupDate ?? _today;
    final monday = _mondayOfWeek(ref);
    return List.generate(
      7,
      (i) => DateTime(monday.year, monday.month, monday.day + i),
    );
  }

  DateTime _mondayOfWeek(DateTime date) =>
      date.subtract(Duration(days: date.weekday - DateTime.monday));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        decoration: BoxDecoration(
          color: _kSheetBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 48,
              offset: const Offset(0, -12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16.h),
            Container(
              width: 48.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: const Color(0xFFC3C6D7).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(32.w, 20.h, 32.w, 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.filterSearchTitle,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_EXTRABOLD,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                        color: _kTitleColor,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _clearAll,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                    ),
                    child: Text(
                      l10n.filterClearAll,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_BOLD,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(32.w, 8.h, 32.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel(text: l10n.filterRouteDetails),
                    SizedBox(height: 16.h),
                    _RouteField(
                      label: l10n.filterFromLabel,
                      hint: l10n.filterFromHint,
                      icon: Icons.location_on_outlined,
                      controller: _fromCtrl,
                    ),
                    SizedBox(height: 12.h),
                    _RouteField(
                      label: l10n.filterToLabel,
                      hint: l10n.filterToHint,
                      icon: Icons.navigation_outlined,
                      controller: _toCtrl,
                    ),
                    SizedBox(height: 40.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SectionLabel(text: l10n.filterPickupDate),
                        GestureDetector(
                          onTap: _toggleCalendar,
                          child: Text(
                            l10n.filterCalendar,
                            style: TextStyle(
                              fontFamily: FontRes.MANROPE_BOLD,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: _isCalendarExpanded
                                  ? _kSectionLabel
                                  : colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeInOutCubic,
                      alignment: Alignment.topCenter,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          final slide = Tween<Offset>(
                            begin: const Offset(0, 0.06),
                            end: Offset.zero,
                          ).animate(animation);
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: slide,
                              child: child,
                            ),
                          );
                        },
                        child: _isCalendarExpanded
                            ? _InlineMonthCalendar(
                                key: const ValueKey('calendar'),
                                month: _calendarMonth,
                                selected: _filter.pickupDate,
                                firstDate: _today,
                                lastDate: _today.add(
                                  const Duration(days: 365),
                                ),
                                onMonthChanged: (m) => safeSetState(
                                  () => _calendarMonth = m,
                                ),
                                onDateSelected: _selectPickupDate,
                              )
                            : _WeekDateRow(
                                key: ValueKey(
                                  'week-${_weekDateOptions.first.millisecondsSinceEpoch}',
                                ),
                                dates: _weekDateOptions,
                                selected: _filter.pickupDate,
                                today: _today,
                                l10n: l10n,
                                onDateTap: _togglePickupDateChip,
                              ),
                      ),
                    ),
                    SizedBox(height: 40.h),
                    _SectionLabel(text: l10n.filterVehicleClass),
                    SizedBox(height: 16.h),
                    SizedBox(
                      height: 44.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _VehiclePill(
                            label: 'Mini',
                            icon: Icons.local_shipping_outlined,
                            selected:
                                _filter.vehicleClass == VehicleType.mini,
                            onTap: () => safeSetState(() {
                              _filter = _filter.vehicleClass ==
                                      VehicleType.mini
                                  ? _filter.copyWith(clearVehicleClass: true)
                                  : _filter.copyWith(
                                      vehicleClass: VehicleType.mini,
                                    );
                            }),
                          ),
                          SizedBox(width: 8.w),
                          _VehiclePill(
                            label: 'Pickup',
                            icon: Icons.fire_truck_outlined,
                            selected: _filter.vehicleClass ==
                                VehicleType.pickupTruck,
                            onTap: () => safeSetState(() {
                              _filter = _filter.vehicleClass ==
                                      VehicleType.pickupTruck
                                  ? _filter.copyWith(clearVehicleClass: true)
                                  : _filter.copyWith(
                                      vehicleClass:
                                          VehicleType.pickupTruck,
                                    );
                            }),
                          ),
                          SizedBox(width: 8.w),
                          _VehiclePill(
                            label: 'Truck',
                            icon: Icons.local_shipping_rounded,
                            selected:
                                _filter.vehicleClass == VehicleType.truck,
                            onTap: () => safeSetState(() {
                              _filter = _filter.vehicleClass ==
                                      VehicleType.truck
                                  ? _filter.copyWith(clearVehicleClass: true)
                                  : _filter.copyWith(
                                      vehicleClass: VehicleType.truck,
                                    );
                            }),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SectionLabel(text: l10n.filterLoadCapacity),
                        Text(
                          _filter.capacityBand.summaryLabel,
                          style: TextStyle(
                            fontFamily: FontRes.MANROPE_BOLD,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _CapacitySegments(
                      selected: _filter.capacityBand,
                      onSelected: (band) => safeSetState(
                        () => _filter = _filter.copyWith(capacityBand: band),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: colors.primary,
                        inactiveTrackColor: const Color(0xFFE1E3E4),
                        thumbColor: colors.surface,
                        overlayColor: colors.primary.withValues(alpha: 0.12),
                        trackHeight: 6.h,
                        rangeThumbShape: RoundRangeSliderThumbShape(
                          enabledThumbRadius: 12.r,
                          elevation: 2,
                        ),
                        rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
                      ),
                      child: RangeSlider(
                        values: RangeValues(
                          _filter.capacityRangeStart,
                          _filter.capacityRangeEnd,
                        ),
                        onChanged: (v) => safeSetState(() {
                          _filter = _filter.copyWith(
                            capacityRangeStart: v.start,
                            capacityRangeEnd: v.end,
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(72.w, 8.h, 72.w, 24.h),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: AppButton(
                  label: l10n.filterApply,
                  onPressed: _apply,
                  height: 56,
                  borderRadius: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ─── Building blocks ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: FontRes.MANROPE_BOLD,
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: _kSectionLabel.withValues(alpha: 0.7),
      ),
    );
  }
}

class _RouteField extends StatelessWidget {
  const _RouteField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;

  static const _iconColor = Color(0xFF737686);
  static const _hintColor = Color(0x99737686);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 71.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: _kFieldFill,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 16.w,
            height: 39.h,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(
                icon,
                size: 18.w,
                color: _iconColor,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(
                textSelectionTheme: TextSelectionThemeData(
                  cursorColor: context.colors.primary,
                  selectionColor:
                      context.colors.primary.withValues(alpha: 0.2),
                ),
                inputDecorationTheme: const InputDecorationTheme(
                  filled: false,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_BOLD,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                      letterSpacing: -0.5,
                      color: context.colors.primary,
                    ),
                  ),
                  TextField(
                    controller: controller,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_MEDIUM,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.375,
                      color: context.colors.textPrimary,
                    ),
                    cursorColor: context.colors.primary,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(
                        fontFamily: FontRes.MANROPE_MEDIUM,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.375,
                        color: _hintColor,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      fillColor: Colors.transparent,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekDateRow extends StatefulWidget {
  const _WeekDateRow({
    super.key,
    required this.dates,
    required this.selected,
    required this.today,
    required this.l10n,
    required this.onDateTap,
  });

  final List<DateTime> dates;
  final DateTime? selected;
  final DateTime today;
  final AppLocalizations l10n;
  final ValueChanged<DateTime> onDateTap;

  @override
  State<_WeekDateRow> createState() => _WeekDateRowState();
}

class _WeekDateRowState extends State<_WeekDateRow> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _centerSelected(animate: false);
  }

  @override
  void didUpdateWidget(covariant _WeekDateRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected ||
        oldWidget.dates != widget.dates) {
      _centerSelected();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _centerSelected({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      var index = -1;
      if (widget.selected != null) {
        index = widget.dates.indexWhere(
          (d) => DateUtils.isSameDay(d, widget.selected),
        );
      }
      if (index < 0) {
        index = widget.dates.indexWhere(
          (d) => DateUtils.isSameDay(d, widget.today),
        );
      }
      if (index < 0) return;

      final chipWidth = 64.w;
      final gap = 12.w;
      final itemStride = chipWidth + gap;
      final viewport = _scrollController.position.viewportDimension;
      final offset =
          (index * itemStride) - ((viewport - chipWidth) / 2);
      final target = offset.clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );

      if (animate) {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }

  String _weekdayLabel(DateTime date) {
    if (DateUtils.isSameDay(date, widget.today)) {
      return widget.l10n.filterToday;
    }
    const labels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return labels[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88.h,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.dates.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final date = widget.dates[index];
          final selected = widget.selected != null &&
              DateUtils.isSameDay(date, widget.selected);
          return _DateChip(
            weekday: _weekdayLabel(date),
            day: '${date.day}',
            selected: selected,
            onTap: () => widget.onDateTap(date),
          );
        },
      ),
    );
  }
}

class _InlineMonthCalendar extends StatelessWidget {
  const _InlineMonthCalendar({
    super.key,
    required this.month,
    required this.selected,
    required this.firstDate,
    required this.lastDate,
    required this.onMonthChanged,
    required this.onDateSelected,
  });

  final DateTime month;
  final DateTime? selected;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final monthStart = DateTime(month.year, month.month);
    final daysInMonth =
        DateUtils.getDaysInMonth(month.year, month.month);
    final leadingEmpty = monthStart.weekday % 7;
    final canGoPrev = monthStart.isAfter(
      DateTime(firstDate.year, firstDate.month),
    );
    final canGoNext = monthStart.isBefore(
      DateTime(lastDate.year, lastDate.month),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 16.h),
      decoration: BoxDecoration(
        color: _kFieldFill,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: canGoPrev
                    ? () {
                        final prev = DateTime(month.year, month.month - 1);
                        onMonthChanged(prev);
                      }
                    : null,
                icon: Icon(
                  Icons.chevron_left_rounded,
                  color: canGoPrev ? _kSectionLabel : _kChipInactive,
                ),
                visualDensity: VisualDensity.compact,
              ),
              Expanded(
                child: Text(
                  DateFormat.yMMMM().format(monthStart),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_BOLD,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: _kTitleColor,
                  ),
                ),
              ),
              IconButton(
                onPressed: canGoNext
                    ? () {
                        final next = DateTime(month.year, month.month + 1);
                        onMonthChanged(next);
                      }
                    : null,
                icon: Icon(
                  Icons.chevron_right_rounded,
                  color: canGoNext ? _kSectionLabel : _kChipInactive,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (d) => Expanded(
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_BOLD,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: _kSectionLabel.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 8.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leadingEmpty + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              if (index < leadingEmpty) return const SizedBox.shrink();

              final day = index - leadingEmpty + 1;
              final date = DateTime(month.year, month.month, day);
              final isBeforeFirst = date.isBefore(firstDate);
              final isAfterLast = date.isAfter(lastDate);
              final enabled = !isBeforeFirst && !isAfterLast;
              final isSelected = selected != null &&
                  DateUtils.isSameDay(selected, date);

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: enabled
                      ? () {
                          HapticFeedback.selectionClick();
                          onDateSelected(date);
                        }
                      : null,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? colors.primary : null,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_BOLD,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: !enabled
                            ? _kSectionLabel.withValues(alpha: 0.25)
                            : isSelected
                                ? Colors.white
                                : _kSectionLabel,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.weekday,
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final String weekday;
  final String day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? context.colors.primary : _kChipInactive;
    final fg = selected ? Colors.white : _kSectionLabel;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12.r),
      elevation: selected ? 4 : 0,
      shadowColor: context.colors.primary.withValues(alpha: 0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          width: 64.w,
          height: 80.h,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weekday,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_BOLD,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: fg.withValues(alpha: selected ? 0.8 : 1),
                ),
              ),
              Text(
                day,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_BOLD,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehiclePill extends StatelessWidget {
  const _VehiclePill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bg = selected ? colors.primary : _kChipInactive;
    final fg = selected ? Colors.white : _kSectionLabel;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16.w, color: fg),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_BOLD,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CapacitySegments extends StatelessWidget {
  const _CapacitySegments({
    required this.selected,
    required this.onSelected,
  });

  final LoadCapacityBand selected;
  final ValueChanged<LoadCapacityBand> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: _kFieldFill,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          for (final band in LoadCapacityBand.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelected(band),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: selected == band
                        ? colors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: selected == band
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    band.label,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_BOLD,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color:
                          selected == band ? Colors.white : _kSectionLabel,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
