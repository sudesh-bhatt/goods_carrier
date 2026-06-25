import 'package:flutter/material.dart';

/// Figma subscription flow tokens — nodes `1:5227`, `1:5084`, `1:5178`.
abstract final class SubscriptionTokens {
  static const screenBg = Color(0xFFFFFFFF);
  static const paymentScreenBg = Color(0xFFF5FAFF);
  static const primaryOrange = Color(0xFFFF6D00);
  static const titleDark = Color(0xFF191C1D);
  static const headingDark = Color(0xFF161C20);
  static const bodyGrey = Color(0xFF434655);
  static const brownText = Color(0xFF594136);
  static const mutedBrown = Color(0xFF5F656A);
  static const secureBadgeBg = Color(0xFFFFDBCB);
  static const secureBadgeText = Color(0xFF7A3000);
  static const secondaryButtonBg = Color(0xFFE7E8E9);
  static const receiptCardBg = Color(0xFFEFF4FA);
  static const divider = Color(0xFFE2BFB0);
  static const successGreenStart = Color(0xFF22C55E);
  static const successGreenEnd = Color(0xFF4ADE80);
  static const failureRedStart = Color(0xFFEF4444);
  static const failureRedEnd = Color(0xFFF87171);
  static const upiIconBg = Color(0xFFCFE5FF);
  static const upiIcon = Color(0xFF004A78);
  static const cardIconBg = Color(0xFFDDE3E9);
  static const bankIconBg = Color(0xFFE3E9EE);
  static const walletIconBg = Color(0xFFFFDBCB);
  static const radioSelected = Color(0xFF9F4200);
  static const radioUnselected = Color(0xFFE2BFB0);

  static const planCardShadow = BoxShadow(
    color: Color.fromRGBO(255, 109, 0, 0.04),
    blurRadius: 32,
    offset: Offset(0, 12),
  );

  static const recommendedCardShadow = BoxShadow(
    color: Color.fromRGBO(255, 109, 0, 0.12),
    blurRadius: 48,
    offset: Offset(0, 20),
  );

  static const paymentOptionShadow = BoxShadow(
    color: Color.fromRGBO(22, 28, 32, 0.03),
    blurRadius: 40,
    offset: Offset(0, 20),
  );

  static const payButtonShadow = BoxShadow(
    color: Color.fromRGBO(255, 109, 0, 0.25),
    blurRadius: 24,
    offset: Offset(0, 8),
  );

  static const successIconShadow = BoxShadow(
    color: Color.fromRGBO(34, 197, 94, 0.2),
    blurRadius: 40,
    offset: Offset(0, 20),
  );
}
