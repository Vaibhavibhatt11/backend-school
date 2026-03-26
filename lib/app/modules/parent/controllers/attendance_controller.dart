import 'package:get/get.dart';
import '../../../../common/services/parent/parent_academics_service.dart';
import '../../../../common/services/parent/parent_context_service.dart';

class AttendanceController extends GetxController {
  final ParentAcademicsService _academicsService = Get.find<ParentAcademicsService>();
  final ParentContextService _parentContext = Get.find<ParentContextService>();

  final isLoading = false.obs;
  final studentName = 'Marcus Johnson'.obs;
  final studentClass = 'Class 10-B • Roll No. 24'.obs;
  final month = 'October 2023'.obs;
  final currentMonthOffset = 0.obs;

  final calendarDays = <int?>[].obs;
  final attendanceStats = {'present': 18, 'absent': 2, 'late': 1}.obs;

  @override
  void onInit() {
    super.onInit();
    _generateDays();
    loadAttendance();
  }

  void _generateDays() {
    List<int?> days = List.filled(35, null);
    for (int i = 0; i < 31; i++) {
      days[i + 4] = i + 1; // start on Thursday
    }
    calendarDays.value = days;
  }

  Future<void> loadAttendance() async {
    isLoading.value = true;
    try {
      final data = await _academicsService.getAttendance(
        childId: _parentContext.selectedChildId.value,
      );
      if (data['studentName'] != null) {
        studentName.value = data['studentName'].toString();
      }
      if (data['studentClass'] != null) {
        studentClass.value = data['studentClass'].toString();
      }
      final stats = data['attendanceStats'];
      if (stats is Map) {
        attendanceStats.assignAll(
          stats.map((key, value) => MapEntry(key.toString(), _asInt(value))),
        );
      }
      final days = data['calendarDays'];
      if (days is List) {
        calendarDays.assignAll(days.map((e) => e == null ? null : _asInt(e)));
      }
    } finally {
      isLoading.value = false;
    }
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String getStatusForDay(int day) {
    if (day == 13) return 'late';
    if (day % 2 == 0) return 'present';
    return 'absent';
  }

  void previousMonth() {
    currentMonthOffset.value--;
    month.value = 'September 2023';
    loadAttendance();
  }

  void nextMonth() {
    currentMonthOffset.value++;
    month.value = 'November 2023';
    loadAttendance();
  }
}
