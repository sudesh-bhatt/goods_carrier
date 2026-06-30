import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/services/google_places_service.dart';
import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/form_scroll_utils.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/vehicle_number_utils.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/domain/entities/driver_trip.dart';
import '../../../../shared/domain/entities/driver_vehicle.dart';
import '../../../../shared/domain/enums/driver_vehicle_status.dart';
import '../../../../shared/domain/models/trip_form_prefill.dart';
import '../../../../shared/domain/models/trip_submit_options.dart';
import '../../../../shared/presentation/widgets/buttons/app_button.dart';
import '../../../../shared/presentation/widgets/feedback/error_view.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../customer/presentation/widgets/customer_light_chrome.dart';
import '../../../customer/presentation/widgets/shipment_form/shipment_form_pickers.dart';
import '../models/trip_post_confirmation_args.dart';
import '../providers/driver_trips_provider.dart';
import '../providers/driver_vehicles_provider.dart';
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
  final _scrollController = ScrollController();
  final _fromFieldKey = GlobalKey();
  final _toFieldKey = GlobalKey();
  final _scheduleSectionKey = GlobalKey();
  final _vehicleSectionKey = GlobalKey();
  final _driverSectionKey = GlobalKey();
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  final _vehicleNumberCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _driverNameCtrl = TextEditingController();
  final _driverPhoneCtrl = TextEditingController();

  DriverVehicle? _selectedDriverVehicle;
  int? _pendingVehicleId;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  String _weightUnit = 'Ton';
  String _dialCode = '+91';
  bool _submitted = false;
  bool _isLoadingPrefill = false;
  String? _loadPrefillError;
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
        _vehicleNumberCtrl.text = VehicleNumberUtils.format(trip.vehicleNumber);
        _applyCapacityFields(
          value: trip.loadCapacity,
          unit: trip.capacityUnit,
          tonsFallback: trip.loadCapacityTons,
        );
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEditData());
  }

  Future<void> _loadEditData() async {
    if (!widget.isEditing) {
      await ref.read(driverVehiclesProvider.notifier).load();
      if (!mounted) return;
      _syncVehicleFromFleet();
      return;
    }

    final cached = ref.read(driverTripsProvider.notifier).byId(widget.tripId!);
    safeSetState(() {
      _isLoadingPrefill = cached == null;
      _loadPrefillError = null;
    });

    try {
      await ref.read(driverVehiclesProvider.notifier).load();
      final apiId = ref
          .read(driverTripsProvider.notifier)
          .apiResourceIdFor(widget.tripId!);
      final prefill =
          await ref.read(tripRepositoryProvider).getTripForEdit(apiId);
      if (!mounted) return;
      safeSetState(() {
        _applyTripPrefill(prefill);
        _isLoadingPrefill = false;
      });
      _syncVehicleFromFleet();
      ref.read(driverTripsProvider.notifier).upsertTrip(prefill.trip);
    } catch (e) {
      if (!mounted) return;
      safeSetState(() {
        _isLoadingPrefill = false;
        _loadPrefillError =
            _editingTrip == null ? ApiExceptionMapper.userMessage(e) : null;
      });
      if (_editingTrip != null) {
        _syncVehicleFromFleet();
      }
    }
  }

  void _applyTripPrefill(TripFormPrefill prefill) {
    final trip = prefill.trip;
    final options = prefill.options;
    _editingTrip = trip;
    _pendingVehicleId = options.vehicleId > 0 ? options.vehicleId : null;

    final from =
        options.fromLocation.isNotEmpty ? options.fromLocation : trip.fromCity;
    final to = options.toLocation.isNotEmpty ? options.toLocation : trip.toCity;
    _fromCtrl.text = from;
    _toCtrl.text = to;
    _fromCity = from;
    _toCity = to;

    if (trip.vehicleNumber.isNotEmpty) {
      _vehicleNumberCtrl.text = VehicleNumberUtils.format(trip.vehicleNumber);
    }

    final cap = options.loadCapacity > 0
        ? options.loadCapacity
        : (trip.loadCapacity ?? trip.loadCapacityTons);
    final unit = options.capacityUnit.isNotEmpty
        ? options.capacityUnit
        : trip.capacityUnit;
    _applyCapacityFields(value: cap, unit: unit, tonsFallback: trip.loadCapacityTons);

    _priceCtrl.text = trip.estimatedPrice.toStringAsFixed(0);
    if (trip.driverName.isNotEmpty) {
      _driverNameCtrl.text = trip.driverName;
    }
    if (options.driverCountryCode.isNotEmpty) {
      _dialCode = options.driverCountryCode;
    }
    if (options.driverPhone.isNotEmpty) {
      _driverPhoneCtrl.text = options.driverPhone;
    } else if (trip.driverPhone?.trim().isNotEmpty == true) {
      _driverPhoneCtrl.text = trip.driverPhone!.trim();
    }

    if (trip.estimatedStartDate.year > 1970) {
      _startDate = DateTime(
        trip.estimatedStartDate.year,
        trip.estimatedStartDate.month,
        trip.estimatedStartDate.day,
      );
      _startTime = TimeOfDay.fromDateTime(trip.estimatedStartDate);
    }
    if (trip.estimatedEndDate.year > 1970) {
      _endDate = DateTime(
        trip.estimatedEndDate.year,
        trip.estimatedEndDate.month,
        trip.estimatedEndDate.day,
      );
      _endTime = TimeOfDay.fromDateTime(trip.estimatedEndDate);
    }
  }

  String _formatCapacityValue(double cap) {
    return cap >= 1 && cap == cap.truncateToDouble()
        ? cap.toInt().toString()
        : cap.toStringAsFixed(cap == cap.truncateToDouble() ? 0 : 1);
  }

  void _applyCapacityFields({
    required double? value,
    required String? unit,
    required double tonsFallback,
  }) {
    if (value != null && value > 0 && unit != null) {
      _capacityCtrl.text = _formatCapacityValue(value);
      _weightUnit = unit == 'KG' ? 'KG' : 'Ton';
      return;
    }
    _capacityCtrl.text = tonsFallback >= 1
        ? tonsFallback.toStringAsFixed(0)
        : tonsFallback.toStringAsFixed(1);
    _weightUnit = 'Ton';
  }

  List<DriverVehicle> _activeVehicles() {
    return ref
        .read(driverVehiclesProvider)
        .vehicles
        .where((v) => v.status == DriverVehicleStatus.active)
        .toList();
  }

  void _syncVehicleFromFleet() {
    final vehicles = _activeVehicles();
    if (vehicles.isEmpty) return;

    if (_pendingVehicleId != null) {
      final match =
          vehicles.where((v) => v.id == _pendingVehicleId).firstOrNull;
      if (match != null) {
        safeSetState(() {
          _selectDriverVehicle(match, applyDefaults: false);
          _pendingVehicleId = null;
        });
        return;
      }
    }

    final trip = _editingTrip;
    if (trip != null && _selectedDriverVehicle == null) {
      final normalized = VehicleNumberUtils.normalize(trip.vehicleNumber);
      if (normalized.isNotEmpty) {
        final match = vehicles
            .where(
              (v) =>
                  VehicleNumberUtils.normalize(v.vehicleNumber) == normalized,
            )
            .firstOrNull;
        if (match != null) {
          safeSetState(() => _selectDriverVehicle(match, applyDefaults: false));
          return;
        }
      }
      return;
    }

    if (_selectedDriverVehicle != null) return;
    if (vehicles.length == 1) {
      safeSetState(
        () => _selectDriverVehicle(vehicles.first, applyDefaults: !widget.isEditing),
      );
    }
  }

  void _selectDriverVehicle(
    DriverVehicle vehicle, {
    required bool applyDefaults,
  }) {
    _selectedDriverVehicle = vehicle;
    if (applyDefaults) {
      _vehicleNumberCtrl.text =
          VehicleNumberUtils.format(vehicle.vehicleNumber);
      if (vehicle.capacity != null) {
        _capacityCtrl.text = _formatCapacityValue(vehicle.capacity!);
      }
      _weightUnit =
          vehicle.capacityUnit.toUpperCase() == 'KG' ? 'KG' : 'Ton';
    } else if (_vehicleNumberCtrl.text.trim().isEmpty) {
      _vehicleNumberCtrl.text =
          VehicleNumberUtils.format(vehicle.vehicleNumber);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
    final vehicles = _activeVehicles();
    if (vehicles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.driverNoVehiclesMessage)),
      );
      return;
    }

    final picked = await ShipmentFormPickers.showDriverVehicle(
      context,
      vehicles: vehicles,
    );
    if (picked == null) return;
    safeSetState(() => _selectDriverVehicle(picked, applyDefaults: true));
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

  String? _validateCapacity(String? value) {
    final l10n = context.l10n;
    if (value == null || value.trim().isEmpty) {
      return l10n.driverTripFormCapacityRequired;
    }
    final n = double.tryParse(value.trim());
    if (n == null || n <= 0) {
      return l10n.driverTripFormCapacityRequired;
    }

    final vehicle = _selectedDriverVehicle;
    final maxCap = vehicle?.capacity;
    if (maxCap != null && maxCap > 0) {
      final formUnit = TripSubmitOptions.apiCapacityUnit(_weightUnit);
      final vehicleUnit =
          vehicle!.capacityUnit.toUpperCase() == 'KG' ? 'KG' : 'TON';
      final enteredKg = formUnit == 'KG' ? n : n * 1000;
      final maxKg = vehicleUnit == 'KG' ? maxCap : maxCap * 1000;
      if (enteredKg > maxKg + 0.001) {
        return l10n.driverTripFormCapacityExceedsVehicle(vehicle.capacityLabel);
      }
    }
    return null;
  }

  String? _validatePrice(String? value) {
    final l10n = context.l10n;
    if (value == null || value.trim().isEmpty) {
      return l10n.driverTripFormPriceRequired;
    }
    final p = double.tryParse(value.trim());
    if (p == null || p <= 0) {
      return l10n.driverTripFormPriceRequired;
    }
    return null;
  }

  String? _validateVehicleCategory(String? value) {
    if (_selectedDriverVehicle != null) return null;
    return context.l10n.driverTripFormVehicleRequired;
  }

  bool _hasVehicleFieldErrors() {
    return _validateVehicleCategory(_selectedDriverVehicle?.tripFormLabel) !=
            null ||
        _validateCapacity(_capacityCtrl.text) != null ||
        _validatePrice(_priceCtrl.text) != null ||
        Validators.vehicleNumber(_vehicleNumberCtrl.text) != null;
  }

  bool _hasDriverFieldErrors() {
    final l10n = context.l10n;
    return Validators.required(_driverNameCtrl.text, l10n.driverTripFormDriverName) !=
            null ||
        Validators.phoneForCountry(_dialCode, _driverPhoneCtrl.text) != null;
  }

  Future<bool> _validateAllAndScroll() async {
    safeSetState(() {
      _submitted = true;
      _scheduleError = null;
    });

    final scheduleOk = _validateSchedule();
    final formOk = _formKey.currentState?.validate() ?? false;

    final routeOk =
        _fromCtrl.text.trim().isNotEmpty && _toCtrl.text.trim().isNotEmpty;
    final vehicleOk = _selectedDriverVehicle != null;

    GlobalKey? scrollKey;
    if (!routeOk) {
      scrollKey =
          _fromCtrl.text.trim().isEmpty ? _fromFieldKey : _toFieldKey;
    } else if (!scheduleOk) {
      scrollKey = _scheduleSectionKey;
    } else if (!vehicleOk || _hasVehicleFieldErrors()) {
      scrollKey = _vehicleSectionKey;
    } else if (!formOk || _hasDriverFieldErrors()) {
      scrollKey = _driverSectionKey;
    }

    final allOk = routeOk && scheduleOk && vehicleOk && formOk;
    if (!allOk && scrollKey != null) {
      await FormScrollUtils.to(scrollKey);
    }
    return allOk;
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
    FocusScope.of(context).unfocus();
    if (!await _validateAllAndScroll()) return;

    final selectedVehicle = _selectedDriverVehicle!;
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    final start = _buildDateTime(_startDate, _startTime)!;
    final end = _buildDateTime(_endDate, _endTime)!;

    final fromCity = _cityFromField(_fromCtrl.text.trim(), _fromCity);
    final toCity = _cityFromField(_toCtrl.text.trim(), _toCity);
    final fromLocation = _fromCtrl.text.trim();
    final toLocation = _toCtrl.text.trim();
    final vehicleNumber =
        VehicleNumberUtils.format(_vehicleNumberCtrl.text.trim());
    final loadCapacity = double.tryParse(_capacityCtrl.text.trim()) ?? 0;
    final loadCapacityTons = _capacityInTons();
    final driverName = _driverNameCtrl.text.trim();
    final capacityUnit = TripSubmitOptions.apiCapacityUnit(_weightUnit);
    final driverPhone =
        _driverPhoneCtrl.text.trim().replaceAll(RegExp(r'\D'), '');

    final notifier = ref.read(driverTripsProvider.notifier);

    if (widget.isEditing) {
      final trip =
          _editingTrip ?? ref.read(driverTripsProvider).byId(widget.tripId!);
      if (trip == null) return;
      final saved = await notifier.updateTrip(
        trip.copyWith(
          fromCity: fromLocation.isNotEmpty ? fromLocation : fromCity,
          toCity: toLocation.isNotEmpty ? toLocation : toCity,
          estimatedStartDate: start,
          estimatedEndDate: end,
          vehicleCategory: selectedVehicle.vehicleType,
          vehicleNumber: vehicleNumber,
          loadCapacity: loadCapacity,
          capacityUnit: capacityUnit,
          loadCapacityTons: loadCapacityTons,
          estimatedPrice: price,
          driverName: driverName,
        ),
        vehicleId: selectedVehicle.id,
        loadCapacity: loadCapacity,
        capacityUnit: capacityUnit,
        fromLocation: fromLocation,
        toLocation: toLocation,
        driverCountryCode: _dialCode,
        driverPhone: driverPhone,
      );
      if (!mounted) return;
      if (saved == null) {
        final error = ref.read(driverTripsProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? context.l10n.errorGeneric)),
        );
        return;
      }
      _goToConfirmation(
        isUpdate: true,
        tripId: saved.id,
        fromLocation: fromLocation,
        toLocation: toLocation,
        startDate: start,
        totalPrice: price,
      );
      return;
    }

    final saved = await notifier.postTrip(
      fromCity: fromCity,
      toCity: toCity,
      fromLocation: fromLocation,
      toLocation: toLocation,
      estimatedStartDate: start,
      estimatedEndDate: end,
      vehicleType: selectedVehicle.vehicleType,
      vehicleNumber: vehicleNumber,
      vehicleId: selectedVehicle.id,
      loadCapacity: loadCapacity,
      loadCapacityTons: loadCapacityTons,
      estimatedPrice: price,
      driverName: driverName,
      capacityUnit: capacityUnit,
      driverCountryCode: _dialCode,
      driverPhone: driverPhone,
    );

    if (!mounted) return;
    if (saved == null) {
      final error = ref.read(driverTripsProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? context.l10n.errorGeneric)),
      );
      return;
    }

    _goToConfirmation(
      isUpdate: false,
      tripId: saved.id,
      fromLocation: fromLocation,
      toLocation: toLocation,
      startDate: start,
      totalPrice: price,
    );
  }

  void _goToConfirmation({
    required bool isUpdate,
    required String tripId,
    required String fromLocation,
    required String toLocation,
    required DateTime startDate,
    required double totalPrice,
  }) {
    context.go(
      AppRoutes.tripPostConfirmation,
      extra: TripPostConfirmationArgs(
        isUpdate: isUpdate,
        tripId: tripId,
        fromCity: fromLocation,
        toCity: toLocation,
        startDate: startDate,
        totalPrice: totalPrice,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLoading = ref.watch(driverTripsProvider).isLoading;

    if (widget.isEditing && _isLoadingPrefill && _editingTrip == null) {
      return CustomerLightChrome(
        child: Scaffold(
          appBar: FlowScreenAppBar(title: l10n.driverUpdateTripTitle),
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (widget.isEditing &&
        _loadPrefillError != null &&
        _editingTrip == null) {
      return CustomerLightChrome(
        child: Scaffold(
          appBar: FlowScreenAppBar(title: l10n.driverUpdateTripTitle),
          body: ErrorView(
            message: _loadPrefillError!,
            onRetry: _loadEditData,
          ),
        ),
      );
    }

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
    final vehicleDisplay = _selectedDriverVehicle?.tripFormLabel ?? '';

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
                  controller: _scrollController,
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
                        fromFieldKey: _fromFieldKey,
                        toFieldKey: _toFieldKey,
                        onFromPlaceSelected: _onFromPlaceSelected,
                        onToPlaceSelected: _onToPlaceSelected,
                        fromValidator: (v) =>
                            Validators.required(v, l10n.driverTripFormFromLocation),
                        toValidator: (v) =>
                            Validators.required(v, l10n.driverTripFormToLocation),
                      ),
                      SizedBox(height: 24.h),
                      KeyedSubtree(
                        key: _scheduleSectionKey,
                        child: DriverTripFormScheduleCard(
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
                      ),
                      SizedBox(height: 24.h),
                      KeyedSubtree(
                        key: _vehicleSectionKey,
                        child: DriverTripFormVehicleCard(
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
                        vehicleCategoryValidator: _validateVehicleCategory,
                        vehicleNumberValidator: Validators.vehicleNumber,
                        capacityValidator: _validateCapacity,
                        priceValidator: _validatePrice,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      KeyedSubtree(
                        key: _driverSectionKey,
                        child: DriverTripFormDriverCard(
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
                        phoneValidator: (v) =>
                            Validators.phoneForCountry(_dialCode, v),
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
