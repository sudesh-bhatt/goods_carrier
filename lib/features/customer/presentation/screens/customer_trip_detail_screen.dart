import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/num_ext.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/domain/entities/shipment.dart';
import '../../../../shared/presentation/widgets/feedback/error_view.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../../../driver/presentation/models/driver_interest_success_args.dart';
import '../../../driver/presentation/providers/driver_shipment_requests_provider.dart';
import '../../../driver/presentation/widgets/confirm_request_bottom_sheet.dart';
import '../models/report_trip_screen_args.dart';
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
    extends ConsumerState<CustomerTripDetailScreen> {
  bool _isSubmittingInterest = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shipment = _resolveShipment();

    if (shipment == null) {
      return Scaffold(
        backgroundColor: TripDetailTokens.screenBg,
        appBar: FlowScreenAppBar(
          title: _screenTitle(l10n),
          fallbackRoute: _fallbackRoute,
        ),
        body: const ErrorView(message: 'Shipment not found.'),
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

  Shipment? _resolveShipment() {
    if (widget.isDriver) {
      final driverState = ref.watch(driverShipmentRequestsProvider);
      return driverState.all
          .where((s) => s.id == widget.shipmentId)
          .firstOrNull;
    }
    final customerState = ref.watch(customerShipmentsProvider);
    return customerState.shipments
        .where((s) => s.id == widget.shipmentId)
        .firstOrNull;
  }

  List<Widget> _customerBody(
    BuildContext context,
    Shipment shipment,
    dynamic l10n,
  ) {
    final showDriverCard = shipment.assignedDriverId != null ||
        shipment.interestedDriverIds.isNotEmpty;
    final vehicleNumber = _vehicleNumberFor(shipment);

    return [
      TripDetailRouteSection(
        fromCity: shipment.pickup.city,
        toCity: shipment.drop.city,
        fromLabel: l10n.tripFrom.toUpperCase(),
        toLabel: l10n.tripTo.toUpperCase(),
      ),
      SizedBox(height: 24.h),
      TripDetailScheduleSection(
        startDateTime: shipment.pickupDateTime,
        endDateTime: shipment.dropDateTime,
        vehicleLabel: shipment.vehicleType.label,
        vehicleNumber: vehicleNumber,
        capacityLabel: shipment.vehicleType.capacityDisplay,
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
    return [
      TripDetailDriverSummaryCard(
        shipment: shipment,
        shipmentIdLabel: l10n.driverHomeShipmentId,
        estimatedPayLabel: l10n.shipmentEstimatedPay,
        fromLabel: l10n.tripFrom.toUpperCase(),
        toLabel: l10n.tripTo.toUpperCase(),
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
      ),
      SizedBox(height: 24.h),
      TripDetailVehicleMatchSection(
        shipment: shipment,
        sectionLabel: l10n.driverVehicleRequirement,
        matchLabel: l10n.driverMatchesYourVehicle,
      ),
    ];
  }

  Widget _driverFooter(
    BuildContext context,
    Shipment shipment,
    dynamic l10n,
  ) {
    final requestsState = ref.watch(driverShipmentRequestsProvider);
    final alreadyExpressed = requestsState.hasExpressed(shipment.id);

    return Opacity(
      opacity: alreadyExpressed || _isSubmittingInterest ? 0.5 : 1,
      child: TripDetailRequestFooter(
        label: alreadyExpressed ? l10n.driverRequestSent : l10n.driverAddRequest,
        onPressed: alreadyExpressed || _isSubmittingInterest
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
    final confirmed = await ConfirmRequestBottomSheet.show(
      context,
      shipment: shipment,
    );
    if (!confirmed || !mounted) return;

    setState(() => _isSubmittingInterest = true);
    await ref
        .read(driverShipmentRequestsProvider.notifier)
        .expressInterest(shipment.id);
    if (!context.mounted) return;
    setState(() => _isSubmittingInterest = false);

    context.push(
      AppRoutes.driverInterestSuccess,
      extra: DriverInterestSuccessArgs(
        fromCity: shipment.pickup.city,
        toCity: shipment.drop.city,
        pickupDateTime: shipment.pickupDateTime,
        estimatedPrice: shipment.estimatedPrice,
      ),
    );
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
