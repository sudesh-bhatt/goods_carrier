/// Helpers for parsing and formatting phone numbers.
abstract final class PhoneUtils {
  PhoneUtils._();

  /// Splits an E.164-style number (e.g. `+919876543210`) into dial code + local digits.
  static ({String dialCode, String localNumber}) splitE164(String phone) {
    final trimmed = phone.trim();
    if (trimmed.startsWith('+91')) {
      final local = trimmed.substring(3).replaceAll(RegExp(r'[^\d]'), '');
      return (dialCode: '+91', localNumber: _clampLocal(local, '+91'));
    }

    final digits = trimmed.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.startsWith('91') && digits.length >= 12) {
      return (
        dialCode: '+91',
        localNumber: _clampLocal(digits.substring(2), '+91'),
      );
    }
    if (digits.length == 10) {
      return (dialCode: '+91', localNumber: digits);
    }

    return (dialCode: '+91', localNumber: _clampLocal(digits, '+91'));
  }

  static String _clampLocal(String digits, String dialCode) {
    final maxLen = dialCode == '+91' ? 10 : 15;
    if (digits.length <= maxLen) return digits;
    return digits.substring(0, maxLen);
  }

  static int maxLocalLength(String dialCode) => dialCode == '+91' ? 10 : 15;

  /// Builds E.164-style number: `+91` + `9876543210` → `+919876543210`.
  static String buildE164(String dialCode, String localNumber) {
    final dc = dialCode.startsWith('+') ? dialCode : '+$dialCode';
    final digits = localNumber.replaceAll(RegExp(r'\D'), '');
    return '$dc$digits';
  }

  /// Display with space after dial code — `+919876543210` → `+91 9876543210`.
  static String formatDisplay(String phone) {
    if (phone.trim().isEmpty) return phone;
    final split = splitE164(phone);
    if (split.localNumber.isEmpty) return phone;
    return '${split.dialCode} ${split.localNumber}';
  }
}
