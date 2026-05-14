import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/id_prefixes.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/domain/entities/shipment.dart';
import '../../../../shared/domain/enums/shipment_status.dart';
import '../../../../shared/domain/enums/vehicle_type.dart';
import '../../../../shared/presentation/widgets/buttons/app_button.dart';
import '../../../../shared/presentation/widgets/inputs/app_text_field.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/customer_shipments_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Step data models (local to this screen, not persisted elsewhere)
// ─────────────────────────────────────────────────────────────────────────────

class _StepData {
  // Step 1 — Pickup
  String pickupCity    = '';
  String pickupAddress = '';

  // Step 2 — Drop
  String dropCity      = '';
  String dropAddress   = '';

  // Step 3 — Goods
  String goodsType     = '';
  double weightKg      = 0;
  bool   isFragile     = false;
  String specialNotes  = '';

  // Step 4 — Vehicle & Date
  VehicleType?  vehicleType;
  DateTime?     pickupDate;
}

// ─────────────────────────────────────────────────────────────────────────────
// Multi-step form screen
// ─────────────────────────────────────────────────────────────────────────────

/// 4-step form to post a new shipment request.
///
/// Step 1 → Pickup location
/// Step 2 → Drop location
/// Step 3 → Goods details
/// Step 4 → Vehicle type + date
///
/// On submit → [CustomerShipmentsNotifier.addShipment] → pop back to home.
class PostShipmentScreen extends ConsumerStatefulWidget {
  const PostShipmentScreen({super.key});

  @override
  ConsumerState<PostShipmentScreen> createState() => _PostShipmentScreenState();
}

class _PostShipmentScreenState extends ConsumerState<PostShipmentScreen> {
  final _data          = _StepData();
  final _pageCtrl      = PageController();
  int   _currentStep   = 0;
  bool  _submitted     = false;

  // Form keys per step
  final _formKey1      = GlobalKey<FormState>();
  final _formKey2      = GlobalKey<FormState>();
  final _formKey3      = GlobalKey<FormState>();

  // Controllers
  final _pickupCityCtrl    = TextEditingController();
  final _pickupAddressCtrl = TextEditingController();
  final _dropCityCtrl      = TextEditingController();
  final _dropAddressCtrl   = TextEditingController();
  final _goodsTypeCtrl     = TextEditingController();
  final _weightCtrl        = TextEditingController();
  final _notesCtrl         = TextEditingController();

  static const _totalSteps = 4;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _pickupCityCtrl.dispose();
    _pickupAddressCtrl.dispose();
    _dropCityCtrl.dispose();
    _dropAddressCtrl.dispose();
    _goodsTypeCtrl.dispose();
    _weightCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ──────────────────────────────────────────────────────────

  bool _validateCurrent() {
    setState(() => _submitted = true);
    return switch (_currentStep) {
      0 => _formKey1.currentState?.validate() ?? false,
      1 => _formKey2.currentState?.validate() ?? false,
      2 => _formKey3.currentState?.validate() ?? false,
      3 => _data.vehicleType != null && _data.pickupDate != null,
      _ => true,
    };
  }

