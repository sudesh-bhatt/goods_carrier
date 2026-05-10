import 'package:flutter/material.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../shared/domain/enums/shipment_status.dart';
import '../../../../shared/domain/enums/trip_status.dart';

/// Colour-coded pill chip for [ShipmentStatus] or [TripStatus].
///
/// Usage:
/// ```dart
/// StatusChip.shipment(status: shipment.status)
/// StatusChip.trip(status: trip.status)
/// ```
class StatusChip extends StatelessWidget {
  const StatusChip._({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  /// Factory for [ShipmentStatus].
  factory StatusChip.shipment({
    required BuildContext context,
    required ShipmentStatus status,
  }) {
    final (bg, fg) = _shipmentColors(context, status);
    return StatusChip._(
      label: status.label,
      backgroundColor: bg,
      foregroundColor: fg,
    );
  }

  /// Factory for [TripStatus].
  factory StatusChip.trip({
    required BuildContext context,
    required TripStatus status,
  }) {
    final (bg, fg) = _tripColors(context, status);
    return StatusChip._(
      label: status.label,
      backgroundColor: bg,
      foregroundColor: fg,
    );
  }

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ─── Colour maps ──────────────────────────────────────────────────────────────

(Color bg, Color fg) _shipmentColors(BuildContext ctx, ShipmentStatus s) {
  final colors = ctx.colors;
  return switch (s) {
    ShipmentStatus.pending          => (const Color(0xFFFFF8E1), const Color(0xFFF57F17)),
    ShipmentStatus.interestReceived => (const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
    ShipmentStatus.assigned         => (colors.primary.withOpacity(0.12), colors.primaryDark),
    ShipmentStatus.inTransit        => (const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
    ShipmentStatus.delivered        => (colors.success.withOpacity(0.15), colors.success),
    ShipmentStatus.cancelled        => (colors.error.withOpacity(0.10), colors.error),
  };
}

(Color bg, Color fg) _tripColors(BuildContext ctx, TripStatus s) {
  final colors = ctx.colors;
  return switch (s) {
    TripStatus.active              => (colors.primary.withOpacity(0.12), colors.primaryDark),
    TripStatus.pendingConfirmation => (const Color(0xFFFFF8E1), const Color(0xFFF57F17)),
    TripStatus.confirmed           => (const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
    TripStatus.completed           => (colors.success.withOpacity(0.15), colors.success),
    TripStatus.cancelled           => (colors.error.withOpacity(0.10), colors.error),
  };
}
