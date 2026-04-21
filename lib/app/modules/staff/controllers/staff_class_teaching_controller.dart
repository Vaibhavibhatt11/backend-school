import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class StaffClassTeachingController extends GetxController {
  final activeTab = 0.obs;
  final classList = <Map<String, String>>[].obs;
  final studentList = <Map<String, String>>[].obs;
  final subjectAssignments = <Map<String, String>>[].obs;
  final classroomSchedule = <Map<String, String>>[].obs;
  final classNotes = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _seed();
    final args = Get.arguments;
    if (args is Map && args['tab'] == 'schedule') {
      activeTab.value = 3;
    }
  }

  void setTab(int index) {
    if (index < 0 || index > 4) return;
    activeTab.value = index;
  }

  void addClass(String name, String section) {
    if (name.trim().isEmpty) return;
    classList.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name.trim(),
      'section': section.trim().isEmpty ? 'A' : section.trim(),
    });
    AppToast.show('Class added');
  }

  void addStudent(String name, String className) {
    if (name.trim().isEmpty) return;
    studentList.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name.trim(),
      'className': className.trim().isEmpty ? 'Class 1' : className.trim(),
    });
    AppToast.show('Student added');
  }

  void upsertSubjectAssignment({
    required String className,
    required String subject,
    required String teacher,
  }) {
    if (className.trim().isEmpty || subject.trim().isEmpty) return;
    subjectAssignments.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'className': className.trim(),
      'subject': subject.trim(),
      'teacher': teacher.trim().isEmpty ? 'Current Staff' : teacher.trim(),
    });
    AppToast.show('Subject assigned');
  }

  void addSchedule({
    required String className,
    required String day,
    required String period,
    required String subject,
  }) {
    if (className.trim().isEmpty || subject.trim().isEmpty) return;
    classroomSchedule.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'className': className.trim(),
      'day': day.trim(),
      'period': period.trim(),
      'subject': subject.trim(),
    });
    AppToast.show('Schedule updated');
  }

  void addClassNote({
    required String className,
    required String title,
    required String note,
  }) {
    if (title.trim().isEmpty || note.trim().isEmpty) return;
    classNotes.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'className': className.trim().isEmpty ? 'General' : className.trim(),
      'title': title.trim(),
      'note': note.trim(),
    });
    AppToast.show('Class note added');
  }

  Map<String, int> metrics() {
    return {
      'classes': classList.length,
      'students': studentList.length,
      'assignments': subjectAssignments.length,
      'schedules': classroomSchedule.length,
      'notes': classNotes.length,
    };
  }

  void _seed() {
    if (classList.isNotEmpty) return;
    classList.assignAll([
      {'id': 'c1', 'name': 'Class 8', 'section': 'A'},
      {'id': 'c2', 'name': 'Class 9', 'section': 'B'},
    ]);
    studentList.assignAll([
      {'id': 's1', 'name': 'Aarav Patel', 'className': 'Class 8-A'},
      {'id': 's2', 'name': 'Diya Shah', 'className': 'Class 9-B'},
    ]);
    subjectAssignments.assignAll([
      {
        'id': 'a1',
        'className': 'Class 8-A',
        'subject': 'Mathematics',
        'teacher': 'You',
      },
    ]);
    classroomSchedule.assignAll([
      {
        'id': 'sc1',
        'className': 'Class 8-A',
        'day': 'Monday',
        'period': '09:00-09:45',
        'subject': 'Mathematics',
      },
    ]);
    classNotes.assignAll([
      {
        'id': 'n1',
        'className': 'Class 8-A',
        'title': 'Fractions recap',
        'note': 'Revise worksheet 3 before next class.',
      },
    ]);
  }
}
