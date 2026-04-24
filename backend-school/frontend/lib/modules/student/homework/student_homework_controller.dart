import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'models/homework_item.dart';

class StudentHomeworkController extends GetxController {
  /// View mode: date | week | subject
  final RxString viewMode = 'date'.obs;

  final RxList<HomeworkItem> homeworkList = <HomeworkItem>[].obs;

  static const Map<String, Color> subjectColors = {
    'Mathematics': Color(0xFF6366F1),
    'English': Color(0xFF059669),
    'Science': Color(0xFF0284C7),
    'History': Color(0xFFB45309),
    'Hindi': Color(0xFFBE185D),
  };

  Color colorForSubject(String subject) =>
      subjectColors[subject] ?? const Color(0xFF6B7280);

  @override
  void onInit() {
    super.onInit();
    homeworkList.assignAll(_seedHomework());
  }

  void setViewMode(String mode) => viewMode.value = mode;

  Map<String, List<HomeworkItem>> get homeworkByDate {
    final map = <String, List<HomeworkItem>>{};
    for (final h in homeworkList) {
      final key =
          '${h.dueDate.year}-${h.dueDate.month.toString().padLeft(2, '0')}-${h.dueDate.day.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => []).add(h);
    }
    for (final list in map.values) {
      list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    }
    final sortedKeys = map.keys.toList()..sort();
    return Map.fromEntries(sortedKeys.map((k) => MapEntry(k, map[k]!)));
  }

  Map<String, List<HomeworkItem>> get homeworkByWeek {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final map = <String, List<HomeworkItem>>{};
    for (final h in homeworkList) {
      final due = DateTime(h.dueDate.year, h.dueDate.month, h.dueDate.day);
      final diff = due.difference(weekStart).inDays;
      String weekKey;
      if (diff < 0) {
        weekKey = 'Previous';
      } else if (diff < 7) {
        weekKey = 'This week';
      } else if (diff < 14) {
        weekKey = 'Next week';
      } else {
        weekKey = 'Later';
      }
      map.putIfAbsent(weekKey, () => []).add(h);
    }
    for (final list in map.values) {
      list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    }
    const order = ['Previous', 'This week', 'Next week', 'Later'];
    return Map.fromEntries(
      order.where((k) => map.containsKey(k)).map((k) => MapEntry(k, map[k]!)),
    );
  }

  Map<String, List<HomeworkItem>> get homeworkBySubject {
    final map = <String, List<HomeworkItem>>{};
    for (final h in homeworkList) {
      map.putIfAbsent(h.subject, () => []).add(h);
    }
    for (final list in map.values) {
      list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    }
    final sortedKeys = map.keys.toList()..sort();
    return Map.fromEntries(sortedKeys.map((k) => MapEntry(k, map[k]!)));
  }

  String dateKeyToLabel(String key) {
    final parts = key.split('-');
    if (parts.length != 3) return key;
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final m = int.tryParse(parts[1]) ?? 0;
    if (m < 1 || m > 12) return key;
    return '${parts[2]} ${months[m - 1]} ${parts[0]}';
  }

  Future<void> submitHomework({
    required String homeworkId,
    required List<String> files,
  }) async {
    final index = homeworkList.indexWhere((h) => h.id == homeworkId);
    if (index < 0) return;
    final score = _plagiarismScore(files.join('|') + homeworkId);
    final flag = score < 20
        ? 'Low'
        : score < 45
            ? 'Medium'
            : 'High';
    homeworkList[index] = homeworkList[index].copyWith(
      status: HomeworkStatus.submitted,
      submittedAt: DateTime.now(),
      submissionFiles: files,
      aiPlagiarismScore: score,
      aiPlagiarismFlag: flag,
      teacherFeedback: score < 45
          ? 'Submission received. Content originality looks acceptable.'
          : 'Submission received. Please review citation quality before final grading.',
    );
    homeworkList.refresh();
  }

  double _plagiarismScore(String seed) {
    final hash = seed.codeUnits.fold<int>(0, (prev, e) => (prev + (e * 13)) % 1000);
    final score = (hash % 80) + 5; // 5..84
    return score.toDouble();
  }

  List<HomeworkItem> _seedHomework() {
    final now = DateTime.now();
    return [
      HomeworkItem(
        id: 'hw_math_1',
        title: 'Algebra worksheet chapter 6',
        subject: 'Mathematics',
        dueDate: now.add(const Duration(days: 1)),
        description: 'Solve all worksheet questions and upload a single PDF.',
      ),
      HomeworkItem(
        id: 'hw_sci_1',
        title: 'Science practical observation report',
        subject: 'Science',
        dueDate: now.add(const Duration(days: 3)),
        description: 'Attach lab notes with diagrams.',
      ),
      HomeworkItem(
        id: 'hw_eng_1',
        title: 'English essay on climate action',
        subject: 'English',
        dueDate: now.subtract(const Duration(days: 1)),
        description: '500-700 words with references.',
      ),
      HomeworkItem(
        id: 'hw_hist_1',
        title: 'History timeline chart',
        subject: 'History',
        dueDate: now.add(const Duration(days: 6)),
        status: HomeworkStatus.graded,
        description: 'Prepare timeline from chapter 3.',
        submittedAt: now.subtract(const Duration(days: 2)),
        submissionFiles: const ['history_timeline.pdf'],
        aiPlagiarismScore: 12,
        aiPlagiarismFlag: 'Low',
        teacherFeedback: 'Good visual structure and references. Keep handwriting clearer.',
      ),
    ];
  }
}
