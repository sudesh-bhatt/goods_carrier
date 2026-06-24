import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_envelope.dart';

class SupportContact {
  const SupportContact({
    this.email = '',
    this.phone = '',
    this.whatsapp = '',
  });

  final String email;
  final String phone;
  final String whatsapp;
}

class SupportFaq {
  const SupportFaq({required this.question, required this.answer});

  final String question;
  final String answer;
}

class SupportCenterData {
  const SupportCenterData({
    this.faqs = const [],
    this.contact = const SupportContact(),
  });

  final List<SupportFaq> faqs;
  final SupportContact contact;
}

abstract final class SupportApiMapper {
  static SupportCenterData fromJson(Map<String, dynamic> json) {
    final faqsRaw = json['faqs'] ?? json['faq'];
    final faqs = <SupportFaq>[];
    if (faqsRaw is List) {
      for (final item in faqsRaw) {
        if (item is! Map<String, dynamic>) continue;
        final q = _firstString(item, ['question', 'title']);
        final a = _firstString(item, ['answer', 'body', 'description']);
        if (q.isNotEmpty && a.isNotEmpty) {
          faqs.add(SupportFaq(question: q, answer: a));
        }
      }
    }

    final contactMap = json['contact'] ?? json['channels'] ?? json;
    final contact = contactMap is Map<String, dynamic>
        ? SupportContact(
            email: _firstString(contactMap, ['email', 'support_email']),
            phone: _firstString(contactMap, ['phone', 'support_phone', 'mobile']),
            whatsapp: _firstString(contactMap, ['whatsapp', 'whatsapp_number']),
          )
        : const SupportContact();

    return SupportCenterData(faqs: faqs, contact: contact);
  }

  static String _firstString(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return '';
  }
}

class CustomerSupportApiClient {
  CustomerSupportApiClient(this._dio);

  final Dio _dio;

  Future<SupportCenterData> fetchSupport() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.customerSupport,
    );
    return SupportApiMapper.fromJson(ApiEnvelope.parseData(response.data));
  }
}
