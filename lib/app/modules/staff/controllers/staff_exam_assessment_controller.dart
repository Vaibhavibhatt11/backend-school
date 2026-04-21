import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class StaffExamAssessmentController extends GetxController {
  final activeTab = 0.obs;
  final exams = <Map<String, String>>[].obs;
  final questionPapers = <Map<String, String>>[].obs;
  final marksEntries = <Map<String, String>>[].obs;
  final gradingRules = <Map<String, String>>[].obs;
  final results = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _seed();
    final args = Get.arguments;
    if (args is Map && args['tab'] == 'papers') activeTab.value = 1;
    if (args is Map && args['tab'] == 'marks') activeTab.value = 2;
    if (args is Map && args['tab'] == 'grading') activeTab.value = 3;
    if (args is Map && args['tab'] == 'results') activeTab.value = 4;
  }

  void setTab(int index) {
    if (index < 0 || index > 4) return;
    activeTab.value = index;
  }

  void createExam({
    required String name,
    required String className,
    required String date,
  }) {
    if (name.trim().isEmpty || className.trim().isEmpty) return;
    exams.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name.trim(),
      'className': className.trim(),
      'date': date.trim(),
      'status': 'PLANNED',
    });
    AppToast.show('Exam created');
  }

  void uploadQuestionPaper({
    required String examName,
    required String subject,
    required String fileName,
  }) {
    if (examName.trim().isEmpty || fileName.trim().isEmpty) return;
    questionPapers.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'examName': examName.trim(),
      'subject': subject.trim().isEmpty ? 'General' : subject.trim(),
      'fileName': fileName.trim(),
      'status': 'UPLOADED',
    });
    AppToast.show('Question paper uploaded');
  }

  void addMarks({
    required String examName,
    required String studentName,
    required String marks,
  }) {
    if (examName.trim().isEmpty || studentName.trim().isEmpty) return;
    marksEntries.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'examName': examName.trim(),
      'studentName': studentName.trim(),
      'marks': marks.trim().isEmpty ? '0' : marks.trim(),
    });
    AppToast.show('Marks entered');
  }

  void addGradingRule({
    required String grade,
    required String minMarks,
    required String maxMarks,
  }) {
    if (grade.trim().isEmpty) return;
    gradingRules.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'grade': grade.trim(),
      'minMarks': minMarks.trim(),
      'maxMarks': maxMarks.trim(),
    });
    AppToast.show('Grading rule added');
  }

  void publishResult({
    required String examName,
    required String className,
  }) {
    if (examName.trim().isEmpty || className.trim().isEmpty) return;
    results.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'examName': examName.trim(),
      'className': className.trim(),
      'status': 'PUBLISHED',
      'publishedOn': DateTime.now().toIso8601String().split('T').first,
    });
    AppToast.show('Result published');
  }

  Map<String, int> metrics() {
    return {
      'exams': exams.length,
      'papers': questionPapers.length,
      'marks': marksEntries.length,
      'grading': gradingRules.length,
      'results': results.length,
    };
  }

  void _seed() {
    if (exams.isNotEmpty) return;
    exams.assignAll([
      {
        'id': 'e1',
        'name': 'Mid Term',
        'className': 'Class 8-A',
        'date': '2026-05-02',
        'status': 'PLANNED',
      },
    ]);
    questionPapers.assignAll([
      {
        'id': 'qp1',
        'examName': 'Mid Term',
        'subject': 'Math',
        'fileName': 'midterm-math.pdf',
        'status': 'UPLOADED',
      },
    ]);
    marksEntries.assignAll([
      {
        'id': 'm1',
        'examName': 'Mid Term',
        'studentName': 'Aarav Patel',
        'marks': '84',
      },
    ]);
    gradingRules.assignAll([
      {
        'id': 'g1',
        'grade': 'A',
        'minMarks': '80',
        'maxMarks': '100',
      },
    ]);
    results.assignAll([
      {
        'id': 'r1',
        'examName': 'Unit Test 1',
        'className': 'Class 8-A',
        'status': 'PUBLISHED',
        'publishedOn': '2026-04-10',
      },
    ]);
  }
}
