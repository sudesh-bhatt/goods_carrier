import 'package:flutter/material.dart';

import '../../../../../core/extensions/theme_ext.dart';
import '../../../../../shared/presentation/widgets/feedback/empty_state.dart';
import 'saved_address_tokens.dart';

/// Empty list placeholder for saved addresses screens.
class SavedAddressesEmptyPlaceholder extends StatelessWidget {
  const SavedAddressesEmptyPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return EmptyState(
      headline: l10n.customerSavedAddressesEmptyTitle,
      subtitle: l10n.customerSavedAddressesEmptySubtitle,
      fallbackIcon: Icons.location_off_outlined,
      fallbackIconColor: SavedAddressTokens.accentUnderline,
      imageHeight: 140,
    );
  }
}
