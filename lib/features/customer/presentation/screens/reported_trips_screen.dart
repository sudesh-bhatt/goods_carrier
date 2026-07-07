import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../res/font_res.dart';
import '../providers/customer_reported_trips_provider.dart';
import '../../../driver/presentation/providers/driver_reported_shipments_provider.dart';
import '../../../../core/router/app_routes.dart';
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

class _ReportedTripsScreenState extends ConsumerState<ReportedTripsScreen>
    with SafeSetStateMixin {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() {
    if (widget.forDriver) {
      return ref.read(driverReportedShipmentsProvider.notifier).refresh();
    }
    return ref.read(customerReportedTripsProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final state = widget.forDriver
        ? ref.watch(driverReportedShipmentsProvider)
        : ref.watch(customerReportedTripsProvider);
    final query = _searchCtrl.text.trim().toLowerCase();

    final trips = state.trips.where((t) {
      if (query.isEmpty) return true;
      final haystack = [
        t.fromCity,
        t.toCity,
        t.vehicleType.label,
        t.id,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();

    final showInitialLoading = state.isLoading && state.trips.isEmpty;

    return Scaffold(
      backgroundColor: ReportedTripsTokens.screenBg,
      appBar: FlowScreenAppBar(
        title: widget.forDriver
            ? l10n.driverReportedShipments
            : l10n.customerReportedTrips,
        fallbackRoute:
            widget.forDriver ? AppRoutes.driverHome : AppRoutes.customerHome,
      ),
      body: showInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: colors.primary,
              onRefresh: _reload,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(25.w, 16.h, 25.w, 32.h),
                children: [
                  ReportedTripsSearchField(
                    controller: _searchCtrl,
                    hint: l10n.customerHomeSearchHint,
                    onChanged: (_) => safeSetState(() {}),
                  ),
                  SizedBox(height: 17.h),
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
                  if (trips.isEmpty)
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
                    ),
                ],
              ),
            ),
    );
  }
}
