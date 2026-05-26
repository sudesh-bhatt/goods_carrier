import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/extensions/size_ext.dart';
import 'support_center_tokens.dart';

/// Compact email / call row — tighter than Figma 160px cards for in-app balance.
class SupportChannelCard extends StatelessWidget {
  const SupportChannelCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.iconSize,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final double iconSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SupportCenterTokens.cardFill,
      borderRadius: BorderRadius.circular(16.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: iconSize, color: iconColor),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: SupportCenterTokens.channelTitle(),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: SupportCenterTokens.channelSubtitle(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
