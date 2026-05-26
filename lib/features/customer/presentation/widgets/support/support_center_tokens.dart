import 'package:flutter/material.dart';

import '../../../../../core/extensions/size_ext.dart';
import '../../../../../res/font_res.dart';

/// Figma Support Center (`1:3571`).
abstract final class SupportCenterTokens {
  static const screenBg = Color(0xFFF5FAFF);
  static const heading = Color(0xFF161C20);
  static const faqFill = Color(0xFFEFF4FA);
  static const cardFill = Color(0xFFFFFFFF);
  static const chevron = Color(0xFF9F4200);
  static const subtitle = Color(0xFF5F656A);
  static const emailIconBg = Color(0xFFFFB692);
  static const emailIconFg = Color(0xFF7A3000);
  static const callIconBg = Color(0xFFC1C7CD);
  static const callIconFg = Color(0xFF161C20);

  /// Section titles — 24px / 32px line / -0.6 tracking.
  static TextStyle sectionTitle() => TextStyle(
        fontFamily: FontRes.MANROPE_BOLD,
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        height: 32 / 24,
        letterSpacing: -0.6,
        color: heading,
      );

  /// FAQ question — 18px / 28px line (width-scaled to match Figma at 390).
  static TextStyle faqQuestion() => TextStyle(
        fontFamily: FontRes.MANROPE_BOLD,
        fontSize: 18.w,
        fontWeight: FontWeight.w700,
        height: 28 / 18,
        letterSpacing: 0,
        color: heading,
      );

  /// FAQ answer — 14px / 20px line, w600.
  static TextStyle faqAnswer() => TextStyle(
        fontFamily: FontRes.MANROPE_SEMIBOLD,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        color: subtitle,
      );

  /// Channel card title — compact 18px / 24px line.
  static TextStyle channelTitle() => TextStyle(
        fontFamily: FontRes.MANROPE_BOLD,
        fontSize: 18.w,
        fontWeight: FontWeight.w700,
        height: 24 / 18,
        color: heading,
      );

  /// Channel card subtitle — 14px / 20px line.
  static TextStyle channelSubtitle() => TextStyle(
        fontFamily: FontRes.MANROPE_SEMIBOLD,
        fontSize: 14.w,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        color: subtitle,
      );
}
