import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class StaffHomeworkAssignmentController extends GetxController {
  final activeTab = 0.obs;
  final assignments = <Map<String, String>>[].obs;
  final deadlines = <Map<String, String>>[].obs;
  final submissions = <Map<String, String>>[].obs;
  final feedbackItems = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _seed();
    final args = Get.arguments;
    if (args is Map && args['tab'] == 'deadlines') activeTab.value = 1;
    if (args is Map && args['tab'] == 'submissions') activeTab.value = 2;
    if (args is Map && args['tab'] == 'feedback') activeTab.value = 3;
  }

  void setTab(int index) {
    if (index < 0 || index > 3) return;
    activeTab.value = index;
  }

  void createAssignment({
    required String title,
    required String className,
    required String subject,
  }) {
    if (title.trim().isEmpty || className.trim().isEmpty) return;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    assignments.insert(0, {
      'id': id,
      'title': title.trim(),
      'className': className.trim(),
      'subject': subject.trim().isEmpty ? 'General' : subject.trim(),
      'status': 'ACTIVE',
    });
    AppToast.show('Assignment created');
  }

  void setDeadline({
    required String assignmentTitle,
    required String dueDate,
    required String dueTime,
  }) {
    if (assignmentTitle.trim().isEmpty || dueDate.trim().isEmpty) return;
    deadlines.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'assignmentTitle': assignmentTitle.trim(),
      'dueDate': dueDate.trim(),
      'dueTime': dueTime.trim().isEmpty ? '23:59' : dueTime.trim(),
    });
    AppToast.show('Deadline set');
  }

  void addSubmission({
    required String studentName,
    required String assignmentTitle,
    required String status,
  }) {
    if (studentName.trim().isEmpty || assignmentTitle.trim().isEmpty) return;
    submissions.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'studentName': studentName.trim(),
      'assignmentTitle': assignmentTitle.trim(),
      'status': status,
    });
    AppToast.show('Submission updated');
  }

  void addFeedback({
    required String studentName,
    required String assignmentTitle,
    required String feedback,
  }) {
    if (studentName.trim().isEmpty || feedback.trim().isEmpty) return;
    feedbackItems.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'studentName': studentName.trim(),
      'assignmentTitle': assignmentTitle.trim(),
      'feedback': feedback.trim(),
    });
    AppToast.show('Feedback shared');
  }

  Map<String, int> metrics() {
    final submitted = submissions.where((e) => e['status'] == 'SUBMITTED').length;
    return {
      'assignments': assignments.length,
      'deadlines': deadlines.length,
      'submissions': submissions.length,
      'submitted': submitted,
      'feedback': feedbackItems.length,
    };
  }

  void _seed() {
    if (assignments.isNotEmpty) return;
    assignments.assignAll([
      {
        'id': 'a1',
        'title': 'Chapter 3 Worksheet',
        'className': 'Class 8-A',
        'subject': 'Math',
        'status': 'ACTIVE',
      },
    ]);
    deadlines.assignAll([
      {
        'id': 'd1',
        'assignmentTitle': 'Chapter 3 Worksheet',
        'dueDate': '2026-04-25',
        'dueTime': '17:00',
      },
    ]);
    submissions.assignAll([
      {
        'id': 's1',
        'studentName': 'Aarav Patel',
        'assignmentTitle': 'Chapter 3 Worksheet',
        'status': 'SUBMITTED',
      },
      {
        'id': 's2',
        'studentName': 'Diya Shah',
        'assignmentTitle': 'Chapter 3 Worksheet',
        'status': 'PENDING',
      },
    ]);
    feedbackItems.assignAll([
      {
        'id': 'f1',
        'studentName': 'Aarav Patel',
        'assignmentTitle': 'Chapter 3 Worksheet',
        'feedback': 'Good work. Improve presentation.',
      },
    ]);
  }
}
