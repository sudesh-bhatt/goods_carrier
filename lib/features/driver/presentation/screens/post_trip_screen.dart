import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/services/google_places_service.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/domain/enums/vehicle_type.dart';
import '../../../../shared/presentation/widgets/buttons/app_button.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../customer/presentation/widgets/customer_light_chrome.dart';
import '../../../customer/presentation/widgets/shipment_form/shipment_form_card.dart';
import '../../../customer/presentation/widgets/shipment_form/shipment_form_pickers.dart';
import '../../../customer/presentation/widgets/shipment_form/shipment_form_phone_row.dart';
import '../../../customer/presentation/widgets/shipment_form/shipment_form_field.dart';
import '../../../customer/presentation/widgets/shipment_form/shipment_form_route_card.dart';
import '../../../customer/presentation/widgets/shipment_form/shipment_form_schedule_field.dart';
import '../../../customer/presentation/widgets/shipment_form/shipment_form_tokens.dart';
import '../../../customer/presentation/widgets/shipment_form/shipment_form_weight_row.dart';
import '../providers/driver_trips_provider.dart';

/// Driver publishes an available route — reuses customer shipment form widgets.
class PostTripScreen extends ConsumerStatefulWidget {
  const PostTripScreen({super.key});

  @override
  ConsumerState<PostTripScreen> createState() => _PostTripScreenState();
}

