import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/extensions/num_ext.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/vehicle_number_utils.dart';
import '../../../../shared/domain/entities/driver_trip.dart';
import '../../../../shared/domain/entities/driver_trip_display.dart';
import '../../../../shared/domain/models/customer_shipment_detail.dart';
import '../../../../shared/domain/models/driver_shipment_detail.dart';
import '../../../../shared/domain/entities/shipment.dart';
import '../../../../shared/presentation/widgets/feedback/error_view.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../../../driver/presentation/providers/driver_shipment_requests_provider.dart';
import '../../../driver/presentation/widgets/confirm_request_bottom_sheet.dart';
import '../models/customer_trip_request_success_args.dart';
import '../models/report_trip_screen_args.dart';
import '../providers/customer_dashboard_provider.dart';
import '../providers/customer_shipments_provider.dart';
import '../providers/customer_trip_actions_provider.dart';
import '../widgets/customer_light_chrome.dart';
import '../widgets/driver_detail_sheet.dart';
import '../widgets/trip_detail/trip_detail_driver_sections.dart';
import '../widgets/trip_detail/trip_detail_more_menu.dart';
import '../widgets/trip_detail/trip_detail_sections.dart';
import '../widgets/trip_detail/trip_detail_tokens.dart';

/// Shared shipment trip details — customer Figma `1:2117`, driver Figma `1:916`.
class CustomerTripDetailScreen extends ConsumerStatefulWidget {
  const CustomerTripDetailScreen({
    super.key,
    required this.shipmentId,
    this.audience = TripDetailAudience.customer,
  });

  final String shipmentId;
  final TripDetailAudience audience;

  bool get isDriver => audience == TripDetailAudience.driver;

  @override
  ConsumerState<CustomerTripDetailScreen> createState() =>
      _CustomerTripDetailScreenState();
}

