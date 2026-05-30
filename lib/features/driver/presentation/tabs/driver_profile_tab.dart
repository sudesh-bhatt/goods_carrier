import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/driver_profile_screen.dart';

/// Driver profile tab body — reuses profile content without duplicate app bar.
class DriverProfileTab extends ConsumerWidget {
  const DriverProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DriverProfileScreen(embedded: true);
  }
}
