import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/utils/profile_image_utils.dart';
import '../network/dio_network_image.dart';

/// Renders a profile photo from a picked path and/or saved local/remote reference.
class ProfileImageContent extends StatelessWidget {
  const ProfileImageContent({
    super.key,
    this.pickedPath,
    this.imageReference,
    required this.placeholder,
    this.fit = BoxFit.cover,
  });

  final String? pickedPath;
  final String? imageReference;
  final Widget placeholder;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final displayRef = ProfileImageUtils.resolveForDisplay(
      pickedPath: pickedPath,
      savedReference: imageReference,
    );

    if (displayRef == null) return placeholder;

    if (ProfileImageUtils.shouldRenderAsFile(displayRef)) {
      return Image.file(
        File(displayRef),
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }

    if (ProfileImageUtils.shouldRenderAsNetwork(displayRef)) {
      final networkUrl = ProfileImageUtils.resolveNetworkUrl(displayRef)!;
      if (ProfileImageUtils.requiresAuthenticatedFetch(displayRef)) {
        return DioNetworkImage(
          url: networkUrl,
          fit: fit,
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          placeholder: placeholder,
        );
      }
      return Image.network(
        networkUrl,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }

    return placeholder;
  }
}