class _CustomerTripDetailScreenState
    extends ConsumerState<CustomerTripDetailScreen> with SafeSetStateMixin {
  Shipment? _detail;
  CustomerShipmentDetail? _customerShipmentDetail;
  DriverShipmentDetail? _driverDetail;
  bool _isLoadingDetail = false;
  String? _loadError;
  bool _isSubmittingRequest = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetail());
  }

  Future<void> _loadDetail() async {
    if (widget.isDriver) {
      await _loadDriverDetail();
      return;
    }

    // Customer driver trips — dashboard list only (no driver API access).
    safeSetState(() {
      _isLoadingDetail = false;
      _loadError = null;
    });
  }

  Future<void> _retryCustomerDriverTrip() async {
    safeSetState(() {
      _isLoadingDetail = true;
      _loadError = null;
    });
    await ref.read(customerDashboardProvider.notifier).refresh();
    if (!mounted) return;
    safeSetState(() => _isLoadingDetail = false);
  }

  Future<void> _loadDriverDetail() async {
    final cached = _resolveCachedShipment();
    if (cached != null) {
      safeSetState(() {
        _driverDetail = DriverShipmentDetail(shipment: cached);
      });
    }

    safeSetState(() {
      _isLoadingDetail = cached == null || EnvConfig.useRemoteApi;
      _loadError = null;
    });

    if (!EnvConfig.useRemoteApi) {
      safeSetState(() => _isLoadingDetail = false);
      return;
    }

    try {
      final apiId = ref
          .read(driverShipmentRequestsProvider.notifier)
          .apiResourceIdFor(widget.shipmentId);
      final fetched = await ref
          .read(shipmentRepositoryProvider)
          .getDriverShipmentDetail(apiId);
      if (!mounted) return;
      safeSetState(() {
        _driverDetail = fetched;
        _isLoadingDetail = false;
      });
      ref
          .read(driverShipmentRequestsProvider.notifier)
          .upsertShipment(fetched.shipment);
      if (fetched.alreadyRequested) {
        ref
            .read(driverShipmentRequestsProvider.notifier)
            .markExpressed(fetched.shipment.id);
      }
    } catch (e) {
      if (!mounted) return;
      safeSetState(() {
        _isLoadingDetail = false;
        _loadError = _driverDetail == null
            ? ApiExceptionMapper.userMessage(e)
            : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (!widget.isDriver) {
      final driverTrip = _resolveDriverTrip();
      final dashboardState = ref.watch(customerDashboardProvider);
      if (_isLoadingDetail || dashboardState.isLoading) {
        return Scaffold(
          backgroundColor: TripDetailTokens.screenBg,
          appBar: FlowScreenAppBar(
            title: _screenTitle(l10n),
            fallbackRoute: _fallbackRoute,
          ),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      if (driverTrip == null) {
        return Scaffold(
          backgroundColor: TripDetailTokens.screenBg,
          appBar: FlowScreenAppBar(
            title: _screenTitle(l10n),
            fallbackRoute: _fallbackRoute,
          ),
          body: ErrorView(
            message: dashboardState.error ?? _loadError ?? 'Trip not found.',
            onRetry: _retryCustomerDriverTrip,
          ),
        );
      }
      return _buildDriverTripDetail(context, driverTrip, l10n);
    }

    final shipment = _resolveShipment();

    if (_isLoadingDetail && shipment == null) {
      return Scaffold(
        backgroundColor: TripDetailTokens.screenBg,
        appBar: FlowScreenAppBar(
          title: _screenTitle(l10n),
          fallbackRoute: _fallbackRoute,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (shipment == null) {
      return Scaffold(
        backgroundColor: TripDetailTokens.screenBg,
        appBar: FlowScreenAppBar(
          title: _screenTitle(l10n),
          fallbackRoute: _fallbackRoute,
        ),
        body: ErrorView(message: _loadError ?? 'Shipment not found.'),
      );
    }

    return CustomerLightChrome(
      child: Scaffold(
        backgroundColor: TripDetailTokens.screenBg,
        appBar: FlowScreenAppBar(
          title: _screenTitle(l10n),
          fallbackRoute: _fallbackRoute,
          backgroundColor: Colors.white.withValues(alpha: 0.8),
          trailing: TripDetailMoreMenuButton(
            reportLabel: widget.isDriver
                ? l10n.driverReportShipmentQuestion
                : l10n.customerReportTripQuestion,
            onReport: () => context.push(
              AppRoutes.reportTripOf(shipment.id),
              extra: ReportTripScreenArgs(
                shipment: shipment,
                isDriver: widget.isDriver,
              ),
            ),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 120.h),
          children: widget.isDriver
              ? _driverBody(context, shipment, l10n)
              : _customerBody(context, shipment, l10n),
        ),
        bottomNavigationBar: widget.isDriver
            ? _driverFooter(context, shipment, l10n)
            : TripDetailRequestFooter(
                label: l10n.actionRequest,
                onPressed: () => _onCustomerRequestTap(context, shipment),
              ),
      ),
    );
  }

  String get _fallbackRoute =>
      widget.isDriver ? AppRoutes.driverHome : AppRoutes.customerHome;

  String _screenTitle(dynamic l10n) => widget.isDriver
      ? l10n.driverShipmentDetailsTitle
      : l10n.customerTripDetailsTitle;

  Shipment? _resolveCachedShipment() {
    if (widget.isDriver) {
      final driverState = ref.read(driverShipmentRequestsProvider);
      return driverState.all
          .where((s) => s.id == widget.shipmentId)
          .firstOrNull;
    }
    return ref.read(customerShipmentsProvider.notifier).byId(widget.shipmentId);
  }

  DriverTrip? _resolveDriverTrip() {
    if (widget.isDriver) return null;
    return ref
        .watch(customerDashboardProvider)
        .trips
        .where((t) => t.id == widget.shipmentId || t.apiId == widget.shipmentId)
        .firstOrNull;
  }

  Widget _buildDriverTripDetail(
    BuildContext context,
    DriverTrip trip,
    dynamic l10n,
  ) {
    final vehicleNumber = trip.vehicleNumber.trim().isEmpty
        ? '—'
        : VehicleNumberUtils.format(trip.vehicleNumber);

    return CustomerLightChrome(
      child: Scaffold(
        backgroundColor: TripDetailTokens.screenBg,
        appBar: FlowScreenAppBar(
          title: _screenTitle(l10n),
          fallbackRoute: _fallbackRoute,
          backgroundColor: Colors.white.withValues(alpha: 0.8),
          trailing: TripDetailMoreMenuButton(
            reportLabel: l10n.customerReportTripQuestion,
            onReport: () => context.push(
              AppRoutes.reportTripOf(trip.apiResourceId),
              extra: ReportTripScreenArgs(driverTrip: trip),
            ),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 120.h),
          children: [
            TripDetailRouteSection(
              fromCity: trip.fromDisplayLabel,
              toCity: trip.toDisplayLabel,
              fromLabel: l10n.tripFrom.toUpperCase(),
              toLabel: l10n.tripTo.toUpperCase(),
            ),
            SizedBox(height: 24.h),
            TripDetailScheduleSection(
              startDateTime: trip.estimatedStartDate,
              endDateTime: trip.estimatedEndDate,
              vehicleLabel: trip.vehicleCategory.label,
              vehicleNumber: vehicleNumber,
              capacityLabel: trip.loadCapacityLabel,
              startDateLabel: l10n.customerTripEstimatedStartDate,
              endDateLabel: l10n.customerTripEstimatedEndDate,
              vehicleTypeLabel: l10n.tripVehicle,
              vehicleNumberLabel: l10n.profileVehicleNumber,
              capacityTitle: l10n.tripCapacity,
            ),
            if (trip.driverName.isNotEmpty) ...[
              SizedBox(height: 24.h),
              TripDetailDriverCard.fromDummy(
                subtitle: trip.driverName,
                onTap: trip.driverId.isEmpty
                    ? () {}
                    : () => DriverDetailSheet.show(
                          context,
                          driverId: trip.driverId,
                          shipmentId: trip.id,
                        ),
              ),
            ],
            SizedBox(height: 24.h),
            TripDetailPriceSection(
              label: l10n.customerTripEstimatedPrice,
              priceText: trip.estimatedPrice.inr,
            ),
          ],
        ),
        bottomNavigationBar: Opacity(
          opacity: trip.isInterested ? 0.5 : 1,
          child: TripDetailRequestFooter(
            label: trip.isInterested
                ? l10n.driverRequestSent
                : l10n.actionRequest,
            isLoading: _isSubmittingRequest,
            onPressed: trip.isInterested || _isSubmittingRequest
                ? () {}
                : () => _onRequestPressed(trip),
          ),
        ),
      ),
    );
  }

  Future<void> _onRequestPressed(DriverTrip trip) async {
    final l10n = context.l10n;
    final confirmed = await ConfirmRequestBottomSheet.show(
      context,
      title: l10n.driverConfirmRequestTitle,
      body: l10n.customerConfirmRequestBody,
      secondaryLabel: l10n.actionNo,
      primaryLabel: l10n.driverConfirmYesContinue,
    );
    if (!confirmed || !mounted) return;

    safeSetState(() => _isSubmittingRequest = true);
    try {
      await ref.read(customerTripActionsProvider.notifier).submitRequest(
            trip: trip,
          );
      if (!mounted) return;
      context.push(
        AppRoutes.customerTripRequestSuccess,
        extra: CustomerTripRequestSuccessArgs(
          fromCity: trip.fromDisplayLabel,
          toCity: trip.toDisplayLabel,
          pickupDateTime: trip.estimatedStartDate,
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
      if (mounted) safeSetState(() => _isSubmittingRequest = false);
    }
  }

  Shipment? _resolveShipment() {
    if (widget.isDriver) {
      return _driverDetail?.shipment ?? _resolveCachedShipment();
    }
    return _detail ?? _resolveCachedShipment();
  }

  DriverShipmentDetail? get _activeDriverDetail =>
      _driverDetail ??
      (_resolveCachedShipment() != null
          ? DriverShipmentDetail(shipment: _resolveCachedShipment()!)
          : null);

  List<Widget> _customerBody(
    BuildContext context,
    Shipment shipment,
    dynamic l10n,
  ) {
    final showDriverCard = shipment.assignedDriverId != null ||
        shipment.resolvedInterestCount > 0;
    final driver = _resolveInterestedDriver(shipment);
    final vehicleNumber = driver?.vehicleNumber.isNotEmpty == true
        ? driver!.vehicleNumber
        : _vehicleNumberFor(shipment);

    return [
      TripDetailRouteSection(
        fromCity: shipment.pickup.displayLabel,
        toCity: shipment.drop.displayLabel,
        fromLabel: l10n.tripFrom.toUpperCase(),
        toLabel: l10n.tripTo.toUpperCase(),
      ),
      SizedBox(height: 24.h),
      TripDetailScheduleSection(
        startDateTime: shipment.pickupDateTime,
        endDateTime: shipment.dropDateTime,
        vehicleLabel: shipment.vehicleType.label,
        vehicleNumber: vehicleNumber,
        capacityLabel: shipment.loadCapacityLabel,
        startDateLabel: l10n.customerTripEstimatedStartDate,
        endDateLabel: l10n.customerTripEstimatedEndDate,
        vehicleTypeLabel: l10n.tripVehicle,
        vehicleNumberLabel: l10n.profileVehicleNumber,
        capacityTitle: l10n.tripCapacity,
      ),
      if (showDriverCard && driver != null) ...[
        SizedBox(height: 24.h),
        TripDetailDriverCard(
          name: driver.name,
          subtitle: driver.subtitle ?? l10n.customerExpertDriver,
          onTap: () => _openDriverFlow(context, shipment, driver),
        ),
      ] else if (showDriverCard) ...[
        SizedBox(height: 24.h),
        TripDetailDriverCard(
          name: l10n.customerExpertDriver,
          subtitle: shipment.status.label,
          onTap: () => _openDriverFlow(context, shipment, null),
        ),
      ],
      SizedBox(height: 24.h),
      TripDetailPriceSection(
        label: l10n.customerTripEstimatedPrice,
        priceText: shipment.estimatedPrice.inr,
      ),
    ];
  }

  List<Widget> _driverBody(
    BuildContext context,
    Shipment shipment,
    dynamic l10n,
  ) {
    final detail = _activeDriverDetail;
    final capacitySecondary = detail?.vehicleCapacityLabel != null
        ? 'Cap: ${detail!.vehicleCapacityLabel}'
        : null;

    return [
      TripDetailDriverSummaryCard(
        shipment: shipment,
        shipmentIdLabel: l10n.driverHomeShipmentId,
        estimatedPayLabel: l10n.shipmentEstimatedPay,
        fromLabel: l10n.tripFrom.toUpperCase(),
        toLabel: l10n.tripTo.toUpperCase(),
        capacitySecondary: capacitySecondary,
      ),
      SizedBox(height: 24.h),
      TripDetailGoodsSection(
        shipment: shipment,
        sectionTitle: l10n.driverGoodsDetails,
        typeLabel: l10n.driverGoodsType,
        weightLabel: l10n.driverGoodsWeight,
        fragileLabel: l10n.driverFragileHandlingRequired,
      ),
      SizedBox(height: 24.h),
      TripDetailDriverLocationSection(
        shipment: shipment,
        pickupLabel: l10n.driverPickupLocation,
        dropLabel: l10n.driverDropLocation,
        pickupScheduleLabel: detail?.pickupScheduleLabel,
      ),
      SizedBox(height: 24.h),
      TripDetailVehicleMatchSection(
        shipment: shipment,
        sectionLabel: l10n.driverVehicleRequirement,
        matchLabel: l10n.driverMatchesYourVehicle,
        showMatchBadge: detail?.matchesDriverVehicle ?? true,
        capacityLabel: detail?.vehicleCapacityLabel,
      ),
    ];
  }

  Widget _driverFooter(
    BuildContext context,
    Shipment shipment,
    dynamic l10n,
  ) {
    final requestsState = ref.watch(driverShipmentRequestsProvider);
    final alreadyExpressed = _activeDriverDetail?.alreadyRequested == true ||
        requestsState.hasExpressed(shipment.id);

    return Opacity(
      opacity: alreadyExpressed ? 0.5 : 1,
      child: TripDetailRequestFooter(
        label: alreadyExpressed ? l10n.driverRequestSent : l10n.driverAddRequest,
        onPressed: alreadyExpressed
            ? () {}
            : () => _onAddRequestTap(context, shipment),
      ),
    );
  }

  ShipmentInterestedDriver? _resolveInterestedDriver(Shipment shipment) {
    final drivers = _customerShipmentDetail?.interestedDrivers ?? const [];
    if (drivers.isEmpty) return null;
    if (shipment.assignedDriverId != null) {
      return drivers
          .where((d) => d.driverId == shipment.assignedDriverId)
          .firstOrNull ??
          drivers.first;
    }
    return drivers.first;
  }

  static String _vehicleNumberFor(Shipment shipment) {
    if (shipment.assignedDriverId != null ||
        shipment.interestedDriverIds.isNotEmpty) {
      return '—';
    }
    return '—';
  }

  void _onCustomerRequestTap(BuildContext context, Shipment shipment) {
    if (shipment.interestedDriverIds.isNotEmpty) {
      _openDriverFlow(context, shipment, _resolveInterestedDriver(shipment));
      return;
    }
    if (shipment.isPending) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.shipmentNoDriversYet)),
      );
      return;
    }
    if (shipment.assignedDriverId != null) {
      context.push(AppRoutes.trackingOf(shipment.id));
    }
  }

  Future<void> _onAddRequestTap(
    BuildContext context,
    Shipment shipment,
  ) async {
    context.push(AppRoutes.driverAddShipmentRequestOf(shipment.id));
  }

  Future<void> _openDriverFlow(
    BuildContext context,
    Shipment shipment,
    ShipmentInterestedDriver? driver,
  ) async {
    final driverId = shipment.assignedDriverId ??
        driver?.driverId ??
        shipment.interestedDriverIds.firstOrNull;
    if (driverId == null) return;

    await DriverDetailSheet.show(
      context,
      driverId: driverId,
      shipmentId: shipment.id,
      driver: driver,
    );
  }
}
