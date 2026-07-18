import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../shared/domain/entities/driver_vehicle.dart';
import '../../../../shared/domain/enums/driver_vehicle_status.dart';
import '../../../../shared/domain/enums/vehicle_type.dart';
import '../../../../shared/domain/models/driver_vehicle_detail.dart';
import '../../../../shared/domain/models/driver_vehicle_list_result.dart';
import '../../../../shared/domain/models/driver_vehicle_masters.dart';

class DriverVehiclesState {
  const DriverVehiclesState({
    this.result = const DriverVehicleListResult(vehicles: []),
    this.isLoading = false,
    this.error,
  });

  final DriverVehicleListResult result;
  final bool isLoading;
  final String? error;

  List<DriverVehicle> get vehicles => result.vehicles;

  DriverVehiclesState copyWith({
    DriverVehicleListResult? result,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      DriverVehiclesState(
        result: result ?? this.result,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

class DriverVehiclesNotifier extends StateNotifier<DriverVehiclesState> {
  DriverVehiclesNotifier(this._ref) : super(const DriverVehiclesState()) {
    load();
  }

  final Ref _ref;

  static final _localVehicles = [
    DriverVehicle(
      id: 1,
      vehicleNumber: 'MH-01-AB-1234',
      vehicleType: VehicleType.heavyDuty,
      vehicleTypeId: 4,
      vehicleTypeName: 'Heavy Duty Truck',
      capacity: 15,
      status: DriverVehicleStatus.active,
    ),
    DriverVehicle(
      id: 2,
      vehicleNumber: 'KA-05-CD-5678',
      vehicleType: VehicleType.mini,
      vehicleTypeId: 1,
      vehicleTypeName: 'Mini Van',
      capacity: 2.5,
      status: DriverVehicleStatus.inMaintenance,
    ),
    DriverVehicle(
      id: 3,
      vehicleNumber: 'DL-03-EF-9012',
      vehicleType: VehicleType.truck,
      vehicleTypeId: 3,
      vehicleTypeName: 'Flatbed Trailer',
      capacity: 25,
      status: DriverVehicleStatus.active,
    ),
    DriverVehicle(
      id: 4,
      vehicleNumber: 'HR-26-GH-3456',
      vehicleType: VehicleType.heavyDuty,
      vehicleTypeId: 5,
      vehicleTypeName: 'Refrigerated Truck',
      capacity: 12,
      status: DriverVehicleStatus.active,
    ),
  ];

  static final _localResult = DriverVehicleListResult(
    vehicles: _localVehicles,
    summary: DriverVehicleFleetSummary(totalActive: 8, inTransit: 5),
  );

  static DriverVehicleDetail _localDetail(int id) {
    final vehicle = _localVehicles.firstWhere(
      (v) => v.id == id,
      orElse: () => _localVehicles.first,
    );
    return DriverVehicleDetail(
      id: vehicle.id,
      registrationNumber: vehicle.vehicleNumber,
      vehicleTypeId: vehicle.vehicleTypeId ?? 1,
      vehicleTypeName: vehicle.displayTypeName,
      vehicleTypeSlug: vehicle.vehicleTypeSlug ?? vehicle.vehicleType.apiValue,
      capacity: vehicle.capacity ?? 0,
      capacityUnit: vehicle.capacityUnit,
      status: vehicle.status,
      driverName: 'Vikram Singh',
      driverSubtitle: 'Expert Driver',
      driverCountryCode: '+91',
      driverPhone: '9876543210',
      fleetCode: 'V-902-XLR',
    );
  }

  static final _localMasters = DriverVehicleMasters.fallback;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    if (!EnvConfig.useRemoteApi) {
      state = DriverVehiclesState(result: _localResult);
      return;
    }

    try {
      final result =
          await _ref.read(driverVehicleApiClientProvider).fetchVehicles();
      state = DriverVehiclesState(result: result);
    } catch (e) {
      state = DriverVehiclesState(
        error: ApiExceptionMapper.userMessage(e),
      );
    }
  }

  Future<DriverVehicleDetail?> fetchDetail(int id) async {
    if (!EnvConfig.useRemoteApi) {
      return _localDetail(id);
    }
    try {
      return await _ref.read(driverVehicleApiClientProvider).getVehicleDetail(id);
    } catch (e) {
      state = state.copyWith(error: ApiExceptionMapper.userMessage(e));
      return null;
    }
  }

  Future<DriverVehicleMasters> fetchMasters() async {
    if (!EnvConfig.useRemoteApi) return _localMasters;
    try {
      final masters =
          await _ref.read(driverVehicleApiClientProvider).fetchMasters();
      if (masters.vehicleTypes.isEmpty) {
        return DriverVehicleMasters.fallback;
      }
      return masters;
    } catch (_) {
      return DriverVehicleMasters.fallback;
    }
  }

  Future<bool> deleteVehicle(int id) async {
    if (!EnvConfig.useRemoteApi) {
      final next = state.vehicles.where((v) => v.id != id).toList();
      state = state.copyWith(
        result: DriverVehicleListResult(
          vehicles: next,
          summary: state.result.summary,
        ),
      );
      return true;
    }

    try {
      await _ref.read(driverVehicleApiClientProvider).deleteVehicle(id);
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(error: ApiExceptionMapper.userMessage(e));
      return false;
    }
  }
}

final driverVehiclesProvider =
    StateNotifierProvider<DriverVehiclesNotifier, DriverVehiclesState>((ref) {
  return DriverVehiclesNotifier(ref);
});
