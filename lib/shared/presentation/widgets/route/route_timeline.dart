import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';

/// Vertical dotted-line route widget: origin city → destination city.
///
/// Renders a filled orange circle at the top (pickup), a dotted connector line,
/// and a filled dark circle at the bottom (drop) — matching the Figma design.
///
/// ```dart
/// RouteTimeline(
///   fromCity: shipment.pickup.city,
///   toCity: shipment.drop.city,
/// )
/// ```
class RouteTimeline extends StatelessWidget {
  const RouteTimeline({
    super.key,
    required this.fromCity,
    required this.toCity,
    this.fromSubtitle,
    this.toSubtitle,
    this.dotSize = 10,
    this.lineHeight = 32,
    this.compact = false,
  });

  final String fromCity;
  final String toCity;

  /// Optional second line under city name (e.g. full address).
  final String? fromSubtitle;
  final String? toSubtitle;

  /// Diameter of the origin/dest dots in logical pixels (before .w scaling).
  final double dotSize;

  /// Height of the connector segment in logical pixels (before .h scaling).
  final double lineHeight;

  /// Compact mode reduces line height — use inside list cards.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveLineHeight = compact ? (lineHeight * 0.7).h : lineHeight.h;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Left: dots + line ───────────────────────────────────────────
          SizedBox(
            width: dotSize.w + AppDimensions.sm.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Origin dot — orange fill
                _Dot(size: dotSize.w, color: colors.routeTimelineDot),
                // Dotted connector
                SizedBox(
                  height: effectiveLineHeight,
                  child: _DottedLine(color: colors.routeTimelineDot.withOpacity(0.4)),
                ),
                // Destination dot — text primary fill
                _Dot(size: dotSize.w, color: colors.textPrimary),
              ],
            ),
          ),

          SizedBox(width: AppDimensions.sm.w),

          // ── Right: city labels ──────────────────────────────────────────
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // From
                _CityLabel(
                  city: fromCity,
                  subtitle: fromSubtitle,
                ),
                SizedBox(height: effectiveLineHeight),
                // To
                _CityLabel(
                  city: toCity,
                  subtitle: toSubtitle,
                  isDestination: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dot ──────────────────────────────────────────────────────────────────────

class _Dot extends StatelessWidget {
  const _Dot({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ─── Dotted line ──────────────────────────────────────────────────────────────

class _DottedLine extends StatelessWidget {
  const _DottedLine({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashHeight = 4.0;
        const dashGap = 3.0;
        const dashWidth = 1.5;
        final count = (constraints.maxHeight / (dashHeight + dashGap)).floor();

        return Column(
          children: List.generate(
            count,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: dashGap),
              child: Container(
                width: dashWidth,
                height: dashHeight,
                color: color,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── City label ───────────────────────────────────────────────────────────────

class _CityLabel extends StatelessWidget {
  const _CityLabel({
    required this.city,
    this.subtitle,
    this.isDestination = false,
  });

  final String city;
  final String? subtitle;
  final bool isDestination;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            city,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            SizedBox(height: 2.h),
            Text(
              subtitle!,
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
