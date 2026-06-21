import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../domain/entities/driver_trip.dart';
import '../../../domain/models/driver_trip_list_query.dart';
import '../../../domain/models/driver_trip_detail.dart';
import '../../../domain/models/paginated_result.dart';
import '../../../domain/models/trip_form_prefill.dart';
import '../../../domain/models/trip_submit_options.dart';
import 'trip_api_mapper.dart';

/// Driver trip endpoints — Postman **Driver → Trips** folder.
class DriverTripApiClient {
  DriverTripApiClient(this._dio);

  final Dio _dio;

  Future<PaginatedResult<DriverTrip>> listTrips({
    DriverTripListQuery query = const DriverTripListQuery(),
    String fallbackDriverId = '',
  }) async {
    final allItems = <DriverTrip>[];
    var page = query.page;
    var lastPage = query.page;

    do {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.driverTrips,
        queryParameters: query.copyWith(page: page).toQueryParameters(),
      );
      final payload = ApiEnvelope.parsePaginatedData(response.data);
      allItems.addAll(
        payload.items.map(
          (row) => TripApiMapper.fromJson(
            row,
            fallbackDriverId: fallbackDriverId,
          ),
        ),
      );
      lastPage = payload.lastPage;
      page++;
    } while (page <= lastPage);

    return PaginatedResult<DriverTrip>(
      items: allItems,
      currentPage: query.page,
      lastPage: lastPage,
      perPage: query.perPage,
      total: allItems.length,
    );
  }

  Future<DriverTrip> getTrip(
    String id, {
    String fallbackDriverId = '',
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.driverTrip(id),
    );
    return TripApiMapper.fromJson(
      ApiEnvelope.parseData(response.data),
      fallbackDriverId: fallbackDriverId,
    );
  }

  Future<DriverTripDetail> getTripDetail(
    String id, {
    String fallbackDriverId = '',
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.driverTrip(id),
    );
    final data = ApiEnvelope.parseData(response.data);
    final detail = TripApiMapper.parseDetail(
      data,
      fallbackDriverId: fallbackDriverId,
    );
    if (detail.requests.isNotEmpty) return detail;

    final requests = await listTripRequests(id);
    return DriverTripDetail(trip: detail.trip, requests: requests);
  }

  Future<List<DriverTripRequest>> listTripRequests(String tripId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.driverTripRequests(tripId),
    );
    final rows = ApiEnvelope.parseDataListFlexible(response.data);
    if (rows.isNotEmpty) {
      return rows.map(TripApiMapper.parseRequestItem).toList(growable: false);
    }
    final data = ApiEnvelope.parseData(response.data);
    return TripApiMapper.parseTripRequests(data);
  }

  Future<DriverTripRequest> acceptTripRequest({
    required String tripId,
    required String requestId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.acceptDriverTripRequest(tripId, requestId),
    );
    return _parseTripRequestResponse(response.data);
  }

  Future<DriverTripRequest> rejectTripRequest({
    required String tripId,
    required String requestId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.rejectDriverTripRequest(tripId, requestId),
    );
    return _parseTripRequestResponse(response.data);
  }

  DriverTripRequest _parseTripRequestResponse(Map<String, dynamic>? raw) {
    final data = ApiEnvelope.parseData(raw);
    final nested = data['request'];
    if (nested is Map<String, dynamic>) {
      return TripApiMapper.parseRequestItem(nested);
    }
    return TripApiMapper.parseRequestItem(data);
  }

  Future<TripFormPrefill> getTripForEdit(
    String id, {
    String fallbackDriverId = '',
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.driverTripEdit(id),
    );
    return TripApiMapper.parseFormPrefill(
      ApiEnvelope.parseData(response.data),
      fallbackDriverId: fallbackDriverId,
    );
  }

  Future<DriverTrip> publishTrip(
    DriverTrip trip, {
    required TripSubmitOptions options,
    String fallbackDriverId = '',
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.driverTrips,
      data: TripApiMapper.toRequestBody(trip, options: options),
    );
    return TripApiMapper.fromJson(
      ApiEnvelope.parseData(response.data),
      fallbackDriverId: fallbackDriverId.isNotEmpty
          ? fallbackDriverId
          : trip.driverId,
    );
  }

  Future<DriverTrip> updateTrip(
    DriverTrip trip, {
    required TripSubmitOptions options,
    String fallbackDriverId = '',
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      ApiConstants.driverTrip(trip.apiResourceId),
      data: TripApiMapper.toRequestBody(trip, options: options),
    );
    return TripApiMapper.fromJson(
      ApiEnvelope.parseData(response.data),
      fallbackDriverId: fallbackDriverId.isNotEmpty
          ? fallbackDriverId
          : trip.driverId,
    );
  }

  Future<DriverTrip> cancelTrip(
    String id, {
    required String reason,
    String? otherReason,
    String fallbackDriverId = '',
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.cancelTrip(id),
      data: TripApiMapper.toCancelBody(
        reason: reason,
        otherReason: otherReason,
      ),
    );
    return TripApiMapper.fromJson(
      ApiEnvelope.parseData(response.data),
      fallbackDriverId: fallbackDriverId,
    );
  }
}
