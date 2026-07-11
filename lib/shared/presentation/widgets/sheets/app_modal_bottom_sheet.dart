import 'package:flutter/material.dart';

/// Presents modal bottom sheets above the full screen (including bottom nav).
///
/// Uses [useRootNavigator] so sheets opened from the customer shell block
/// the app bar, FAB, and bottom navigation until dismissed.
class AppModalBottomSheet {
  AppModalBottomSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = true,
    bool showDragHandle = false,
    Color? backgroundColor,
    Color? barrierColor,
    ShapeBorder? shape,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: isScrollControlled,
      // Sheet shells ([AppBottomSheetContainer], etc.) own bottom inset via
      // viewPadding. Flutter's default SafeArea uses padding (unreliable on
      // Android edge-to-edge) and would also inset the top awkwardly.
      useSafeArea: false,
      showDragHandle: showDragHandle,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor ?? Colors.transparent,
      barrierColor: barrierColor,
      shape: shape,
      builder: builder,
    );
  }
}
