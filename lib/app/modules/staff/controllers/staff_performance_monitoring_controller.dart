import 'package:erp_frontend/common/utils/app_toast.dart';
import 'package:get/get.dart';

class StaffPerformanceMonitoringController extends GetxController {
  final activeTab = 0.obs;
  final marks = <Map<String, String>>[].obs;
  final attendance = <Map<String, String>>[].obs;
  final progressReports = <Map<String, String>>[].obs;
  final weakStudents = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _seed();
    final args = Get.arguments;
    if (args is Map && args['tab'] == 'attendance') activeTab.value = 1;
    if (args is Map && args['tab'] == 'reports') activeTab.value = 2;
    if (args is Map && args['tab'] == 'weak') activeTab.value = 3;
  }

  void setTab(int index) {
    if (index < 0 || index > 3) return;
    activeTab.value = index;
  }

  void addMarks({
    required String studentName,
    required String subject,
    required String score,
  }) {
    if (studentName.trim().isEmpty || subject.trim().isEmpty) return;
    marks.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'studentName': studentName.trim(),
      'subject': subject.trim(),
      'score': score.trim().isEmpty ? '0' : score.trim(),
    });
    _rebuildWeakStudents();
    AppToast.show('Student marks tracked');
  }

  void addAttendance({
    required String studentName,
    required String percentage,
  }) {
    if (studentName.trim().isEmpty) return;
    attendance.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'studentName': studentName.trim(),
      'percentage': percentage.trim().isEmpty ? '0' : percentage.trim(),
    });
    _rebuildWeakStudents();
    AppToast.show('Attendance monitored');
  }

  void addProgressReport({
    required String studentName,
    required String summary,
    required String term,
  }) {
    if (studentName.trim().isEmpty || summary.trim().isEmpty) return;
    progressReports.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'studentName': studentName.trim(),
      'summary': summary.trim(),
      'term': term.trim().isEmpty ? 'Term 1' : term.trim(),
    });
    AppToast.show('Progress report added');
  }

  void resolveWeakStudent(String id) {
    weakStudents.assignAll(weakStudents.where((row) => row['id'] != id).toList());
    AppToast.show('Weak student marked for follow-up');
  }

  Map<String, int> metrics() {
    return {
      'marks': marks.length,
      'attendance': attendance.length,
      'reports': progressReports.length,
      'weak': weakStudents.length,
    };
  }

  void _seed() {
    if (marks.isNotEmpty) return;
    marks.assignAll([
      {
        'id': 'm1',
        'studentName': 'Aarav Patel',
        'subject': 'Math',
        'score': '84',
      },
      {
        'id': 'm2',
        'studentName': 'Diya Shah',
        'subject': 'Math',
        'score': '42',
      },
    ]);
    attendance.assignAll([
      {
        'id': 'a1',
        'studentName': 'Aarav Patel',
        'percentage': '92',
      },
      {
        'id': 'a2',
        'studentName': 'Diya Shah',
        'percentage': '63',
      },
    ]);
    progressReports.assignAll([
      {
        'id': 'r1',
        'studentName': 'Aarav Patel',
        'summary': 'Consistent performance and class participation.',
        'term': 'Term 1',
      },
    ]);
    _rebuildWeakStudents();
  }

  void _rebuildWeakStudents() {
    final weak = <Map<String, String>>[];
    for (final m in marks) {
      final score = int.tryParse(m['score'] ?? '0') ?? 0;
      if (score < 50) {
        weak.add({
          'id': m['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'studentName': m['studentName'] ?? 'Student',
          'reason': 'Low marks (${m['score'] ?? '0'})',
        });
      }
    }
    for (final a in attendance) {
      final pct = int.tryParse(a['percentage'] ?? '0') ?? 0;
      if (pct < 75 &&
          weak.every((e) => e['studentName'] != a['studentName'])) {
        weak.add({
          'id': a['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'studentName': a['studentName'] ?? 'Student',
          'reason': 'Low attendance (${a['percentage'] ?? '0'}%)',
        });
      }
    }
    weakStudents.assignAll(weak);
  }
}
