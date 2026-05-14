import 'package:flutter/material.dart';

@immutable
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  const AppColorScheme({
    required this.primary,
    required this.primaryDark,
    required this.background,
    required this.surface,
    required this.cardBackground,
    required this.inputFill,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.divider,
    required this.success,
    required this.warningBackground,
    required this.error,
    required this.orangeText,
    required this.brownText,
    required this.selectedText,
    required this.notificationUnread,
    required this.routeTimelineDot,
    required this.borderColor,
    required this.onPrimary,
    required this.languageTileBorderUnselected,
    required this.languageTileSelectedFill,
    required this.languageTileShadow,
    required this.ratingBannerGradientStart,
    required this.ratingBannerGradientEnd,
    required this.shadowCard,
  });

  final Color primary;
  final Color primaryDark;
  final Color background;
  final Color surface;
  final Color cardBackground;
  final Color inputFill;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color divider;
  final Color success;
  final Color warningBackground;
  final Color error;
  final Color orangeText;     // price, IDs
  final Color brownText;      // #594136 subtitle / secondary
  final Color selectedText;   // #582100 — text on selected/tinted items (light)
  final Color notificationUnread;
  final Color routeTimelineDot;
  final Color disableColor = const Color(0xFFABABAB);
  final Color borderColor;

  /// Text/icons on top of [primary] (CTAs, FAB, filled buttons).
  final Color onPrimary;

  /// Language-selection tile border (unselected), Figma #E2BFB0.
  final Color languageTileBorderUnselected;

  /// Language tile selected wash (~20% #FFB692 / orange tint in dark).
  final Color languageTileSelectedFill;

  /// Soft shadow under elevated tiles (e.g. language cards).
  final Color languageTileShadow;

  /// Driver profile “Gold Member” badge gradient.
  final Color ratingBannerGradientStart;
  final Color ratingBannerGradientEnd;

  /// Card/list elevation shadow tint (light = subtle black, dark = deeper).
  final Color shadowCard;

  // ─── LIGHT ─────────────────────────────────────────────────────
  static const light = AppColorScheme(
    primary: Color(0xFFFF6D00),
    primaryDark: Color(0xFF9F4200),
    background: Color(0xFFF5FAFF),
    surface: Color(0xFFFFFFFF),
    cardBackground: Color(0xFFFFFFFF),
    inputFill: Color(0xFFE8E8E8),
    textPrimary: Color(0xFF161C20),   // Figma: #161C20
    textSecondary: Color(0xFF6B6B6B),
    textHint: Color(0xFFAAAAAA),
    divider: Color(0xFFE8E8E8),
    success: Color(0xFF4CAF50),
    warningBackground: Color(0xFFFFF3E0),
    error: Color(0xFFD32F2F),
    orangeText: Color(0xFFFF6D00),
    brownText: Color(0xFF594136),
    selectedText: Color(0xFF582100),  // Figma: #582100 — selected tile name
    notificationUnread: Color(0xFFFFF8F3),
    routeTimelineDot: Color(0xFFFF6D00),
    borderColor: Color(0xFFE8E8E8),
    onPrimary: Color(0xFFFFFFFF),
    languageTileBorderUnselected: Color(0xFFE2BFB0),
    languageTileSelectedFill: Color(0x33FFB692),
    languageTileShadow: Color(0x0A000000),
    ratingBannerGradientStart: Color(0xFFFFB300),
    ratingBannerGradientEnd: Color(0xFFFF8F00),
    shadowCard: Color(0x12000000),
  );

  // ─── DARK ──────────────────────────────────────────────────────
  static const dark = AppColorScheme(
      primary: Color(0xFFFF6D00),
      primaryDark: Color(0xFFFF8C3A),
      background: Color(0xFF0F1117),
      surface: Color(0xFF1C1E26),
      cardBackground: Color(0xFF242630),
      inputFill: Color(0xFF2A2C38),
      textPrimary: Color(0xFFF2F2F2),
      textSecondary: Color(0xFFB0B0B0),
      textHint: Color(0xFF6B6B6B),
      divider: Color(0xFF2E2E2E),
      success: Color(0xFF66BB6A),
      warningBackground: Color(0xFF3D2800),
      error: Color(0xFFEF5350),
      orangeText: Color(0xFFFF8C3A),
      brownText: Color(0xFFD4A899),
      selectedText: Color(0xFFFFB692),  // dark mode: light peach on tinted bg
      notificationUnread: Color(0xFF2D1E00),
      routeTimelineDot: Color(0xFFFF8C3A),
      borderColor: Color(0xFF3A3D48),
      onPrimary: Color(0xFFFFFFFF),
      languageTileBorderUnselected: Color(0xFF5C4A42),
      languageTileSelectedFill: Color(0x40FF6D00),
      languageTileShadow: Color(0x40000000),
      ratingBannerGradientStart: Color(0xFFFFA726),
      ratingBannerGradientEnd: Color(0xFFFF9800),
      shadowCard: Color(0x66000000),
  );

  @override
  AppColorScheme copyWith({
    Color? primary,
    Color? primaryDark,
    Color? background,
    Color? surface,
    Color? cardBackground,
    Color? inputFill,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? divider,
    Color? success,
    Color? warningBackground,
    Color? error,
    Color? orangeText,
    Color? brownText,
    Color? selectedText,
    Color? notificationUnread,
    Color? routeTimelineDot,
    Color? borderColor,
    Color? onPrimary,
    Color? languageTileBorderUnselected,
    Color? languageTileSelectedFill,
    Color? languageTileShadow,
    Color? ratingBannerGradientStart,
    Color? ratingBannerGradientEnd,
    Color? shadowCard,
  }) =>
      AppColorScheme(
        primary: primary ?? this.primary,
        primaryDark: primaryDark ?? this.primaryDark,
        background: background ?? this.background,
        surface: surface ?? this.surface,
        cardBackground: cardBackground ?? this.cardBackground,
        inputFill: inputFill ?? this.inputFill,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        textHint: textHint ?? this.textHint,
        divider: divider ?? this.divider,
        success: success ?? this.success,
        warningBackground: warningBackground ?? this.warningBackground,
        error: error ?? this.error,
        orangeText: orangeText ?? this.orangeText,
        brownText: brownText ?? this.brownText,
        selectedText: selectedText ?? this.selectedText,
        notificationUnread: notificationUnread ?? this.notificationUnread,
        routeTimelineDot: routeTimelineDot ?? this.routeTimelineDot,
        borderColor: borderColor ?? this.borderColor,
        onPrimary: onPrimary ?? this.onPrimary,
        languageTileBorderUnselected:
            languageTileBorderUnselected ?? this.languageTileBorderUnselected,
        languageTileSelectedFill:
            languageTileSelectedFill ?? this.languageTileSelectedFill,
        languageTileShadow: languageTileShadow ?? this.languageTileShadow,
        ratingBannerGradientStart:
            ratingBannerGradientStart ?? this.ratingBannerGradientStart,
        ratingBannerGradientEnd:
            ratingBannerGradientEnd ?? this.ratingBannerGradientEnd,
        shadowCard: shadowCard ?? this.shadowCard,
      );

  @override
  AppColorScheme lerp(AppColorScheme? other, double t) {
    if (other is! AppColorScheme) return this;
    return AppColorScheme(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      success: Color.lerp(success, other.success, t)!,
      warningBackground:
          Color.lerp(warningBackground, other.warningBackground, t)!,
      error: Color.lerp(error, other.error, t)!,
      orangeText: Color.lerp(orangeText, other.orangeText, t)!,
      brownText: Color.lerp(brownText, other.brownText, t)!,
      selectedText: Color.lerp(selectedText, other.selectedText, t)!,
      notificationUnread:
          Color.lerp(notificationUnread, other.notificationUnread, t)!,
      routeTimelineDot:
          Color.lerp(routeTimelineDot, other.routeTimelineDot, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      languageTileBorderUnselected: Color.lerp(
        languageTileBorderUnselected,
        other.languageTileBorderUnselected,
        t,
      )!,
      languageTileSelectedFill: Color.lerp(
        languageTileSelectedFill,
        other.languageTileSelectedFill,
        t,
      )!,
      languageTileShadow:
          Color.lerp(languageTileShadow, other.languageTileShadow, t)!,
      ratingBannerGradientStart: Color.lerp(
        ratingBannerGradientStart,
        other.ratingBannerGradientStart,
        t,
      )!,
      ratingBannerGradientEnd: Color.lerp(
        ratingBannerGradientEnd,
        other.ratingBannerGradientEnd,
        t,
      )!,
      shadowCard: Color.lerp(shadowCard, other.shadowCard, t)!,
    );
  }
}

extension HexColor on Color {
  Color setOpacity(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0);
    return withAlpha((255.0 * opacity).round());
  }
}
