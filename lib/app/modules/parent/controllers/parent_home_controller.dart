import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';
import '../../../../common/services/parent/parent_context_service.dart';
import '../../../../common/services/parent/parent_dashboard_service.dart';

class ParentHomeController extends GetxController {
  final ParentDashboardService _dashboardService = Get.find<ParentDashboardService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
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

  @override
  void onInit() {
    super.onInit();
    loadHome();
  }

  Future<void> loadHome({String? month}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _dashboardService.getHome(
        childId: _parentContext.selectedChildId.value,
        month: month,
      );
      childName.value = (data['childName'] ?? childName.value).toString();
      childGrade.value = (data['childGrade'] ?? childGrade.value).toString();
      attendance.value = _asInt(data['attendance'], attendance.value);
      feesDue.value = _asInt(data['feesDue'], feesDue.value);
      feesDueDate.value = (data['feesDueDate'] ?? feesDueDate.value).toString();
      upcomingClass.value = (data['upcomingClass'] ?? upcomingClass.value).toString();
      classStartIn.value = (data['classStartIn'] ?? classStartIn.value).toString();

      final notices = data['recentNotices'];
      if (notices is List) {
        recentNotices.assignAll(
          notices.whereType<Map>().map(
            (e) => e.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')),
          ),
        );
      }
      final scores = data['subjectScores'];
      if (scores is Map) {
        subjectScores.assignAll(
          scores.map((key, value) => MapEntry(key.toString(), _asInt(value, 0))),
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  int _asInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  void goToChildSwitcher() => Get.toNamed(AppRoutes.PARENT_CHILD_SWITCHER);
  void goToNotifications() => Get.toNamed(AppRoutes.PARENT_NOTIFICATIONS);
  void goToAnnouncements() => Get.toNamed(AppRoutes.PARENT_ANNOUNCEMENTS);
  void goToPerformance() => Get.toNamed(AppRoutes.PARENT_PERFORMANCE);
  void goToAIAssistant() => Get.toNamed(AppRoutes.PARENT_AI_ASSISTANT);
}
