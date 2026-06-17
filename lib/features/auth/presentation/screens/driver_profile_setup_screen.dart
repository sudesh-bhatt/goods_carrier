import 'package:flutter/material.dart';

import '../../../driver/presentation/screens/driver_profile_page.dart';

export '../../../driver/presentation/screens/driver_profile_page.dart'
    show DriverProfilePage;

/// Post-OTP driver profile setup — delegates to [DriverProfilePage].
class DriverProfileSetupScreen extends StatelessWidget {
  const DriverProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DriverProfilePage();
  }
}
