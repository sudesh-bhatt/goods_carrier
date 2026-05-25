import 'package:flutter/material.dart';

import '../../../../../core/extensions/size_ext.dart';
import '../../../../../res/font_res.dart';
import 'saved_address_tokens.dart';

/// "SAVED LOCATIONS" + orange bar — Figma `1:3130`.
class SavedLocationsSectionHeader extends StatelessWidget {
  const SavedLocationsSectionHeader({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: FontRes.MANROPE_REGULAR,
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            height: 16 / 12,
            letterSpacing: 1.2,
            color: SavedAddressTokens.labelBrown,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 48.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: SavedAddressTokens.accentUnderline,
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
      ],
    );
  }
}
