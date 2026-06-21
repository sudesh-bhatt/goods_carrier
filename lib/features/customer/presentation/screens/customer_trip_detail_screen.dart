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
import '../../../../shared/domain/entities/driver_trip.dart';
import '../../../../shared/domain/entities/driver_trip_display.dart';
import '../../../../shared/domain/models/driver_shipment_detail.dart';
import '../../../../shared/domain/entities/shipment.dart';
import '../../../../shared/presentation/widgets/feedback/error_view.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../../../driver/presentation/providers/driver_shipment_requests_provider.dart';
import '../models/report_trip_screen_args.dart';
import '../providers/customer_dashboard_provider.dart';
import '../providers/customer_shipments_provider.dart';
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
  DriverShipmentDetail? _driverDetail;
  bool _isLoadingDetail = false;
  String? _loadError;

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

    final cachedDriverTrip = _resolveCachedDriverTrip();
    if (cachedDriverTrip != null) {
      safeSetState(() {
        _isLoadingDetail = false;
        _loadError = null;
      });
      return;
    }

    final cached = _resolveCachedShipment();
    if (cached != null) {
      safeSetState(() => _detail = cached);
    }

    if (!EnvConfig.useRemoteApi) return;

    safeSetState(() {
      _isLoadingDetail = cached == null;
      _loadError = null;
    });

    try {
      final apiId = cached?.apiResourceId ?? widget.shipmentId;
      final fetched =
          await ref.read(shipmentRepositoryProvider).getShipment(apiId);
      if (!mounted) return;
      safeSetState(() {
        _detail = fetched;
        _isLoadingDetail = false;
      });
      ref.read(customerShipmentsProvider.notifier).upsertShipment(fetched);
    } catch (e) {
      if (!mounted) return;
      safeSetState(() {
        _isLoadingDetail = false;
        _loadError = cached == null ? ApiExceptionMapper.userMessage(e) : null;
      });
    }
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
    final driverTrip = _resolveDriverTrip();
    if (!widget.isDriver && driverTrip != null) {
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
              extra: ReportTripScreenArgs(shipment: shipment),
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

  DriverTrip? _resolveCachedDriverTrip() {
    if (widget.isDriver) return null;
    return ref.read(customerDashboardProvider.notifier).byId(widget.shipmentId);
  }

  DriverTrip? _resolveDriverTrip() {
    if (widget.isDriver) return null;
    return ref
        .watch(customerDashboardProvider)
        .trips
        .where((t) => t.id == widget.shipmentId)
        .firstOrNull;
  }

  Widget _buildDriverTripDetail(
    BuildContext context,
    DriverTrip trip,
    dynamic l10n,
  ) {
    final vehicleNumber =
        trip.vehicleNumber.isNotEmpty ? trip.vehicleNumber : '—';

    return CustomerLightChrome(
      child: Scaffold(
        backgroundColor: TripDetailTokens.screenBg,
        appBar: FlowScreenAppBar(
          title: _screenTitle(l10n),
          fallbackRoute: _fallbackRoute,
          backgroundColor: Colors.white.withValues(alpha: 0.8),
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
        bottomNavigationBar: TripDetailRequestFooter(
          label: l10n.actionRequest,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.customerHomeFilterSoon)),
            );
          },
        ),
      ),
    );
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
    final vehicleNumber = _vehicleNumberFor(shipment);

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
      if (showDriverCard) ...[
        SizedBox(height: 24.h),
        TripDetailDriverCard.fromDummy(
          subtitle: l10n.customerExpertDriver,
          onTap: () => _openDriverFlow(context, shipment),
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

  static String _vehicleNumberFor(Shipment shipment) {
    if (shipment.assignedDriverId != null ||
        shipment.interestedDriverIds.isNotEmpty) {
      return 'MH 01 AB 1234';
    }
    return '—';
  }

  void _onCustomerRequestTap(BuildContext context, Shipment shipment) {
    if (shipment.interestedDriverIds.isNotEmpty) {
      _openDriverFlow(context, shipment);
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

  Future<void> _openDriverFlow(BuildContext context, Shipment shipment) async {
    final driverId = shipment.assignedDriverId ??
        shipment.interestedDriverIds.first;
    await DriverDetailSheet.show(
      context,
      driverId: driverId,
      shipmentId: shipment.id,
    );
  }
}
