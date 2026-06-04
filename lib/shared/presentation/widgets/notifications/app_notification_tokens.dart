import 'package:flutter/material.dart';

import '../../../../res/font_res.dart';

/// Shared notification UI — Figma customer & driver (`1:4690` / `2013:3460`).
abstract final class AppNotificationTokens {
  static const background = Color(0xFFF5FAFF);
  static const cardUnread = Color(0xFFFFFFFF);
  static const cardPaymentRead = Color(0x66F3F4F5);
  static const cardBorder = Color(0x80E1E3E4);
  static const heading = Color(0xFF191C1D);
  static const body = Color(0xFF434655);
  static const timestamp = Color(0xFF737686);
  static const primary = Color(0xFFFF6D00);
  static const payment = Color(0xFF006C49);
  static const iconOrangeBg = Color(0x1AFF6D00);
  static const iconGreenBg = Color(0x1A006C49);
  static const headerBorder = Color(0x33E1E3E4);
  static const markAllReadIcon = Color(0xFF737686);

  static const cardShadow = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 2,
    offset: Offset(0, 1),
  );

  static const titleStyle = TextStyle(
    fontFamily: FontRes.MANROPE_BOLD,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 20 / 16,
    color: heading,
  );

  static const bodyStyle = TextStyle(
    fontFamily: FontRes.MANROPE_REGULAR,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 23 / 14,
    color: body,
  );

  static const timestampStyle = TextStyle(
    fontFamily: FontRes.MANROPE_SEMIBOLD,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 16 / 11,
    color: timestamp,
  );

  static const newBadgeStyle = TextStyle(
    fontFamily: FontRes.MANROPE_BOLD,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 15 / 10,
    color: primary,
  );
}
