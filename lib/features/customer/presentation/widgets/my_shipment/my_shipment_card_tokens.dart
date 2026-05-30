import 'package:flutter/material.dart';

/// My Shipment list card — Figma `1:2327` / `1:2328`.
abstract final class MyShipmentCardTokens {
  static const cardBg = Color(0xFFFFFFFF);
  static const labelBrown = Color(0xFF594136);
  static const bodyDark = Color(0xFF161C20);
  static const priceBrown = Color(0xFF9F4200);
  static const primaryOrange = Color(0xFFFF6D00);
  static const routeRing = Color(0xFF9F4200);
  static const actionSecondaryBg = Color(0xFFEFF4FA);
  static const deleteRed = Color(0xFFBA1A1A);
  static const metaDivider = Color.fromRGBO(226, 191, 176, 0.15);

  static const publishedBg = Color(0xFFDCFCE7);
  static const publishedFg = Color(0xFF15803D);
  static const expiredBg = Color(0xFFE0E0E0);
  static const expiredFg = Color(0xFF484848);
  static const draftBg = Color(0xFFFFDAD6);
  static const draftFg = Color(0xFF93000A);

  static const cardRadius = 24.0;
  static const actionRadius = 12.0;

  static const cardShadow = BoxShadow(
    color: Color.fromRGBO(22, 28, 32, 0.04),
    blurRadius: 40,
    offset: Offset(0, -10),
  );
}
