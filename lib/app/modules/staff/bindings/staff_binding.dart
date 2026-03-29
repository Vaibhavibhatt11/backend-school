import 'package:erp_frontend/app/modules/staff/controllers/staff_communication_controller.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_dashboard_controller.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_profile_controller.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_reports_controller.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_shell_controller.dart';
import 'package:get/get.dart';

class StaffBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<StaffShellController>()) {
      Get.put(StaffShellController(), permanent: true);
    }
    if (!Get.isRegistered<StaffDashboardController>()) {
      Get.put(StaffDashboardController(), permanent: true);
    }
    if (!Get.isRegistered<StaffProfileController>()) {
      Get.put(StaffProfileController(), permanent: true);
    }
    if (!Get.isRegistered<StaffCommunicationController>()) {
      Get.put(StaffCommunicationController(), permanent: true);
    }
    if (!Get.isRegistered<StaffReportsController>()) {
      Get.put(StaffReportsController(), permanent: true);
    }
  }
}

