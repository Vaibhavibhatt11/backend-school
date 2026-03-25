import 'package:get/get.dart';

class ClassAttendance {
  final String grade;
  final String teacher;
  final int percent;
  final int? absent;
  final bool perfect;
  final bool notSubmitted;
  ClassAttendance({
    required this.grade,
    required this.teacher,
    required this.percent,
    this.absent,
    this.perfect = false,
    this.notSubmitted = false,
  });
}

class AdminAttendanceController extends GetxController {
  final studentPercent = 94;
  final studentPresent = 850;
  final studentTotal = 904;
  final staffPercent = 98;
  final staffPresent = 48;
  final staffTotal = 50;

  final classes = [
    ClassAttendance(
      grade: '12A',
      teacher: 'Mr. Henderson',
      percent: 100,
      perfect: true,
    ),
    ClassAttendance(grade: '11B', teacher: 'Ms. Ortiz', percent: 88, absent: 3),
    ClassAttendance(
      grade: '10C',
      teacher: 'Mrs. Chang',
      percent: 92,
      absent: 2,
    ),
    ClassAttendance(grade: '09A', teacher: '', percent: 0, notSubmitted: true),
  ];

  void onViewAll() {
    Get.snackbar('Classes', 'Show all classes');
  }

  void onRemind(ClassAttendance cls) {
    Get.snackbar('Reminder', 'Reminder sent to ${cls.grade}');
  }

  void onMarkManual() {
    Get.snackbar('Manual', 'Mark attendance manually');
  }

  void onExportPDF() {
    Get.snackbar('Export', 'PDF exported');
  }
}