class _PostTripScreenState extends ConsumerState<PostTripScreen>
    with SafeSetStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  final _vehicleCtrl = TextEditingController();
  final _vehicleNumberCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _driverNameCtrl = TextEditingController();
  final _driverPhoneCtrl = TextEditingController();

  VehicleType? _selectedVehicle;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  String _weightUnit = 'Ton';
  String _dialCode = '+91';
  bool _submitted = false;
  String? _scheduleError;

  String? _fromCity;
  String? _toCity;

  static const _datePlaceholder = 'mm/dd/yyyy';
  static const _timePlaceholder = '00:00';

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user != null) {
      _driverNameCtrl.text = user.name;
      final parsed = PhoneUtils.splitE164(user.phone);
      _dialCode = parsed.dialCode;
      _driverPhoneCtrl.text = parsed.localNumber;
    }
    final now = DateTime.now();
    _startDate =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    _startTime = const TimeOfDay(hour: 9, minute: 0);
    _endDate = _startDate!.add(const Duration(days: 2));
    _endTime = const TimeOfDay(hour: 19, minute: 0);
  }

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    _vehicleCtrl.dispose();
    _vehicleNumberCtrl.dispose();
    _capacityCtrl.dispose();
    _priceCtrl.dispose();
    _driverNameCtrl.dispose();
    _driverPhoneCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) =>
      date == null ? _datePlaceholder : DateFormat('MM/dd/yyyy').format(date);

  String _formatTime(TimeOfDay? time) {
    if (time == null) return _timePlaceholder;
    final dt = DateTime(2020, 1, 1, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  DateTime? _buildDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String _cityFromField(String text, String? resolvedCity) {
    if (resolvedCity != null && resolvedCity.isNotEmpty) return resolvedCity;
    final parts =
        text.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty);
    final list = parts.toList();
    if (list.length >= 2) return list[list.length - 2];
    return text.trim();
  }

  double _defaultCapacityFor(VehicleType type) => switch (type) {
        VehicleType.mini => 0.5,
        VehicleType.pickupTruck => 1,
        VehicleType.truck => 5,
        VehicleType.heavyDuty => 15,
      };

  double _capacityInTons() {
    final raw = double.tryParse(_capacityCtrl.text.trim()) ?? 0;
    return _weightUnit == 'Ton' ? raw : raw / 1000;
  }

  void _onFromPlaceSelected(PlaceAddressDetails details) {
    safeSetState(() {
      _fromCity = details.city.isNotEmpty ? details.city : null;
    });
  }

  void _onToPlaceSelected(PlaceAddressDetails details) {
    safeSetState(() {
      _toCity = details.city.isNotEmpty ? details.city : null;
    });
  }

  Future<void> _pickVehicle() async {
    final picked = await ShipmentFormPickers.showVehicleType(context);
    if (picked == null) return;
    safeSetState(() {
      _selectedVehicle = picked;
      _vehicleCtrl.text = picked.label;
      if (_capacityCtrl.text.trim().isEmpty) {
        final cap = _defaultCapacityFor(picked);
        _capacityCtrl.text = cap >= 1
            ? cap.toStringAsFixed(0)
            : cap.toStringAsFixed(1);
        _weightUnit = 'Ton';
      }
    });
  }

  Future<void> _pickWeightUnit() async {
    final picked = await ShipmentFormPickers.showWeightUnit(context);
    if (picked != null) safeSetState(() => _weightUnit = picked);
  }

  void _onDialCodeChanged(CountryCode code) {
    final newCode = code.dialCode ?? '+91';
    final maxLen = PhoneUtils.maxLocalLength(newCode);
    final text = _driverPhoneCtrl.text;
    if (text.length > maxLen) {
      _driverPhoneCtrl.text = text.substring(0, maxLen);
    }
    safeSetState(() => _dialCode = newCode);
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      safeSetState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) safeSetState(() => _endDate = picked);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) safeSetState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (picked != null) safeSetState(() => _endTime = picked);
  }

  bool _validateSchedule() {
    if (_startDate == null ||
        _startTime == null ||
        _endDate == null ||
        _endTime == null) {
      safeSetState(() {
        _scheduleError = context.l10n.shipmentFormScheduleRequired;
      });
      return false;
    }

    final start = _buildDateTime(_startDate, _startTime)!;
    final end = _buildDateTime(_endDate, _endTime)!;
    if (!end.isAfter(start)) {
      safeSetState(() {
        _scheduleError = context.l10n.driverTripFormEndBeforeStart;
      });
      return false;
    }

    safeSetState(() => _scheduleError = null);
    return true;
  }

  Future<void> _submit() async {
    safeSetState(() => _submitted = true);
    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.shipmentFormVehicleRequired)),
      );
      return;
    }
    if (!_validateSchedule()) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();

    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    final start = _buildDateTime(_startDate, _startTime)!;
    final end = _buildDateTime(_endDate, _endTime)!;

    await ref.read(driverTripsProvider.notifier).postTrip(
          fromCity: _cityFromField(_fromCtrl.text.trim(), _fromCity),
          toCity: _cityFromField(_toCtrl.text.trim(), _toCity),
          estimatedStartDate: start,
          estimatedEndDate: end,
          vehicleType: _selectedVehicle!,
          vehicleNumber: _vehicleNumberCtrl.text.trim().toUpperCase(),
          loadCapacityTons: _capacityInTons(),
          estimatedPrice: price,
          driverName: _driverNameCtrl.text.trim(),
        );

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLoading = ref.watch(driverTripsProvider).isLoading;

    return CustomerLightChrome(
      child: Scaffold(
        backgroundColor: ShipmentFormTokens.background,
        appBar: FlowScreenAppBar(
          title: l10n.driverAddTripTitle,
          backgroundColor: Colors.white.withValues(alpha: 0.8),
        ),
        body: Form(
          key: _formKey,
          autovalidateMode: _submitted
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24.w, 30.h, 24.w, 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.driverTripFormContext,
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_MEDIUM,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: ShipmentFormTokens.label,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        l10n.driverTripFormHero,
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_EXTRABOLD,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          height: 32 / 24,
                          letterSpacing: -0.6,
                          color: ShipmentFormTokens.heading,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      ShipmentFormRouteCard(
                        fromController: _fromCtrl,
                        toController: _toCtrl,
                        fromHint: l10n.shipmentFormFromHint,
                        toHint: l10n.shipmentFormToHint,
                        onFromPlaceSelected: _onFromPlaceSelected,
                        onToPlaceSelected: _onToPlaceSelected,
                        fromValidator: (v) =>
                            Validators.required(v, l10n.tripFrom),
                        toValidator: (v) => Validators.required(v, l10n.tripTo),
                      ),
                      SizedBox(height: 24.h),
                      ShipmentFormScheduleGrid(
                        sectionTitle: l10n.driverTripFormSchedule,
                        sectionIcon: Icons.calendar_today_outlined,
                        startDateLabel: l10n.driverTripFormEstStartDate,
                        startTimeLabel: l10n.driverTripFormEstStartTime,
                        endDateLabel: l10n.driverTripFormEstEndDate,
                        endTimeLabel: l10n.driverTripFormEstEndTime,
                        startDateValue: _formatDate(_startDate),
                        startTimeValue: _formatTime(_startTime),
                        endDateValue: _formatDate(_endDate),
                        endTimeValue: _formatTime(_endTime),
                        onStartDateTap: _pickStartDate,
                        onStartTimeTap: _pickStartTime,
                        onEndDateTap: _pickEndDate,
                        onEndTimeTap: _pickEndTime,
                        startDatePlaceholder: _startDate == null,
                        startTimePlaceholder: _startTime == null,
                        endDatePlaceholder: _endDate == null,
                        endTimePlaceholder: _endTime == null,
                        scheduleError: _scheduleError,
                      ),
                      SizedBox(height: 24.h),
                      ShipmentFormCard(
                        child: ShipmentFormSection(
                          label: l10n.shipmentFormVehicleRequirement,
                          child: ShipmentFormInputRow(
                            icon: Icons.local_shipping_outlined,
                            controller: _vehicleCtrl,
                            hint: l10n.shipmentFormVehicleRequirement,
                            readOnly: true,
                            onTap: _pickVehicle,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      ShipmentFormCard(
                        child: ShipmentFormSection(
                          label: l10n.profileVehicleNumber,
                          child: ShipmentFormInputRow(
                            icon: Icons.directions_car_outlined,
                            controller: _vehicleNumberCtrl,
                            hint: l10n.profileVehicleNumberHint,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[A-Za-z0-9 ]'),
                              ),
                            ],
                            validator: Validators.vehicleNumber,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      ShipmentFormWeightRow(
                        weightController: _capacityCtrl,
                        weightUnit: _weightUnit,
                        weightLabel: l10n.shipmentFormEstWeight,
                        unitLabel: l10n.shipmentFormEstWeightType,
                        onUnitTap: _pickWeightUnit,
                        weightValidator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return l10n.driverTripFormCapacityRequired;
                          }
                          final n = double.tryParse(v.trim());
                          if (n == null || n <= 0) {
                            return l10n.driverTripFormCapacityRequired;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24.h),
                      ShipmentFormCard(
                        child: ShipmentFormSection(
                          label: l10n.driverTripFormEstPrice,
                          child: ShipmentFormInputRow(
                            icon: Icons.currency_rupee,
                            controller: _priceCtrl,
                            hint: l10n.shipmentFormBudgetHint,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return l10n.driverTripFormPriceRequired;
                              }
                              final p = double.tryParse(v.trim());
                              if (p == null || p <= 0) {
                                return l10n.driverTripFormPriceRequired;
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      ShipmentFormCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 18.w,
                                  color: ShipmentFormTokens.primary,
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  l10n.driverTripFormDriverInfo,
                                  style: TextStyle(
                                    fontFamily: FontRes.MANROPE_BOLD,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: ShipmentFormTokens.title,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24.h),
                            ShipmentFormSection(
                              label: l10n.driverTripFormDriverName,
                              child: ShipmentFormInputRow(
                                icon: Icons.badge_outlined,
                                controller: _driverNameCtrl,
                                hint: l10n.driverTripFormDriverNameHint,
                                validator: (v) => Validators.required(
                                  v,
                                  l10n.driverTripFormDriverName,
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            ShipmentFormSection(
                              label: l10n.driverTripFormDriverPhone,
                              child: ShipmentFormPhoneRow(
                                controller: _driverPhoneCtrl,
                                dialCode: _dialCode,
                                onDialCodeChanged: _onDialCodeChanged,
                                hint: l10n.authPhoneDigitsPlaceholder,
                                validator: (v) =>
                                    Validators.phoneForCountry(_dialCode, v),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 100.h),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(72.w, 8.h, 72.w, 24.h),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: const [ShipmentFormTokens.ctaShadow],
                  ),
                  child: AppButton(
                    label: l10n.driverPublishTrip,
                    onPressed: isLoading ? null : _submit,
                    isLoading: isLoading,
                    height: 54,
                    borderRadius: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
