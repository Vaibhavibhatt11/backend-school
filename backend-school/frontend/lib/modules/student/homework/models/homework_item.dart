import 'package:flutter/material.dart';

class HomeworkItem {
  const HomeworkItem({
    required this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    this.status = HomeworkStatus.pending,
    this.description,
    this.submittedAt,
    this.submissionFiles = const [],
    this.aiPlagiarismScore,
    this.aiPlagiarismFlag,
    this.teacherFeedback,
  });

  final String id;
  final String title;
  final String subject;
  final DateTime dueDate;
  final HomeworkStatus status;
  final String? description;
  final DateTime? submittedAt;
  final List<String> submissionFiles;
  final double? aiPlagiarismScore;
  final String? aiPlagiarismFlag;
  final String? teacherFeedback;

  HomeworkItem copyWith({
    String? id,
    String? title,
    String? subject,
    DateTime? dueDate,
    HomeworkStatus? status,
    String? description,
    DateTime? submittedAt,
    List<String>? submissionFiles,
    double? aiPlagiarismScore,
    String? aiPlagiarismFlag,
    String? teacherFeedback,
  }) {
    return HomeworkItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      description: description ?? this.description,
      submittedAt: submittedAt ?? this.submittedAt,
      submissionFiles: submissionFiles ?? this.submissionFiles,
      aiPlagiarismScore: aiPlagiarismScore ?? this.aiPlagiarismScore,
      aiPlagiarismFlag: aiPlagiarismFlag ?? this.aiPlagiarismFlag,
      teacherFeedback: teacherFeedback ?? this.teacherFeedback,
    );
  }

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
