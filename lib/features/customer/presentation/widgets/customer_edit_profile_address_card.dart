import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../res/font_res.dart';

/// Default shipping address selector — Figma edit profile `1:1877`.
class CustomerEditProfileAddressCard extends StatelessWidget {
  const CustomerEditProfileAddressCard({
    super.key,
    required this.address,
    required this.placeholder,
    required this.onTap,
  });

  final String address;
  final String placeholder;
  final VoidCallback onTap;

  static const _kCardFill = Color(0xFFEFF4FA);
  static const _kTitle = Color(0xFF161C20);
  static const _kBody = Color(0xFF594136);
  static const _kChevron = Color(0x66594136);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final trimmed = address.trim();
    final isEmpty = trimmed.isEmpty;

    final parts = trimmed
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final title = isEmpty ? placeholder : parts.first;
    final lines = isEmpty ? <String>[] : (parts.length > 1 ? parts.sublist(1) : <String>[]);

    return Material(
      color: _kCardFill,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Icon(
                  Icons.location_on_rounded,
                  size: 20.w,
                  color: colors.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_BOLD,
                        fontSize: isEmpty ? 14.sp : 14.sp,
                        fontWeight: FontWeight.w700,
                        height: 20 / 14,
                        color: isEmpty ? colors.textHint : _kTitle,
                      ),
                    ),
                    if (lines.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        lines.join('\n'),
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_REGULAR,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          height: 20 / 12,
                          color: _kBody,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 12.w,
                  color: _kChevron,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
