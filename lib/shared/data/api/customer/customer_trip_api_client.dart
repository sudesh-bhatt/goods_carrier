import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../domain/models/customer_trip_request_result.dart';
import 'customer_trip_api_mapper.dart';

class CustomerTripApiClient {
  CustomerTripApiClient(this._dio);

  final Dio _dio;

  Future<CustomerTripRequestResult> submitTripRequest({
    required String tripId,
    required int shipmentId,
    required String note,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.customerTripRequests(tripId),
      data: CustomerTripApiMapper.toRequestBody(
        shipmentId: shipmentId,
        note: note,
      ),
    );
    return CustomerTripApiMapper.requestFromJson(
      ApiEnvelope.parseData(response.data),
    );
  }

  Future<String> reportTrip({
    required String tripId,
    required String reasonSlug,
    String? description,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.customerTripReport(tripId),
      data: CustomerTripApiMapper.toReportBody(
        reasonSlug: reasonSlug,
        description: description,
      ),
    );
    return CustomerTripApiMapper.reportIdFromJson(
      ApiEnvelope.parseData(response.data),
    );
  }
}
