import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_color_scheme.dart';

/// A slim animated banner shown at the very top of the screen when the device
/// goes offline.  It slides in / out with an [AnimatedContainer] height tween
/// so the underlying content is pushed down — no overlay, no obscured pixels.
///
/// Wire it in [app.dart] inside the [MaterialApp.builder] callback:
///
/// ```dart
/// builder: (context, child) {
///   final isOnline = ref.watch(isOnlineProvider);
///   return ConnectivityBanner(isOnline: isOnline, child: content);
/// }
/// ```
///
/// The widget is intentionally a plain [StatelessWidget] — connectivity state
/// is owned by [isOnlineProvider] in [GoodsCarrierApp] and passed in, keeping
/// this widget trivially unit-testable.
class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({
    super.key,
    required this.isOnline,
    required this.child,
  });

  final bool   isOnline;
  final Widget child;

  // Banner height when visible.  28 logical pixels is legible on all DPI
  // classes and does not trigger a noticeable layout shift.
  static const double _bannerHeight = 28.0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorScheme>()!;

    return Column(
      children: [
        // ── Offline banner ──────────────────────────────────────────────────
        ClipRect(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve:    Curves.easeInOut,
            height:   isOnline ? 0.0 : _bannerHeight,
            color:    colors.error,
            alignment: Alignment.center,
            child: SizedBox(
              height: _bannerHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    size:  14.r,
                    color: Colors.white,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'No internet connection',
                    style: TextStyle(
                      color:      Colors.white,
                      fontSize:   11.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── App content ─────────────────────────────────────────────────────
        Expanded(child: child),
      ],
    );
  }
}
