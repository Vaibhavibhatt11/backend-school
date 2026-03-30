import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';
import '../../../../common/services/parent/parent_api_utils.dart';
import '../../../../common/services/parent/parent_context_service.dart';
import '../../../../common/services/parent/parent_dashboard_service.dart';

class ParentHomeController extends GetxController {
  final ParentDashboardService _dashboardService = Get.find<ParentDashboardService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final childName = ''.obs;
  final childGrade = ''.obs;
  /// From home API when provided (`childPhotoUrl` / `photoUrl` / `avatarUrl`).
  final childPhotoUrl = ''.obs;
  final attendance = 0.obs;
  final feesDue = 0.obs;
  final feesDueDate = ''.obs;
  final upcomingClass = ''.obs;
  final classStartIn = ''.obs;

  final recentNotices = <Map<String, dynamic>>[].obs;

  final subjectScores = <String, int>{}.obs;
  Worker? _childWorker;

  @override
  void onInit() {
    super.onInit();
    _childWorker = ever<String?>(
      _parentContext.selectedChildId,
      (_) => loadHome(),
    );
    loadHome();
  }

  @override
  void onClose() {
    _childWorker?.dispose();
    super.onClose();
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
      childPhotoUrl.value =
          (data['childPhotoUrl'] ?? data['photoUrl'] ?? data['avatarUrl'] ?? childPhotoUrl.value)
              .toString();
      attendance.value = _asInt(data['attendance'], attendance.value);
      feesDue.value = _asInt(data['feesDue'], feesDue.value);
      feesDueDate.value = (data['feesDueDate'] ?? feesDueDate.value).toString();
      upcomingClass.value = (data['upcomingClass'] ?? upcomingClass.value).toString();
      classStartIn.value = (data['classStartIn'] ?? classStartIn.value).toString();

      final notices = data['recentNotices'];
      if (notices is List) {
        recentNotices.assignAll(notices.whereType<Map>().map((e) => Map<String, dynamic>.from(e)));
      }
      final scores = data['subjectScores'];
      if (scores is Map) {
        subjectScores.assignAll(
          scores.map((key, value) => MapEntry(key.toString(), _asInt(value, 0))),
        );
      }
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
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
  void goToLiveClass() => Get.toNamed(AppRoutes.PARENT_LIVE_CLASS);
}
