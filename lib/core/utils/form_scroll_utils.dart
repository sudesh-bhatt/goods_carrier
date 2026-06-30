import 'package:flutter/material.dart';

/// Scrolls a [Scrollable] ancestor so a keyed field is visible after validation.
abstract final class FormScrollUtils {
  FormScrollUtils._();

  static Future<void> to(GlobalKey key) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final target = key.currentContext;
    if (target == null) return;
    await Scrollable.ensureVisible(
      target,
      alignment: 0.12,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }
}
