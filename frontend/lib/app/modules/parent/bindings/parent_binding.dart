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
import '../controllers/parent_shell_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/monthly_timetable_controller.dart';
import '../controllers/exam_timetable_controller.dart';
import '../controllers/event_timetable_controller.dart';
import '../controllers/communication_hub_controller.dart';
import '../controllers/events_hub_controller.dart';
// import '../controllers/transport_hub_controller.dart'; // Transport module commented for now.
import '../controllers/achievements_hub_controller.dart';
import '../controllers/finance_hub_controller.dart';

class ParentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ParentShellController());
    Get.lazyPut(() => ParentHomeController());
    Get.lazyPut(() => AttendanceController());
    Get.lazyPut(() => FeesController());
    Get.lazyPut(() => InvoiceDetailController());
    Get.lazyPut(() => TimetableController());
    Get.lazyPut(() => MonthlyTimetableController());
    Get.lazyPut(() => ExamTimetableController());
    Get.lazyPut(() => EventTimetableController());
    Get.lazyPut(() => ProfileController());
    Get.lazyPut(() => ChildSwitcherController());
    Get.lazyPut(() => AnnouncementsController());
    Get.lazyPut(() => ProgressReportsController());
    Get.lazyPut(() => LiveClassController());
    Get.lazyPut(() => LibraryController());
    Get.lazyPut(() => DocumentViewerController());
    Get.lazyPut(() => NotificationsController());
    Get.lazyPut(() => CommunicationHubController());
    Get.lazyPut(() => EventsHubController());
    // Transport module binding commented for now.
    // Get.lazyPut(() => TransportHubController());
    Get.lazyPut(() => AchievementsHubController());
    Get.lazyPut(() => FinanceHubController());
    Get.lazyPut(() => SettingsController());
  }
}
