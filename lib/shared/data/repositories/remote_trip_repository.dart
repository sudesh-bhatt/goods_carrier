import 'package:dio/dio.dart';

import '../../../core/network/api_constants.dart';
import '../../domain/entities/driver_trip.dart';
import '../../domain/repositories/i_trip_repository.dart';

/// REST implementation of [ITripRepository].
class RemoteTripRepository implements ITripRepository {
  RemoteTripRepository(this._dio);
  final Dio _dio;

  @override
  Future<List<DriverTrip>> getDriverTrips(String driverId) async {
    final response = await _dio.get(
      ApiConstants.driverTrips,
      queryParameters: {'driver_id': driverId},
    );
    return (response.data['data'] as List<dynamic>)
        .map((e) => DriverTrip.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DriverTrip> postTrip(DriverTrip trip) async {
    final response = await _dio.post(
      ApiConstants.driverTrips,
      data: trip.toJson(),
    );
    return DriverTrip.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> cancelTrip(String tripId) =>
      _dio.patch(ApiConstants.cancelTrip(tripId));
}
