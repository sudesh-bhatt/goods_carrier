import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/extensions/size_ext.dart';
import '../../../../../core/services/google_places_service.dart';
import '../../../../../generated/assets.dart';
import '../../../../customer/presentation/widgets/shipment_form/shipment_form_places_autocomplete.dart';

import 'driver_trip_form_common.dart';
import 'driver_trip_form_tokens.dart';

/// Route section — Figma publish trip `1:3634`.
class DriverTripFormRouteCard extends StatelessWidget {
  const DriverTripFormRouteCard({
    super.key,
    required this.fromController,
    required this.toController,
    required this.fromLabel,
    required this.toLabel,
    required this.fromHint,
    required this.toHint,
    required this.sectionTitle,
    required this.onFromPlaceSelected,
    required this.onToPlaceSelected,
    this.fromValidator,
    this.toValidator,
  });

  final TextEditingController fromController;
  final TextEditingController toController;
  final String fromLabel;
  final String toLabel;
  final String fromHint;
  final String toHint;
  final String sectionTitle;
  final ValueChanged<PlaceAddressDetails> onFromPlaceSelected;
  final ValueChanged<PlaceAddressDetails> onToPlaceSelected;
  final String? Function(String?)? fromValidator;
  final String? Function(String?)? toValidator;

  @override
  Widget build(BuildContext context) {
    return DriverTripFormCard(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DriverTripFormSectionHeader(
            title: sectionTitle,
            leading: SvgPicture.asset(Assets.icRouteInfo.path),
          ),
          SizedBox(height: 24.h),
          _RouteStopRow(
            label: fromLabel,
            icon: Icons.location_on,
            iconSize: 16.67,
            iconColor: DriverTripFormTokens.primary,
            iconHalo: DriverTripFormTokens.primary.withValues(alpha: 0.05),
            controller: fromController,
            hint: fromHint,
            onPlaceSelected: onFromPlaceSelected,
            validator: fromValidator,
          ),
          Padding(
            padding: EdgeInsets.only(left: 19.w),
            child: SizedBox(
              width: 2.w,
              height: 24.h,
              child: CustomPaint(
                painter: _DashedConnectorPainter(),
              ),
            ),
          ),
          _RouteStopRow(
            label: toLabel,
            icon: Icons.map,
            iconSize: 15,
            iconColor: DriverTripFormTokens.destinationIcon,
            iconHalo: DriverTripFormTokens.destinationIcon.withValues(alpha: 0.05),
            controller: toController,
            hint: toHint,
            onPlaceSelected: onToPlaceSelected,
            validator: toValidator,
          ),
        ],
      ),
    );
  }
}

class _RouteStopRow extends StatelessWidget {
  const _RouteStopRow({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.iconHalo,
    this.iconSize = 16,
    required this.controller,
    required this.hint,
    required this.onPlaceSelected,
    this.validator,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconHalo;
  final double iconSize;
  final TextEditingController controller;
  final String hint;
  final ValueChanged<PlaceAddressDetails> onPlaceSelected;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IconCircle(
          icon: icon,
          color: iconColor,
          halo: iconHalo,
          size: iconSize,
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DriverTripFormFieldLabel(text: label),
              SizedBox(height: 8.h),
              ShipmentFormPlacesAutocomplete(
                leading: const SizedBox.shrink(),
                externalLeading: true,
                fieldFillColor: DriverTripFormTokens.fieldFill,
                fieldHintColor: DriverTripFormTokens.hint,
                fieldTextColor: DriverTripFormTokens.heading,
                fieldHeight: 44.h,
                fieldRadius: 8.r,
                controller: controller,
                hint: hint,
                onPlaceSelected: onPlaceSelected,
                validator: validator,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({
    required this.icon,
    required this.color,
    required this.halo,
    this.size = 16,
  });

  final IconData icon;
  final Color color;
  final Color halo;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: halo,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: size.w, color: color),
    );
  }
}

class _DashedConnectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = DriverTripFormTokens.primary.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashHeight = 4.0;
    const gap = 4.0;
    var y = 0.0;
    while (y < size.height) {
      final end = (y + dashHeight).clamp(0.0, size.height);
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, end),
        paint,
      );
      y += dashHeight + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
