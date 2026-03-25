/// An upcoming exam (for timeline).
class UpcomingExam {
  const UpcomingExam({
    required this.id,
    required this.subject,
    required this.date,
    this.time,
    this.syllabus,
  });

  final String id;
  final String subject;
  final DateTime date;
  final String? time;
  final String? syllabus;
}

/// A past exam with marks/result.
class PastExam {
  const PastExam({
    required this.id,
    required this.subject,
    required this.examName,
    required this.date,
    required this.marksObtained,
    required this.maxMarks,
    this.grade,
  });

  final String id;
  final String subject;
  final String examName;
  final DateTime date;
  final double marksObtained;
  final double maxMarks;
  final String? grade;

  double get percentage => maxMarks > 0 ? (marksObtained / maxMarks) * 100 : 0;
}
