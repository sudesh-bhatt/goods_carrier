import 'dart:io';

import '../config/env_config.dart';

/// Helpers for local vs remote profile image references.
abstract final class ProfileImageUtils {
  static bool isRemoteUrl(String? value) {
    if (value == null || value.isEmpty) return false;
    final lower = value.trim().toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }

  static bool isServerRelativePath(String? value) {
    final path = normalizePath(value);
    if (path == null || isRemoteUrl(path)) return false;
    if (!path.startsWith('/')) return false;
    return !File(path).existsSync();
  }

  static String? normalizePath(String? value) {
    if (value == null || value.isEmpty) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return trimmed.replaceFirst(RegExp(r'^file://'), '');
  }

  static bool isLocalFileAvailable(String? value) {
    final path = normalizePath(value);
    if (path == null || isRemoteUrl(path)) return false;
    return File(path).existsSync();
  }

  /// Full URL for [Image.network], or null when not a remote/server path.
  static String? resolveNetworkUrl(String? reference) {
    if (reference == null || reference.isEmpty) return null;
    final trimmed = reference.trim();
    if (isLocalFileAvailable(trimmed)) return null;
    if (isRemoteUrl(trimmed)) return trimmed;
    if (isServerRelativePath(trimmed)) {
      return '${EnvConfig.apiBaseUrl}$trimmed';
    }
    return null;
  }

  /// Upload avatar only when [value] points to an existing local file.
  static bool needsAvatarUpload(String? value) => isLocalFileAvailable(value);

  /// Picked local file wins, then saved remote URL, then saved local file.
  static String? resolveForApiSubmission({
    String? pickedPath,
    String? savedReference,
  }) {
    final picked = normalizePath(pickedPath);
    if (picked != null && isLocalFileAvailable(picked)) return picked;

    final saved = savedReference?.trim();
    if (saved == null || saved.isEmpty) return null;
    if (isRemoteUrl(saved)) return saved;
    if (isServerRelativePath(saved)) return saved;
    if (isLocalFileAvailable(saved)) return normalizePath(saved);
    return null;
  }

  /// Best reference for on-screen preview (picked → local file → network URL).
  static String? resolveForDisplay({
    String? pickedPath,
    String? savedReference,
  }) {
    final picked = normalizePath(pickedPath);
    if (picked != null && isLocalFileAvailable(picked)) return picked;

    final saved = savedReference?.trim();
    if (saved == null || saved.isEmpty) return null;
    if (isLocalFileAvailable(saved)) return normalizePath(saved);

    return resolveNetworkUrl(saved);
  }

  static bool shouldRenderAsNetwork(String? reference) =>
      resolveNetworkUrl(reference) != null;

  /// Private `/storage/...` assets require Bearer auth — [Image.network] alone fails.
  static bool requiresAuthenticatedFetch(String? reference) {
    final path = normalizePath(reference);
    if (path == null || isLocalFileAvailable(path)) return false;

    if (isRemoteUrl(path)) {
      final uri = Uri.tryParse(path);
      return uri != null && uri.path.startsWith('/storage/');
    }

    return isServerRelativePath(path) && path.startsWith('/storage/');
  }

  static bool shouldRenderAsFile(String? reference) =>
      isLocalFileAvailable(reference);
}
