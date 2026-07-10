import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../res/font_res.dart';
import '../../../driver/presentation/providers/driver_reported_shipments_provider.dart';
import '../providers/customer_reported_trips_provider.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../widgets/reported_trips/reported_trip_card.dart';
import '../widgets/reported_trips/reported_trips_search_field.dart';
import '../widgets/reported_trips/reported_trips_tokens.dart';

/// Reported trips list — [Figma](https://www.figma.com/design/YxnNResvDQnbkcPhGejtxa/Mobile-App-UI--Developer-?node-id=1-6391).
class ReportedTripsScreen extends ConsumerStatefulWidget {
  const ReportedTripsScreen({super.key, this.forDriver = false});

  final bool forDriver;

  @override
  ConsumerState<ReportedTripsScreen> createState() =>
      _ReportedTripsScreenState();
}

class _ReportedTripsScreenState extends ConsumerState<ReportedTripsScreen> {
  static const _searchDebounce = Duration(milliseconds: 600);

  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  String get _searchQuery => _searchCtrl.text.trim();

  Future<void> _reload() {
    if (widget.forDriver) {
      return ref.read(driverReportedShipmentsProvider.notifier).refresh(
            search: _searchQuery.isEmpty ? null : _searchQuery,
          );
    }
    return ref.read(customerReportedTripsProvider.notifier).refresh(
          search: _searchQuery,
        );
  }

  void _onSearchChanged(String _) {
    _searchTimer?.cancel();
    _searchTimer = Timer(_searchDebounce, () {
      if (!mounted) return;
      if (widget.forDriver) {
        ref.read(driverReportedShipmentsProvider.notifier).load(
              search: _searchQuery.isEmpty ? null : _searchQuery,
              showLoadingIndicator: false,
            );
      } else {
        ref.read(customerReportedTripsProvider.notifier).load(
              search: _searchQuery,
              showLoadingIndicator: false,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final state = widget.forDriver
        ? ref.watch(driverReportedShipmentsProvider)
        : ref.watch(customerReportedTripsProvider);
    final trips = state.trips;

    return Scaffold(
      backgroundColor: ReportedTripsTokens.screenBg,
      appBar: FlowScreenAppBar(
        title: widget.forDriver
            ? l10n.driverReportedShipments
            : l10n.customerReportedTrips,
        fallbackRoute:
            widget.forDriver ? AppRoutes.driverHome : AppRoutes.customerHome,
      ),
      body: Column(
        children: [
          // Keep search mounted so focus is never lost on list rebuilds.
          Padding(
            padding: EdgeInsets.fromLTRB(25.w, 16.h, 25.w, 0),
            child: ReportedTripsSearchField(
              controller: _searchCtrl,
              focusNode: _searchFocus,
              hint: l10n.customerHomeSearchHint,
              onChanged: _onSearchChanged,
            ),
          ),
          SizedBox(height: 17.h),
          Expanded(
            child: RefreshIndicator(
              color: colors.primary,
              onRefresh: _reload,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(25.w, 0, 25.w, 32.h),
                children: [
                  if (state.isLoading && trips.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 48.h),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  else if (state.error != null && trips.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 48.h),
                      child: Center(
                        child: Text(
                          state.error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: FontRes.MANROPE_MEDIUM,
                            fontSize: 14.sp,
                            color: ReportedTripsTokens.labelGrey,
                          ),
                        ),
                      ),
                    )
                  else if (trips.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 48.h),
                      child: Center(
                        child: Text(
                          l10n.emptyHistory,
                          style: TextStyle(
                            fontFamily: FontRes.MANROPE_MEDIUM,
                            fontSize: 14.sp,
                            color: ReportedTripsTokens.labelGrey,
                          ),
                        ),
                      ),
                    )
                  else
                    ...trips.map(
                      (trip) => Padding(
                        padding: EdgeInsets.only(bottom: 17.h),
                        child: ReportedTripCard(
                          trip: trip,
                          reportedByYouLabel: l10n.customerReportedByYouBadge,
                          estStartLabel: l10n.customerHomeEstStartDate,
                          estEndLabel: l10n.customerHomeEstEndDate,
                          vehicleLabel: l10n.tripVehicle,
                          capacityLabel: l10n.tripCapacity,
                          estimatedPriceLabel: l10n.customerEstimatedPrice,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
