/// @deprecated Use [RemoteDriverTripRepository] instead.
library;

import 'package:dio/dio.dart';

import '../../../core/network/api_constants.dart';
import '../../../core/network/api_envelope.dart';
import '../../domain/entities/driver_trip.dart';
import '../../domain/models/driver_trip_detail.dart';
import '../../domain/models/trip_form_prefill.dart';
import '../../domain/models/trip_submit_options.dart';
import '../../domain/repositories/i_trip_repository.dart';
import '../api/driver/trip_api_mapper.dart';

@Deprecated('Use RemoteDriverTripRepository')
class RemoteTripRepository implements ITripRepository {
  RemoteTripRepository(this._dio);
  final Dio _dio;

  @override
  Future<List<DriverTrip>> getDriverTrips(String driverId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.driverTrips,
    );
    final items = ApiEnvelope.parsePaginatedData(response.data).items;
    return items
        .map((e) => TripApiMapper.fromJson(e, fallbackDriverId: driverId))
        .toList();
  }

  @override
  Future<DriverTrip> getTrip(String id) {
    throw UnsupportedError('Use DriverTripApiClient.getTrip');
  }

  @override
  Future<DriverTripDetail> getTripDetail(String id) {
    throw UnsupportedError('Use DriverTripApiClient.getTripDetail');
  }

  @override
  Future<DriverTripRequest> acceptTripRequest({
    required String tripId,
    required String requestId,
  }) {
    throw UnsupportedError('Use DriverTripApiClient.acceptTripRequest');
  }

  @override
  Future<DriverTripRequest> rejectTripRequest({
    required String tripId,
    required String requestId,
  }) {
    throw UnsupportedError('Use DriverTripApiClient.rejectTripRequest');
  }

  @override
  Future<TripFormPrefill> getTripForEdit(String id) {
    throw UnsupportedError('Use DriverTripApiClient.getTripForEdit');
  }

  @override
  Future<DriverTrip> postTrip(
    DriverTrip trip, {
    required TripSubmitOptions options,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.driverTrips,
      data: TripApiMapper.toRequestBody(trip, options: options),
    );
    return TripApiMapper.fromJson(
      ApiEnvelope.parseData(response.data),
      fallbackDriverId: trip.driverId,
    );
  }

  @override
  Future<DriverTrip> updateTrip(
    DriverTrip trip, {
    required TripSubmitOptions options,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      ApiConstants.driverTrip(trip.apiResourceId),
      data: TripApiMapper.toRequestBody(trip, options: options),
    );
    return TripApiMapper.fromJson(
      ApiEnvelope.parseData(response.data),
      fallbackDriverId: trip.driverId,
    );
  }

  @override
  Future<DriverTrip> cancelTrip(
    String tripId, {
    required String reason,
    String? otherReason,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.cancelTrip(tripId),
      data: TripApiMapper.toCancelBody(
        reason: reason,
        otherReason: otherReason,
      ),
    );
    return TripApiMapper.fromJson(ApiEnvelope.parseData(response.data));
  }
}
