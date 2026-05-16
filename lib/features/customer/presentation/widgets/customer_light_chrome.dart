import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extensions/theme_ext.dart';

/// White status bar + surface chrome for customer main screens (Figma app bar).
class CustomerLightChrome extends StatelessWidget {
  const CustomerLightChrome({super.key, required this.child});

  final Widget child;

  static SystemUiOverlayStyle overlayFor(BuildContext context) {
    final surface = context.colors.surface;
    return SystemUiOverlayStyle(
      statusBarColor: surface,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayFor(context),
      child: child,
    );
  }
}
