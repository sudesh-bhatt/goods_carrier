import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/extensions/size_ext.dart';
import '../../../../../res/font_res.dart';
import 'customer_settings_tokens.dart';

class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: FontRes.MANROPE_EXTRABOLD,
          fontSize: 12.sp,
          fontWeight: FontWeight.w800,
          height: 16 / 12,
          letterSpacing: -0.3,
          color: CustomerSettingsTokens.labelBrown,
        ),
      ),
    );
  }
}

class SettingsIconBox extends StatelessWidget {
  const SettingsIconBox({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: CustomerSettingsTokens.iconBg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 20.w,
        color: CustomerSettingsTokens.iconFg,
      ),
    );
  }
}

/// Figma orange pill toggle (44×24).
class SettingsFigmaSwitch extends StatelessWidget {
  const SettingsFigmaSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44.w,
        height: 24.h,
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: value
              ? CustomerSettingsTokens.primaryOrange
              : const Color(0xFFDDE3E9),
          borderRadius: BorderRadius.circular(9999),
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsToggleCard extends StatelessWidget {
  const SettingsToggleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: CustomerSettingsTokens.cardFill,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          SettingsIconBox(icon: icon),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_SEMIBOLD,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    height: 24 / 16,
                    color: CustomerSettingsTokens.bodyDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_REGULAR,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    height: 16 / 12,
                    color: CustomerSettingsTokens.labelBrown,
                  ),
                ),
              ],
            ),
          ),
          SettingsFigmaSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// Language row — Figma `1:3297` / dropdown `1:3319`.
class SettingsLanguageCard extends StatelessWidget {
  const SettingsLanguageCard({
    super.key,
    required this.title,
    required this.languageLabel,
    required this.onTap,
  });

  final String title;
  final String languageLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80.h,
      padding: EdgeInsets.fromLTRB(16.w, 16.w, 8.w, 16.w),
      decoration: BoxDecoration(
        color: CustomerSettingsTokens.cardFill,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SettingsIconBox(icon: Icons.translate_rounded),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: FontRes.MANROPE_SEMIBOLD,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                height: 24 / 16,
                color: CustomerSettingsTokens.bodyDark,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          _LanguageDropdownChip(
            label: languageLabel,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

/// Figma dropdown pill `1:3319` — 112×40, 10px label, chevron zone 44px.
class _LanguageDropdownChip extends StatelessWidget {
  const _LanguageDropdownChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  static const _labelStyle = TextStyle(
    fontFamily: FontRes.MANROPE_BOLD,
    fontWeight: FontWeight.w700,
    color: CustomerSettingsTokens.bodyDark,
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.r),
        child: Container(
          width: 112.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: CustomerSettingsTokens.dropdownBorder,
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.05),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _labelStyle.copyWith(
                      fontSize: 12.sp,
                      height: 1,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 44.w,
                child: Center(
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 24.w,
                    color: CustomerSettingsTokens.labelBrown,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsLegalCard extends StatelessWidget {
  const SettingsLegalCard({
    super.key,
    required this.items,
  });

  final List<SettingsLegalRow> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: CustomerSettingsTokens.cardFill,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: CustomerSettingsTokens.rowDivider,
              ),
            items[i],
          ],
        ],
      ),
    );
  }
}

class SettingsLegalRow extends StatelessWidget {
  const SettingsLegalRow({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(24.r),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_SEMIBOLD,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    height: 24 / 16,
                    color: CustomerSettingsTokens.bodyDark,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 16.w,
                color: CustomerSettingsTokens.labelBrown,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsVersionFooter extends StatelessWidget {
  const SettingsVersionFooter({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: FontRes.MANROPE_EXTRABOLD,
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
          height: 15 / 10,
          letterSpacing: 2,
          color: CustomerSettingsTokens.labelMuted,
        ),
      ),
    );
  }
}
