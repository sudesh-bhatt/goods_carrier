import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/constants/id_prefixes.dart';
import '../../../../core/router/app_routes.dart';
import '../models/shipment_post_confirmation_args.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/utils/validators.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/domain/entities/shipment.dart';
import '../../../../shared/domain/enums/shipment_status.dart';
import '../../../../shared/domain/enums/vehicle_type.dart';
import '../../../../shared/presentation/widgets/buttons/app_button.dart';
import '../../../../shared/presentation/widgets/sheets/app_picker_bottom_sheet.dart';
import '../providers/customer_shipments_provider.dart';
import '../widgets/customer_light_chrome.dart';
import '../widgets/shipment_form/shipment_form_card.dart';
import '../widgets/shipment_form/shipment_form_field.dart';
import '../widgets/shipment_form/shipment_form_route_card.dart';
import '../widgets/shipment_form/shipment_form_tokens.dart';
import '../widgets/shipment_form/shipment_form_weight_row.dart';

/// Unified create / edit shipment form — Figma Post Shipment (`1:2787`).
class ShipmentFormScreen extends ConsumerStatefulWidget {
  const ShipmentFormScreen({super.key, this.shipmentId});

  /// When set, form opens in edit mode with fields pre-filled.
  final String? shipmentId;

  bool get isEditing => shipmentId != null;

  @override
  ConsumerState<ShipmentFormScreen> createState() => _ShipmentFormScreenState();
}

