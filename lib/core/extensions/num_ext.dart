import 'package:intl/intl.dart';

extension CurrencyExt on num {
  /// Formats as Indian Rupee — 2100 → "₹2,100"
  String get inr => NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 0,
      ).format(this);
}
