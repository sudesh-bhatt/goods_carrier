/// Normalizes Sanctum bearer tokens for storage and API headers.
abstract final class AuthTokenUtils {
  /// Stores and sends `Bearer <token>` (no duplicate prefix).
  static String bearerValue(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.toLowerCase().startsWith('bearer ')) return trimmed;
    return 'Bearer $trimmed';
  }

  /// Value for the `Authorization` request header.
  static String authorizationHeader(String storedOrRaw) =>
      bearerValue(storedOrRaw);
}
