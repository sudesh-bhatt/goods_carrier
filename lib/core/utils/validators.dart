class Validators {
  Validators._();

  /// +91XXXXXXXXXX or 10-digit Indian mobile (India-only validator).
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length == 12 && digits.startsWith('91')) return null;
    if (digits.length == 10) return null;
    return 'Enter a valid 10-digit mobile number';
  }

  /// Country-aware phone validator used when a [CountryCodePicker] is present.
  /// India (+91) requires exactly 10 digits. All other countries: 7–15 digits.
  static String? phoneForCountry(String dialCode, String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    final isIndia = dialCode == '+91';
    if (isIndia && digits.length != 10) {
      return 'Enter a valid 10-digit mobile number';
    }
    if (!isIndia && (digits.length < 7 || digits.length > 15)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  /// 15-char Indian GST: 27AABCS1429B1ZB
  static String? gstNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'GST number is required';
    final gst = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
    if (!gst.hasMatch(value.toUpperCase())) return 'Enter a valid GST number (e.g. 27AABCS1429B1ZB)';
    return null;
  }

  /// Indian vehicle number: MH 02 CC 4156
  static String? vehicleNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vehicle number is required';
    final vehicle = RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z]{1,2}[0-9]{4}$');
    if (!vehicle.hasMatch(value.replaceAll(' ', '').toUpperCase())) {
      return 'Enter a valid vehicle number (e.g. MH02CC4156)';
    }
    return null;
  }

  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  /// Figma design shows 4 OTP boxes — validated as 4 digits.
  static String? otp(String? value) {
    if (value == null || value.length != 4) return 'Enter the 4-digit OTP';
    if (!RegExp(r'^\d{4}$').hasMatch(value)) return 'OTP must be 4 digits';
    return null;
  }
}
