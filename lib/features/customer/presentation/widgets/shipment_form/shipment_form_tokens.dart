import 'package:flutter/material.dart';

/// Figma Post / Edit Shipment tokens.
abstract final class ShipmentFormTokens {
  static const background = Color(0xFFF5FAFF);
  static const cardFill = Color(0xFFFFFFFF);
  static const fieldFill = Color(0xFFEFF4FA);
  /// Additional comments multiline field — Figma white fill on card.
  static const commentsFieldFill = Color(0xFFFFFFFF);
  static const label = Color(0xFF594136);
  static const heading = Color(0xFF161C20);
  static const title = Color(0xFF191C1D);
  static const fieldText = Color(0xFF6B7280);
  static const hint = Color(0xFF737686);
  static const hintMuted = Color(0x805F656A);
  /// Figma terms line — `#594136` at readable opacity (spec uses 30%, too faint on device).
  static const termsText = Color(0xA6594136);
  static const primary = Color(0xFFFF6D00);
  static const currencySuffix = Color(0xFFC3C6D7);
  static const connector = Color(0x4DC3C6D7);

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
