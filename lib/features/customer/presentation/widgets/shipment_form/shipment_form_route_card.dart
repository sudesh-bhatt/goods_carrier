import 'package:flutter/material.dart';

import '../../../../../core/extensions/size_ext.dart';
import '../../../../../res/font_res.dart';
import 'shipment_form_card.dart';
import 'shipment_form_field.dart';
import 'shipment_form_icons.dart';
import 'shipment_form_tokens.dart';

class ShipmentFormRouteCard extends StatelessWidget {
  const ShipmentFormRouteCard({
    super.key,
    required this.fromController,
    required this.toController,
    required this.fromHint,
    required this.toHint,
    this.fromValidator,
    this.toValidator,
  });

  final TextEditingController fromController;
  final TextEditingController toController;
  final String fromHint;
  final String toHint;
  final String? Function(String?)? fromValidator;
  final String? Function(String?)? toValidator;

  @override
  Widget build(BuildContext context) {
    return ShipmentFormCard(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShipmentFormFieldLabel(text: 'From'),
          SizedBox(height: 8.h),
          ShipmentFormInputRow(
            leading: const ShipmentFormLocationIcon(),
            controller: fromController,
            hint: fromHint,
            validator: fromValidator,
          ),
          Padding(
            padding: EdgeInsets.only(left: 30.w, top: 1.h, bottom: 1.h),
            child: Container(
              width: 1,
              height: 24.h,
              color: ShipmentFormTokens.connector,
            ),
          ),
          const ShipmentFormFieldLabel(text: 'To'),
          SizedBox(height: 8.h),
          ShipmentFormInputRow(
            leading: const ShipmentFormNavigationIcon(),
            controller: toController,
            hint: toHint,
            validator: toValidator,
          ),
        ],
      ),
    );
  }
}

class ShipmentFormReadOnlyIdCard extends StatelessWidget {
  const ShipmentFormReadOnlyIdCard({super.key, required this.shipmentId});

  final String shipmentId;

  @override
  Widget build(BuildContext context) {
    return ShipmentFormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SHIPMENT ID',
            style: TextStyle(
              fontFamily: FontRes.MANROPE_BOLD,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: ShipmentFormTokens.label,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            height: 54.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: ShipmentFormTokens.fieldFill,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              shipmentId,
              style: TextStyle(
                fontFamily: FontRes.MANROPE_MEDIUM,
                fontSize: 16.sp,
                color: ShipmentFormTokens.fieldText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
