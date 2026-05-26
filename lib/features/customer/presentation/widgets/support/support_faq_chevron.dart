import 'package:flutter/material.dart';

import '../../../../../core/extensions/size_ext.dart';
import 'support_center_tokens.dart';

/// Figma FAQ chevron — 12×7.4px (width-scaled), stroke `#9F4200` (`1:3571`).
class SupportFaqChevron extends StatelessWidget {
  const SupportFaqChevron({
    super.key,
    required this.expanded,
  });

  final bool expanded;

  /// Figma icon box — scale from width only so w/h ratio stays 12:7.4.
  static const double _figmaWidth = 12;
  static const double _figmaHeight = 7.4;
  static const double _figmaStroke = 1.8;

  @override
  Widget build(BuildContext context) {
    final width = 12.w;
    final height = width * (_figmaHeight / _figmaWidth);

    return AnimatedRotation(
      turns: expanded ? 0.5 : 0,
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          size: Size(width, height),
          painter: _ChevronPainter(
            color: SupportCenterTokens.chevron,
            strokeWidth: _figmaStroke.w,
          ),
        ),
      ),
    );
  }
}

/// Down-pointing chevron (V shape), not a filled triangle.
class _ChevronPainter extends CustomPainter {
  _ChevronPainter({
    required this.color,
    required this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final inset = strokeWidth / 2;
    final path = Path()
      ..moveTo(inset, inset)
      ..lineTo(size.width / 2, size.height - inset)
      ..lineTo(size.width - inset, inset);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChevronPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
