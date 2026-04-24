import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';
import '../../../../common/services/parent/parent_academics_service.dart';
import '../../../../common/services/parent/parent_api_utils.dart';
import '../../../../common/services/parent/parent_context_service.dart';

class TimetableController extends GetxController {
  final ParentAcademicsService _academicsService = Get.find<ParentAcademicsService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final selectedDate = DateTime.now().obs;
  final selectedDay = DateTime.now().day.obs;
  final dayView = true.obs;
  final errorMessage = ''.obs;

  final timetable = <Map<String, dynamic>>[].obs;
  Worker? _childWorker;

  @override
  void onInit() {
    super.onInit();
    _childWorker = ever<String?>(
      _parentContext.selectedChildId,
      (_) => loadTimetable(),
    );
    loadTimetable();
  }

  Future<void> loadTimetable() async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final day = selectedDate.value.toIso8601String().split('T').first;
      final data = await _academicsService.getTimetable(
        childId: _parentContext.selectedChildId.value,
        day: day,
      );
      final items = data['items'];
      if (items is List) {
        timetable.assignAll(
          items.whereType<Map>().map((e) {
            final m = Map<String, dynamic>.from(e);
            final isLive = m['isLive'] == true || m['status'] == 'live';
            return {
              'time': (m['time'] ?? '').toString(),
              'subject': (m['subject'] ?? '').toString(),
              'teacher': (m['teacher'] ?? '').toString(),
              'room': (m['room'] ?? '').toString(),
              'period': (m['period'] ?? '').toString(),
              'isLive': isLive,
              'progress': m['progress'],
              'remaining': m['remaining']?.toString(),
            };
          }),
        );
      }
    } catch (e) {
      errorMessage.value = dioOrApiErrorMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  void changeDate(DateTime date) {
    selectedDate.value = DateTime(date.year, date.month, date.day);
    selectedDay.value = selectedDate.value.day;
    loadTimetable();
  }

  void toggleView() {
    dayView.toggle();
  }

  void joinLiveClass(String subject) {
    Get.toNamed(AppRoutes.PARENT_LIVE_CLASS, arguments: {'subject': subject});
  }

  void goToMonthlyTimetable() => Get.toNamed(AppRoutes.PARENT_TIMETABLE_MONTHLY);
  void goToExamTimetable() => Get.toNamed(AppRoutes.PARENT_EXAM_TIMETABLE);
  void goToEventTimetable() => Get.toNamed(AppRoutes.PARENT_EVENT_TIMETABLE);

  @override
  void onClose() {
    _childWorker?.dispose();
    super.onClose();
  }
}
