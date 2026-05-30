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
import '../models/report_trip_screen_args.dart';
import '../providers/customer_shipments_provider.dart';
import '../widgets/customer_light_chrome.dart';
import '../widgets/driver_detail_sheet.dart';
import '../widgets/trip_detail/trip_detail_more_menu.dart';
import '../widgets/trip_detail/trip_detail_sections.dart';
import '../widgets/trip_detail/trip_detail_tokens.dart';

/// Trip details — Figma `1:2117`. Opened from **Home** via [AppRoutes.tripDetailOf].
class CustomerTripDetailScreen extends ConsumerStatefulWidget {
  const CustomerTripDetailScreen({super.key, required this.shipmentId});

  final String shipmentId;

  @override
  ConsumerState<CustomerTripDetailScreen> createState() =>
      _CustomerTripDetailScreenState();
}

class _CustomerTripDetailScreenState
    extends ConsumerState<CustomerTripDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(customerShipmentsProvider);
    final shipment =
        state.shipments.where((s) => s.id == widget.shipmentId).firstOrNull;

    if (shipment == null) {
      return Scaffold(
        backgroundColor: TripDetailTokens.screenBg,
        appBar: FlowScreenAppBar(
          title: l10n.customerTripDetailsTitle,
          fallbackRoute: AppRoutes.customerHome,
        ),
        body: const ErrorView(message: 'Shipment not found.'),
      );
    }

    final showDriverCard = shipment.assignedDriverId != null ||
        shipment.interestedDriverIds.isNotEmpty;
    final vehicleNumber = _vehicleNumberFor(shipment);

    return CustomerLightChrome(
      child: Scaffold(
        backgroundColor: TripDetailTokens.screenBg,
        appBar: FlowScreenAppBar(
          title: l10n.customerTripDetailsTitle,
          fallbackRoute: AppRoutes.customerHome,
          backgroundColor: Colors.white.withValues(alpha: 0.8),
          trailing: TripDetailMoreMenuButton(
            reportLabel: l10n.customerReportTripQuestion,
            onReport: () => context.push(
              AppRoutes.reportTripOf(shipment.id),
              extra: ReportTripScreenArgs(shipment: shipment),
            ),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 120.h),
          children: [
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
          ],
        ),
        bottomNavigationBar: TripDetailRequestFooter(
          label: l10n.actionRequest,
          onPressed: () => _onRequestTap(context, shipment),
        ),
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

  void _onRequestTap(BuildContext context, Shipment shipment) {
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
