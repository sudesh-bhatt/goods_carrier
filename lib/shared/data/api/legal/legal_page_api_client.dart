import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../domain/models/legal_page.dart';

/// Static CMS pages — `GET /api/pages/{slug}` (also tries customer path).
class LegalPageApiClient {
  LegalPageApiClient(this._dio);

  final Dio _dio;

  Future<LegalPage> fetchPage(String slug) async {
    try {
      return await _fetch(ApiConstants.legalPage(slug));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return _fetch(ApiConstants.customerLegalPage(slug));
      }
      rethrow;
    }
  }

  Future<LegalPage> _fetch(String path) async {
    final response = await _dio.get<Map<String, dynamic>>(path);
    final data = ApiEnvelope.parseData(response.data);
    final page = LegalPage.fromJson(data);
    if (!page.hasContent) {
      // Some APIs nest under `page` / `static_page`.
      final nested = data['page'] ?? data['static_page'];
      if (nested is Map<String, dynamic>) {
        return LegalPage.fromJson(nested);
      }
    }
    return page;
  }
}
