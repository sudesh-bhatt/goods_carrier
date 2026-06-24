import '../../../domain/models/driver_payment_record.dart';

abstract final class DriverPaymentApiMapper {
  static DriverPaymentRecord fromJson(Map<String, dynamic> json) =>
      DriverPaymentRecord(
        id: _readInt(json['id']) ?? 0,
        tripId: _firstString(json, ['trip_id', 'reference_id', 'trip_reference']),
        amount: _readDouble(json['amount'] ?? json['total_amount']) ?? 0,
        paidAt: DateTime.tryParse(
              json['paid_at']?.toString() ??
                  json['payment_date']?.toString() ??
                  json['created_at']?.toString() ??
                  '',
            ) ??
            DateTime.now(),
        isPaid: json['is_paid'] as bool? ??
            (json['status']?.toString().toLowerCase() == 'paid'),
        invoiceUrl: _nullableString(json['invoice_url'] ?? json['invoice']),
      );

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
