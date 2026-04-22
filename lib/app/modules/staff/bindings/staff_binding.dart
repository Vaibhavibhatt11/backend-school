import 'package:erp_frontend/app/modules/staff/controllers/staff_communication_controller.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_attendance_leave_controller.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_class_teaching_controller.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_dashboard_controller.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_lesson_planning_controller.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_homework_assignment_controller.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_exam_assessment_controller.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_performance_monitoring_controller.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_profile_controller.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_reports_controller.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_settings_controller.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_study_material_controller.dart';
import 'package:erp_frontend/common/services/admin/admin_service.dart';
import 'package:erp_frontend/app/modules/staff/controllers/staff_shell_controller.dart';
import 'package:erp_frontend/common/services/staff/staff_service.dart';
import 'package:get/get.dart';

class StaffBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<StaffShellController>()) {
      Get.put(StaffShellController(), permanent: true);
    }
    if (!Get.isRegistered<StaffDashboardController>()) {
      Get.put(StaffDashboardController(Get.find<StaffService>()), permanent: true);
    }
    if (!Get.isRegistered<StaffProfileController>()) {
      Get.put(StaffProfileController(Get.find<StaffService>()), permanent: true);
    }
    if (!Get.isRegistered<StaffCommunicationController>()) {
      Get.put(
        StaffCommunicationController(
          Get.find<StaffService>(),
          Get.find<AdminService>(),
        ),
        permanent: true,
      );
    }
    if (!Get.isRegistered<StaffReportsController>()) {
      Get.put(StaffReportsController(Get.find<StaffService>()), permanent: true);
    }
    if (!Get.isRegistered<StaffSettingsController>()) {
      Get.put(StaffSettingsController(Get.find<StaffService>()), permanent: true);
    }
    if (!Get.isRegistered<StaffAttendanceLeaveController>()) {
      Get.put(StaffAttendanceLeaveController(), permanent: true);
    }
    if (!Get.isRegistered<StaffClassTeachingController>()) {
      Get.put(StaffClassTeachingController(), permanent: true);
    }
    if (!Get.isRegistered<StaffLessonPlanningController>()) {
      Get.put(StaffLessonPlanningController(), permanent: true);
    }
    if (!Get.isRegistered<StaffHomeworkAssignmentController>()) {
      Get.put(StaffHomeworkAssignmentController(), permanent: true);
    }
    if (!Get.isRegistered<StaffExamAssessmentController>()) {
      Get.put(StaffExamAssessmentController(), permanent: true);
    }
    if (!Get.isRegistered<StaffPerformanceMonitoringController>()) {
      Get.put(StaffPerformanceMonitoringController(), permanent: true);
    }
    if (!Get.isRegistered<StaffStudyMaterialController>()) {
      Get.put(
        StaffStudyMaterialController(Get.find<AdminService>()),
        permanent: true,
      );
    }
  }
}

