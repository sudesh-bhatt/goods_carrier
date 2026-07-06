import 'package:flutter/material.dart';

import '../../../../core/extensions/theme_ext.dart';
import '../../../../shared/presentation/widgets/feedback/trip_empty_placeholder_view.dart';

/// Driver My Trip empty state — Figma `1:3425`.
class DriverTripsEmptyView extends StatelessWidget {
  const DriverTripsEmptyView({
    super.key,
    required this.onPostTrip,
    this.scrollable = true,
    this.showActionIcon = false,
  });

  final VoidCallback onPostTrip;
  final bool scrollable;
  final bool showActionIcon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return TripEmptyPlaceholderView(
      title: l10n.driverEmptyTripsTitle,
      description: l10n.driverEmptyTripsDescription,
      actionLabel: l10n.tripPostNew,
      onAction: onPostTrip,
      showActionIcon: showActionIcon,
      scrollable: scrollable,
    );
  }
}
