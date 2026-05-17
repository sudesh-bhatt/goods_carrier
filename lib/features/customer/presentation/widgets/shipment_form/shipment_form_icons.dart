import 'package:flutter/material.dart';

import '../../../../../core/extensions/size_ext.dart';
import 'shipment_form_tokens.dart';

/// Figma-aligned leading icons for shipment form fields.
class ShipmentFormLocationIcon extends StatelessWidget {
  const ShipmentFormLocationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16.w,
      height: 20.h,
      child: Icon(
        Icons.location_on_outlined,
        size: 18.w,
        color: ShipmentFormTokens.primary,
      ),
    );
  }
}

/// TO field — Material navigation icon (same as filter sheet, no extra rotation).
class ShipmentFormNavigationIcon extends StatelessWidget {
  const ShipmentFormNavigationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18.w,
      height: 18.w,
      child: Icon(
        Icons.near_me_outlined,
        size: 18.w,
        color: ShipmentFormTokens.primary,
      ),
    );
  }
}
