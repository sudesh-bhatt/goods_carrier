import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Result of a gallery / photo-library permission check.
enum GalleryAccessResult {
  /// Full library access (or system picker without restriction).
  full,

  /// iOS / Android partial access — user selected a subset of photos.
  limited,

  /// Denied this session; can ask again.
  denied,

  /// Denied with "Don't ask again" — must open Settings.
  permanentlyDenied,
}

/// Camera + gallery permission helpers for profile image picking.
abstract final class MediaPermissionHelper {
  static bool _pluginAvailable = true;

  /// Requests camera permission. Returns `true` when granted or when the
  /// native plugin is unavailable ( [image_picker] will prompt on its own).
  static Future<bool> ensureCamera() async {
    return _safeCall(
      () async {
        var status = await Permission.camera.status;
        if (status.isGranted) return true;
        status = await Permission.camera.request();
        return status.isGranted;
      },
      fallback: true,
    );
  }

  /// Requests photo-library permission appropriate for the platform.
  static Future<GalleryAccessResult> ensureGallery() async {
    return _safeCall(
      () async {
        final permissions = _galleryPermissions();
        var aggregate = await _aggregateStatus(permissions);

        if (aggregate == GalleryAccessResult.full ||
            aggregate == GalleryAccessResult.limited) {
          return aggregate;
        }

        for (final permission in permissions) {
          final status = await permission.request();
          aggregate = _statusToGalleryResult(status, aggregate);
          if (aggregate == GalleryAccessResult.full ||
              aggregate == GalleryAccessResult.limited) {
            return aggregate;
          }
        }

        return aggregate;
      },
      fallback: _galleryFallbackWhenPluginMissing(),
    );
  }

  static Future<void> openSettings() async {
    if (!_pluginAvailable) return;
    try {
      await openAppSettings();
    } on MissingPluginException {
      _pluginAvailable = false;
    }
  }

  /// When [permission_handler] is not linked (e.g. after hot restart), defer
  /// to [image_picker] which uses the system camera / photo UI on its own.
  static GalleryAccessResult _galleryFallbackWhenPluginMissing() {
    if (Platform.isIOS) {
      return GalleryAccessResult.full;
    }
    return GalleryAccessResult.denied;
  }

  static List<Permission> _galleryPermissions() {
    if (!Platform.isAndroid) {
      return [Permission.photos];
    }
    return [Permission.photos, Permission.storage];
  }

  static Future<GalleryAccessResult> _aggregateStatus(
    List<Permission> permissions,
  ) async {
    var result = GalleryAccessResult.denied;
    for (final permission in permissions) {
      final status = await permission.status;
      result = _statusToGalleryResult(status, result);
    }
    return result;
  }

  static GalleryAccessResult _statusToGalleryResult(
    PermissionStatus status,
    GalleryAccessResult current,
  ) {
    if (status.isGranted) {
      return GalleryAccessResult.full;
    }
    if (status.isLimited) {
      return GalleryAccessResult.limited;
    }
    if (status.isPermanentlyDenied) {
      return GalleryAccessResult.permanentlyDenied;
    }
    if (current == GalleryAccessResult.permanentlyDenied) {
      return current;
    }
    return GalleryAccessResult.denied;
  }

  static Future<T> _safeCall<T>(
    Future<T> Function() action, {
    required T fallback,
  }) async {
    if (!_pluginAvailable) {
      return fallback;
    }
    try {
      return await action();
    } on MissingPluginException catch (e, st) {
      _pluginAvailable = false;
      if (kDebugMode) {
        debugPrint(
          'MediaPermissionHelper: permission_handler native code not '
          'registered ($e). Stop the app and run `flutter run` again '
          '(hot restart cannot load new plugins). Using fallback.',
        );
        debugPrint('$st');
      }
      return fallback;
    }
  }
}
