import 'package:flutter/material.dart';

/// Named text styles that supplement Flutter's [TextTheme].
///
/// Access via [BuildContext]:
/// ```dart
/// context.appTextStyles.screenTitle
/// context.appTextStyles.sectionHeading
/// ```
///
/// Every style is Manrope and colour-agnostic (no colour baked in) —
/// callers apply colour via [TextStyle.copyWith] or widget [DefaultTextStyle].
@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  const AppTextStyles({
    required this.screenTitle,
    required this.sectionHeading,
    required this.cardTitle,
    required this.label,
    required this.caption,
  });

  // ── ExtraBold (w800) ──────────────────────────────────────────────────────

  /// Manrope ExtraBold 30 sp — onboarding / screen hero titles (Figma spec).
  final TextStyle screenTitle;

  /// Manrope ExtraBold 24 sp — section / card-group headings.
  final TextStyle sectionHeading;

  // ── Bold (w700) ────────────────────────────────────────────────────────────

  /// Manrope Bold 16 sp — card / tile primary text.
  final TextStyle cardTitle;

  // ── SemiBold (w600) ───────────────────────────────────────────────────────

  /// Manrope SemiBold 14 sp — buttons, form labels.
  final TextStyle label;

  // ── Regular (w400) ────────────────────────────────────────────────────────

  /// Manrope Regular 12 sp — helper text, timestamps, chips.
  final TextStyle caption;

  // ── Factory ───────────────────────────────────────────────────────────────

  static const AppTextStyles defaults = AppTextStyles(
    screenTitle:    TextStyle(fontFamily: 'Manrope', fontSize: 30, fontWeight: FontWeight.w800, height: 1.2),
    sectionHeading: TextStyle(fontFamily: 'Manrope', fontSize: 24, fontWeight: FontWeight.w800, height: 1.25),
    cardTitle:      TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w700, height: 1.4),
    label:          TextStyle(fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
    caption:        TextStyle(fontFamily: 'Manrope', fontSize: 12, fontWeight: FontWeight.w400, height: 1.4),
  );

  // ── ThemeExtension overrides ──────────────────────────────────────────────

  @override
  AppTextStyles copyWith({
    TextStyle? screenTitle,
    TextStyle? sectionHeading,
    TextStyle? cardTitle,
    TextStyle? label,
    TextStyle? caption,
  }) {
    return AppTextStyles(
      screenTitle:    screenTitle    ?? this.screenTitle,
      sectionHeading: sectionHeading ?? this.sectionHeading,
      cardTitle:      cardTitle      ?? this.cardTitle,
      label:          label          ?? this.label,
      caption:        caption        ?? this.caption,
    );
  }

  @override
  AppTextStyles lerp(AppTextStyles? other, double t) {
    if (other == null) return this;
    return AppTextStyles(
      screenTitle:    TextStyle.lerp(screenTitle,    other.screenTitle,    t)!,
      sectionHeading: TextStyle.lerp(sectionHeading, other.sectionHeading, t)!,
      cardTitle:      TextStyle.lerp(cardTitle,      other.cardTitle,      t)!,
      label:          TextStyle.lerp(label,          other.label,          t)!,
      caption:        TextStyle.lerp(caption,        other.caption,        t)!,
    );
  }
}
