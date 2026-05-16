import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../generated/assets.dart';

/// Extra helpers for [SvgGenImage] from `lib/generated/assets.dart`.
///
/// That file is auto-generated (iFlutter) and its `.svg()` helper does not
/// forward [ColorFilter] to [SvgPicture.asset]. Do not edit the generated file;
/// use [svgTint] here instead.
extension SvgGenImageX on SvgGenImage {
  SvgPicture svgTint({
    Key? key,
    Color? color,
    ColorFilter? colorFilter,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    Clip clipBehavior = Clip.hardEdge,
  }) {
    final filter = colorFilter ??
        (color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null);

    return SvgPicture.asset(
      path,
      key: key,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      clipBehavior: clipBehavior,
      colorFilter: filter,
    );
  }
}
