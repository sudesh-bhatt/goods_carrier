import '../../../domain/models/driver_payment_record.dart';

abstract final class DriverPaymentApiMapper {
  static DriverPaymentRecord fromJson(Map<String, dynamic> json) {
    final status = json['status']?.toString() ?? '';
    return DriverPaymentRecord(
      id: _readInt(json['id']) ?? 0,
      transactionId: _firstString(json, ['transaction_id', 'reference_id']),
      planName: _firstString(json, [
        'plan_name',
        'subscription_plan_name',
        'plan',
        'description',
      ]),
      amount: _readDouble(json['amount'] ?? json['total_amount']) ?? 0,
      currency: json['currency']?.toString() ?? 'INR',
      paymentMethod: _firstString(json, ['payment_method', 'method']),
      status: status.isNotEmpty ? status : 'pending',
      paidAt: DateTime.tryParse(
            json['payment_date']?.toString() ??
                json['paid_at']?.toString() ??
                json['created_at']?.toString() ??
                '',
          ) ??
          DateTime.now(),
      invoiceUrl: _nullableString(json['invoice_url'] ?? json['invoice']),
    );
  }

  static int? _readInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString());
  }

  static double? _readDouble(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString());
  }

  static String? _nullableString(dynamic raw) {
    if (raw == null) return null;
    final value = raw.toString().trim();
    return value.isEmpty ? null : value;
  }

  static String _firstString(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return '';
  }
}
