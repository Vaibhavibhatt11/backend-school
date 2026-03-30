import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:erp_frontend/common/services/parent/parent_api_utils.dart';
import 'package:erp_frontend/common/services/staff/staff_service.dart';
import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class StaffDashboardController extends GetxController {
  StaffDashboardController(this._staffService);

  final StaffService _staffService;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final todaySchedule = <String>[].obs;
  final assignedClasses = <String>[].obs;
  final pendingTasks = <String>[].obs;
  final studentAlerts = <String>[].obs;
  final upcomingExams = <String>[].obs;
  final meetings = <String>[].obs;
  final notifications = <String>[].obs;
  final homeworkStatus = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _staffService.getDashboard();
      todaySchedule.assignAll(_asStringList(data['todaySchedule']));
      assignedClasses.assignAll(_asStringList(data['assignedClasses']));
      pendingTasks.assignAll(_asStringList(data['pendingTasks']));
      studentAlerts.assignAll(_asStringList(data['studentAlerts']));
      upcomingExams.assignAll(_asStringList(data['upcomingExams']));
      meetings.assignAll(_asStringList(data['meetings']));
      notifications.assignAll(_asStringList(data['notifications']));
      homeworkStatus.assignAll(_asStringList(data['homeworkStatus']));
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
      AppToast.show(errorMessage.value);
      todaySchedule.clear();
      assignedClasses.clear();
      pendingTasks.clear();
      studentAlerts.clear();
      upcomingExams.clear();
      meetings.clear();
      notifications.clear();
      homeworkStatus.clear();
    } finally {
      isLoading.value = false;
    }
  }

  List<String> _asStringList(dynamic value) {
    if (value is! List) return <String>[];
    return value.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
  }

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

