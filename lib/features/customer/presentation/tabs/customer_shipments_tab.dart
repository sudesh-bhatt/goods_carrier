import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/domain/entities/shipment.dart';
import '../../../../shared/domain/enums/shipment_status.dart';
import '../providers/customer_shipments_provider.dart';
import '../widgets/customer_shipments_empty_view.dart';
import '../widgets/my_shipment/my_shipment_card.dart';

/// My Shipment tab body — Figma `1:2327`.
class CustomerShipmentsTab extends ConsumerStatefulWidget {
  const CustomerShipmentsTab({super.key});

  @override
  ConsumerState<CustomerShipmentsTab> createState() =>
      _CustomerShipmentsTabState();
}

class _CustomerShipmentsTabState extends ConsumerState<CustomerShipmentsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customerShipmentsProvider.notifier).loadForTab();
    });
  }

  bool _canEditDelete(Shipment shipment) =>
      shipment.status == ShipmentStatus.pending ||
      shipment.status == ShipmentStatus.interestReceived;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.colors;
    final l10n = context.l10n;
    final state = ref.watch(customerShipmentsProvider);
    final shipments = List<Shipment>.from(
      state.shipments.where((s) => !s.isCancelled),
    )..sort((a, b) => b.pickupDateTime.compareTo(a.pickupDateTime));

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (shipments.isEmpty) {
      return CustomerShipmentsEmptyView(
        title: l10n.customerEmptyShipmentsTitle,
        description: l10n.customerEmptyShipmentsDescription,
        actionLabel: l10n.shipmentPostNew,
        onAction: () => context.push(AppRoutes.postShipment),
      );
    }

    return RefreshIndicator(
      color: colors.primary,
      onRefresh: () =>
          ref.read(customerShipmentsProvider.notifier).refresh(),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
        itemCount: shipments.length,
        itemBuilder: (context, index) {
          final shipment = shipments[index];
          final interestCount = shipment.resolvedInterestCount;
          final showInterest = shipment.status ==
                  ShipmentStatus.interestReceived ||
              interestCount > 0;
          final editable = _canEditDelete(shipment);

          return Padding(
            padding: EdgeInsets.only(bottom: 24.h),
            child: MyShipmentListCard(
              shipment: shipment,
              shipmentIdLabel: l10n.shipmentId,
              estimatedPayLabel: l10n.shipmentEstimatedPay,
              fromLabel: l10n.tripFrom.toUpperCase(),
              toLabel: l10n.tripTo.toUpperCase(),
              primaryActionLabel: showInterest
                  ? l10n.shipmentViewInterest(interestCount)
                  : l10n.actionViewDetails,
              onPrimaryAction: () =>
                  context.push(AppRoutes.shipmentDetailOf(shipment.id)),
              showEditDelete: editable,
              onEdit: editable
                  ? () => context.push(AppRoutes.editShipmentOf(shipment.id))
                  : null,
              onDelete: editable
                  ? () => context.push(
                        AppRoutes.cancelShipmentOf(shipment.id),
                      )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
