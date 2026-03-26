import 'package:erp_frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';
import '../../../../common/services/parent/parent_academics_service.dart';
import '../../../../common/services/parent/parent_context_service.dart';

class TimetableController extends GetxController {
  final ParentAcademicsService _academicsService = Get.find<ParentAcademicsService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final selectedDate = DateTime.now().obs;
  final selectedDay = 24.obs; // 24th
  final dayView = true.obs;

  final timetable =
      [
        {
          'time': '08:00 AM - 08:50 AM',
          'subject': 'Advanced Mathematics',
          'teacher': 'Mr. Alexander Smith',
          'room': 'Block A, Room 102',
          'period': 'Period 1',
          'isLive': false,
          'progress': null,
        },
        {
          'time': '09:00 AM - 09:50 AM',
          'subject': 'Theoretical Physics',
          'teacher': 'Dr. Sarah Connor',
          'room': 'Science Lab B-4',
          'period': 'Period 2',
          'isLive': true,
          'progress': 0.65,
          'remaining': '15 mins',
        },
        {
          'time': '10:15 AM - 11:05 AM',
          'subject': 'World Literature',
          'teacher': 'Ms. Elena Gilbert',
          'room': 'Humanities Hall 205',
          'period': 'Period 3',
          'isLive': false,
        },
        {
          'time': '11:15 AM - 12:05 PM',
          'subject': 'Computer Science',
          'teacher': 'Prof. Alan Turing',
          'room': 'IT Lab 02',
          'period': 'Period 4',
          'isLive': false,
        },
      ].obs;

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
          items.whereType<Map>().map((e) => Map<String, Object>.from(e)),
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
