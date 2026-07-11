import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Bottom-inset-aware padding for sticky CTA bars and footers.
///
/// Uses [MediaQuery.viewPadding] (not [MediaQuery.padding]) so Android
/// edge-to-edge + 3-button navigation is respected even when `padding.bottom`
/// is incorrectly reported as 0.
///
/// Applies `max(minimum.bottom, systemInset)` — never the sum — so:
///
/// * devices with no bottom system UI render exactly [minimum];
/// * Android 3-button navigation grows just enough to clear the bar;
/// * iPhone home indicator is cleared without double padding.
///
/// When the keyboard is open, system inset is skipped (keyboard covers the
/// nav bar). Prefer placing this INSIDE the decorated container so the bar's
/// background can still extend behind the system navigation area when used
/// outside [AppSystemBottomInset].
///
/// ```dart
/// Container(
///   decoration: ...,
///   child: AppBottomSafeArea(
///     minimum: EdgeInsets.all(24.w),
///     child: button,
///   ),
/// )
/// ```
class AppBottomSafeArea extends StatelessWidget {
  const AppBottomSafeArea({
    super.key,
    this.minimum = EdgeInsets.zero,
    required this.child,
  });

  /// The bar's own visual padding; the bottom side is raised to the system
  /// inset when the inset is larger.
  final EdgeInsets minimum;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final keyboardOpen = mq.viewInsets.bottom > 0;
    final systemBottom = keyboardOpen ? 0.0 : mq.viewPadding.bottom;

    final resolved = EdgeInsets.only(
      left: minimum.left,
      top: minimum.top,
      right: minimum.right,
      bottom: math.max(minimum.bottom, systemBottom),
    );

    return Padding(
      padding: resolved,
      child: MediaQuery(
        data: mq.removePadding(
          removeLeft: resolved.left > 0,
          removeTop: resolved.top > 0,
          removeRight: resolved.right > 0,
          removeBottom: resolved.bottom > 0,
        ).removeViewPadding(
          removeBottom: systemBottom > 0,
        ),
        child: child,
      ),
    );
  }
}
