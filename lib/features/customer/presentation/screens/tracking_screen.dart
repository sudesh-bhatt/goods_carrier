import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../shared/domain/enums/shipment_status.dart';
import '../../../../shared/presentation/widgets/feedback/error_view.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../../../../shared/presentation/widgets/status/status_chip.dart';
import '../providers/customer_shipments_provider.dart';

/// Shipment tracking screen.
///
/// Receives [shipmentId] from GoRouter path parameter `:id`.
/// Map area is a placeholder — real map integration (google_maps_flutter)
/// is deferred to Session 7 / Session 8.
/// Status timeline reflects the current [ShipmentStatus] progression.
class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({super.key, required this.shipmentId});

  final String shipmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors   = context.colors;
    final state    = ref.watch(customerShipmentsProvider);
    final shipment = state.shipments.where((s) => s.id == shipmentId).firstOrNull;

    if (shipment == null) {
      return const Scaffold(
        appBar: AppBarWidget(title: 'Tracking'),
        body: ErrorView(message: 'Shipment not found.'),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBarWidget(
        title: 'Track ${shipment.id}',
        actions: [
          AppBarAction(
            icon: Icons.share_outlined,
            onTap: () {}, // Share tracking link — wired in Session 7
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Map placeholder ─────────────────────────────────────────────
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              color: colors.cardBackground,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Grid lines (simulated map tiles)
                  CustomPaint(
                    size: Size.infinite,
                    painter: _MapGridPainter(color: colors.divider),
                  ),
                  // Pickup pin
                  Positioned(
                    top: 80.h,
                    left: 60.w,
                    child: _MapPin(
                      color: colors.primary,
                      icon: Icons.location_on_rounded,
                      label: shipment.pickup.city,
                    ),
                  ),
                  // Drop pin
                  Positioned(
                    bottom: 80.h,
                    right: 60.w,
                    child: _MapPin(
                      color: colors.textPrimary,
                      icon: Icons.flag_rounded,
                      label: shipment.drop.city,
                    ),
                  ),
                  // Truck icon (mid-route)
                  Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withOpacity(0.35),
                          blurRadius: 16,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.local_shipping_rounded,
                      color: colors.onPrimary,
                      size: AppDimensions.iconLg.w,
                    ),
                  ),
                  // Map attribution placeholder
                  Positioned(
                    bottom: AppDimensions.sm.h,
                    right: AppDimensions.sm.w,
                    child: Text(
                      'Map integration coming soon',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: colors.textHint,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Status panel ───────────────────────────────────────────────
          Expanded(
            flex: 4,
            child: Container(
              color: colors.surface,
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPadding.w,
                vertical: AppDimensions.xl.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Current Status',
                        style: context.textTheme.titleMedium?.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      StatusChip.shipment(
                        context: context,
                        status:  shipment.status,
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimensions.xl.h),
                  Expanded(
                    child: _StatusTimeline(currentStatus: shipment.status),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Status timeline ──────────────────────────────────────────────────────────

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.currentStatus});

  final ShipmentStatus currentStatus;

  static const _steps = [
    ShipmentStatus.pending,
    ShipmentStatus.interestReceived,
    ShipmentStatus.assigned,
    ShipmentStatus.inTransit,
    ShipmentStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    final colors       = context.colors;
    final currentIndex = _steps.indexOf(currentStatus);

    return ListView.builder(
      itemCount: _steps.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, i) {
        final step     = _steps[i];
        final isDone   = i <= currentIndex;
        final isActive = i == currentIndex;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline dot + connector
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    color: isDone ? colors.primary : colors.divider,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive ? colors.primary : Colors.transparent,
                      width: isActive ? 3 : 0,
                    ),
                  ),
                  child: isDone
                      ? Icon(Icons.check_rounded,
                            size: 12.w, color: colors.onPrimary)
                      : null,
                ),
                if (i < _steps.length - 1)
                  Container(
                    width: 2.w,
                    height: 32.h,
                    color: i < currentIndex ? colors.primary : colors.divider,
                  ),
              ],
            ),
            SizedBox(width: AppDimensions.sm.w),
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Text(
                step.label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: isDone ? colors.textPrimary : colors.textHint,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Map pin widget ───────────────────────────────────────────────────────────

class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color    color;
  final IconData icon;
  final String   label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, color: colors.onPrimary, size: 16.w),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.xs.w,
            vertical: 2.h,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: colors.onPrimary,
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Map grid painter ─────────────────────────────────────────────────────────

class _MapGridPainter extends CustomPainter {
  const _MapGridPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_MapGridPainter old) => old.color != color;
}
