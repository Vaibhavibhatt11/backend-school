import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';
import '../../../../common/services/parent/parent_academics_service.dart';
import '../../../../common/services/parent/parent_context_service.dart';

class TimetableController extends GetxController {
  final ParentAcademicsService _academicsService = Get.find<ParentAcademicsService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final selectedDate = DateTime.now().obs;
  final selectedDay = DateTime.now().day.obs;
  final dayView = true.obs;

  final timetable = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTimetable();
  }

  Future<void> loadTimetable() async {
    isLoading.value = true;
    try {
      final day = selectedDate.value.toIso8601String().split('T').first;
      final data = await _academicsService.getTimetable(
        childId: _parentContext.selectedChildId.value,
        day: day,
      );
      final items = data['items'];
      if (items is List) {
        timetable.assignAll(
          items.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void changeDate(int day) {
    selectedDay.value = day;
    selectedDate.value = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      day,
    );
    loadTimetable();
  }

  void toggleView() {
    dayView.toggle();
  }

  void joinLiveClass(String subject) {
    Get.toNamed(AppRoutes.PARENT_LIVE_CLASS, arguments: {'subject': subject});
  }
}
