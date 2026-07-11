/// Dotted numeric version comparison for minimum-version gates.
abstract final class AppVersionUtils {
  AppVersionUtils._();

  /// Returns `true` when [installed] is strictly below [minimum].
  ///
  /// Null or empty [minimum] means no gate — always returns `false`.
  static bool isBelowMinimum({
    required String installed,
    required String? minimum,
  }) {
    if (minimum == null || minimum.trim().isEmpty) return false;

    final installedSegments = _parseSegments(installed);
    final minimumSegments = _parseSegments(minimum);
    final length = installedSegments.length > minimumSegments.length
        ? installedSegments.length
        : minimumSegments.length;

    for (var i = 0; i < length; i++) {
      final installedValue = i < installedSegments.length
          ? installedSegments[i]
          : 0;
      final minimumValue =
          i < minimumSegments.length ? minimumSegments[i] : 0;

      if (installedValue < minimumValue) return true;
      if (installedValue > minimumValue) return false;
    }

    return false;
  }

  static List<int> _parseSegments(String version) {
    return version.split('.').map(_segmentValue).toList();
  }

  static int _segmentValue(String segment) {
    final digits = segment.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return 0;
    return int.parse(digits);
  }
}
