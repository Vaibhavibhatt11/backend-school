import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';

class StaffDashboardController extends GetxController {
  final todaySchedule = <String>[
    '08:30 - Grade 8 Science',
    '10:00 - Grade 9 Math',
    '12:30 - PTM follow-up',
  ].obs;

  final assignedClasses = <String>['8-A', '8-B', '9-C'].obs;
  final pendingTasks = <String>[
    'Upload Grade 9 unit test marks',
    'Approve 2 leave requests',
    'Publish homework for 8-B',
  ].obs;

  final studentAlerts = <String>[
    'Aarav: low attendance this week',
    'Riya: pending assignment overdue',
  ].obs;

  final upcomingExams = <String>[
    'Science Quiz - Monday',
    'Math Unit Test - Wednesday',
  ].obs;

  final meetings = <String>[
    'PTM: Fri 04:30 PM',
    'Staff Meeting: Sat 10:00 AM',
  ].obs;

  final notifications = <String>[
    'New circular published for Grade 8',
    'Reminder: Submit weekly plan by 6 PM',
  ].obs;

  final homeworkStatus = <String>[
    '8-A: 18/22 submissions reviewed',
    '9-C: 12 submissions pending review',
  ].obs;

  final quickActions = const <String>[
    'Attendance & Leave',
    'Class & Teaching',
    'Lesson Planning',
    'Homework',
    'Exams',
    'Communication',
  ];

  void goToModules() => Get.toNamed(AppRoutes.STAFF_MODULES);

  void openModule(String moduleId) {
    Get.toNamed(
      AppRoutes.STAFF_MODULE_DETAIL,
      arguments: {'moduleId': moduleId},
    );
  }
}

