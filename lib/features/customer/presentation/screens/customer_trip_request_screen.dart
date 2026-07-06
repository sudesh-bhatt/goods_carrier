import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/num_ext.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/domain/entities/driver_trip.dart';
import '../../../../shared/domain/entities/shipment.dart';
import '../../../../shared/presentation/widgets/feedback/error_view.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../../../auth/presentation/widgets/driver_profile_form_widgets.dart';
import '../models/customer_trip_request_success_args.dart';
import '../providers/customer_dashboard_provider.dart';
import '../providers/customer_shipments_provider.dart';
import '../providers/customer_trip_actions_provider.dart';
import '../widgets/customer_light_chrome.dart';
import '../widgets/trip_detail/trip_detail_tokens.dart';

/// Customer sends interest in a driver trip linked to one of their shipments.
class CustomerTripRequestScreen extends ConsumerStatefulWidget {
  const CustomerTripRequestScreen({
    super.key,
    this.trip,
    this.tripId,
  }) : assert(trip != null || tripId != null);

  final DriverTrip? trip;
  final String? tripId;

  @override
  ConsumerState<CustomerTripRequestScreen> createState() =>
      _CustomerTripRequestScreenState();
}

class _CustomerTripRequestScreenState
    extends ConsumerState<CustomerTripRequestScreen> with SafeSetStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _noteCtrl = TextEditingController();

  Shipment? _selectedShipment;
  bool _isSubmitting = false;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureShipmentsLoaded();
      _autoSelectShipment();
    });
  }

  void _ensureShipmentsLoaded() {
    ref.read(customerShipmentsProvider.notifier).loadForTab();
  }

  void _autoSelectShipment() {
    final eligible = _eligibleShipments();
    if (eligible.length == 1) {
      safeSetState(() => _selectedShipment = eligible.first);
    }
  }

  List<Shipment> _eligibleShipments() {
    return ref
        .read(customerShipmentsProvider)
        .shipments
        .where((s) => s.isPending && _shipmentApiId(s) != null)
        .toList(growable: false);
  }

  int? _shipmentApiId(Shipment shipment) =>
      int.tryParse(shipment.apiResourceId);

  DriverTrip? _resolveTrip() {
    if (widget.trip != null) return widget.trip;
    final id = widget.tripId;
    if (id == null) return null;
    return ref.watch(customerDashboardProvider.notifier).byId(id);
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(DriverTrip trip) async {
    safeSetState(() => _submitted = true);
    if (_selectedShipment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.customerSelectShipment)),
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final shipmentId = _shipmentApiId(_selectedShipment!);
    if (shipmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.errorGeneric)),
      );
      return;
    }

    safeSetState(() => _isSubmitting = true);
    try {
      await ref.read(customerTripActionsProvider.notifier).submitRequest(
            trip: trip,
            shipmentId: shipmentId,
            note: _noteCtrl.text.trim(),
          );
      if (!mounted) return;

      final shipment = _selectedShipment!;
      context.pushReplacement(
        AppRoutes.customerTripRequestSuccess,
        extra: CustomerTripRequestSuccessArgs(
          fromCity: shipment.pickup.displayLabel,
          toCity: shipment.drop.displayLabel,
          pickupDateTime: shipment.pickupDateTime,
          estimatedPrice: trip.estimatedPrice,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      final error = ref.read(customerTripActionsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? context.l10n.errorGeneric)),
      );
    } finally {
      if (mounted) safeSetState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final trip = _resolveTrip();
    final shipmentsState = ref.watch(customerShipmentsProvider);
    final eligible = shipmentsState.shipments
        .where((s) => s.isPending && _shipmentApiId(s) != null)
        .toList(growable: false);

    if (trip == null) {
      return Scaffold(
        backgroundColor: TripDetailTokens.screenBg,
        appBar: FlowScreenAppBar(
          title: l10n.customerTripRequestTitle,
          fallbackRoute: AppRoutes.customerHome,
        ),
        body: const ErrorView(message: 'Trip not found.'),
      );
    }

    return CustomerLightChrome(
      child: Scaffold(
        backgroundColor: TripDetailTokens.screenBg,
        appBar: FlowScreenAppBar(
          title: l10n.customerTripRequestTitle,
          backgroundColor: Colors.white.withValues(alpha: 0.8),
        ),
        body: shipmentsState.isLoading && eligible.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : eligible.isEmpty
                ? ErrorView(
                    message: l10n.customerTripRequestNoShipments,
                    onRetry: () => context.push(AppRoutes.postShipment),
                  )
                : Form(
                    key: _formKey,
                    autovalidateMode: _submitted
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 120.h),
                      children: [
                        _TripSummaryCard(trip: trip),
                        SizedBox(height: 24.h),
                        Text(
                          l10n.customerSelectShipment.toUpperCase(),
                          style: TextStyle(
                            fontFamily: FontRes.MANROPE_BOLD,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: TripDetailTokens.routeLabel,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        ...eligible.map((shipment) {
                          final selected = _selectedShipment?.id == shipment.id;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: _ShipmentOptionTile(
                              shipment: shipment,
                              selected: selected,
                              shipmentIdLabel: l10n.shipmentId,
                              onTap: () => safeSetState(
                                () => _selectedShipment = shipment,
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: 12.h),
                        DriverProfileAddressField(
                          label: l10n.customerTripRequestNote,
                          hint: l10n.customerTripRequestNoteHint,
                          controller: _noteCtrl,
                          textInputAction: TextInputAction.done,
                          validator: (value) => Validators.required(
                            value,
                            l10n.customerTripRequestNote,
                          ),
                        ),
                      ],
                    ),
                  ),
        bottomNavigationBar: eligible.isEmpty
            ? null
            : SafeArea(
                minimum: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
                child: SizedBox(
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : () => _submit(trip),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TripDetailTokens.primaryOrange,
                      disabledBackgroundColor: TripDetailTokens.primaryOrange
                          .withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            width: 22.w,
                            height: 22.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            l10n.actionRequest,
                            style: TextStyle(
                              fontFamily: FontRes.MANROPE_BOLD,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _TripSummaryCard extends StatelessWidget {
  const _TripSummaryCard({required this.trip});

  final DriverTrip trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: TripDetailTokens.cardBg,
        borderRadius: BorderRadius.circular(TripDetailTokens.cardRadius.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${trip.fromCity} → ${trip.toCity}',
            style: TextStyle(
              fontFamily: FontRes.MANROPE_BOLD,
              fontSize: 16.sp,
              color: TripDetailTokens.bodyDark,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            trip.estimatedPrice.inr,
            style: TextStyle(
              fontFamily: FontRes.MANROPE_EXTRABOLD,
              fontSize: 20.sp,
              color: TripDetailTokens.primaryOrange,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShipmentOptionTile extends StatelessWidget {
  const _ShipmentOptionTile({
    required this.shipment,
    required this.selected,
    required this.shipmentIdLabel,
    required this.onTap,
  });

  final Shipment shipment;
  final bool selected;
  final String shipmentIdLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: selected
              ? TripDetailTokens.primaryOrange
              : TripDetailTokens.footerBorder,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? TripDetailTokens.primaryOrange : Colors.white,
                  border: Border.all(
                    color: selected
                        ? TripDetailTokens.primaryOrange
                        : TripDetailTokens.routeLabel,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: selected
                    ? Icon(Icons.check, size: 12.w, color: Colors.white)
                    : null,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$shipmentIdLabel ${shipment.id}',
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_SEMIBOLD,
                        fontSize: 14.sp,
                        color: TripDetailTokens.bodyDark,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${shipment.pickup.displayLabel} → ${shipment.drop.displayLabel}',
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_REGULAR,
                        fontSize: 13.sp,
                        color: TripDetailTokens.subtitleGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
