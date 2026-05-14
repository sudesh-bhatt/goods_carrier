import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/domain/enums/vehicle_type.dart';
import '../../../../shared/presentation/widgets/buttons/app_button.dart';
import '../../../../shared/presentation/widgets/inputs/app_text_field.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../providers/auth_provider.dart';

/// Profile setup for new Driver accounts.
///
/// Required: name, vehicle type (chip selector), vehicle number.
/// Capacity is auto-derived from the selected [VehicleType].
///
/// On submit → [AuthNotifier.submitDriverProfile] → auth status becomes
/// [AuthStatus.authenticated] → GoRouter redirects to driverHome.
class DriverProfileSetupScreen extends ConsumerStatefulWidget {
  const DriverProfileSetupScreen({super.key});

  @override
  ConsumerState<DriverProfileSetupScreen> createState() =>
      _DriverProfileSetupScreenState();
}

class _DriverProfileSetupScreenState
    extends ConsumerState<DriverProfileSetupScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _vehicleCtrl  = TextEditingController();

  VehicleType? _selectedVehicle;
  bool _submitted = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _vehicleCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (_selectedVehicle == null) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    await ref.read(authProvider.notifier).submitDriverProfile(
      name: _nameCtrl.text.trim(),
      vehicleNumber: _vehicleCtrl.text.trim(),
      vehicleType: _selectedVehicle!.label,
      capacityTons: _capacityFor(_selectedVehicle!),
    );
    // GoRouter redirect handles navigation.
  }

  double _capacityFor(VehicleType v) => switch (v) {
        VehicleType.mini        => 0.5,
        VehicleType.pickupTruck => 1.5,
        VehicleType.truck       => 5.0,
        VehicleType.heavyDuty   => 15.0,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLoading = ref.watch(authProvider).isLoading;
    final noVehicleSelected = _submitted && _selectedVehicle == null;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBarWidget(
        title: context.l10n.profileSetupTitle,
        leadingType: AppBarLeadingType.none,
      ),
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

                  Text(
                    context.l10n.profileSetupSubtitle,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),

                  SizedBox(height: AppDimensions.xl.h),

                  // ── Avatar placeholder ────────────────────────────────────
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 80.w,
                          height: 80.w,
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.10),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.drive_eta_outlined,
                              size: 40.w, color: colors.primary),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 28.w,
                            height: 28.w,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: colors.surface, width: 2),
                            ),
                            child: Icon(Icons.camera_alt_outlined,
                                size: 14.w, color: colors.onPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppDimensions.xl.h),

                  // ── Name ──────────────────────────────────────────────────
                  AppTextField(
                    label: context.l10n.profileName,
                    hint: 'Vikram Singh',
                    controller: _nameCtrl,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofocus: true,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    validator: (v) => Validators.required(
                        v, context.l10n.profileName),
                  ),

                  SizedBox(height: AppDimensions.xl.h),

                  // ── Vehicle type ──────────────────────────────────────────
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
                              color: selected
                                  ? colors.primary
                                  : colors.divider,
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
                                style:
                                    context.textTheme.labelSmall?.copyWith(
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
                                style:
                                    context.textTheme.labelSmall?.copyWith(
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

                  if (noVehicleSelected) ...[
                    SizedBox(height: AppDimensions.xs.h),
                    Text(
                      'Please select a vehicle type',
                      style: context.textTheme.bodySmall
                          ?.copyWith(color: colors.error),
                    ),
                  ],

                  SizedBox(height: AppDimensions.xl.h),

                  // ── Vehicle number ────────────────────────────────────────
                  AppTextField(
                    label: context.l10n.profileVehicleNumber,
                    hint: context.l10n.profileVehicleNumberHint,
                    controller: _vehicleCtrl,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.done,
                    prefixIcon: const Icon(Icons.directions_car_outlined),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[A-Za-z0-9 ]')),
                    ],
                    validator: Validators.vehicleNumber,
                  ),

                  // ── Capacity (read-only, auto-filled) ─────────────────────
                  if (_selectedVehicle != null) ...[
                    SizedBox(height: AppDimensions.base.h),
                    AppTextField(
                      label: context.l10n.profileLoadCapacity,
                      controller: TextEditingController(
                        text: _selectedVehicle!.capacityLabel,
                      ),
                      readOnly: true,
                      prefixIcon: const Icon(Icons.scale_outlined),
                    ),
                  ],

                  SizedBox(height: AppDimensions.xxxl.h),

                  AppButton(
                    label: context.l10n.actionContinue,
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
