import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/presentation/widgets/cards/driver_trip_card.dart';
import '../widgets/driver_trips_empty_view.dart';
import '../providers/driver_trips_provider.dart';

/// Driver "My Trip" tab — active trips posted by the driver.
class DriverMyTripsTab extends ConsumerStatefulWidget {
  const DriverMyTripsTab({super.key});

  @override
  ConsumerState<DriverMyTripsTab> createState() => _DriverMyTripsTabState();
}

class _DriverMyTripsTabState extends ConsumerState<DriverMyTripsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final l10n = context.l10n;
    final colors = context.colors;
    final tripsState = ref.watch(driverTripsProvider);
    final activeTrips = tripsState.active;

    if (tripsState.isLoading && tripsState.trips.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (activeTrips.isEmpty) {
      return DriverTripsEmptyView(
        onPostTrip: () => context.push(AppRoutes.postTrip),
      );
    }

    return RefreshIndicator(
      color: colors.primary,
      onRefresh: () => ref.read(driverTripsProvider.notifier).refresh(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(25.w, 20.h, 25.w, 24.h),
        itemCount: activeTrips.length,
        separatorBuilder: (_, __) => SizedBox(height: AppDimensions.base.h),
        itemBuilder: (context, index) {
          final trip = activeTrips[index];
          return DriverTripCard(
            trip: trip,
            showDriverInfo: false,
            actionLabel: l10n.actionViewDetails,
            onAction: () => context.push(AppRoutes.driverTripDetailOf(trip.id)),
            onTap: () => context.push(AppRoutes.driverTripDetailOf(trip.id)),
          );
        },
      ),
    );
  }
}
