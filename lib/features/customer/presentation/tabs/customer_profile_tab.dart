import 'package:flutter/material.dart';

import '../../../../shared/presentation/profile/app_profile_tab.dart';

export '../../../../shared/presentation/profile/app_profile_tab.dart'
    show AppProfileTab;

/// Customer profile tab — shared [AppProfileTab] (role-based menu from auth).
class CustomerProfileTab extends StatelessWidget {
  const CustomerProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppProfileTab();
  }
}
