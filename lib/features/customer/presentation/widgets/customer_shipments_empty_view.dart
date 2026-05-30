import 'package:flutter/material.dart';

import '../../../../shared/presentation/widgets/feedback/trip_empty_placeholder_view.dart';

/// Figma empty shipments — [node 1:3367](https://www.figma.com/design/YxnNResvDQnbkcPhGejtxa/Mobile-App-UI--Developer-?node-id=1-3367).
class CustomerShipmentsEmptyView extends StatelessWidget {
  const CustomerShipmentsEmptyView({
    super.key,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return TripEmptyPlaceholderView(
      title: title,
      description: description,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}
