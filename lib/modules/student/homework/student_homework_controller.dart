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
    _loadMockHomework();
  }

  void setViewMode(String mode) => viewMode.value = mode;

  void _loadMockHomework() {
    final now = DateTime.now();
    homeworkList.addAll([
      HomeworkItem(
        id: '1',
        title: 'Chapter 5 – Algebra problems 1 to 15',
        subject: 'Mathematics',
        dueDate: now.add(const Duration(days: 1)),
        description: 'Solve all odd-numbered questions from exercise 5.2 in notebook. Show full steps.',
      ),
      HomeworkItem(
        id: '2',
        title: 'Essay: My favourite season',
        subject: 'English',
        dueDate: now.add(const Duration(days: 6)),
        description: 'Write a 300-word essay with introduction, body, and conclusion. Use neat handwriting.',
      ),
      HomeworkItem(
        id: '3',
        title: 'Physics – Motion numericals',
        subject: 'Science',
        dueDate: now,
        description: 'Complete worksheet questions 1-10 on speed, velocity, and acceleration with formulas.',
      ),
      HomeworkItem(
        id: '4',
        title: 'Chapter 3 – Reading comprehension',
        subject: 'English',
        dueDate: now.add(const Duration(days: 2)),
        description: 'Read chapter 3 and answer comprehension questions A to F in complete sentences.',
      ),
      HomeworkItem(
        id: '5',
        title: 'History – Short answers Ch 2',
        subject: 'History',
        dueDate: now.subtract(const Duration(days: 1)),
        status: HomeworkStatus.submitted,
        description: 'Write short answers for questions 1-8 from chapter 2. Keep each answer within 4-5 lines.',
      ),
      HomeworkItem(
        id: '6',
        title: 'Trigonometry – Worksheet 4',
        subject: 'Mathematics',
        dueDate: now.add(const Duration(days: 7)),
        description: 'Solve all worksheet 4 questions and revise trigonometric ratios before next class.',
      ),
    ]);
  }

  /// Group by due date (date key = yyyy-mm-dd).
  Map<String, List<HomeworkItem>> get homeworkByDate {
    final map = <String, List<HomeworkItem>>{};
    for (final h in homeworkList) {
      final key = '${h.dueDate.year}-${h.dueDate.month.toString().padLeft(2, '0')}-${h.dueDate.day.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => []).add(h);
    }
    for (final list in map.values) {
      list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    }
    final sortedKeys = map.keys.toList()..sort();
    return Map.fromEntries(sortedKeys.map((k) => MapEntry(k, map[k]!)));
  }

  /// Group by week label (This week, Next week, etc.).
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

  /// Group by subject.
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
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final m = int.tryParse(parts[1]) ?? 0;
    return '${parts[2]} ${months[m - 1]} ${parts[0]}';
  }
}
