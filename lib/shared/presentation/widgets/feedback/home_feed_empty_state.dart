import 'package:flutter/material.dart';

import '../../../../core/extensions/theme_ext.dart';
import 'trip_empty_placeholder_view.dart';

/// Empty state for home feed tabs — Figma warehouse illustration.
class HomeFeedEmptyState extends StatelessWidget {
  const HomeFeedEmptyState({
    super.key,
    required this.emptyTitle,
    required this.hasActiveFilters,
    required this.onClearFilters,
    this.scrollable = true,
  });

  final String emptyTitle;
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return TripEmptyPlaceholderView(
      title: hasActiveFilters
          ? l10n.customerHomeNoMatchingShipments
          : emptyTitle,
      description: l10n.customerHomeNoMatchingShipmentsHint,
      actionLabel: hasActiveFilters ? l10n.filterClearAll : null,
      onAction: hasActiveFilters ? onClearFilters : null,
      showActionIcon: false,
      scrollable: scrollable,
    );
  }
}
