import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/domain/enums/shipment_status.dart';
import '../../../../shared/presentation/widgets/feedback/error_view.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../providers/customer_shipments_provider.dart';
import '../widgets/customer_light_chrome.dart';
import '../widgets/driver_detail_sheet.dart';
import '../widgets/shipment_publish/shipment_publish_sections.dart';
import '../widgets/shipment_publish/shipment_publish_tokens.dart';

/// Shipment Details (Publish) — Figma `1:2540`.
///
/// Opened from **My Shipment** via [AppRoutes.shipmentDetailOf].
class ShipmentDetailScreen extends ConsumerWidget {
  const ShipmentDetailScreen({super.key, required this.shipmentId});

  final String shipmentId;

  static const _demoDriverNames = [
    'Vikram Singh',
    'Raja Pandit',
    'Raghav Gupta',
    'Chinmay Swami',
    'Pawan Shetty',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(customerShipmentsProvider);
    final shipment =
        state.shipments.where((s) => s.id == shipmentId).firstOrNull;

    if (shipment == null) {
      return Scaffold(
        backgroundColor: ShipmentPublishTokens.screenBg,
        appBar: FlowScreenAppBar(
          title: l10n.shipmentDetailsTitle,
          fallbackRoute: AppRoutes.customerHome,
        ),
        body: const ErrorView(message: 'Shipment not found.'),
      );
    }

    final displayId =
        shipment.id.startsWith('#') ? shipment.id : '#${shipment.id}';
    final (fromTitle, fromSub) = parseLocationLabel(shipment.pickup.city);
    final (toTitle, toSub) = parseLocationLabel(shipment.drop.city);
    final driverIds = shipment.interestedDriverIds.isNotEmpty
        ? shipment.interestedDriverIds
        : ['USR-0002'];

    return CustomerLightChrome(
      child: Scaffold(
        backgroundColor: ShipmentPublishTokens.screenBg,
        appBar: FlowScreenAppBar(
          title: l10n.shipmentDetailsTitle,
          fallbackRoute: AppRoutes.customerHome,
          backgroundColor: Colors.white.withValues(alpha: 0.8),
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
          children: [
            PublishRouteCard(
              tripIdLabel: l10n.tripId,
              displayId: displayId,
              publishLabel: l10n.customerShipmentPublishBadge,
              fromTitle: fromTitle,
              fromSubtitle: fromSub,
              toTitle: toTitle,
              toSubtitle: toSub.isNotEmpty ? toSub : shipment.drop.fullAddress,
            ),
            SizedBox(height: 32.h),
            ...List.generate(driverIds.length, (i) {
              final driverId = driverIds[i];
              final name = _demoDriverNames[i % _demoDriverNames.length];
              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: PublishDriverInterestCard(
                  driverName: name,
                  expertLabel: l10n.customerExpertDriver,
                  vehicleName: 'Tata Ace',
                  vehicleNumber: 'MH 01 AB 1234',
                  capacityLabel: l10n.tripCapacity,
                  capacityValue:
                      shipment.vehicleType.capacityDisplay.toUpperCase(),
                  onTap: () => DriverDetailSheet.show(
                    context,
                    driverId: driverId,
                    shipmentId: shipment.id,
                  ),
                  onCall: () => DriverDetailSheet.show(
                    context,
                    driverId: driverId,
                    shipmentId: shipment.id,
                  ),
                  onWhatsApp: () => DriverDetailSheet.show(
                    context,
                    driverId: driverId,
                    shipmentId: shipment.id,
                  ),
                ),
              );
            }),
            PublishPaymentSummaryCard(
              headerLabel: l10n.customerPaymentSummary,
              baseFareLabel: l10n.customerBaseFare,
              totalLabel: l10n.customerTotalAmount,
              amount: shipment.estimatedPrice,
            ),
            if (shipment.isPending ||
                shipment.status == ShipmentStatus.interestReceived) ...[
              SizedBox(height: 32.h),
              Center(
                child: TextButton(
                  onPressed: () =>
                      context.push(AppRoutes.cancelShipmentOf(shipment.id)),
                  child: Text(
                    l10n.customerCancelShipment,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_BOLD,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: ShipmentPublishTokens.priceBrown,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

}
