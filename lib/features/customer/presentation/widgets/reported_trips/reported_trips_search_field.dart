import 'package:flutter/material.dart';

import '../../../../../core/extensions/size_ext.dart';
import '../../../../../res/font_res.dart';
import 'reported_trips_tokens.dart';

/// Hero search — Figma `1:6391`.
class ReportedTripsSearchField extends StatelessWidget {
  const ReportedTripsSearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.5.r),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        style: TextStyle(
          fontFamily: FontRes.MANROPE_MEDIUM,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          height: 15 / 12,
          color: ReportedTripsTokens.bodyDark,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: FontRes.MANROPE_MEDIUM,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            height: 15 / 12,
            color: ReportedTripsTokens.hintGrey,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.5.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.5.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.5.r),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 20.w, right: 12.w),
            child: Icon(
              Icons.search_rounded,
              size: 19.w,
              color: ReportedTripsTokens.searchIcon,
            ),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 52.w),
          contentPadding: EdgeInsets.fromLTRB(0, 18.h, 17.w, 18.h),
          isDense: true,
        ),
      ),
    );
  }
}
