import 'package:flutter/material.dart';

import '../../../../../core/extensions/size_ext.dart';
import 'driver_trip_form_tokens.dart';

/// Figma route section header icon (`1:3634`) — two nodes on a path, 18×18.
class DriverRouteSectionIcon extends StatelessWidget {
  const DriverRouteSectionIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18.w,
      height: 18.w,
      child: CustomPaint(
        painter: _DriverRouteSectionIconPainter(),
      ),
    );
  }
}

class _DriverRouteSectionIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = DriverTripFormTokens.primary
      ..style = PaintingStyle.fill;

    const nodeRadius = 2.8;
    final top = Offset(size.width * 0.28, size.height * 0.22);
    final bottom = Offset(size.width * 0.72, size.height * 0.78);

    canvas.drawCircle(top, nodeRadius, paint);
    canvas.drawCircle(bottom, nodeRadius, paint);

    final stroke = Paint()
      ..color = DriverTripFormTokens.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(top.dx + nodeRadius * 0.4, top.dy + nodeRadius * 0.5)
      ..cubicTo(
        size.width * 0.42,
        size.height * 0.38,
        size.width * 0.58,
        size.height * 0.62,
        bottom.dx - nodeRadius * 0.4,
        bottom.dy - nodeRadius * 0.5,
      );
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
