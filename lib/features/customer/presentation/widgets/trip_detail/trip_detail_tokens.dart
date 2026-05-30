import 'package:flutter/material.dart';

/// Who is viewing a shared shipment trip detail screen.
enum TripDetailAudience { customer, driver }

/// Figma Trip Details screen (`1:2117`) and driver Shipment Details (`1:916`).
abstract final class TripDetailTokens {
  static const screenBg = Color(0xFFF5FAFF);
  static const cardBg = Color(0xFFEFF4FA);
  static const routeLabel = Color(0xFF594136);
  static const bodyDark = Color(0xFF161C20);
  static const scheduleLabel = Color(0xFF434655);
  static const primaryOrange = Color(0xFFFF6D00);
  static const routeRing = Color(0xFF9F4200);
  static const titleDark = Color(0xFF191C1D);
  static const subtitleGrey = Color(0xFF41484C);
  static const footerBorder = Color.fromRGBO(226, 191, 176, 0.1);
  static const menuBg = Color(0xFFEDEDED);
  static const menuText = Color(0xFF191C1D);

  static const cardRadius = 24.0;
  static const buttonRadius = 16.0;

  // Driver shipment details (`1:916`)
  static const summaryCardBg = Color(0xFFFFFFFF);
  static const estimatedPayBrown = Color(0xFF9F4200);
  static const fragileBannerBg = Color(0xFFFFDBCB);
  static const fragileBannerText = Color(0xFF7A3000);
  static const matchBadgeBlue = Color(0xFF00A0FC);
  static const dropPinOrange = Color(0xFFFF6D00);
  static const successDropBlue = Color(0xFF00629E);
  static const successFromGlow = Color(0xFFFFDBCB);
  static const successToGlow = Color(0xFFCFE5FF);
  static const successGreenStart = Color(0xFF22C55E);
  static const successGreenEnd = Color(0xFF4ADE80);
}
