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
    required this.notificationUnread,
    required this.routeTimelineDot,
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
  final Color orangeText;           // price, IDs
  final Color brownText;            // #594136 secondary
  final Color notificationUnread;
  final Color routeTimelineDot;

  // ─── LIGHT ─────────────────────────────────────────────────────
  static const light = AppColorScheme(
    primary:            Color(0xFFFF6D00),
    primaryDark:        Color(0xFF9F4200),
    background:         Color(0xFFF5FAFF),
    surface:            Color(0xFFFFFFFF),
    cardBackground:     Color(0xFFFFFFFF),
    inputFill:          Color(0xFFF5F5F5),
    textPrimary:        Color(0xFF1A1A1A),
    textSecondary:      Color(0xFF6B6B6B),
    textHint:           Color(0xFFAAAAAA),
    divider:            Color(0xFFE8E8E8),
    success:            Color(0xFF4CAF50),
    warningBackground:  Color(0xFFFFF3E0),
    error:              Color(0xFFD32F2F),
    orangeText:         Color(0xFFFF6D00),
    brownText:          Color(0xFF594136),
    notificationUnread: Color(0xFFFFF8F3),
    routeTimelineDot:   Color(0xFFFF6D00),
  );

  // ─── DARK ──────────────────────────────────────────────────────
  static const dark = AppColorScheme(
    primary:            Color(0xFFFF6D00),
    primaryDark:        Color(0xFFFF8C3A),
    background:         Color(0xFF0F1117),
    surface:            Color(0xFF1C1E26),
    cardBackground:     Color(0xFF242630),
    inputFill:          Color(0xFF2A2C38),
    textPrimary:        Color(0xFFF2F2F2),
    textSecondary:      Color(0xFFB0B0B0),
    textHint:           Color(0xFF6B6B6B),
    divider:            Color(0xFF2E2E2E),
    success:            Color(0xFF66BB6A),
    warningBackground:  Color(0xFF3D2800),
    error:              Color(0xFFEF5350),
    orangeText:         Color(0xFFFF8C3A),
    brownText:          Color(0xFFD4A899),
    notificationUnread: Color(0xFF2D1E00),
    routeTimelineDot:   Color(0xFFFF8C3A),
  );

  @override
  AppColorScheme copyWith({
    Color? primary, Color? primaryDark, Color? background, Color? surface,
    Color? cardBackground, Color? inputFill, Color? textPrimary,
    Color? textSecondary, Color? textHint, Color? divider, Color? success,
    Color? warningBackground, Color? error, Color? orangeText, Color? brownText,
    Color? notificationUnread, Color? routeTimelineDot,
  }) => AppColorScheme(
    primary:            primary            ?? this.primary,
    primaryDark:        primaryDark        ?? this.primaryDark,
    background:         background         ?? this.background,
    surface:            surface            ?? this.surface,
    cardBackground:     cardBackground     ?? this.cardBackground,
    inputFill:          inputFill          ?? this.inputFill,
    textPrimary:        textPrimary        ?? this.textPrimary,
    textSecondary:      textSecondary      ?? this.textSecondary,
    textHint:           textHint           ?? this.textHint,
    divider:            divider            ?? this.divider,
    success:            success            ?? this.success,
    warningBackground:  warningBackground  ?? this.warningBackground,
    error:              error              ?? this.error,
    orangeText:         orangeText         ?? this.orangeText,
    brownText:          brownText          ?? this.brownText,
    notificationUnread: notificationUnread ?? this.notificationUnread,
    routeTimelineDot:   routeTimelineDot   ?? this.routeTimelineDot,
  );

  @override
  AppColorScheme lerp(AppColorScheme? other, double t) {
    if (other is! AppColorScheme) return this;
    return AppColorScheme(
      primary:            Color.lerp(primary,            other.primary,            t)!,
      primaryDark:        Color.lerp(primaryDark,        other.primaryDark,        t)!,
      background:         Color.lerp(background,         other.background,         t)!,
      surface:            Color.lerp(surface,            other.surface,            t)!,
      cardBackground:     Color.lerp(cardBackground,     other.cardBackground,     t)!,
      inputFill:          Color.lerp(inputFill,          other.inputFill,          t)!,
      textPrimary:        Color.lerp(textPrimary,        other.textPrimary,        t)!,
      textSecondary:      Color.lerp(textSecondary,      other.textSecondary,      t)!,
      textHint:           Color.lerp(textHint,           other.textHint,           t)!,
      divider:            Color.lerp(divider,            other.divider,            t)!,
      success:            Color.lerp(success,            other.success,            t)!,
      warningBackground:  Color.lerp(warningBackground,  other.warningBackground,  t)!,
      error:              Color.lerp(error,              other.error,              t)!,
      orangeText:         Color.lerp(orangeText,         other.orangeText,         t)!,
      brownText:          Color.lerp(brownText,          other.brownText,          t)!,
      notificationUnread: Color.lerp(notificationUnread, other.notificationUnread, t)!,
      routeTimelineDot:   Color.lerp(routeTimelineDot,   other.routeTimelineDot,   t)!,
    );
  }
}