class _ShipmentFormScreenState extends ConsumerState<ShipmentFormScreen>
    with SafeSetStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  final _goodsTypeCtrl = TextEditingController();
  final _vehicleCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _commentsCtrl = TextEditingController();

  VehicleType? _vehicleType;
  DateTime? _pickupDate;
  TimeOfDay? _pickupTime;
  String _weightUnit = 'KG';
  bool _termsAccepted = false;
  bool _submitted = false;
  Shipment? _existing;

  static const _goodsOptions = [
    'Electric',
    'Electronics',
    'FMCG',
    'Textiles',
    'Furniture',
    'Machinery',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (!widget.isEditing) {
      final now = DateTime.now();
      _pickupDate = DateTime(now.year, now.month, now.day);
      _pickupTime = const TimeOfDay(hour: 9, minute: 0);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
  }

  void _loadExisting() {
    if (!widget.isEditing) return;
    final shipment = ref.read(customerShipmentsProvider.notifier).byId(
          widget.shipmentId!,
        );
    if (shipment == null) return;

    _existing = shipment;
    _fromCtrl.text = shipment.pickup.city;
    _toCtrl.text = shipment.drop.city;
    _goodsTypeCtrl.text = shipment.goods.type;
    _vehicleType = shipment.vehicleType;
    _vehicleCtrl.text = shipment.vehicleType.label;
    _weightCtrl.text = shipment.goods.weightKg.toStringAsFixed(
      shipment.goods.weightKg % 1 == 0 ? 0 : 2,
    );
    _weightUnit = shipment.goods.weightKg >= 1000 ? 'Ton' : 'KG';
    _pickupDate = DateTime(
      shipment.pickupDateTime.year,
      shipment.pickupDateTime.month,
      shipment.pickupDateTime.day,
    );
    _pickupTime = TimeOfDay.fromDateTime(shipment.pickupDateTime);
    _budgetCtrl.text = shipment.estimatedPrice.toStringAsFixed(0);
    _commentsCtrl.text = shipment.goods.specialInstructions ?? '';
    _termsAccepted = true;
    safeSetState(() {});
  }

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    _goodsTypeCtrl.dispose();
    _vehicleCtrl.dispose();
    _weightCtrl.dispose();
    _budgetCtrl.dispose();
    _commentsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickOption({
    required String title,
    required List<String> options,
    required TextEditingController controller,
    ValueChanged<String>? onSelected,
  }) async {
    final picked = await AppPickerBottomSheet.show<String>(
      context: context,
      title: title,
      items: options
          .map((o) => AppPickerItem<String>(value: o, label: o))
          .toList(),
    );
    if (picked == null) return;
    controller.text = picked;
    onSelected?.call(picked);
    safeSetState(() {});
  }

  Future<void> _pickVehicle() async {
    final picked = await AppPickerBottomSheet.show<VehicleType>(
      context: context,
      title: context.l10n.shipmentFormVehicleRequirement,
      items: VehicleType.values
          .map(
            (v) => AppPickerItem<VehicleType>(
              value: v,
              label: v.label,
              subtitle: v.capacityLabel,
            ),
          )
          .toList(),
    );
    if (picked == null) return;
    safeSetState(() {
      _vehicleType = picked;
      _vehicleCtrl.text = picked.label;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickupDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) safeSetState(() => _pickupDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _pickupTime ?? TimeOfDay.now(),
    );
    if (picked != null) safeSetState(() => _pickupTime = picked);
  }

  Future<void> _pickWeightUnit() async {
    final picked = await AppPickerBottomSheet.show<String>(
      context: context,
      title: context.l10n.shipmentFormEstWeightType,
      items: const [
        AppPickerItem(value: 'KG', label: 'KG'),
        AppPickerItem(value: 'Ton', label: 'Ton'),
      ],
    );
    if (picked != null) safeSetState(() => _weightUnit = picked);
  }

  double _weightInKg() {
    final raw = double.tryParse(_weightCtrl.text.trim()) ?? 0;
    return _weightUnit == 'Ton' ? raw * 1000 : raw;
  }

  DateTime _buildPickupDateTime() {
    final d = _pickupDate ?? DateTime.now();
    final t = _pickupTime ?? const TimeOfDay(hour: 9, minute: 0);
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  double _estimatePrice(VehicleType v, double weightKg) => switch (v) {
        VehicleType.mini => 800 + weightKg * 0.5,
        VehicleType.pickupTruck => 1500 + weightKg * 0.8,
        VehicleType.truck => 3000 + weightKg * 1.0,
        VehicleType.heavyDuty => 6000 + weightKg * 1.2,
      };

  Shipment _buildShipment({required String id, required String customerId}) {
    final weightKg = _weightInKg();
    final budget = double.tryParse(_budgetCtrl.text.trim());
  final vehicle = _vehicleType ?? VehicleType.mini;

    return Shipment(
      id: id,
      customerId: customerId,
      pickup: ShipmentLocation(
        city: _fromCtrl.text.trim(),
        fullAddress: _fromCtrl.text.trim(),
      ),
      drop: ShipmentLocation(
        city: _toCtrl.text.trim(),
        fullAddress: _toCtrl.text.trim(),
      ),
      pickupDateTime: _buildPickupDateTime(),
      dropDateTime: _buildPickupDateTime().add(const Duration(days: 2)),
      goods: GoodsDetail(
        type: _goodsTypeCtrl.text.trim(),
        weightKg: weightKg,
        isFragile: false,
        specialInstructions: _commentsCtrl.text.trim().isEmpty
            ? null
            : _commentsCtrl.text.trim(),
      ),
      vehicleType: vehicle,
      status: _existing?.status ?? ShipmentStatus.pending,
      estimatedPrice: budget ?? _estimatePrice(vehicle, weightKg),
      assignedDriverId: _existing?.assignedDriverId,
      interestedDriverIds: _existing?.interestedDriverIds ?? const [],
    );
  }

  Future<void> _submit() async {
    safeSetState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_vehicleType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.shipmentFormVehicleRequired)),
      );
      return;
    }
    if (_pickupDate == null || _pickupTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.shipmentFormScheduleRequired)),
      );
      return;
    }
    if (!widget.isEditing && !_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.shipmentFormTermsRequired)),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    final user = ref.read(authProvider).user!;
    final notifier = ref.read(customerShipmentsProvider.notifier);

    if (widget.isEditing && _existing != null) {
      final updated = _buildShipment(
        id: _existing!.id,
        customerId: _existing!.customerId,
      );
      await notifier.updateShipment(updated);
    } else {
      final now = DateTime.now();
      final newId =
          '${IdPrefixes.shipment}${now.millisecondsSinceEpoch % 9000 + 1000}';
      final created = _buildShipment(id: newId, customerId: user.id);
      await notifier.addShipment(created);
      if (!mounted) return;
      context.go(
        AppRoutes.shipmentPostConfirmation,
        extra: ShipmentPostConfirmationArgs(
          shipmentId: created.id,
          fromCity: created.pickup.city,
          toCity: created.drop.city,
          pickupDate: created.pickupDateTime,
          totalPrice: created.estimatedPrice,
        ),
      );
      return;
    }

    if (mounted) context.pop();
  }

  String _formatDate(DateTime? date) =>
      date == null ? 'mm/dd/yyyy' : DateFormat('MM/dd/yyyy').format(date);

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '00:00';
    final dt = DateTime(2020, 1, 1, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLoading = ref.watch(customerShipmentsProvider).isLoading;
    final isEditing = widget.isEditing;

    return CustomerLightChrome(
      child: Scaffold(
        backgroundColor: ShipmentFormTokens.background,
        appBar: _ShipmentFormAppBar(
          title: isEditing ? l10n.shipmentEditTitle : l10n.shipmentPostNew,
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
                      if (!isEditing) ...[
                        Text(
                          l10n.shipmentFormPrecisionLogistics,
                          style: TextStyle(
                            fontFamily: FontRes.MANROPE_MEDIUM,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.35,
                            color: ShipmentFormTokens.primary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          l10n.shipmentFormHeroTitle,
                          style: TextStyle(
                            fontFamily: FontRes.MANROPE_EXTRABOLD,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w800,
                            height: 38 / 24,
                            color: ShipmentFormTokens.heading,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          l10n.shipmentFormHeroSubtitle,
                          style: TextStyle(
                            fontFamily: FontRes.MANROPE_REGULAR,
                            fontSize: 16.sp,
                            height: 20 / 16,
                            color: ShipmentFormTokens.label,
                          ),
                        ),
                        SizedBox(height: 32.h),
                      ],
                      if (isEditing && _existing != null) ...[
                        ShipmentFormReadOnlyIdCard(shipmentId: _existing!.id),
                        SizedBox(height: 24.h),
                      ],
                      ShipmentFormRouteCard(
                        fromController: _fromCtrl,
                        toController: _toCtrl,
                        fromHint: l10n.shipmentFormFromHint,
                        toHint: l10n.shipmentFormToHint,
                        fromValidator: (v) =>
                            Validators.required(v, 'From'),
                        toValidator: (v) => Validators.required(v, 'To'),
                      ),
                      SizedBox(height: 24.h),
                      ShipmentFormCard(
                        child: ShipmentFormSection(
                          label: l10n.shipmentGoodsType,
                          child: ShipmentFormInputRow(
                            icon: Icons.inventory_2_outlined,
                            controller: _goodsTypeCtrl,
                            hint: l10n.shipmentGoodsType,
                            readOnly: true,
                            onTap: () => _pickOption(
                              title: l10n.shipmentGoodsType,
                              options: _goodsOptions,
                              controller: _goodsTypeCtrl,
                            ),
                            validator: (v) =>
                                Validators.required(v, l10n.shipmentGoodsType),
                          ),
                        ),
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
                      ShipmentFormWeightRow(
                        weightController: _weightCtrl,
                        weightUnit: _weightUnit,
                        weightLabel: l10n.shipmentFormEstWeight,
                        unitLabel: l10n.shipmentFormEstWeightType,
                        onUnitTap: _pickWeightUnit,
                      ),
                      SizedBox(height: 24.h),
                      ShipmentFormCard(
                        padding: EdgeInsets.fromLTRB(24.w, 23.h, 24.w, 24.h),
                        child: Column(
                          children: [
                            _ScheduleField(
                              label: l10n.shipmentFormPickupDate,
                              value: _formatDate(_pickupDate),
                              icon: Icons.calendar_today_outlined,
                              onTap: _pickDate,
                              isPlaceholder: _pickupDate == null,
                            ),
                            SizedBox(height: 23.h),
                            _ScheduleField(
                              label: l10n.shipmentFormPickupTime,
                              value: _formatTime(_pickupTime),
                              icon: Icons.access_time_rounded,
                              onTap: _pickTime,
                              isPlaceholder: _pickupTime == null,
                            ),
                            SizedBox(height: 23.h),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.shipmentFormYourBudget.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: FontRes.MANROPE_BOLD,
                                    fontSize: 11.sp,
                                    letterSpacing: 1.1,
                                    color: ShipmentFormTokens.label,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                ShipmentFormInputRow(
                                  icon: Icons.currency_rupee,
                                  controller: _budgetCtrl,
                                  hint: l10n.shipmentFormBudgetHint,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  suffix: Padding(
                                    padding: EdgeInsets.only(left: 8.w),
                                    child: Text(
                                      'INR',
                                      style: TextStyle(
                                        fontFamily: FontRes.MANROPE_SEMIBOLD,
                                        fontSize: 10.sp,
                                        color: ShipmentFormTokens.currencySuffix,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        l10n.shipmentFormCommentsLabel.toUpperCase(),
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_BOLD,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: ShipmentFormTokens.label,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      ShipmentFormCommentsField(
                        controller: _commentsCtrl,
                        hint: l10n.shipmentFormCommentsHint,
                      ),
                      if (!isEditing) ...[
                        SizedBox(height: 24.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24.w,
                              height: 24.w,
                              child: Checkbox(
                                value: _termsAccepted,
                                onChanged: (v) => safeSetState(
                                  () => _termsAccepted = v ?? false,
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                fillColor: WidgetStateProperty.resolveWith(
                                  (states) => Colors.white,
                                ),
                                checkColor: Colors.black,
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 0.7,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                l10n.shipmentFormTerms,
                                style: TextStyle(
                                  fontFamily: FontRes.MANROPE_SEMIBOLD,
                                  fontSize: 12.sp,
                                  height: 16 / 12,
                                  color: ShipmentFormTokens.termsText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
                    label: isEditing
                        ? l10n.shipmentUpdate
                        : l10n.shipmentPostNew,
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

class _ShipmentFormAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ShipmentFormAppBar({required this.title});

  final String title;

  @override
  Size get preferredSize => Size.fromHeight(64.h);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white.withValues(alpha: 0.8),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.pop();
                    },
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: EdgeInsets.only(left: 4.w, top: 8.h, bottom: 8.h, right: 8.w),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        size: 28.w,
                        color: ShipmentFormTokens.primary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_BOLD,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.45,
                    color: ShipmentFormTokens.title,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScheduleField extends StatelessWidget {
  const _ScheduleField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.isPlaceholder = false,
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
        ShipmentFormFieldLabel(text: label),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 52.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: ShipmentFormTokens.fieldFill,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18.w, color: ShipmentFormTokens.primary),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_MEDIUM,
                      fontSize: 16.sp,
                      color: isPlaceholder
                          ? ShipmentFormTokens.hint
                          : ShipmentFormTokens.heading,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
