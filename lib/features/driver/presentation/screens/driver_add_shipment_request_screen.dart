import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/domain/entities/driver_vehicle.dart';
import '../../../../shared/domain/entities/shipment.dart';
import '../../../../shared/domain/enums/vehicle_type.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../../../auth/presentation/widgets/driver_profile_form_widgets.dart';
import '../../../customer/presentation/widgets/customer_light_chrome.dart';
import '../../../customer/presentation/widgets/trip_detail/trip_detail_tokens.dart';
import '../models/driver_interest_success_args.dart';
import '../providers/driver_shipment_requests_provider.dart';

/// Driver submits interest with vehicle, offered price, and note.
class DriverAddShipmentRequestScreen extends ConsumerStatefulWidget {
  const DriverAddShipmentRequestScreen({super.key, required this.shipmentId});

  final String shipmentId;

  @override
  ConsumerState<DriverAddShipmentRequestScreen> createState() =>
      _DriverAddShipmentRequestScreenState();
}

class _DriverAddShipmentRequestScreenState
    extends ConsumerState<DriverAddShipmentRequestScreen>
    with SafeSetStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _priceCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  List<DriverVehicle> _vehicles = const [];
  DriverVehicle? _selectedVehicle;
  bool _isLoadingVehicles = true;
  bool _isSubmitting = false;
  String? _loadError;
  bool _submitted = false;

  static const _localVehicles = [
    DriverVehicle(
      id: 1,
      vehicleNumber: 'MH 02 CC 4156',
      vehicleType: VehicleType.pickupTruck,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initForm();
      _loadVehicles();
    });
  }

  void _initForm() {
    final shipment = _resolveShipment();
    if (shipment != null && _priceCtrl.text.isEmpty) {
      _priceCtrl.text = shipment.estimatedPrice.toStringAsFixed(0);
    }
  }

  Shipment? _resolveShipment() {
    return ref.read(driverShipmentRequestsProvider.notifier).byId(widget.shipmentId);
  }

  Future<void> _loadVehicles() async {
    safeSetState(() {
      _isLoadingVehicles = true;
      _loadError = null;
    });

    if (!EnvConfig.useRemoteApi) {
      safeSetState(() {
        _vehicles = _localVehicles;
        _selectedVehicle = _localVehicles.first;
        _isLoadingVehicles = false;
      });
      return;
    }

    try {
      final vehicles =
          await ref.read(driverVehicleApiClientProvider).listVehicles();
      if (!mounted) return;
      final l10n = context.l10n;
      safeSetState(() {
        _vehicles = vehicles;
        _selectedVehicle = vehicles.isNotEmpty ? vehicles.first : null;
        _isLoadingVehicles = false;
        _loadError =
            vehicles.isEmpty ? l10n.driverNoVehiclesMessage : null;
      });
    } catch (e) {
      if (!mounted) return;
      safeSetState(() {
        _isLoadingVehicles = false;
        _loadError = ApiExceptionMapper.userMessage(e);
      });
    }
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    safeSetState(() => _submitted = true);
    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.driverSelectVehicle)),
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final shipment = _resolveShipment();
    if (shipment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shipment not found.')),
      );
      return;
    }

    final offeredPrice = double.parse(_priceCtrl.text.trim());
    final note = _noteCtrl.text.trim();

    safeSetState(() => _isSubmitting = true);
    final ok = await ref.read(driverShipmentRequestsProvider.notifier).expressInterest(
          shipmentId: shipment.id,
          vehicleId: _selectedVehicle!.id,
          offeredPrice: offeredPrice,
          note: note,
        );
    if (!mounted) return;
    safeSetState(() => _isSubmitting = false);

    if (!ok) {
      final error = ref.read(driverShipmentRequestsProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
      return;
    }

    context.push(
      AppRoutes.driverInterestSuccess,
      extra: DriverInterestSuccessArgs(
        fromCity: shipment.pickup.displayLabel,
        toCity: shipment.drop.displayLabel,
        pickupDateTime: shipment.pickupDateTime,
        estimatedPrice: offeredPrice,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shipment = _resolveShipment();

    return CustomerLightChrome(
      child: Scaffold(
        backgroundColor: TripDetailTokens.screenBg,
        appBar: FlowScreenAppBar(title: l10n.driverAddRequestTitle),
        body: _isLoadingVehicles
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                autovalidateMode: _submitted
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 120.h),
                  children: [
                    if (_loadError != null) ...[
                      Text(
                        _loadError!,
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_REGULAR,
                          fontSize: 14.sp,
                          color: TripDetailTokens.estimatedPayBrown,
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                    if (shipment != null) ...[
                      _ShipmentSummaryCard(shipment: shipment),
                      SizedBox(height: 24.h),
                    ],
                    Text(
                      l10n.driverSelectVehicle.toUpperCase(),
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_BOLD,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: const Color(0xFF594136),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<DriverVehicle>(
                      value: _selectedVehicle,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: kDriverProfileFieldFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      hint: Text(l10n.driverSelectVehicle),
                      items: _vehicles
                          .map(
                            (vehicle) => DropdownMenuItem(
                              value: vehicle,
                              child: Text(vehicle.displayLabel),
                            ),
                          )
                          .toList(),
                      onChanged: _isSubmitting
                          ? null
                          : (value) => safeSetState(() => _selectedVehicle = value),
                      validator: (value) =>
                          value == null ? l10n.driverSelectVehicle : null,
                    ),
                    SizedBox(height: 20.h),
                    DriverProfilePersonalField(
                      label: l10n.driverOfferedPrice,
                      hint: l10n.driverOfferedPriceHint,
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return Validators.required(value, l10n.driverOfferedPrice);
                        }
                        final parsed = double.tryParse(value.trim());
                        if (parsed == null || parsed <= 0) {
                          return l10n.driverOfferedPriceInvalid;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),
                    DriverProfileAddressField(
                      label: l10n.driverRequestNote,
                      hint: l10n.driverRequestNoteHint,
                      controller: _noteCtrl,
                      textInputAction: TextInputAction.done,
                      validator: (value) =>
                          Validators.required(value, l10n.driverRequestNote),
                    ),
                  ],
                ),
              ),
        bottomNavigationBar: SafeArea(
          minimum: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
          child: SizedBox(
            height: 56.h,
            child: ElevatedButton(
              onPressed: _isSubmitting ||
                      _isLoadingVehicles ||
                      _vehicles.isEmpty
                  ? null
                  : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                disabledBackgroundColor:
                    context.colors.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: _isSubmitting
                  ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: context.colors.onPrimary,
                      ),
                    )
                  : Text(
                      l10n.driverSubmitRequest,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_BOLD,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: context.colors.onPrimary,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShipmentSummaryCard extends StatelessWidget {
  const _ShipmentSummaryCard({required this.shipment});

  final Shipment shipment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: TripDetailTokens.cardBg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            shipment.id.startsWith('#') ? shipment.id : '#${shipment.id}',
            style: TextStyle(
              fontFamily: FontRes.MANROPE_BOLD,
              fontSize: 16.sp,
              color: TripDetailTokens.bodyDark,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${shipment.pickup.displayLabel} → ${shipment.drop.displayLabel}',
            style: TextStyle(
              fontFamily: FontRes.MANROPE_REGULAR,
              fontSize: 14.sp,
              color: TripDetailTokens.routeLabel,
            ),
          ),
        ],
      ),
    );
  }
}
