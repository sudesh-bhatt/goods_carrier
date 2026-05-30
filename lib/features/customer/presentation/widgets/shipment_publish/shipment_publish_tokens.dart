import 'package:flutter/material.dart';

/// Shipment Details (Publish) — Figma `1:2540`.
abstract final class ShipmentPublishTokens {
  static const screenBg = Color(0xFFF5FAFF);
  static const cardWhite = Color(0xFFFFFFFF);
  static const cardDriver = Color(0xFFEFF4FA);
  static const paymentCard = Color(0xFFE9EEF4);
  static const paymentHeader = Color.fromRGBO(221, 227, 233, 0.3);
  static const labelBrown = Color(0xFF594136);
  static const bodyDark = Color(0xFF161C20);
  static const subtitleGrey = Color(0xFF41484C);
  static const priceBrown = Color(0xFF9F4200);
  static const routeRing = Color(0xFF9F4200);
  static const routeLine = Color(0xFFDDE3E9);
  static const ringGlow = Color(0xFFFFDBCB);
  static const publishBg = Color(0xFFDCFCE7);
  static const publishFg = Color(0xFF15803D);
  static const dividerTan = Color.fromRGBO(226, 191, 176, 0.2);
  static const dashedBorder = Color(0xFFE9EEF4);

  static const cardRadius = 24.0;
  static const actionRadius = 12.0;

  static const routeCardShadow = BoxShadow(
    color: Color.fromRGBO(22, 28, 32, 0.04),
    blurRadius: 40,
    offset: Offset(0, 20),
  );
}
