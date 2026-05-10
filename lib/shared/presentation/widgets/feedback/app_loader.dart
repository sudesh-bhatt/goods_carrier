import 'package:flutter/material.dart';

import '../../../../core/extensions/theme_ext.dart';

/// Centred [CircularProgressIndicator] using the design-system primary colour.
///
/// Drop into any screen while async data is loading:
/// ```dart
/// if (state.isLoading) return const AppLoader();
/// ```
class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.size = 28.0});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
        ),
      ),
    );
  }
}
