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
    students.clear();
    filteredStudents.assignAll(students);
    ever(searchQuery, _filter);
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
