import 'package:flutter/material.dart';

/// App-wide bottom system-inset guard for Android edge-to-edge.
///
/// Why this exists:
/// * With [SystemUiMode.edgeToEdge], content draws behind the system
///   navigation bar. Many screens never wrap a [SafeArea], so CTAs clip.
/// * [SafeArea] / [MediaQuery.padding] can report `bottom: 0` on some
///   Android 3-button devices even when a real inset exists.
///   [MediaQuery.viewPadding] is the reliable source of truth.
///
/// Behaviour:
/// * Pads the child by `viewPadding.bottom` when the keyboard is hidden.
/// * While the keyboard is visible, adds nothing — the keyboard covers the
///   nav bar and [Scaffold] already resizes for `viewInsets`.
/// * Removes the consumed bottom padding / viewPadding from the child
///   [MediaQuery] so nested [SafeArea]s do not double-pad.
/// * Paints [color] (or the scaffold background) into the inset strip so
///   the system nav area does not flash the raw window background.
///
/// Apply once in [MaterialApp.builder] — do not wrap individual screens.
class AppSystemBottomInset extends StatelessWidget {
  const AppSystemBottomInset({
    super.key,
    this.color,
    required this.child,
  });

  /// Fill color for the system-nav strip. Defaults to scaffold background.
  final Color? color;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final keyboardOpen = mq.viewInsets.bottom > 0;
    final bottom = keyboardOpen ? 0.0 : mq.viewPadding.bottom;

    if (bottom <= 0) return child;

    final fill = color ?? Theme.of(context).scaffoldBackgroundColor;

    return ColoredBox(
      color: fill,
      child: MediaQuery(
        data: mq
            .removePadding(removeBottom: true)
            .removeViewPadding(removeBottom: true),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: child,
        ),
      ),
    );
  }
}
