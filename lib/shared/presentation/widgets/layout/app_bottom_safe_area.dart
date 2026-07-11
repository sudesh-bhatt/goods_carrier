import 'package:flutter/material.dart';

/// Bottom-inset-aware padding for sticky CTA bars and footers.
///
/// Wraps [child] in a bottom-only [SafeArea] whose [minimum] padding is the
/// bar's visual padding. `SafeArea.minimum` applies `max(minimum, inset)`,
/// NOT their sum, so:
///
/// * devices with no bottom system UI (older iPhones, gesture-nav hidden)
///   render exactly [minimum] — pixel-identical to a plain `Padding`;
/// * Android 3-button navigation (~48dp opaque inset) grows the bottom
///   padding just enough to clear the bar;
/// * iPhone home indicator (34pt) is cleared without double padding.
///
/// No platform checks — the system inset from `MediaQuery.viewPadding`
/// is the single source of truth on both platforms.
///
/// Place this INSIDE the decorated container so the bar's background
/// extends behind the system navigation area:
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
    return SafeArea(
      top: false,
      left: false,
      right: false,
      minimum: minimum,
      child: child,
    );
  }
}
