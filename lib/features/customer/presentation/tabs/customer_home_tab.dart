import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/domain/entities/driver_trip.dart';
import '../../../../shared/domain/models/shipment_filter.dart';
import '../../../../shared/presentation/widgets/filters/filter_search_sheet.dart';
import '../../../../shared/presentation/widgets/feedback/home_feed_empty_state.dart';
import '../../../../shared/presentation/widgets/feedback/skeleton_card.dart';
import '../providers/customer_dashboard_provider.dart';
import '../widgets/customer_home_search_section.dart';
import '../widgets/customer_home_trip_card.dart';

/// Home tab body — available driver trips from dashboard API.
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customerDashboardProvider.notifier).refresh();
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
    ref.read(customerDashboardProvider.notifier).applyFilters(
          search: '',
          filter: const ShipmentFilter(),
          clearVehicleTypeId: true,
        );
  }

  bool get _hasLocalFilters =>
      _searchCtrl.text.trim().isNotEmpty ||
      ref.read(customerDashboardProvider).selectedVehicleTypeId != null ||
      _shipmentFilter.hasActiveFilters;

  Future<void> _reloadDashboard() async {
    final dashboard = ref.read(customerDashboardProvider);
    await ref.read(customerDashboardProvider.notifier).applyFilters(
          search: _searchCtrl.text,
          filter: _shipmentFilter,
          vehicleTypeId: dashboard.selectedVehicleTypeId,
        );
  }

  List<DriverTrip> _filterTripsLocally(List<DriverTrip> source) {
    final query = _searchCtrl.text.trim().toLowerCase();
    final selectedId =
        ref.read(customerDashboardProvider).selectedVehicleTypeId;
    return source.where((trip) {
      if (_shipmentFilter.fromCity != null &&
          _shipmentFilter.fromCity!.trim().isNotEmpty &&
          !trip.fromCity
              .toLowerCase()
              .contains(_shipmentFilter.fromCity!.trim().toLowerCase())) {
        return false;
      }
      if (_shipmentFilter.toCity != null &&
          _shipmentFilter.toCity!.trim().isNotEmpty &&
          !trip.toCity
              .toLowerCase()
              .contains(_shipmentFilter.toCity!.trim().toLowerCase())) {
        return false;
      }
      if (_shipmentFilter.pickupDate != null) {
        final d = trip.estimatedStartDate;
        if (d.year != _shipmentFilter.pickupDate!.year ||
            d.month != _shipmentFilter.pickupDate!.month ||
            d.day != _shipmentFilter.pickupDate!.day) {
          return false;
        }
      }
      if (selectedId != null) {
        // Local dummy mode only — remote uses API vehicle_type_id filter.
      }
      if (query.isEmpty) return true;
      final haystack = [
        trip.id,
        trip.fromCity,
        trip.toCity,
        trip.vehicleCategory.label,
        trip.driverName,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final colors = context.colors;
    final l10n = context.l10n;
    final state = ref.watch(customerDashboardProvider);
    final trips = EnvConfig.useRemoteApi
        ? state.trips
        : _filterTripsLocally(state.trips);

    if (state.isLoading && state.trips.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      color: colors.primary,
      onRefresh: () => ref.read(customerDashboardProvider.notifier).refresh(),
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
                      final result = await FilterSearchSheet.show(
                        context,
                        initial: _shipmentFilter,
                      );
                      if (result != null) {
                        safeSetState(() => _shipmentFilter = result);
                        await _reloadDashboard();
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
                    vehicleTypes: state.vehicleTypes,
                    selectedVehicleTypeId: state.selectedVehicleTypeId,
                    onSelected: (id) => ref
                        .read(customerDashboardProvider.notifier)
                        .selectVehicleType(id),
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
          else if (trips.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(25.w, 0, 25.w, 120.h),
                child: HomeFeedEmptyState(
                  emptyTitle: l10n.customerHomeEmptyTitle,
                  hasActiveFilters: _hasLocalFilters,
                  onClearFilters: _resetFilters,
                  scrollable: false,
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(25.w, 0, 25.w, 24.h),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final trip = trips[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: AppDimensions.base.h,
                      ),
                      child: CustomerHomeTripCard(
                        trip: trip,
                        onTap: () => context.push(
                          AppRoutes.tripDetailOf(trip.id),
                        ),
                        onViewDetails: () => context.push(
                          AppRoutes.tripDetailOf(trip.id),
                        ),
                      ),
                    );
                  },
                  childCount: trips.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
