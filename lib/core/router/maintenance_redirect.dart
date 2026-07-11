import 'app_routes.dart';

String? resolveMaintenanceRedirect({
  required bool isMaintenanceMode,
  required String location,
}) {
  if (!isMaintenanceMode) return null;
  if (location == AppRoutes.splash || location == AppRoutes.maintenance) {
    return null;
  }
  return AppRoutes.maintenance;
}
