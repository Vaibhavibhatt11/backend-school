import 'package:erp_frontend/app/modules/teacher/controllers/mark_attendance_view.dart';
import 'package:get/get.dart';
import '../controllers/teacher_home_controller.dart';
import '../controllers/attendance_selector_controller.dart';
import '../controllers/student_directory_controller.dart';
import '../controllers/student_profile_controller.dart';
import '../controllers/timetable_controller.dart';
import '../controllers/announcements_controller.dart';
import '../controllers/live_class_controller.dart';
import '../controllers/upload_controller.dart';
import '../controllers/teacher_profile_controller.dart';
import '../controllers/notifications_controller.dart';
import '../controllers/teacher_shell_controller.dart';

class TeacherBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TeacherShellController());
    Get.lazyPut(() => TeacherHomeController());
    Get.lazyPut(() => AttendanceSelectorController());
    Get.lazyPut(() => MarkAttendanceController());
    Get.lazyPut(() => StudentDirectoryController());
    Get.lazyPut(() => StudentProfileController());
    Get.lazyPut(() => TimetableController());
    Get.lazyPut(() => AnnouncementsController());
    Get.lazyPut(() => LiveClassController());
    Get.lazyPut(() => UploadController());
    Get.lazyPut(() => TeacherProfileController());
    Get.lazyPut(() => NotificationsController());
  }
}
