import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../buttons/app_button.dart';

/// Full-page or inline empty state with illustration, headline, and sub-text.
///
/// [imagePath] should point to a PNG asset (e.g. `assets/images/illustration_empty_shipments.png`).
/// If null, a generic icon container is shown as fallback.
///
/// ```dart
/// EmptyState(
///   imagePath: 'assets/images/illustration_empty_shipments.png',
///   headline: context.l10n.emptyShipments,
///   subtitle: context.l10n.emptyShipmentsSubtitle,
///   actionLabel: context.l10n.shipmentPostNew,
///   onAction: () => context.push('/post-shipment'),
/// );
/// ```
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.headline,
    this.subtitle,
    this.imagePath,
    this.fallbackIcon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.imageHeight,
  });

  final String headline;
  final String? subtitle;

  /// Optional PNG asset path for the illustration.
  final String? imagePath;

  /// Shown when [imagePath] is null.
  final IconData fallbackIcon;

  final String? actionLabel;
  final VoidCallback? onAction;

  /// Override illustration height in logical pixels (before .h scaling).
  final double? imageHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final imgH = (imageHeight ?? 180).h;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.xxl.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration or fallback icon
            if (imagePath != null)
              Image.asset(
                imagePath!,
                height: imgH,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _FallbackIcon(
                  icon: fallbackIcon,
                  color: colors.textHint,
                ),
              )
            else
              _FallbackIcon(icon: fallbackIcon, color: colors.textHint),

            SizedBox(height: AppDimensions.xl.h),

            Text(
              headline,
              style: context.textTheme.titleMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),

            if (subtitle != null) ...[
              SizedBox(height: AppDimensions.xs.h),
              Text(
                subtitle!,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: AppDimensions.xl.h),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                isFullWidth: false,
                height: 48,
                borderRadius: AppDimensions.radiusFull,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  const _FallbackIcon({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: 100.w,
      decoration: BoxDecoration(
        color: context.colors.inputFill,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 48.w, color: color),
    );
  }
}
