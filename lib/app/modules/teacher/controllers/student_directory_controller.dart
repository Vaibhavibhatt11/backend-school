import 'package:erp_frontend/app/modules/teacher/models/teacher_models.dart';
import 'package:get/get.dart';
// Import models

class StudentDirectoryController extends GetxController {
  final students = <Student>[].obs;
  final filteredStudents = <Student>[].obs;
  final searchQuery = ''.obs;
  final selectedLetter = 'A'.obs;

  @override
  void onInit() {
    super.onInit();
    students.assignAll(_mockStudents());
    filteredStudents.assignAll(students);
    ever(searchQuery, _filter);
  }

  List<Student> _mockStudents() {
    return [
      Student(
        id: '1',
        name: 'Aaron Thompson',
        rollNo: '#2024-001',
        grade: '10-A',
        imageUrl: 'https://via.placeholder.com/150',
        attendancePercentage: 95.0,
        recentAttendance: {
          'Mon': AttendanceStatus.present,
          'Tue': AttendanceStatus.present,
          'Wed': AttendanceStatus.present,
          'Thu': AttendanceStatus.present,
          'Fri': AttendanceStatus.present,
        },
      ),
      Student(
        id: '2',
        name: 'Alice Walker',
        rollNo: '#2024-002',
        grade: '10-A',
        imageUrl: 'https://via.placeholder.com/150',
        attendancePercentage: 98.0,
        recentAttendance: {
          'Mon': AttendanceStatus.present,
          'Tue': AttendanceStatus.present,
          'Wed': AttendanceStatus.present,
          'Thu': AttendanceStatus.present,
          'Fri': AttendanceStatus.present,
        },
      ),
      Student(
        id: '3',
        name: 'Benjamin Hayes',
        rollNo: '#2024-003',
        grade: '10-A',
        imageUrl: 'https://via.placeholder.com/150',
        attendancePercentage: 85.0,
        recentAttendance: {
          'Mon': AttendanceStatus.present,
          'Tue': AttendanceStatus.present,
          'Wed': AttendanceStatus.late,
          'Thu': AttendanceStatus.present,
          'Fri': AttendanceStatus.absent,
        },
      ),
      // Add more students as needed
    ];
  }

  void _filter(String query) {
    if (query.isEmpty) {
      filteredStudents.assignAll(students);
    } else {
      filteredStudents.assignAll(
        students.where(
          (s) =>
              s.name.toLowerCase().contains(query.toLowerCase()) ||
              s.rollNo.toLowerCase().contains(query.toLowerCase()),
        ),
      );
    }
  }

  void selectLetter(String letter) {
    selectedLetter.value = letter;
    // Optionally scroll to that section
  }

  Map<String, List<Student>> get groupedStudents {
    final map = <String, List<Student>>{};
    for (var student in filteredStudents) {
      String firstLetter = student.name[0].toUpperCase();
      if (!map.containsKey(firstLetter)) {
        map[firstLetter] = [];
      }
      map[firstLetter]!.add(student);
    }
    final sortedKeys = map.keys.toList()..sort();
    final sortedMap = <String, List<Student>>{};
    for (var key in sortedKeys) {
      sortedMap[key] = map[key]!;
    }
    return sortedMap;
  }
}
