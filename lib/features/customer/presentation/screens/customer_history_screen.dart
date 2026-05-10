import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/domain/entities/shipment.dart';
import '../../../../shared/presentation/widgets/cards/shipment_card.dart';
import '../../../../shared/presentation/widgets/feedback/empty_state.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../providers/customer_shipments_provider.dart';

/// Shipment history screen — tabs for Completed and Cancelled.
///
/// Data driven by [customerShipmentsProvider] filtered lists.
class CustomerHistoryScreen extends ConsumerStatefulWidget {
  const CustomerHistoryScreen({super.key});

  @override
  ConsumerState<CustomerHistoryScreen> createState() =>
      _CustomerHistoryScreenState();
}

class _CustomerHistoryScreenState
    extends ConsumerState<CustomerHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors    = context.colors;
    final state     = ref.watch(customerShipmentsProvider);
    final completed = state.completed;
    final cancelled = state.cancelled;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBarWidget(
        title: 'Shipment History',
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: colors.primary,
          unselectedLabelColor: colors.textHint,
          indicatorColor: colors.primary,
          labelStyle: context.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabCtrl,
          children: [
            _ShipmentList(
              shipments:    completed,
              emptyHeadline: context.l10n.emptyHistory,
              emptySubText:  'No completed shipments yet',
            ),
            _ShipmentList(
              shipments:    cancelled,
              emptyHeadline: context.l10n.emptyHistory,
              emptySubText:  'No cancelled shipments',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shipment list tab ────────────────────────────────────────────────────────

class _ShipmentList extends ConsumerWidget {
  const _ShipmentList({
    required this.shipments,
    required this.emptyHeadline,
    required this.emptySubText,
  });

  final List<Shipment> shipments;
  final String         emptyHeadline;
  final String         emptySubText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (shipments.isEmpty) {
      return EmptyState(
        headline: emptyHeadline,
        subtitle:  emptySubText,
        fallbackIcon:     Icons.history_rounded,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPadding.w,
        vertical:   AppDimensions.base.h,
      ),
      itemCount: shipments.length,
      itemBuilder: (context, index) {
        final shipment = shipments[index];
        return Padding(
          padding: EdgeInsets.only(bottom: AppDimensions.base.h),
          child: ShipmentCard(
            shipment: shipment,
            onTap: () =>
                context.push(AppRoutes.shipmentDetailOf(shipment.id)),
          ),
        );
      },
    );
  }
}
