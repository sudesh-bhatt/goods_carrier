import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../domain/entities/driver_vehicle.dart';
import '../../../domain/models/driver_vehicle_detail.dart';
import '../../../domain/models/driver_vehicle_list_result.dart';
import '../../../domain/models/driver_vehicle_masters.dart';
import 'driver_vehicle_api_mapper.dart';

class DriverVehicleApiClient {
  DriverVehicleApiClient(this._dio);

  final Dio _dio;

  Future<DriverVehicleListResult> fetchVehicles() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.driverVehicles,
    );
    final raw = response.data;
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) {
        return DriverVehicleApiMapper.listResultFromJson(data);
      }
      if (data is List) {
        final vehicles = data
            .whereType<Map<String, dynamic>>()
            .map(DriverVehicleApiMapper.fromJson)
            .where((v) => v.id > 0)
            .toList(growable: false);
        return DriverVehicleListResult(vehicles: vehicles);
      }
    }

    final rows = ApiEnvelope.parseDataListFlexible(raw);
    final vehicles = rows
        .map(DriverVehicleApiMapper.fromJson)
        .where((v) => v.id > 0)
        .toList(growable: false);
    return DriverVehicleListResult(vehicles: vehicles);
  }

  Future<List<DriverVehicle>> listVehicles() async {
    final result = await fetchVehicles();
    return result.vehicles;
  }

  Future<DriverVehicleMasters> fetchMasters() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.vehicleMasters,
    );
    final data = ApiEnvelope.parseData(response.data);
    return DriverVehicleApiMapper.mastersFromJson(data);
  }

  Future<DriverVehicleDetail> getVehicleDetail(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.driverVehicle(id),
    );
    final data = ApiEnvelope.parseData(response.data);
    return DriverVehicleApiMapper.detailFromJson(data);
  }

  Future<DriverVehicleDetail> addVehicle(FormData formData) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.driverVehicles,
      data: formData,
    );
    final data = ApiEnvelope.parseData(response.data);
    return DriverVehicleApiMapper.detailFromJson(data);
  }

  Future<DriverVehicleDetail> updateVehicle(int id, FormData formData) async {
    // PHP only parses multipart/form-data on POST. Laravel routes PUT via _method.
    final payload = FormData()
      ..fields.addAll(formData.fields)
      ..files.addAll(formData.files)
      ..fields.add(const MapEntry('_method', 'PUT'));

    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.driverVehicle(id),
      data: payload,
    );
    final data = ApiEnvelope.parseData(response.data);
    return DriverVehicleApiMapper.detailFromJson(data);
  }

  Future<void> deleteVehicle(int id) async {
    await _dio.delete<void>(ApiConstants.driverVehicle(id));
  }
}
