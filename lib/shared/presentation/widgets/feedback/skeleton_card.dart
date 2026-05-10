import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';

/// Shimmer loading placeholder that mimics the shape of [ShipmentCard] /
/// [DriverTripCard] while data is being fetched.
///
/// Built with [AnimationController] + [TweenSequence] — no external package.
///
/// ```dart
/// if (state.isLoading)
///   return ListView.separated(
///     itemCount: 4,
///     itemBuilder: (_, __) => const SkeletonCard(),
///     separatorBuilder: (_, __) => SizedBox(height: AppDimensions.md.h),
///   );
/// ```
class SkeletonCard extends StatefulWidget {
  const SkeletonCard({super.key, this.height});

  /// Override height in logical pixels; defaults to auto (~160).
  final double? height;

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _shimmer = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 0.7), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.7, end: 0.3), weight: 50),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, _) {
        final baseColor = colors.divider;
        final highlightColor = colors.surface;

        Color shimmerColor(double opacity) =>
            Color.lerp(baseColor, highlightColor, _shimmer.value * opacity)!;

        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg.r),
            boxShadow: context.cardShadow,
          ),
          padding: EdgeInsets.all(AppDimensions.base.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ID bar + status chip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Bar(width: 80.w, height: 14.h, color: shimmerColor(1)),
                  _Bar(width: 72.w, height: 22.h, color: shimmerColor(0.8),
                      radius: AppDimensions.radiusFull),
                ],
              ),

              SizedBox(height: AppDimensions.md.h),

              // Route line
              Row(
                children: [
                  Column(
                    children: [
                      _Circle(size: 10.w, color: shimmerColor(1)),
                      SizedBox(
                        height: 28.h,
                        child: _Bar(width: 2, height: double.infinity,
                            color: shimmerColor(0.6)),
                      ),
                      _Circle(size: 10.w, color: shimmerColor(0.8)),
                    ],
                  ),
                  SizedBox(width: AppDimensions.sm.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Bar(width: 100.w, height: 14.h, color: shimmerColor(1)),
                        SizedBox(height: 24.h),
                        _Bar(width: 120.w, height: 14.h, color: shimmerColor(0.8)),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppDimensions.md.h),

              // Meta row
              Row(
                children: [
                  _Bar(width: 70.w, height: 12.h, color: shimmerColor(0.7)),
                  SizedBox(width: AppDimensions.md.w),
                  _Bar(width: 50.w, height: 12.h, color: shimmerColor(0.7)),
                  SizedBox(width: AppDimensions.md.w),
                  _Bar(width: 60.w, height: 12.h, color: shimmerColor(0.7)),
                ],
              ),

              SizedBox(height: AppDimensions.md.h),
              Divider(color: colors.divider, thickness: 1, height: 1),
              SizedBox(height: AppDimensions.sm.h),

              // Price row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Bar(width: 90.w, height: 12.h, color: shimmerColor(0.7)),
                  _Bar(width: 60.w, height: 14.h, color: shimmerColor(1)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _Bar extends StatelessWidget {
  const _Bar({
    required this.width,
    required this.height,
    required this.color,
    this.radius = 4,
  });

  final double width;
  final double height;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
