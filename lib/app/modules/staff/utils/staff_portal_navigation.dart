import 'package:erp_frontend/app/modules/staff/widgets/staff_ai_assistant_sheet.dart';
import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';

/// Opens the staff shell tab (or AI sheet) for a catalog module id.
class StaffPortalNavigation {
  StaffPortalNavigation._();

  static void openModule(String moduleId) {
    if (moduleId == 'ai_teaching_assistant') {
      StaffAiAssistantSheet.open();
      return;
    }

    var tab = 0;
    switch (moduleId) {
      case 'profile':
        tab = 1;
        break;
      case 'communication':
      case 'communication_ai':
        tab = 2;
        break;
      case 'reports':
        tab = 3;
        break;
      case 'settings':
        tab = 4;
        break;
      default:
        tab = 0;
    }

    Get.offNamed(AppRoutes.STAFF_HOME, arguments: {'tabIndex': tab});
  }
}
