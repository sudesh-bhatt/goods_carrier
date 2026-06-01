import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';

import '../../../../../core/extensions/size_ext.dart';
import '../../../../customer/presentation/widgets/shipment_form/shipment_form_phone_row.dart';
import 'driver_trip_form_common.dart';
import 'driver_trip_form_tokens.dart';

/// Driver name + phone — Figma `1:3634`.
class DriverTripFormDriverCard extends StatelessWidget {
  const DriverTripFormDriverCard({
    super.key,
    required this.sectionTitle,
    required this.nameLabel,
    required this.phoneLabel,
    required this.nameController,
    required this.phoneController,
    required this.nameHint,
    required this.phoneHint,
    required this.dialCode,
    required this.onDialCodeChanged,
    this.nameValidator,
    this.phoneValidator,
  });

  final String sectionTitle;
  final String nameLabel;
  final String phoneLabel;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final String nameHint;
  final String phoneHint;
  final String dialCode;
  final ValueChanged<CountryCode> onDialCodeChanged;
  final String? Function(String?)? nameValidator;
  final String? Function(String?)? phoneValidator;

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
            label: nameLabel,
            child: DriverTripFormField(
              controller: nameController,
              hint: nameHint,
              validator: nameValidator,
            ),
          ),
          SizedBox(height: 20.h),
          _LabeledField(
            label: phoneLabel,
            child: ShipmentFormPhoneRow(
              controller: phoneController,
              dialCode: dialCode,
              onDialCodeChanged: onDialCodeChanged,
              hint: phoneHint,
              validator: phoneValidator,
              height: 44.h,
              fieldFillColor: DriverTripFormTokens.fieldFill,
              fieldHintColor: DriverTripFormTokens.hint,
              fieldTextColor: DriverTripFormTokens.heading,
              dividerColor:
                  DriverTripFormTokens.hint.withValues(alpha: 0.35),
              fieldRadius: 8.r,
              showLeadingIcon: false,
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
