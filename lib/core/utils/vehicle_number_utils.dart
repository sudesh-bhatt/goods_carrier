import 'package:flutter/services.dart';

/// Indian vehicle registration helpers — normalize, validate, and format plates.
abstract final class VehicleNumberUtils {
  VehicleNumberUtils._();

  static final _standardCompact =
      RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z]{1,2}[0-9]{4}$');
  static final _bharatCompact =
      RegExp(r'^[0-9]{2}BH[0-9]{4}[A-Z]{2}$');

  /// Strips spaces, hyphens, and other separators; uppercases letters.
  static String normalize(String raw) =>
      raw.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();

  static bool isValid(String raw) {
    final compact = normalize(raw);
    if (compact.isEmpty) return false;
    return _standardCompact.hasMatch(compact) ||
        _bharatCompact.hasMatch(compact);
  }

  /// Canonical display / API format — e.g. `GJ-01-YB-3879`, `22-BH-1234-AA`.
  static String format(String raw) {
    final compact = normalize(raw);
    if (compact.isEmpty) return '';

    final bharat = RegExp(r'^(\d{2})(BH)(\d{4})([A-Z]{2})$').firstMatch(compact);
    if (bharat != null) {
      return '${bharat.group(1)}-${bharat.group(2)}-'
          '${bharat.group(3)}-${bharat.group(4)}';
    }

    final standard =
        RegExp(r'^([A-Z]{2})(\d{2})([A-Z]{1,2})(\d{4})$').firstMatch(compact);
    if (standard != null) {
      return '${standard.group(1)}-${standard.group(2)}-'
          '${standard.group(3)}-${standard.group(4)}';
    }

    return formatPartial(compact);
  }

  /// Progressive hyphen formatting while the user types.
  static String formatPartial(String compact) {
    if (compact.isEmpty) return '';
    if (compact.length >= 4 && compact.substring(2, 4) == 'BH') {
      return _formatBharatPartial(compact);
    }
    return _formatStandardPartial(compact);
  }

  static String _formatStandardPartial(String compact) {
    if (compact.length <= 2) return compact;
    if (compact.length <= 4) {
      return '${compact.substring(0, 2)}-${compact.substring(2)}';
    }

    final state = compact.substring(0, 2);
    final district = compact.substring(2, 4);
    final rest = compact.substring(4);

    if (rest.length >= 2 &&
        RegExp(r'^[A-Z]{2}').hasMatch(rest.substring(0, 2)) &&
        (rest.length == 2 || RegExp(r'^\d').hasMatch(rest[2]))) {
      final series = rest.substring(0, 2);
      final number = rest.length > 2 ? rest.substring(2) : '';
      return number.isEmpty
          ? '$state-$district-$series'
          : '$state-$district-$series-$number';
    }

    final series = rest.substring(0, 1);
    final number = rest.length > 1 ? rest.substring(1) : '';
    return number.isEmpty
        ? '$state-$district-$series'
        : '$state-$district-$series-$number';
  }

  static String _formatBharatPartial(String compact) {
    if (compact.length <= 2) return compact;
    if (compact.length <= 4) {
      return '${compact.substring(0, 2)}-${compact.substring(2)}';
    }
    if (compact.length <= 8) {
      return '${compact.substring(0, 2)}-${compact.substring(2, 4)}-'
          '${compact.substring(4)}';
    }
    return '${compact.substring(0, 2)}-${compact.substring(2, 4)}-'
        '${compact.substring(4, 8)}-${compact.substring(8)}';
  }
}

/// Uppercases, strips invalid characters, and inserts hyphens for Indian plates.
class VehicleNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final compact = VehicleNumberUtils.normalize(newValue.text);
    if (compact.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final maxLen = compact.length >= 4 && compact.substring(2, 4) == 'BH'
        ? 10
        : 10;
    final clamped =
        compact.length > maxLen ? compact.substring(0, maxLen) : compact;
    final formatted = VehicleNumberUtils.formatPartial(clamped);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
