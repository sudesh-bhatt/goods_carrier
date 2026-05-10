import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/domain/enums/vehicle_type.dart';
import '../../../../shared/presentation/widgets/buttons/app_button.dart';
import '../../../../shared/presentation/widgets/inputs/app_text_field.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/driver_trips_provider.dart';

/// Driver posts a new VB-XXXX trip (available route).
///
/// Fields: from city, to city, start date, vehicle type (chip selector),
/// vehicle number (auto-filled from profile), load capacity (derived),
/// quoted price.
///
/// On submit → [DriverTripsNotifier.postTrip] → pop back to home.
class PostTripScreen extends ConsumerStatefulWidget {
  const PostTripScreen({super.key});

  @override
  ConsumerState<PostTripScreen> createState() => _PostTripScreenState();
}

class _PostTripScreenState extends ConsumerState<PostTripScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _fromCtrl     = TextEditingController();
  final _toCtrl       = TextEditingController();
  final _vehicleCtrl  = TextEditingController();
  final _priceCtrl    = TextEditingController();

  VehicleType? _selectedVehicle;
  DateTime?    _startDate;
  bool         _submitted = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill vehicle number from driver profile (Session 7 will load from API)
    final user = ref.read(authProvider).user;
    if (user != null) {
      // DummyUser.driver has no vehicleNumber field on User entity;
      // that's in DriverTrip. We leave it blank for user to fill.
    }
  }

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    _vehicleCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  double _capacityFor(VehicleType v) => switch (v) {
        VehicleType.mini        => 0.5,
        VehicleType.pickupTruck => 1.5,
        VehicleType.truck       => 5.0,
        VehicleType.heavyDuty   => 15.0,
      };

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate:   DateTime.now(),
      lastDate:    DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (_selectedVehicle == null || _startDate == null) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;

    await ref.read(driverTripsProvider.notifier).postTrip(
      fromCity:         _fromCtrl.text.trim(),
      toCity:           _toCtrl.text.trim(),
      startDate:        _startDate!,
      vehicleType:      _selectedVehicle!,
      vehicleNumber:    _vehicleCtrl.text.trim().toUpperCase(),
      loadCapacityTons: _capacityFor(_selectedVehicle!),
      estimatedPrice:   price,
    );

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors    = context.colors;
    final isLoading = ref.watch(driverTripsProvider).isLoading;
    final hasVehicleError = _submitted && _selectedVehicle == null;
    final hasDateError    = _submitted && _startDate == null;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBarWidget(title: context.l10n.tripPostNew),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Form(
            key: _formKey,
            autovalidateMode: _submitted
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenPadding.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppDimensions.xl.h),

                  // ── Route ──────────────────────────────────────────────
                  Text(
                    'Route Details',
                    style: context.textTheme.titleSmall?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppDimensions.sm.h),

                  AppTextField(
                    label: context.l10n.tripFrom,
                    hint: 'e.g. Mumbai, MH',
                    controller: _fromCtrl,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    validator: (v) =>
                        Validators.required(v, context.l10n.tripFrom),
                  ),

                  SizedBox(height: AppDimensions.base.h),

                  AppTextField(
                    label: context.l10n.tripTo,
                    hint: 'e.g. Delhi',
                    controller: _toCtrl,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.flag_outlined),
                    validator: (v) =>
                        Validators.required(v, context.l10n.tripTo),
                  ),

                  SizedBox(height: AppDimensions.xl.h),

                  // ── Date ───────────────────────────────────────────────
                  Text(
                    context.l10n.tripDate,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: AppDimensions.sm.h),

                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: EdgeInsets.all(AppDimensions.base.w),
                      decoration: BoxDecoration(
                        color: colors.cardBackground,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMd.r),
                        border: Border.all(
                          color: hasDateError ? colors.error : colors.divider,
                          width: hasDateError ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              color: colors.primary,
                              size: AppDimensions.iconBase.w),
                          SizedBox(width: AppDimensions.sm.w),
                          Text(
                            _startDate == null
                                ? 'Select start date'
                                : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: _startDate == null
                                  ? colors.textHint
                                  : colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (hasDateError) ...[
                    SizedBox(height: AppDimensions.xs.h),
                    Text(
                      'Please select a start date',
                      style: context.textTheme.bodySmall
                          ?.copyWith(color: colors.error),
                    ),
                  ],

                  SizedBox(height: AppDimensions.xl.h),

                  // ── Vehicle type ───────────────────────────────────────
                  Text(
                    context.l10n.profileVehicleType,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: AppDimensions.sm.h),

                  Wrap(
                    spacing: AppDimensions.sm.w,
                    runSpacing: AppDimensions.sm.h,
                    children: VehicleType.values.map((v) {
                      final selected = _selectedVehicle == v;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedVehicle = v);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.base.w,
                            vertical: AppDimensions.sm.h,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? colors.primary.withOpacity(0.10)
                                : colors.cardBackground,
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd.r),
                            border: Border.all(
                              color: selected ? colors.primary : colors.divider,
                              width: selected ? 2.0 : 1.0,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_shipping_outlined,
                                size: AppDimensions.iconLg.w,
                                color: selected
                                    ? colors.primary
                                    : colors.textHint,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                v.label,
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: selected
                                      ? colors.primary
                                      : colors.textSecondary,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                              Text(
                                v.capacityLabel,
                                style: context.textTheme.labelSmall?.copyWith(
                                  fontSize: 10.sp,
                                  color: colors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  if (hasVehicleError) ...[
                    SizedBox(height: AppDimensions.xs.h),
                    Text(
                      'Please select a vehicle type',
                      style: context.textTheme.bodySmall
                          ?.copyWith(color: colors.error),
                    ),
                  ],

                  SizedBox(height: AppDimensions.xl.h),

                  // ── Vehicle number ─────────────────────────────────────
                  AppTextField(
                    label: context.l10n.profileVehicleNumber,
                    hint: context.l10n.profileVehicleNumberHint,
                    controller: _vehicleCtrl,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.next,
                    prefixIcon:
                        const Icon(Icons.directions_car_outlined),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[A-Za-z0-9 ]')),
                    ],
                    validator: Validators.vehicleNumber,
                  ),

                  SizedBox(height: AppDimensions.base.h),

                  // ── Capacity (auto-derived, read-only) ─────────────────
                  if (_selectedVehicle != null)
                    AppTextField(
                      label: context.l10n.tripCapacity,
                      controller: TextEditingController(
                          text: _selectedVehicle!.capacityLabel),
                      readOnly: true,
                      prefixIcon: const Icon(Icons.scale_outlined),
                    ),

                  SizedBox(height: AppDimensions.base.h),

                  // ── Quoted price ───────────────────────────────────────
                  AppTextField(
                    label: context.l10n.tripPrice,
                    hint: 'e.g. 2500',
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    prefixIcon: const Icon(Icons.currency_rupee_rounded),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Quote price is required';
                      }
                      final p = double.tryParse(v.trim());
                      if (p == null || p <= 0) return 'Enter a valid price';
                      return null;
                    },
                  ),

                  SizedBox(height: AppDimensions.xxxl.h),

                  AppButton(
                    label: context.l10n.tripPostNew,
                    onPressed: isLoading ? null : _submit,
                    isLoading: isLoading,
                  ),

                  SizedBox(height: AppDimensions.xl.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
