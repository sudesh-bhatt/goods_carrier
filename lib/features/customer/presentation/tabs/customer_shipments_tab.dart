import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/domain/entities/shipment.dart';
import '../../../../shared/domain/enums/shipment_status.dart';
import '../../../../shared/presentation/widgets/feedback/empty_state.dart';
import '../providers/customer_shipments_provider.dart';
import '../widgets/customer_figma_shipment_card.dart';

/// My Shipment tab body.
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
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.colors;
    final l10n = context.l10n;
    final state = ref.watch(customerShipmentsProvider);
    final shipments = List<Shipment>.from(state.shipments)
      ..sort((a, b) => b.pickupDateTime.compareTo(a.pickupDateTime));

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (shipments.isEmpty) {
      return EmptyState(
        headline: l10n.emptyShipments,
        subtitle: l10n.emptyShipmentsSubtitle,
        fallbackIcon: Icons.local_shipping_outlined,
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
          final interestCount = shipment.interestedDriverIds.length;
          final showInterest = shipment.status ==
                  ShipmentStatus.interestReceived ||
              interestCount > 0;

          return Padding(
            padding: EdgeInsets.only(bottom: AppDimensions.base.h),
            child: CustomerFigmaShipmentCard(
              shipment: shipment,
              onTap: () =>
                  context.push(AppRoutes.shipmentDetailOf(shipment.id)),
              interestCount: interestCount,
              primaryActionLabel: showInterest
                  ? l10n.shipmentViewInterest(interestCount)
                  : l10n.actionViewDetails,
              onPrimaryAction: () =>
                  context.push(AppRoutes.shipmentDetailOf(shipment.id)),
            ),
          );
        },
      ),
    );
  }
}
