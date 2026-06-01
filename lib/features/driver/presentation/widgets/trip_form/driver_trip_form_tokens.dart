import 'package:flutter/material.dart';

/// Figma driver publish / update trip (`1:3634`, `1:3799`).
abstract final class DriverTripFormTokens {
  static const background = Color(0xFFF5FAFF);
  static const cardFill = Color(0xFFFFFFFF);
  static const fieldFill = Color(0xFFF3F4F5);
  static const label = Color(0xFF434655);
  static const heading = Color(0xFF191C1D);
  static const hint = Color(0xFF737686);
  static const primary = Color(0xFFFF6D00);
  static const destinationIcon = Color(0xFF006C49);
  static const filledValue = Color(0xFF000000);

  static const cardShadow = BoxShadow(
    color: Color(0x0AFF6D00),
    blurRadius: 32,
    offset: Offset(0, 12),
  );

  static const ctaShadow = BoxShadow(
    color: Color(0x4DFF6D00),
    blurRadius: 24,
    offset: Offset(0, 8),
  );
}
