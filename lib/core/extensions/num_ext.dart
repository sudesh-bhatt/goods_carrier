import 'package:intl/intl.dart';

extension CurrencyExt on num {
  /// Formats as Indian Rupee — 2100 → "₹2,100"
  String get inr => NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 0,
      ).format(this);

  /// ₹10,450.00 — payment summary rows.
  String get inrDetailed => NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 2,
      ).format(this);
}
