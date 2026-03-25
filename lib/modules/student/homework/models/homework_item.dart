import 'package:flutter/material.dart';

class HomeworkItem {
  const HomeworkItem({
    required this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    this.status = HomeworkStatus.pending,
    this.description,
  });

  final String id;
  final String title;
  final String subject;
  final DateTime dueDate;
  final HomeworkStatus status;
  final String? description;

  String get dueLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final diff = due.difference(today).inDays;
    if (diff < 0) return 'Overdue';
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff < 7) return 'In $diff days';
    return '${dueDate.day}/${dueDate.month}/${dueDate.year}';
  }

  bool get isOverdue =>
      dueDate.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));

  bool get isDueToday {
    final n = DateTime.now();
    return dueDate.year == n.year && dueDate.month == n.month && dueDate.day == n.day;
  }
}

enum HomeworkStatus { pending, submitted, graded }

/// Subject with a display color for chips/cards.
class SubjectStyle {
  const SubjectStyle(this.name, this.color);
  final String name;
  final Color color;
}
