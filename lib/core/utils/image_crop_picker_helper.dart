import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'media_permission_helper.dart';
import 'profile_image_utils.dart';
import 'vehicle_image_crop_kind.dart';

/// Picks an image from the gallery and opens the native crop UI before upload.
abstract final class ImageCropPickerHelper {
  static const _accentOrange = Color(0xFFFF6D00);

  static Future<String?> pickAndCrop({
    required BuildContext context,
    required VehicleImageCropKind kind,
    required String cropTitle,
    ImagePicker? picker,
  }) async {
    final access = await MediaPermissionHelper.ensureGallery();
    if (access == GalleryAccessResult.denied ||
        access == GalleryAccessResult.permanentlyDenied) {
      return null;
    }

    final file = await (picker ?? ImagePicker()).pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
    );
    if (file == null) return null;
    if (!context.mounted) return null;

    return cropExisting(
      context: context,
      sourcePath: file.path,
      kind: kind,
      cropTitle: cropTitle,
    );
  }

  /// Re-opens the cropper for a local file (adjust crop / resize).
  static Future<String?> cropExisting({
    required BuildContext context,
    required String sourcePath,
    required VehicleImageCropKind kind,
    required String cropTitle,
  }) async {
    final normalized = ProfileImageUtils.normalizePath(sourcePath);
    if (normalized == null || !ProfileImageUtils.isLocalFileAvailable(normalized)) {
      return null;
    }

    final aspect = _aspectRatio(kind);
    final (maxW, maxH) = _maxSize(kind);

    final cropped = await ImageCropper().cropImage(
      sourcePath: normalized,
      aspectRatio: aspect,
      maxWidth: maxW,
      maxHeight: maxH,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 85,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: cropTitle,
          toolbarColor: _accentOrange,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: _accentOrange,
          initAspectRatio: _androidPreset(kind),
          lockAspectRatio: true,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: cropTitle,
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          aspectRatioPickerButtonHidden: true,
        ),
      ],
    );

    return cropped?.path;
  }

  static CropAspectRatio? _aspectRatio(VehicleImageCropKind kind) {
    return switch (kind) {
      VehicleImageCropKind.profile =>
        const CropAspectRatio(ratioX: 1, ratioY: 1),
      VehicleImageCropKind.license =>
        const CropAspectRatio(ratioX: 4, ratioY: 3),
      VehicleImageCropKind.vehicleHero =>
        const CropAspectRatio(ratioX: 16, ratioY: 9),
    };
  }

  static (int, int) _maxSize(VehicleImageCropKind kind) {
    return switch (kind) {
      VehicleImageCropKind.profile => (512, 512),
      VehicleImageCropKind.license => (1280, 960),
      VehicleImageCropKind.vehicleHero => (1280, 720),
    };
  }

  static CropAspectRatioPreset _androidPreset(VehicleImageCropKind kind) {
    return switch (kind) {
      VehicleImageCropKind.profile => CropAspectRatioPreset.square,
      VehicleImageCropKind.license => CropAspectRatioPreset.ratio4x3,
      VehicleImageCropKind.vehicleHero => CropAspectRatioPreset.ratio16x9,
    };
  }
}
