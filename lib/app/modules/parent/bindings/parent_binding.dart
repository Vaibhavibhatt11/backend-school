import 'package:erp_frontend/app/modules/parent/controllers/progress_reposrts_controller.dart';
import 'package:get/get.dart';
import '../controllers/parent_home_controller.dart';
import '../controllers/attendance_controller.dart';
import '../controllers/fees_controller.dart';
import '../controllers/invoice_detail_controller.dart';
import '../controllers/timetable_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/child_switcher_controller.dart';
import '../controllers/announcements_controller.dart';
import '../controllers/live_class_controller.dart';
import '../controllers/library_controller.dart';
import '../controllers/document_viewer_controller.dart';
import '../controllers/notifications_controller.dart';
import '../controllers/settings_controller.dart';

class ParentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ParentHomeController());
    Get.lazyPut(() => AttendanceController());
    Get.lazyPut(() => FeesController());
    Get.lazyPut(() => InvoiceDetailController());
    Get.lazyPut(() => TimetableController());
    Get.lazyPut(() => ProfileController());
    Get.lazyPut(() => ChildSwitcherController());
    Get.lazyPut(() => AnnouncementsController());
    Get.lazyPut(() => ProgressReportsController());
    Get.lazyPut(() => LiveClassController());
    Get.lazyPut(() => LibraryController());
    Get.lazyPut(() => DocumentViewerController());
    Get.lazyPut(() => NotificationsController());
    Get.lazyPut(() => SettingsController());
  }
}
