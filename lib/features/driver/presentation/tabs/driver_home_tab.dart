import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/providers/vehicle_masters_provider.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/domain/entities/shipment.dart';
import '../../../../shared/domain/entities/shipment_masters.dart';
import '../../../../shared/domain/models/shipment_filter.dart';
import '../../../../shared/presentation/widgets/feedback/skeleton_card.dart';
import '../../../../shared/presentation/widgets/feedback/trip_empty_placeholder_view.dart';
import '../../../../shared/presentation/widgets/filters/filter_search_sheet.dart';
import '../../../customer/presentation/widgets/customer_home_search_section.dart';
import '../providers/driver_shipment_requests_provider.dart';
import '../widgets/driver_home_shipment_card.dart';
import '../widgets/driver_trips_empty_view.dart';

/// Driver home tab — customer shipment feed (Figma `1:408`, no vehicle chips).
class DriverHomeTab extends ConsumerStatefulWidget {
  const DriverHomeTab({super.key});

  @override
  ConsumerState<DriverHomeTab> createState() => _DriverHomeTabState();
}

class _DriverHomeTabState extends ConsumerState<DriverHomeTab>
    with AutomaticKeepAliveClientMixin, SafeSetStateMixin {
  final _searchCtrl = TextEditingController();
  ShipmentFilter _shipmentFilter = const ShipmentFilter();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Warm masters cache for filter pills (falls back locally on failure).
      ref.read(vehicleMastersProvider);
      ref.read(driverShipmentRequestsProvider.notifier).loadForTab();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _resetFilters() {
    safeSetState(() {
      _shipmentFilter = const ShipmentFilter();
      _searchCtrl.clear();
    });
    if (EnvConfig.useRemoteApi) {
      ref.read(driverShipmentRequestsProvider.notifier).applyFilters(
            search: '',
            filter: const ShipmentFilter(),
          );
    }
  }

  bool get _hasLocalFilters =>
      _searchCtrl.text.trim().isNotEmpty || _shipmentFilter.hasActiveFilters;

  Future<void> _reloadDashboard() async {
    await ref.read(driverShipmentRequestsProvider.notifier).applyFilters(
          search: _searchCtrl.text,
          filter: _shipmentFilter,
        );
  }

  List<Shipment> _filterShipmentsLocally(List<Shipment> source) {
    final query = _searchCtrl.text.trim().toLowerCase();
    return source.where((s) {
      if (!_shipmentFilter.matches(s)) return false;
      if (query.isEmpty) return true;
      final haystack = [
        s.id,
        s.pickup.city,
        s.drop.city,
        s.pickup.fullAddress,
        s.drop.fullAddress,
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
    final state = ref.watch(driverShipmentRequestsProvider);
    final shipments = EnvConfig.useRemoteApi
        ? state.all
        : _filterShipmentsLocally(state.all);

    if (state.isLoading && state.all.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      color: colors.primary,
      onRefresh: () =>
          ref.read(driverShipmentRequestsProvider.notifier).refresh(),
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
                    onChanged: (_) {
                      safeSetState(() {});
                      if (EnvConfig.useRemoteApi) _reloadDashboard();
                    },
                    onFilterTap: () async {
                      final masters =
                          ref.read(vehicleMastersProvider).valueOrNull;
                      final result = await FilterSearchSheet.show(
                        context,
                        initial: _shipmentFilter,
                        vehicleTypes: masters?.asMasterOptions ??
                            const <ShipmentMasterOption>[],
                      );
                      if (result != null) {
                        safeSetState(() => _shipmentFilter = result);
                        if (EnvConfig.useRemoteApi) await _reloadDashboard();
                      }
                    },
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        l10n.customerHomeActiveShipments(shipments.length)
                            .toUpperCase(),
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_BOLD,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          height: 16 / 12,
                          color: colors.brownText,
                        ),
                      ),
                    ],
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
                  padding: EdgeInsets.fromLTRB(25.w, 0, 25.w, AppDimensions.sm.h),
                  child: const SkeletonCard(),
                ),
                childCount: 3,
              ),
            )
          else if (shipments.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(25.w, 0, 25.w, 120.h),
                child: _hasLocalFilters
                    ? TripEmptyPlaceholderView(
                        title: l10n.customerHomeNoMatchingShipments,
                        description: l10n.customerHomeNoMatchingShipmentsHint,
                        actionLabel: l10n.filterClearAll,
                        onAction: _resetFilters,
                        showActionIcon: false,
                        scrollable: false,
                      )
                    : DriverTripsEmptyView(
                        onPostTrip: () => context.push(AppRoutes.postTrip),
                        scrollable: false,
                        showActionIcon: true,
                      ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(25.w, 0, 25.w, 24.h),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final shipment = shipments[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 24.h),
                      child: DriverHomeShipmentCard(
                        shipment: shipment,
                        onViewDetails: () => context.push(
                          AppRoutes.driverShipmentDetailOf(shipment.id),
                        ),
                      ),
                    );
                  },
                  childCount: shipments.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
