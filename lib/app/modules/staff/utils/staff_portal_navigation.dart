import 'package:erp_frontend/app/modules/staff/widgets/staff_ai_assistant_sheet.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/utils/safe_navigation.dart';

/// Opens the staff shell tab (or AI sheet) for a catalog module id.
class StaffPortalNavigation {
  StaffPortalNavigation._();

  static void openModule(
    String moduleId, {
    String? feature,
  }) {
    if (moduleId == 'ai_teaching_assistant') {
      StaffAiAssistantSheet.open();
      return;
    }

    switch (moduleId) {
      case 'dashboard':
        SafeNavigation.offNamed(AppRoutes.STAFF_HOME, arguments: {'tabIndex': 0});
        return;
      case 'profile':
        SafeNavigation.offNamed(AppRoutes.STAFF_HOME, arguments: {'tabIndex': 1});
        return;
      case 'communication':
      case 'communication_ai':
        SafeNavigation.offNamed(AppRoutes.STAFF_HOME, arguments: {'tabIndex': 2});
        return;
      case 'reports':
        SafeNavigation.offNamed(AppRoutes.STAFF_HOME, arguments: {'tabIndex': 3});
        return;
      case 'settings':
        SafeNavigation.offNamed(AppRoutes.STAFF_HOME, arguments: {'tabIndex': 4});
        return;
      case 'attendance_leave':
        SafeNavigation.toNamed(AppRoutes.TEACHER_ATTENDANCE_SELECTOR);
        return;
      case 'class_teaching':
      case 'performance':
        SafeNavigation.toNamed(AppRoutes.TEACHER_STUDENT_DIRECTORY);
        return;
      case 'lesson_planning':
      case 'homework_assignment':
      case 'study_material':
        SafeNavigation.toNamed(AppRoutes.TEACHER_UPLOAD);
        return;
      case 'events':
        SafeNavigation.toNamed(AppRoutes.TEACHER_ANNOUNCEMENTS);
        return;
      default:
        SafeNavigation.toNamed(
          AppRoutes.STAFF_FEATURE_DETAIL,
          arguments: {
            'module': moduleId.replaceAll('_', ' ').toUpperCase(),
            'feature': feature ?? 'Feature',
          },
        );
        return;
    }
  }
}
