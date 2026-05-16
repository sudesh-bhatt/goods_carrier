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
import '../../../../shared/presentation/widgets/navigation/customer_bottom_nav_bar.dart';
import '../providers/customer_shipments_provider.dart';
import '../widgets/customer_figma_shipment_card.dart';
import '../widgets/customer_light_chrome.dart';
import '../widgets/customer_navigation.dart';
import '../widgets/customer_subscreen_header.dart';

/// My Shipment list — [Figma `2013:2327`](https://www.figma.com/design/wT5NdNeg7YVPPcq1nY9D2P/Goods-Carrier--Copy-?node-id=2013-2327).
class CustomerHistoryScreen extends ConsumerWidget {
  const CustomerHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = context.l10n;
    final state = ref.watch(customerShipmentsProvider);
    final shipments = List<Shipment>.from(state.shipments)
      ..sort((a, b) => b.pickupDateTime.compareTo(a.pickupDateTime));

    return CustomerLightChrome(
      child: Scaffold(
      backgroundColor: colors.background,
      appBar: CustomerSubscreenHeader(
        title: l10n.customerMyShipment,
        showBack: true,
      ),
      body: SafeArea(
        top: false,
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : shipments.isEmpty
                ? EmptyState(
                    headline: l10n.emptyShipments,
                    subtitle: l10n.emptyShipmentsSubtitle,
                    fallbackIcon: Icons.local_shipping_outlined,
                    actionLabel: l10n.shipmentPostNew,
                    onAction: () => context.push(AppRoutes.postShipment),
                  )
                : RefreshIndicator(
                    color: colors.primary,
                    onRefresh: () =>
                        ref.read(customerShipmentsProvider.notifier).refresh(),
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        24.w,
                        16.h,
                        24.w,
                        100.h,
                      ),
                      itemCount: shipments.length,
                      itemBuilder: (context, index) {
                        final shipment = shipments[index];
                        final interestCount =
                            shipment.interestedDriverIds.length;
                        final showInterest = shipment.status ==
                                ShipmentStatus.interestReceived ||
                            interestCount > 0;

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: AppDimensions.base.h,
                          ),
                          child: CustomerFigmaShipmentCard(
                            shipment: shipment,
                            onTap: () => context.push(
                              AppRoutes.shipmentDetailOf(shipment.id),
                            ),
                            interestCount: interestCount,
                            primaryActionLabel: showInterest
                                ? l10n.shipmentViewInterest(interestCount)
                                : l10n.actionViewDetails,
                            onPrimaryAction: () => context.push(
                              AppRoutes.shipmentDetailOf(shipment.id),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.postShipment),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        child: Icon(Icons.add_rounded, size: 28.w),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: CustomerBottomNavBar(
        currentTab: CustomerMainTab.shipments,
        onTabSelected: (tab) => navigateCustomerTab(context, tab),
      ),
    ),
    );
  }
}
