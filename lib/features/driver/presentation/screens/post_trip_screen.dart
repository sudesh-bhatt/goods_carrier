import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
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
import '../../../../shared/domain/entities/driver_trip.dart';
import '../../../../shared/domain/enums/vehicle_type.dart';
import '../../../../shared/presentation/widgets/buttons/app_button.dart';
import '../../../../shared/presentation/widgets/feedback/error_view.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../customer/presentation/widgets/customer_light_chrome.dart';
import '../../../customer/presentation/widgets/shipment_form/shipment_form_pickers.dart';
import '../providers/driver_trips_provider.dart';
import '../widgets/trip_form/driver_trip_form_driver_card.dart';
import '../widgets/trip_form/driver_trip_form_route_card.dart';
import '../widgets/trip_form/driver_trip_form_schedule_card.dart';
import '../widgets/trip_form/driver_trip_form_tokens.dart';
import '../widgets/trip_form/driver_trip_form_vehicle_card.dart';

/// Driver publish / update trip — Figma `1:3634` / `1:3799`.
class PostTripScreen extends ConsumerStatefulWidget {
  const PostTripScreen({super.key, this.tripId});

  final String? tripId;

  bool get isEditing => tripId != null && tripId!.isNotEmpty;

  @override
  ConsumerState<PostTripScreen> createState() => _PostTripScreenState();
}

