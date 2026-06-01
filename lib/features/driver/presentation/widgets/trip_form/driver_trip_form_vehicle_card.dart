import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/extensions/size_ext.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../res/font_res.dart';
import 'driver_trip_form_common.dart';
import 'driver_trip_form_tokens.dart';

/// Vehicle & capacity — single card, Figma `1:3634`.
class DriverTripFormVehicleCard extends StatelessWidget {
  const DriverTripFormVehicleCard({
    super.key,
    required this.sectionTitle,
    required this.vehicleCategoryLabel,
    required this.vehicleNumberLabel,
    required this.loadCapacityLabel,
    required this.weightTypeLabel,
    required this.priceLabel,
    required this.vehicleCategoryValue,
    required this.vehicleCategoryHint,
    required this.vehicleNumberController,
    required this.capacityController,
    required this.priceController,
    required this.weightUnit,
    required this.vehicleNumberHint,
    required this.onVehicleTap,
    required this.onWeightUnitTap,
    this.vehicleNumberValidator,
    this.capacityValidator,
    this.priceValidator,
  });

  final String sectionTitle;
  final String vehicleCategoryLabel;
  final String vehicleNumberLabel;
  final String loadCapacityLabel;
  final String weightTypeLabel;
  final String priceLabel;
  final String vehicleCategoryValue;
  final String vehicleCategoryHint;
  final TextEditingController vehicleNumberController;
  final TextEditingController capacityController;
  final TextEditingController priceController;
  final String weightUnit;
  final String vehicleNumberHint;
  final VoidCallback onVehicleTap;
  final VoidCallback onWeightUnitTap;
  final String? Function(String?)? vehicleNumberValidator;
  final String? Function(String?)? capacityValidator;
  final String? Function(String?)? priceValidator;

  @override
  Widget build(BuildContext context) {
    return DriverTripFormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DriverTripFormSectionHeader(
            title: sectionTitle,
            icon: Icons.local_shipping_outlined,
          ),
          SizedBox(height: 24.h),
          _LabeledField(
            label: vehicleCategoryLabel,
            child: DriverTripFormField(
              value: vehicleCategoryValue,
              hint: vehicleCategoryHint,
              readOnly: true,
              onTap: onVehicleTap,
              suffix: const DriverTripFormPickerSuffix(),
            ),
          ),
          SizedBox(height: 20.h),
          _LabeledField(
            label: vehicleNumberLabel,
            child: DriverTripFormField(
              controller: vehicleNumberController,
              hint: vehicleNumberHint,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 ]')),
              ],
              validator: vehicleNumberValidator ?? Validators.vehicleNumber,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LabeledField(
                  label: loadCapacityLabel,
                  child: DriverTripFormField(
                    controller: capacityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_SEMIBOLD,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: DriverTripFormTokens.heading,
                    ),
                    validator: capacityValidator,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _LabeledField(
                  label: weightTypeLabel,
                  child: DriverTripFormField(
                    value: weightUnit.toUpperCase(),
                    readOnly: true,
                    onTap: onWeightUnitTap,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_SEMIBOLD,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: DriverTripFormTokens.heading,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _LabeledField(
            label: priceLabel,
            child: DriverTripFormField(
              controller: priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              prefix: Text(
                '₹',
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_BOLD,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: DriverTripFormTokens.primary,
                ),
              ),
              validator: priceValidator,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DriverTripFormFieldLabel(text: label),
        SizedBox(height: 8.h),
        child,
      ],
    );
  }
}
