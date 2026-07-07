import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../providers/driver_vehicles_provider.dart';
import '../widgets/vehicles/driver_fleet_overview.dart';
import '../widgets/vehicles/driver_vehicle_card.dart';
import '../widgets/vehicles/driver_vehicle_tokens.dart';

/// My Vehicles list — [Figma](https://www.figma.com/design/YxnNResvDQnbkcPhGejtxa/Mobile-App-UI--Developer-?node-id=1-2).
class DriverVehiclesScreen extends ConsumerStatefulWidget {
  const DriverVehiclesScreen({super.key});

  @override
  ConsumerState<DriverVehiclesScreen> createState() =>
      _DriverVehiclesScreenState();
}

class _DriverVehiclesScreenState extends ConsumerState<DriverVehiclesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(driverVehiclesProvider.notifier).load();
    });
  }

  Future<void> _reload() => ref.read(driverVehiclesProvider.notifier).load();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final state = ref.watch(driverVehiclesProvider);
    final showInitialLoading = state.isLoading && state.vehicles.isEmpty;

    return Scaffold(
      backgroundColor: DriverVehicleTokens.screenBg,
      appBar: FlowScreenAppBar(
        title: l10n.driverMyVehiclesTitle,
        fallbackRoute: AppRoutes.driverProfile,
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 8.h, right: 4.w),
        child: Material(
          color: DriverVehicleTokens.accentOrange,
          borderRadius: BorderRadius.circular(16.r),
          elevation: 8,
          shadowColor: const Color.fromRGBO(159, 66, 0, 0.3),
          child: InkWell(
            onTap: () => context.push(AppRoutes.driverAddVehicle),
            borderRadius: BorderRadius.circular(16.r),
            child: SizedBox(
              width: 64.w,
              height: 64.w,
              child: Icon(Icons.add_rounded, color: Colors.white, size: 17.5.w),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: showInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: colors.primary,
              onRefresh: _reload,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(24.w, 30.h, 24.w, 128.h),
                children: [
                  if (state.error != null) ...[
                    Text(
                      state.error!,
                      style: TextStyle(
                        color: context.colors.error,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                  DriverFleetOverview(
                    summary: state.result.summary,
                    sectionLabel: l10n.driverVehiclesSectionLabel,
                    title: l10n.driverFleetOverviewTitle,
                    totalActiveLabel: l10n.driverFleetTotalActive,
                    inTransitLabel: l10n.driverFleetInTransit,
                  ),
                  SizedBox(height: 22.h),
                  if (state.vehicles.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 48.h),
                      child: Center(
                        child: Text(
                          l10n.driverNoVehiclesMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: DriverVehicleTokens.mutedGrey,
                          ),
                        ),
                      ),
                    )
                  else
                    ...state.vehicles.map(
                      (vehicle) => Padding(
                        padding: EdgeInsets.only(bottom: 32.h),
                        child: DriverVehicleCard(
                          vehicle: vehicle,
                          capacityLabel: l10n.driverVehicleCapacityLabel,
                          onTap: () => context.push(
                            AppRoutes.driverVehicleDetailOf(vehicle.id),
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
