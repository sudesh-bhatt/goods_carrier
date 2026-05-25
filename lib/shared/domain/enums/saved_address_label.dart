import 'package:flutter/material.dart';

/// Saved address label — Figma add address chips + list icons (`1:3201`, `1:3130`).
enum SavedAddressLabel {
  home,
  office,
  other;

  String get storageKey => name;

  static SavedAddressLabel fromKey(String? key) {
    return SavedAddressLabel.values.firstWhere(
      (e) => e.name == key,
      orElse: () => SavedAddressLabel.other,
    );
  }

  IconData get icon => switch (this) {
        SavedAddressLabel.home => Icons.home_outlined,
        SavedAddressLabel.office => Icons.work_outline_rounded,
        SavedAddressLabel.other => Icons.place_outlined,
      };

  /// List card icon — Figma `1:3130` (outlined house / briefcase / warehouse).
  IconData get listIcon => switch (this) {
        SavedAddressLabel.home => Icons.home_outlined,
        SavedAddressLabel.office => Icons.work_outline_rounded,
        SavedAddressLabel.other => Icons.warehouse_outlined,
      };

  /// Icon box size (width, height) per Figma export.
  (double width, double height) get listIconSize => switch (this) {
        SavedAddressLabel.home => (16, 18),
        SavedAddressLabel.office => (20, 19),
        SavedAddressLabel.other => (20, 18),
      };

  /// List card icon treatment — Figma saved addresses (`1:3130`).
  (Color bg, Color fg) get listIconColors => switch (this) {
        SavedAddressLabel.home => (
            const Color(0xFFFFDBCB),
            const Color(0xFF9F4200),
          ),
        SavedAddressLabel.office => (
            const Color(0xFFCFE5FF),
            const Color(0xFF00629E),
          ),
        SavedAddressLabel.other => (
            const Color(0xFFDDE3E9),
            const Color(0xFF595F64),
          ),
      };
}
