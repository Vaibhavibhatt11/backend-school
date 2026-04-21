import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class StaffLessonPlanningController extends GetxController {
  final activeTab = 0.obs;
  final lessonPlans = <Map<String, String>>[].obs;
  final topicSchedules = <Map<String, String>>[].obs;
  final lessonNotes = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _seed();
    final args = Get.arguments;
    if (args is Map && args['tab'] == 'topics') activeTab.value = 1;
    if (args is Map && args['tab'] == 'notes') activeTab.value = 2;
  }

  void setTab(int index) {
    if (index < 0 || index > 2) return;
    activeTab.value = index;
  }

  void addLessonPlan({
    required String className,
    required String subject,
    required String objective,
  }) {
    if (className.trim().isEmpty || subject.trim().isEmpty) return;
    lessonPlans.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'className': className.trim(),
      'subject': subject.trim(),
      'objective': objective.trim().isEmpty ? 'General lesson objective' : objective.trim(),
    });
    AppToast.show('Lesson plan created');
  }

  void addTopicSchedule({
    required String className,
    required String topic,
    required String date,
    required String period,
  }) {
    if (topic.trim().isEmpty) return;
    topicSchedules.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'className': className.trim().isEmpty ? 'General' : className.trim(),
      'topic': topic.trim(),
      'date': date.trim(),
      'period': period.trim(),
    });
    AppToast.show('Topic scheduled');
  }

  void addLessonNote({
    required String title,
    required String note,
    required String className,
  }) {
    if (title.trim().isEmpty || note.trim().isEmpty) return;
    lessonNotes.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title.trim(),
      'note': note.trim(),
      'className': className.trim().isEmpty ? 'General' : className.trim(),
    });
    AppToast.show('Lesson note added');
  }

  Map<String, int> metrics() {
    return {
      'plans': lessonPlans.length,
      'topics': topicSchedules.length,
      'notes': lessonNotes.length,
    };
  }

  void _seed() {
    if (lessonPlans.isNotEmpty) return;
    lessonPlans.assignAll([
      {
        'id': 'lp1',
        'className': 'Class 8-A',
        'subject': 'Science',
        'objective': 'Understand photosynthesis process',
      },
    ]);
    topicSchedules.assignAll([
      {
        'id': 'ts1',
        'className': 'Class 8-A',
        'topic': 'Photosynthesis',
        'date': '2026-04-22',
        'period': '10:00-10:45',
      },
    ]);
    lessonNotes.assignAll([
      {
        'id': 'ln1',
        'title': 'Lab prep note',
        'note': 'Bring leaf samples for practical demo.',
        'className': 'Class 8-A',
      },
    ]);
  }
}
