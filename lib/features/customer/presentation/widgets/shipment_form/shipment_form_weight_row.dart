import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/extensions/size_ext.dart';
import 'shipment_form_card.dart';
import 'shipment_form_field.dart';

class ShipmentFormWeightRow extends StatelessWidget {
  const ShipmentFormWeightRow({
    super.key,
    required this.weightController,
    required this.weightUnit,
    required this.weightLabel,
    required this.unitLabel,
    required this.onUnitTap,
    this.weightValidator,
  });

  final TextEditingController weightController;
  final String weightUnit;
  final String weightLabel;
  final String unitLabel;
  final VoidCallback onUnitTap;
  final String? Function(String?)? weightValidator;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ShipmentFormCard(
            child: ShipmentFormSection(
              label: weightLabel,
              child: ShipmentFormInputRow(
                icon: Icons.scale_outlined,
                controller: weightController,
                height: 38.h,
                fieldRadius: 12,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                textAlign: TextAlign.center,
                validator: weightValidator,
              ),
            ),
          ),
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: ShipmentFormCard(
            child: ShipmentFormSection(
              label: unitLabel,
              child: ShipmentFormInputRow(
                icon: Icons.inventory_2_outlined,
                value: weightUnit,
                height: 38.h,
                fieldRadius: 12,
                readOnly: true,
                onTap: onUnitTap,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
