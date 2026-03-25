import 'package:get/get.dart';

class AttendanceController extends GetxController {
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
  }

  void _generateDays() {
    List<int?> days = List.filled(35, null);
    for (int i = 0; i < 31; i++) {
      days[i + 4] = i + 1; // start on Thursday
    }
    calendarDays.value = days;
  }

  String getStatusForDay(int day) {
    if (day == 13) return 'late';
    if (day % 2 == 0) return 'present';
    return 'absent';
  }

  void previousMonth() {
    currentMonthOffset.value--;
    month.value = 'September 2023';
    _generateDays();
  }

  void nextMonth() {
    currentMonthOffset.value++;
    month.value = 'November 2023';
    _generateDays();
  }
}
