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
    _loadSessions();
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
    _loadSessions();
  }

  void _loadSessions() {
    // Mock data – replace with API call
    sessions.assignAll([
      ClassSession(
        id: '1',
        title: 'Physics Advanced',
        grade: '12-A',
        subject: 'Physics',
        room: 'Room 402',
        startTime: DateTime(2023, 10, selectedDay.value.day, 8, 0),
        endTime: DateTime(2023, 10, selectedDay.value.day, 9, 30),
        isCompleted: true,
      ),
      ClassSession(
        id: '2',
        title: 'General Science',
        grade: '10-B',
        subject: 'Science',
        room: 'Lab 02',
        startTime: DateTime(2023, 10, selectedDay.value.day, 9, 30),
        endTime: DateTime(2023, 10, selectedDay.value.day, 10, 45),
        isLive: true,
      ),
      ClassSession(
        id: '3',
        title: 'Free Period',
        grade: '',
        subject: '',
        room: '',
        startTime: DateTime(2023, 10, selectedDay.value.day, 10, 45),
        endTime: DateTime(2023, 10, selectedDay.value.day, 12, 0),
      ),
      ClassSession(
        id: '4',
        title: 'Mathematics',
        grade: '11-C',
        subject: 'Math',
        room: 'Room 105',
        startTime: DateTime(2023, 10, selectedDay.value.day, 12, 0),
        endTime: DateTime(2023, 10, selectedDay.value.day, 13, 15),
      ),
      ClassSession(
        id: '5',
        title: 'Faculty Meeting',
        grade: '',
        subject: '',
        room: 'Conference Room A',
        startTime: DateTime(2023, 10, selectedDay.value.day, 13, 30),
        endTime: DateTime(2023, 10, selectedDay.value.day, 14, 30),
      ),
    ]);
  }

  String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
