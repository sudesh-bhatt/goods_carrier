/// Main shell tabs — same order for customer and driver branch indices.
enum AppMainTab {
  home,
  listings,
  notifications,
  profile,
}

extension AppMainTabIndex on AppMainTab {
  static AppMainTab fromIndex(int index) => AppMainTab.values[index];
}
