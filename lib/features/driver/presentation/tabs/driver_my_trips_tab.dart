import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../providers/driver_trips_provider.dart';
import '../widgets/driver_trips_empty_view.dart';
import '../widgets/my_trips/driver_my_trip_card.dart';
import '../widgets/my_trips/driver_my_trip_tokens.dart';

/// Driver My Trips tab — Figma `1:3967`.
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(driverTripsProvider.notifier).loadForTab();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final tripsState = ref.watch(driverTripsProvider);
    final trips = tripsState.myTripsList;

    if (tripsState.isLoading && trips.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (trips.isEmpty) {
      return RefreshIndicator(
        color: context.colors.primary,
        onRefresh: () => ref.read(driverTripsProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.7,
            child: DriverTripsEmptyView(
              onPostTrip: () => context.push(AppRoutes.postTrip),
            ),
          ),
        ),
      );
    }

    return ColoredBox(
      color: DriverMyTripTokens.screenBg,
      child: RefreshIndicator(
        color: context.colors.primary,
        onRefresh: () => ref.read(driverTripsProvider.notifier).refresh(),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(25.w, 20.h, 25.w, 100.h),
          itemCount: trips.length,
          separatorBuilder: (_, __) => SizedBox(height: 24.h),
          itemBuilder: (context, index) {
            final trip = trips[index];
            return DriverMyTripListCard(
              trip: trip,
              onViewRequests: () =>
                  context.push(AppRoutes.driverTripDetailOf(trip.id)),
              onEdit: () => context.push(AppRoutes.editTripOf(trip.id)),
              onDelete: () => context.push(AppRoutes.cancelTripOf(trip.id)),
            );
          },
        ),
      ),
    );
  }
}
