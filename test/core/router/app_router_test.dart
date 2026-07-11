import 'package:flutter_test/flutter_test.dart';
import 'package:goods_carrier/core/router/app_routes.dart';
import 'package:goods_carrier/core/router/maintenance_redirect.dart';

void main() {
  test('maintenance mode redirects non-splash locations to maintenance', () {
    expect(
      resolveMaintenanceRedirect(
        isMaintenanceMode: true,
        location: AppRoutes.customerHome,
      ),
      AppRoutes.maintenance,
    );
  });

  test('maintenance mode allows splash and maintenance locations', () {
    expect(
      resolveMaintenanceRedirect(
        isMaintenanceMode: true,
        location: AppRoutes.splash,
      ),
      isNull,
    );

    expect(
      resolveMaintenanceRedirect(
        isMaintenanceMode: true,
        location: AppRoutes.maintenance,
      ),
      isNull,
    );
  });
}
