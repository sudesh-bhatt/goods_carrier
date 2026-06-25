import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../domain/models/driver_payment_record.dart';
import 'driver_payment_api_mapper.dart';

class DriverPaymentApiClient {
  DriverPaymentApiClient(this._dio);

  final Dio _dio;

  Future<List<DriverPaymentRecord>> listPayments({
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.driverPaymentHistory,
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
        'per_page': perPage,
      },
    );
    final rows = ApiEnvelope.parseDataListFlexible(response.data);
    return rows
        .map(DriverPaymentApiMapper.fromJson)
        .toList(growable: false);
  }

  Future<DriverPaymentRecord> getPaymentDetail(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.driverPaymentDetail(id),
    );
    return DriverPaymentApiMapper.fromJson(
      ApiEnvelope.parseData(response.data),
    );
  }

  Future<String> getPaymentInvoiceUrl(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.driverPaymentInvoice(id),
    );
    final data = ApiEnvelope.parseData(response.data);
    final url = data['invoice_url']?.toString().trim();
    if (url == null || url.isEmpty) {
      throw StateError('Invoice URL not available');
    }
    return url;
  }
}
