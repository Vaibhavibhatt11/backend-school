import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';

class ParentHomeController extends GetxController {
  final childName = 'Liam Jenkins'.obs;
  final childGrade = '4-B'.obs;
  final attendance = 96.obs;
  final feesDue = 245.obs;
  final feesDueDate = 'Nov 15'.obs;
  final upcomingClass = 'Mathematics • Room 302'.obs;
  final classStartIn = '12 minutes'.obs;

  final recentNotices = [
    {
      'title': 'Annual Sports Day 2024 Registration Open',
      'description':
          'Ensure your child\'s participation by filling the consent form...',
      'postedBy': 'Admin',
      'time': '2h ago',
      'type': 'Events',
    },
    {
      'title': 'Mid-Term Assessment Schedule',
      'description':
          'The assessment schedule for the month of November has been released...',
      'postedBy': 'Mr. Smith',
      'time': '5h ago',
      'type': 'Academics',
    },
  ].obs;

  final subjectScores = {
    'Eng': 60,
    'Math': 85,
    'Sci': 75,
    'Art': 65,
    'Hist': 90,
  }.obs;

  void goToChildSwitcher() => Get.toNamed(AppRoutes.PARENT_CHILD_SWITCHER);
  void goToNotifications() => Get.toNamed(AppRoutes.PARENT_NOTIFICATIONS);
  void goToAnnouncements() => Get.toNamed(AppRoutes.PARENT_ANNOUNCEMENTS);
  void goToPerformance() => Get.toNamed(AppRoutes.PARENT_PERFORMANCE);
  void goToAIAssistant() => Get.toNamed(AppRoutes.PARENT_AI_ASSISTANT);
}
