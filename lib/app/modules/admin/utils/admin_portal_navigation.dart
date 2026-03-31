import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/utils/safe_navigation.dart';

/// Maps catalog module / feature labels to existing admin screens.
class AdminPortalNavigation {
  AdminPortalNavigation._();

  static void openFromCatalog({
    required String moduleId,
    required String feature,
  }) {
    final m = moduleId.toLowerCase().trim();
    final f = feature.toLowerCase();

    bool has(String s) => m.contains(s) || f.contains(s);

    if (m == 'fees' || has('fee') && !has('feedback')) {
      SafeNavigation.offNamed(AppRoutes.ADMIN_FEE_SNAPSHOT);
      return;
    }
    if (m == 'attendance' || has('attendance') || has('leave')) {
      SafeNavigation.offNamed(AppRoutes.ADMIN_ATTENDANCE);
      return;
    }
    if (m == 'admissions' || has('admission') || has('approv') || has('waiting')) {
      SafeNavigation.offNamed(AppRoutes.ADMIN_APPROVALS, arguments: {'tabIndex': 1});
      return;
    }
    if (m == 'communication' ||
        m == 'events' ||
        has('announce') ||
        has('broadcast') ||
        has('notif') ||
        has('sms') ||
        has('whatsapp')) {
      SafeNavigation.offNamed(AppRoutes.ADMIN_NOTICE_BOARD, arguments: {'tabIndex': 3});
      return;
    }
    if (m == 'reports' || has('report') || has('analytic')) {
      SafeNavigation.offNamed(AppRoutes.ADMIN_REPORTS, arguments: {'tabIndex': 2});
      return;
    }
    if (m == 'security' || has('audit') || has('permission')) {
      SafeNavigation.offNamed(AppRoutes.ADMIN_AUDIT_LOGS);
      return;
    }
    if (m == 'settings' || has('setting') || has('privacy')) {
      SafeNavigation.offNamed(AppRoutes.ADMIN_SETTINGS, arguments: {'tabIndex': 4});
      return;
    }
    if (m == 'dashboard') {
      SafeNavigation.offNamed(AppRoutes.ADMIN_HOME, arguments: {'tabIndex': 0});
      return;
    }
    if (m == 'students' ||
        m == 'staff' ||
        m == 'academics' ||
        m == 'exams' ||
        m == 'timetable' ||
        m == 'library' ||
        m == 'transport' ||
        m == 'hostel' ||
        m == 'inventory' ||
        m == 'payroll') {
      SafeNavigation.offNamed(AppRoutes.ADMIN_REPORTS, arguments: {'tabIndex': 2});
      return;
    }

    SafeNavigation.offNamed(
      AppRoutes.ADMIN_FEATURE_DETAIL,
      arguments: {'moduleId': moduleId, 'feature': feature},
    );
  }
}
