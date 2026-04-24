import 'package:erp_frontend/app/modules/teacher/models/teacher_models.dart';
import 'package:get/get.dart';

class TimetableController extends GetxController {
  final selectedDay = DateTime.now().obs;
  final sessions = <ClassSession>[].obs;

  final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final List<DateTime> days = [];

  @override
  void onInit() {
    super.onInit();
    _generateWeek(DateTime.now());
    sessions.clear();
  }

  void _generateWeek(DateTime start) {
    days.clear();
    final monday = start.subtract(Duration(days: start.weekday - 1));
    for (int i = 0; i < 6; i++) {
      days.add(monday.add(Duration(days: i)));
    }
  }

  void selectDay(DateTime day) {
    selectedDay.value = day;
    sessions.clear();
  }

  String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