class _PostTripScreenState extends ConsumerState<PostTripScreen>
    with SafeSetStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
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
  DriverTrip? _editingTrip;

  static const _datePlaceholder = 'dd/mm/yyyy';
  static const _timePlaceholder = '00:00AM';

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _editingTrip = ref.read(driverTripsProvider).byId(widget.tripId!);
      final trip = _editingTrip;
      if (trip != null) {
        _fromCtrl.text = trip.fromCity;
        _toCtrl.text = trip.toCity;
        _fromCity = trip.fromCity;
        _toCity = trip.toCity;
        _selectedVehicle = trip.vehicleCategory;
        _vehicleNumberCtrl.text = trip.vehicleNumber;
        _capacityCtrl.text = trip.loadCapacityTons >= 1
            ? trip.loadCapacityTons.toStringAsFixed(0)
            : trip.loadCapacityTons.toStringAsFixed(1);
        _weightUnit = 'Ton';
        _priceCtrl.text = trip.estimatedPrice.toStringAsFixed(0);
        _driverNameCtrl.text = trip.driverName;
        _startDate = DateTime(
          trip.estimatedStartDate.year,
          trip.estimatedStartDate.month,
          trip.estimatedStartDate.day,
        );
        _startTime = TimeOfDay.fromDateTime(trip.estimatedStartDate);
        _endDate = DateTime(
          trip.estimatedEndDate.year,
          trip.estimatedEndDate.month,
          trip.estimatedEndDate.day,
        );
        _endTime = TimeOfDay.fromDateTime(trip.estimatedEndDate);
      }
    } else {
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
    if (widget.isEditing) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        final parsed = PhoneUtils.splitE164(user.phone);
        _dialCode = parsed.dialCode;
        if (_driverPhoneCtrl.text.isEmpty) {
          _driverPhoneCtrl.text = parsed.localNumber;
        }
      }
    }
  }

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    _vehicleNumberCtrl.dispose();
    _capacityCtrl.dispose();
    _priceCtrl.dispose();
    _driverNameCtrl.dispose();
    _driverPhoneCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) =>
      date == null ? _datePlaceholder : DateFormat('dd/MM/yyyy').format(date);

  String _formatTime(TimeOfDay? time) {
    if (time == null) return _timePlaceholder;
    final dt = DateTime(2020, 1, 1, time.hour, time.minute);
    return DateFormat('hh:mma').format(dt);
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
        _scheduleError = context.l10n.driverTripFormScheduleRequired;
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
        SnackBar(content: Text(context.l10n.driverTripFormVehicleRequired)),
      );
      return;
    }
    if (!_validateSchedule()) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();

    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    final start = _buildDateTime(_startDate, _startTime)!;
    final end = _buildDateTime(_endDate, _endTime)!;

    final fromCity = _cityFromField(_fromCtrl.text.trim(), _fromCity);
    final toCity = _cityFromField(_toCtrl.text.trim(), _toCity);
    final vehicleNumber = _vehicleNumberCtrl.text.trim().toUpperCase();
    final loadCapacityTons = _capacityInTons();
    final driverName = _driverNameCtrl.text.trim();

    if (widget.isEditing) {
      final trip =
          _editingTrip ?? ref.read(driverTripsProvider).byId(widget.tripId!);
      if (trip == null) return;
      await ref.read(driverTripsProvider.notifier).updateTrip(
            trip.copyWith(
              fromCity: fromCity,
              toCity: toCity,
              estimatedStartDate: start,
              estimatedEndDate: end,
              vehicleCategory: _selectedVehicle!,
              vehicleNumber: vehicleNumber,
              loadCapacityTons: loadCapacityTons,
              estimatedPrice: price,
              driverName: driverName,
            ),
          );
    } else {
      await ref.read(driverTripsProvider.notifier).postTrip(
            fromCity: fromCity,
            toCity: toCity,
            estimatedStartDate: start,
            estimatedEndDate: end,
            vehicleType: _selectedVehicle!,
            vehicleNumber: vehicleNumber,
            loadCapacityTons: loadCapacityTons,
            estimatedPrice: price,
            driverName: driverName,
          );
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLoading = ref.watch(driverTripsProvider).isLoading;

    if (widget.isEditing && _editingTrip == null) {
      return CustomerLightChrome(
        child: Scaffold(
          appBar: FlowScreenAppBar(title: l10n.driverUpdateTripTitle),
          body: const ErrorView(message: 'Trip not found.'),
        ),
      );
    }

    final screenTitle =
        widget.isEditing ? l10n.driverUpdateTripTitle : l10n.driverAddTripTitle;
    final ctaLabel =
        widget.isEditing ? l10n.driverUpdateTrip : l10n.driverPublishTrip;
    final vehicleDisplay = _selectedVehicle?.formLabel ?? '';

    return CustomerLightChrome(
      child: Scaffold(
        backgroundColor: DriverTripFormTokens.background,
        appBar: FlowScreenAppBar(
          title: screenTitle,
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
                  padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.driverTripFormContext,
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_MEDIUM,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          height: 20 / 14,
                          color: DriverTripFormTokens.label,
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
                          color: DriverTripFormTokens.heading,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      DriverTripFormRouteCard(
                        sectionTitle: l10n.driverTripFormRouteInfo,
                        fromLabel: l10n.driverTripFormFromLocation,
                        toLabel: l10n.driverTripFormToLocation,
                        fromHint: l10n.driverTripFormFromHint,
                        toHint: l10n.driverTripFormToHint,
                        fromController: _fromCtrl,
                        toController: _toCtrl,
                        onFromPlaceSelected: _onFromPlaceSelected,
                        onToPlaceSelected: _onToPlaceSelected,
                        fromValidator: (v) =>
                            Validators.required(v, l10n.driverTripFormFromLocation),
                        toValidator: (v) =>
                            Validators.required(v, l10n.driverTripFormToLocation),
                      ),
                      SizedBox(height: 24.h),
                      DriverTripFormScheduleCard(
                        sectionTitle: l10n.driverTripFormSchedule,
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
                      DriverTripFormVehicleCard(
                        sectionTitle: l10n.driverTripFormVehicleCapacity,
                        vehicleCategoryLabel: l10n.driverTripFormVehicleCategory,
                        vehicleNumberLabel: l10n.profileVehicleNumber,
                        loadCapacityLabel: l10n.driverTripFormLoadCapacity,
                        weightTypeLabel: l10n.shipmentFormEstWeightType,
                        priceLabel: l10n.driverTripFormEstPrice,
                        vehicleCategoryValue: vehicleDisplay,
                        vehicleCategoryHint: l10n.driverTripFormVehicleCategory,
                        vehicleNumberController: _vehicleNumberCtrl,
                        capacityController: _capacityCtrl,
                        priceController: _priceCtrl,
                        weightUnit: _weightUnit,
                        vehicleNumberHint: l10n.profileVehicleNumberHint,
                        onVehicleTap: _pickVehicle,
                        onWeightUnitTap: _pickWeightUnit,
                        capacityValidator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return l10n.driverTripFormCapacityRequired;
                          }
                          final n = double.tryParse(v.trim());
                          if (n == null || n <= 0) {
                            return l10n.driverTripFormCapacityRequired;
                          }
                          return null;
                        },
                        priceValidator: (v) {
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
                      SizedBox(height: 24.h),
                      DriverTripFormDriverCard(
                        sectionTitle: l10n.driverTripFormDriverInfo,
                        nameLabel: l10n.driverTripFormDriverName,
                        phoneLabel: l10n.driverTripFormDriverPhone,
                        nameController: _driverNameCtrl,
                        phoneController: _driverPhoneCtrl,
                        nameHint: l10n.driverTripFormDriverNameHint,
                        phoneHint: l10n.authPhoneDigitsPlaceholder,
                        dialCode: _dialCode,
                        onDialCodeChanged: _onDialCodeChanged,
                        nameValidator: (v) => Validators.required(
                          v,
                          l10n.driverTripFormDriverName,
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(58.w, 8.h, 58.w, 24.h),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: const [DriverTripFormTokens.ctaShadow],
                  ),
                  child: AppButton(
                    label: ctaLabel,
                    onPressed: isLoading ? null : _submit,
                    isLoading: isLoading,
                    height: 56,
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
