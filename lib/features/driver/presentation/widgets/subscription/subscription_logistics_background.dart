import 'package:flutter/material.dart';
import 'package:goods_carrier/generated/assets.dart';

import '../../../../../core/extensions/size_ext.dart';

/// Decorative right-side strip — Figma `Logistics Background` (`1:5231`).
///
/// Uses [Assets] (not [AssetsRes]) so iFlutter overwrites of `assets_res.dart`
/// cannot break this widget.
abstract final class SubscriptionLogisticsBackground {
  /// Figma: wrapper `opacity: 0.1`, image clipped with `border-radius: 0 0 0 9999px`.
  static Widget positioned({double opacity = 0.1}) {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      width: 195.w,
      child: IgnorePointer(
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(9999.r),
          ),
          child: Opacity(
            opacity: opacity,
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix(_greyscaleMatrix),
              child: Assets.subscriptionLogisticsBackground.image(
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                gaplessPlayback: true,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, __, ___) => Assets.loginScreenBanner.image(
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                  color: const Color(0xFF8A9BAA),
                  colorBlendMode: BlendMode.modulate,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Rec. 709 luma weights — matches Figma grey treatment on the photo fill.
  static const _greyscaleMatrix = <double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ];
}
