import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/domain/entities/shipment.dart';
import '../../../../shared/domain/models/shipment_filter.dart';
import '../../../../shared/presentation/widgets/filters/filter_search_sheet.dart';
import '../../../../shared/presentation/widgets/feedback/empty_state.dart';
import '../../../../shared/presentation/widgets/feedback/skeleton_card.dart';
import '../providers/customer_shipments_provider.dart';
import '../widgets/customer_home_search_section.dart';
import '../widgets/customer_home_trip_card.dart';
import '../widgets/customer_shipments_empty_view.dart';

/// Home tab body — driver trips feed (no shell chrome).
class CustomerHomeTab extends ConsumerStatefulWidget {
  const CustomerHomeTab({super.key});

  @override
  ConsumerState<CustomerHomeTab> createState() => _CustomerHomeTabState();
}

class _CustomerHomeTabState extends ConsumerState<CustomerHomeTab>
    with AutomaticKeepAliveClientMixin, SafeSetStateMixin {
  final _searchCtrl = TextEditingController();
  ShipmentFilter _shipmentFilter = const ShipmentFilter();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Shipment> _filterShipments(List<Shipment> source) {
    final query = _searchCtrl.text.trim().toLowerCase();
    return source.where((s) {
      if (!_shipmentFilter.matches(s)) return false;
      if (query.isEmpty) return true;
      final haystack = [
        s.id,
        s.pickup.city,
        s.drop.city,
        s.vehicleType.label,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.colors;
    final l10n = context.l10n;
    final state = ref.watch(customerShipmentsProvider);
    final activeList = _filterShipments(state.active);

    if (state.isLoading && state.active.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.active.isEmpty) {
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
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(25.w, 20.h, 25.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomerHomeSearchRow(
                    controller: _searchCtrl,
                    hint: l10n.customerHomeSearchHint,
                    onChanged: (_) => safeSetState(() {}),
                    onFilterTap: () async {
                      final result = await FilterSearchSheet.show(
                        context,
                        initial: _shipmentFilter,
                      );
                      if (result != null) {
                        safeSetState(() => _shipmentFilter = result);
                      }
                    },
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    l10n.customerHomeDriverTrips,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_EXTRABOLD,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  CustomerHomeVehicleChips(
                    selected: _shipmentFilter.vehicleClass,
                    onSelected: (type) => safeSetState(() {
                      _shipmentFilter = _shipmentFilter.vehicleClass == type
                          ? _shipmentFilter.copyWith(clearVehicleClass: true)
                          : _shipmentFilter.copyWith(vehicleClass: type);
                    }),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
          if (state.isLoading)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, __) => Padding(
                  padding: EdgeInsets.fromLTRB(
                    25.w,
                    0,
                    25.w,
                    AppDimensions.sm.h,
                  ),
                  child: const SkeletonCard(),
                ),
                childCount: 3,
              ),
            )
          else if (activeList.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w),
                child: EmptyState(
                  headline: l10n.emptyHistory,
                  subtitle: l10n.customerHomeSearchHint,
                  fallbackIcon: Icons.search_off_rounded,
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(25.w, 0, 25.w, 24.h),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final shipment = activeList[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: AppDimensions.base.h,
                      ),
                      child: CustomerHomeTripCard(
                        shipment: shipment,
                        onTap: () => context.push(
                          AppRoutes.shipmentDetailOf(shipment.id),
                        ),
                        onViewDetails: () => context.push(
                          AppRoutes.shipmentDetailOf(shipment.id),
                        ),
                      ),
                    );
                  },
                  childCount: activeList.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