  void _goNext() {
    if (!_validateCurrent()) return;
    setState(() => _submitted = false);
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageCtrl.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _submitted = false;
      });
      _pageCtrl.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  Future<void> _submit() async {
    if (!_validateCurrent()) return;
    FocusScope.of(context).unfocus();

    final user   = ref.read(authProvider).user!;
    final now    = DateTime.now();
    final newId  = '${IdPrefixes.shipment}${now.millisecondsSinceEpoch % 9000 + 1000}';

    final shipment = Shipment(
      id:            newId,
      customerId:    user.id,
      pickup:        ShipmentLocation(
        city:        _pickupCityCtrl.text.trim(),
        fullAddress: _pickupAddressCtrl.text.trim(),
      ),
      drop:          ShipmentLocation(
        city:        _dropCityCtrl.text.trim(),
        fullAddress: _dropAddressCtrl.text.trim(),
      ),
      pickupDateTime: _data.pickupDate!,
      dropDateTime:   _data.pickupDate!.add(const Duration(days: 2)),
      goods: GoodsDetail(
        type:                 _goodsTypeCtrl.text.trim(),
        weightKg:             double.tryParse(_weightCtrl.text.trim()) ?? 0,
        isFragile:            _data.isFragile,
        specialInstructions:  _notesCtrl.text.trim().isEmpty
            ? null
            : _notesCtrl.text.trim(),
      ),
      vehicleType:     _data.vehicleType!,
      status:          ShipmentStatus.pending,
      estimatedPrice:  _estimatePrice(_data.vehicleType!,
          double.tryParse(_weightCtrl.text.trim()) ?? 0),
    );

    await ref.read(customerShipmentsProvider.notifier).addShipment(shipment);

    if (mounted) context.pop();
  }

  double _estimatePrice(VehicleType v, double weightKg) => switch (v) {
        VehicleType.mini        => 800  + weightKg * 0.5,
        VehicleType.pickupTruck => 1500 + weightKg * 0.8,
        VehicleType.truck       => 3000 + weightKg * 1.0,
        VehicleType.heavyDuty   => 6000 + weightKg * 1.2,
      };

  // ── Date picker ──────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) setState(() => _data.pickupDate = picked);
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors    = context.colors;
    final isLoading = ref.watch(customerShipmentsProvider).isLoading;

    // Android back button: go to the previous step instead of exiting the flow.
    // On step 0 the back button pops the route normally.
    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return; // step 0 — route already popped by the OS
        _goBack();          // step > 0 — walk back one page
      },
      child: Scaffold(
      backgroundColor: colors.background,
      appBar: AppBarWidget(
        title: context.l10n.shipmentPostNew,
        leadingType: AppBarLeadingType.back,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Step indicator ────────────────────────────────────────────
            _StepIndicator(current: _currentStep, total: _totalSteps),

            // ── Page content ──────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller:   _pageCtrl,
                physics:      const NeverScrollableScrollPhysics(),
                children: [
                  _Step1Pickup(
                    formKey:     _formKey1,
                    cityCtrl:    _pickupCityCtrl,
                    addressCtrl: _pickupAddressCtrl,
                    submitted:   _submitted,
                  ),
                  _Step2Drop(
                    formKey:     _formKey2,
                    cityCtrl:    _dropCityCtrl,
                    addressCtrl: _dropAddressCtrl,
                    submitted:   _submitted,
                  ),
                  _Step3Goods(
                    formKey:      _formKey3,
                    typeCtrl:     _goodsTypeCtrl,
                    weightCtrl:   _weightCtrl,
                    notesCtrl:    _notesCtrl,
                    isFragile:    _data.isFragile,
                    submitted:    _submitted,
                    onFragileChanged: (v) => setState(() => _data.isFragile = v),
                  ),
                  _Step4VehicleDate(
                    selectedVehicle: _data.vehicleType,
                    selectedDate:    _data.pickupDate,
                    submitted:       _submitted,
                    onVehicleSelect: (v) => setState(() => _data.vehicleType = v),
                    onPickDate:      _pickDate,
                  ),
                ],
              ),
            ),

            // ── Bottom navigation bar ─────────────────────────────────────
            _BottomNav(
              currentStep:  _currentStep,
              totalSteps:   _totalSteps,
              isLoading:    isLoading,
              onBack:       _goBack,
              onNext:       _currentStep == _totalSteps - 1 ? _submit : _goNext,
            ),
          ],
        ),
      ),
    ),   // Scaffold
    );   // PopScope
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step indicator
// ─────────────────────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.screenPadding.w,
        AppDimensions.base.h,
        AppDimensions.screenPadding.w,
        AppDimensions.sm.h,
      ),
      child: Row(
        children: List.generate(total, (i) {
          final isCompleted = i < current;
          final isActive    = i == current;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 4.h,
                decoration: BoxDecoration(
                  color: isActive || isCompleted
                      ? colors.primary
                      : colors.divider,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1 — Pickup
// ─────────────────────────────────────────────────────────────────────────────

class _Step1Pickup extends StatelessWidget {
  const _Step1Pickup({
    required this.formKey,
    required this.cityCtrl,
    required this.addressCtrl,
    required this.submitted,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController cityCtrl;
  final TextEditingController addressCtrl;
  final bool submitted;

  @override
  Widget build(BuildContext context) => _StepScaffold(
        icon: Icons.location_on_outlined,
        title: context.l10n.shipmentPickup,
        child: Form(
          key: formKey,
          autovalidateMode: submitted
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Column(
            children: [
              AppTextField(
                label: context.l10n.shipmentPickupCity,
                hint: 'e.g. Mumbai, MH',
                controller: cityCtrl,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.location_city_outlined),
                validator: (v) => Validators.required(
                    v, context.l10n.shipmentPickupCity),
              ),
              SizedBox(height: AppDimensions.base.h),
              AppTextField(
                label: context.l10n.shipmentPickup,
                hint: 'e.g. Bandra East, Mumbai',
                controller: addressCtrl,
                keyboardType: TextInputType.streetAddress,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                prefixIcon: const Icon(Icons.home_outlined),
                validator: (v) => Validators.required(
                    v, context.l10n.shipmentPickup),
              ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2 — Drop
// ─────────────────────────────────────────────────────────────────────────────

class _Step2Drop extends StatelessWidget {
  const _Step2Drop({
    required this.formKey,
    required this.cityCtrl,
    required this.addressCtrl,
    required this.submitted,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController cityCtrl;
  final TextEditingController addressCtrl;
  final bool submitted;

  @override
  Widget build(BuildContext context) => _StepScaffold(
        icon: Icons.flag_outlined,
        title: context.l10n.shipmentDrop,
        child: Form(
          key: formKey,
          autovalidateMode: submitted
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Column(
            children: [
              AppTextField(
                label: context.l10n.shipmentDropCity,
                hint: 'e.g. Delhi',
                controller: cityCtrl,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.location_city_outlined),
                validator: (v) => Validators.required(
                    v, context.l10n.shipmentDropCity),
              ),
              SizedBox(height: AppDimensions.base.h),
              AppTextField(
                label: context.l10n.shipmentDrop,
                hint: 'e.g. Karol Bagh, New Delhi',
                controller: addressCtrl,
                keyboardType: TextInputType.streetAddress,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                prefixIcon: const Icon(Icons.home_outlined),
                validator: (v) => Validators.required(
                    v, context.l10n.shipmentDrop),
              ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 3 — Goods
// ─────────────────────────────────────────────────────────────────────────────

class _Step3Goods extends StatelessWidget {
  const _Step3Goods({
    required this.formKey,
    required this.typeCtrl,
    required this.weightCtrl,
    required this.notesCtrl,
    required this.isFragile,
    required this.submitted,
    required this.onFragileChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController typeCtrl;
  final TextEditingController weightCtrl;
  final TextEditingController notesCtrl;
  final bool isFragile;
  final bool submitted;
  final ValueChanged<bool> onFragileChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _StepScaffold(
      icon: Icons.inventory_2_outlined,
      title: context.l10n.shipmentGoods,
      child: Form(
        key: formKey,
        autovalidateMode: submitted
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: Column(
          children: [
            AppTextField(
              label: context.l10n.shipmentGoodsType,
              hint: 'e.g. Electronics, FMCG, Textiles',
              controller: typeCtrl,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              prefixIcon: const Icon(Icons.category_outlined),
              validator: (v) =>
                  Validators.required(v, context.l10n.shipmentGoodsType),
            ),
            SizedBox(height: AppDimensions.base.h),
            AppTextField(
              label: context.l10n.shipmentWeight,
              hint: 'Weight in KG (e.g. 500)',
              controller: weightCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              prefixIcon: const Icon(Icons.scale_outlined),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return '${context.l10n.shipmentWeight} is required';
                }
                final kg = double.tryParse(v.trim());
                if (kg == null || kg <= 0) return 'Enter a valid weight in KG';
                return null;
              },
            ),
            SizedBox(height: AppDimensions.base.h),
            AppTextField(
              label: context.l10n.shipmentSpecialInstructions,
              hint: context.l10n.shipmentSpecialInstructionsHint,
              controller: notesCtrl,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(Icons.notes_outlined),
            ),
            SizedBox(height: AppDimensions.base.h),
            // Fragile toggle
            GestureDetector(
              onTap: () => onFragileChanged(!isFragile),
              child: Container(
                padding: EdgeInsets.all(AppDimensions.base.w),
                decoration: BoxDecoration(
                  color: isFragile
                      ? colors.warningBackground
                      : colors.cardBackground,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd.r),
                  border: Border.all(
                    color: isFragile ? colors.orangeText : colors.divider,
                    width: isFragile ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: isFragile ? colors.orangeText : colors.textHint,
                    ),
                    SizedBox(width: AppDimensions.sm.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.shipmentFragile,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: isFragile
                                  ? colors.orangeText
                                  : colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            context.l10n.shipmentFragileWarning,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: colors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isFragile,
                      onChanged: onFragileChanged,
                      activeThumbColor: colors.orangeText,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 4 — Vehicle & Date
// ─────────────────────────────────────────────────────────────────────────────

class _Step4VehicleDate extends StatelessWidget {
  const _Step4VehicleDate({
    required this.selectedVehicle,
    required this.selectedDate,
    required this.submitted,
    required this.onVehicleSelect,
    required this.onPickDate,
  });

  final VehicleType? selectedVehicle;
  final DateTime? selectedDate;
  final bool submitted;
  final ValueChanged<VehicleType> onVehicleSelect;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasVehicleError = submitted && selectedVehicle == null;
    final hasDateError    = submitted && selectedDate == null;

    return _StepScaffold(
      icon: Icons.local_shipping_outlined,
      title: context.l10n.profileVehicleType,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle chips
          Wrap(
            spacing: AppDimensions.sm.w,
            runSpacing: AppDimensions.sm.h,
            children: VehicleType.values.map((v) {
              final selected = selectedVehicle == v;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onVehicleSelect(v);
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
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
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
                        color: selected ? colors.primary : colors.textHint,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        v.label,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: selected ? colors.primary : colors.textSecondary,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
              style: context.textTheme.bodySmall?.copyWith(color: colors.error),
            ),
          ],

          SizedBox(height: AppDimensions.xl.h),

          // Date picker
          Text(
            context.l10n.shipmentDate,
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppDimensions.sm.h),

          GestureDetector(
            onTap: onPickDate,
            child: Container(
              padding: EdgeInsets.all(AppDimensions.base.w),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
                border: Border.all(
                  color: hasDateError ? colors.error : colors.divider,
                  width: hasDateError ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      color: colors.primary, size: AppDimensions.iconBase.w),
                  SizedBox(width: AppDimensions.sm.w),
                  Text(
                    selectedDate == null
                        ? 'Select pickup date'
                        : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: selectedDate == null
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
              'Please select a pickup date',
              style: context.textTheme.bodySmall?.copyWith(color: colors.error),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared step scaffold
// ─────────────────────────────────────────────────────────────────────────────

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String   title;
  final Widget   child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: SingleChildScrollView(
        padding:
            EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppDimensions.xl.h),
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: AppDimensions.iconLg.w, color: colors.primary),
            ),
            SizedBox(height: AppDimensions.base.h),
            Text(
              title,
              style: context.textTheme.titleLarge?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppDimensions.xl.h),
            child,
            SizedBox(height: AppDimensions.xxxl.h),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom navigation bar (Back / Next or Submit)
// ─────────────────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.currentStep,
    required this.totalSteps,
    required this.isLoading,
    required this.onBack,
    required this.onNext,
  });

  final int  currentStep;
  final int  totalSteps;
  final bool isLoading;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isLast = currentStep == totalSteps - 1;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.screenPadding.w,
        AppDimensions.base.h,
        AppDimensions.screenPadding.w,
        AppDimensions.xl.h,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        boxShadow: context.cardShadow,
      ),
      child: Row(
        children: [
          if (currentStep > 0)
            AppButton(
              label: context.l10n.actionBack,
              onPressed: isLoading ? null : onBack,
              variant: AppButtonVariant.secondary,
              isFullWidth: false,
              height: AppDimensions.buttonHeight,
            ),
          if (currentStep > 0) SizedBox(width: AppDimensions.sm.w),
          Expanded(
            child: AppButton(
              label: isLast
                  ? context.l10n.actionSubmit
                  : context.l10n.actionNext,
              onPressed: isLoading ? null : onNext,
              isLoading: isLoading && isLast,
              height: AppDimensions.buttonHeight,
            ),
          ),
        ],
      ),
    );
  }
}
