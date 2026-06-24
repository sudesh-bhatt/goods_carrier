import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../domain/entities/reported_trip.dart';
import 'reports_api_mapper.dart';

class ReportsApiClient {
  ReportsApiClient(this._dio);

  final Dio _dio;

  Future<ReportSubmissionResult> submitReport({
    required String referenceType,
    required String referenceId,
    required String reason,
    String? details,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.reports,
      data: ReportsApiMapper.toSubmitBody(
        referenceType: referenceType,
        referenceId: referenceId,
        reason: reason,
        details: details,
      ),
    );
    return ReportsApiMapper.fromSubmitJson(
      ApiEnvelope.parseData(response.data),
    );
  }

  Future<ReportSubmissionResult> getReportStatus(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.report(id),
    );
    return ReportsApiMapper.fromSubmitJson(
      ApiEnvelope.parseData(response.data),
    );
  }

  Future<List<ReportedTrip>> listDriverReportedShipments({
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.driverReportedShipments,
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
        'per_page': perPage,
      },
    );
    final rows = ApiEnvelope.parseDataListFlexible(response.data);
    return rows
        .map(ReportsApiMapper.reportedTripFromJson)
        .whereType<ReportedTrip>()
        .toList(growable: false);
  }
}
