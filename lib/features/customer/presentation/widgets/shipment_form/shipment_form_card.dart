import 'package:flutter/material.dart';

import '../../../../../core/extensions/size_ext.dart';
import 'shipment_form_tokens.dart';

class ShipmentFormCard extends StatelessWidget {
  const ShipmentFormCard({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: ShipmentFormTokens.cardFill,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: const [ShipmentFormTokens.cardShadow],
      ),
      child: child,
    );
  }
}
