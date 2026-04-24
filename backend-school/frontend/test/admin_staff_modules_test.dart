import 'package:erp_frontend/app/modules/admin/models/admin_module_catalog.dart';
import 'package:erp_frontend/app/modules/admin/utils/admin_portal_navigation.dart';
import 'package:erp_frontend/app/modules/staff/models/staff_module_catalog.dart';
import 'package:erp_frontend/app/modules/staff/utils/staff_portal_navigation.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final registeredRoutes = AppPages.routes.map((route) => route.name).toSet();

  group('Admin ERP modules', () {
    test('visible modules expose registered screens', () {
      expect(kAdminModules, isNotEmpty);

      for (final module in kAdminModules) {
        final screens = AdminPortalNavigation.screensForModule(module.id);
        expect(
          screens,
          isNotEmpty,
          reason: '${module.title} should expose at least one screen.',
        );

        for (final screen in screens) {
          expect(
            registeredRoutes,
            contains(screen.route),
            reason: '${screen.title} route should be registered.',
          );
        }
      }
    });
  });

  group('Staff ERP modules', () {
    test('hidden modules are not visible', () {
      final ids = kStaffModules.map((module) => module.id).toSet();

      expect(ids, isNot(contains('payroll_hr')));
      expect(ids, isNot(contains('ai_teaching_assistant')));
    });

    test('visible modules expose registered screens or assistant actions', () {
      expect(kStaffModules, isNotEmpty);

      for (final module in kStaffModules) {
        final screens = StaffPortalNavigation.screensForModule(module.id);
        expect(
          screens,
          isNotEmpty,
          reason: '${module.title} should expose at least one screen.',
        );

        for (final screen in screens) {
          if (screen.route == null) {
            expect(
              screen.opensAssistant,
              isTrue,
              reason: '${screen.title} should either navigate or open a tool.',
            );
            continue;
          }

          expect(
            registeredRoutes,
            contains(screen.route),
            reason: '${screen.title} route should be registered.',
          );
        }
      }
    });
  });
}
